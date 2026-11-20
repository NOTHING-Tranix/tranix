package com.nothing.tranix.engagement.internal;

import java.sql.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.engagement.api.Notifier;
import com.nothing.tranix.identity.api.MeContributor;
import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.integrations.PushSender;
import com.nothing.tranix.shared.integrations.SmsSender;
import com.nothing.tranix.shared.types.NotificationTab;
import com.nothing.tranix.shared.types.Role;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** B-1101/B-1102: inbox with tabs, summary, push/SMS routing. */
@Service
public class NotificationService implements Notifier, MeContributor {

    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);

    private final JdbcTemplate jdbc;
    private final UserDirectory users;
    private final PushSender push;
    private final SmsSender sms;
    private final Clock clock;

    NotificationService(JdbcTemplate jdbc, UserDirectory users, PushSender push, SmsSender sms, Clock clock) {
        this.jdbc = jdbc;
        this.users = users;
        this.push = push;
        this.sms = sms;
        this.clock = clock;
    }

    @Override
    @Transactional(propagation = org.springframework.transaction.annotation.Propagation.REQUIRES_NEW)
    public void notify(UUID userId, NotificationTab tab, String type, Map<String, String> params, String route) {
        UserDirectory.UserView user = users.find(userId).orElse(null);
        if (user == null) {
            return;
        }
        Templates.Text text = Templates.render(type, user.language(), params);
        UUID id = UUID.randomUUID();
        jdbc.update("""
                insert into engagement_notification (id, user_id, tab, type, title, body, route, created_at)
                values (?, ?, ?, ?, ?, ?, ?, ?)""",
                id, userId, tab.name(), type, cut(text.title(), 120), cut(text.body(), 500), route,
                Timestamp.from(Instant.now(clock)));
        Templates.Template template = Templates.get(type);
        if (template.push()) {
            Map<String, String> data = new HashMap<>();
            data.put("notificationId", id.toString());
            data.put("tab", tab.name());
            if (route != null) {
                data.put("route", route);
            }
            for (String token : users.fcmTokens(userId)) {
                try {
                    push.send(token, text.title(), text.body(), data);
                } catch (RuntimeException e) {
                    log.warn("Push failed for notification {}", id);
                }
            }
        }
        if (template.sms()) {
            sms.send(user.mobile(), "NOTIFY_" + type, params, user.language());
        }
    }

    private static final RowMapper<Map<String, Object>> ITEM = (rs, i) -> {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", rs.getObject("id"));
        m.put("tab", rs.getString("tab"));
        m.put("type", rs.getString("type"));
        m.put("title", rs.getString("title"));
        m.put("body", rs.getString("body"));
        m.put("route", rs.getString("route"));
        m.put("read", rs.getTimestamp("read_at") != null);
        m.put("createdAt", rs.getTimestamp("created_at").toInstant());
        return m;
    };

    @Transactional(readOnly = true)
    public Map<String, Object> list(UUID userId, NotificationTab tab, int page, int size) {
        String where = " from engagement_notification where user_id = ?" + (tab == null ? "" : " and tab = ?");
        List<Object> args = new ArrayList<>(List.of(userId));
        if (tab != null) {
            args.add(tab.name());
        }
        long total = jdbc.queryForObject("select count(*)" + where, Long.class, args.toArray());
        args.add(size);
        args.add((long) page * size);
        List<Map<String, Object>> items = jdbc.query("select *" + where + " order by created_at desc limit ? offset ?", ITEM,
                args.toArray());
        return Map.of("items", items, "page", page, "size", size, "total", total);
    }

    @Transactional
    public void markRead(UUID userId, UUID id) {
        int n = jdbc.update("update engagement_notification set read_at = coalesce(read_at, ?) where id = ? and user_id = ?",
                Timestamp.from(Instant.now(clock)), id, userId);
        if (n == 0) {
            throw ApiException.notFound("Notification");
        }
    }

    @Transactional
    public void markAllRead(UUID userId) {
        jdbc.update("update engagement_notification set read_at = ? where user_id = ? and read_at is null",
                Timestamp.from(Instant.now(clock)), userId);
    }

    @Transactional(readOnly = true)
    public Map<String, Object> summary(UUID userId) {
        Map<String, Integer> unread = new LinkedHashMap<>();
        for (NotificationTab t : NotificationTab.values()) {
            unread.put(t.name(), 0);
        }
        jdbc.query("select tab, count(*) c from engagement_notification where user_id = ? and read_at is null group by tab",
                rs -> {
                    unread.put(rs.getString("tab"), rs.getInt("c"));
                }, userId);
        Map<String, Object> m = new HashMap<>();
        m.put("unreadByTab", unread);
        m.put("latestTranixMessage", latest(userId, NotificationTab.TRANIX));
        m.put("latestTripUpdate", latest(userId, NotificationTab.TRIPS));
        return m;
    }

    private Map<String, Object> latest(UUID userId, NotificationTab tab) {
        List<Map<String, Object>> r = jdbc.query(
                "select * from engagement_notification where user_id = ? and tab = ? order by created_at desc limit 1", ITEM,
                userId, tab.name());
        return r.isEmpty() ? null : r.getFirst();
    }

    @Override
    public Map<String, Object> contribute(UUID userId, Role role) {
        Integer n = jdbc.queryForObject("select count(*) from engagement_notification where user_id = ? and read_at is null",
                Integer.class, userId);
        return Map.of("unreadNotifications", n == null ? 0 : n);
    }

    private static String cut(String s, int max) {
        return s.length() <= max ? s : s.substring(0, max - 1) + "…";
    }
}
