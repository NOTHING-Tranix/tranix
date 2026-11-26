package com.nothing.tranix.engagement.internal;

import java.sql.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.shared.audit.AuditLog;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.types.NotificationTab;
import com.nothing.tranix.shared.types.Role;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** B-1103: admin broadcasts to all / a role / a district / one user, now or scheduled → inbox (Tranix messages) + push. */
@Service
public class BroadcastService {

    private final JdbcTemplate jdbc;
    private final UserDirectory users;
    private final NotificationService notifications;
    private final AuditLog audit;
    private final Clock clock;

    BroadcastService(JdbcTemplate jdbc, UserDirectory users, NotificationService notifications, AuditLog audit, Clock clock) {
        this.jdbc = jdbc;
        this.users = users;
        this.notifications = notifications;
        this.audit = audit;
        this.clock = clock;
    }

    public record Input(String title, String body, String audience, Role role, String district, UUID userId, Instant sendAt) {
    }

    @Transactional
    public Map<String, Object> create(UUID adminId, Input in) {
        switch (in.audience()) {
            case "ALL" -> { }
            case "ROLE" -> require(in.role() != null && in.role() != Role.ADMIN, "role", "Choose a role");
            case "DISTRICT" -> require(in.district() != null && !in.district().isBlank(), "district", "Enter a district");
            case "USER" -> require(in.userId() != null && users.find(in.userId()).isPresent(), "userId", "Unknown user");
            default -> throw ApiException.invalidField("audience", "ALL, ROLE, DISTRICT or USER");
        }
        Instant now = Instant.now(clock);
        Instant sendAt = in.sendAt() == null || in.sendAt().isBefore(now) ? now : in.sendAt();
        UUID id = UUID.randomUUID();
        jdbc.update("""
                insert into engagement_broadcast (id, title, body, audience, role, district, user_id, send_at, created_by, created_at)
                values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""", id, in.title().trim(), in.body().trim(), in.audience(),
                in.role() == null ? null : in.role().name(), in.district(), in.userId(), Timestamp.from(sendAt), adminId, Timestamp.from(now));
        audit.record(adminId, "BROADCAST_CREATE", "BROADCAST", id, null, in.audience() + " " + sendAt, null);
        if (!sendAt.isAfter(now)) {
            send(id);
        }
        return get(id);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> list() {
        return jdbc.queryForList("select * from engagement_broadcast order by created_at desc limit 100").stream().map(BroadcastService::view).toList();
    }

    /** Due scheduled broadcasts; called every minute by the job (and by tests). */
    @Transactional
    public int sendDue() {
        List<UUID> due = jdbc.queryForList("select id from engagement_broadcast where sent_at is null and send_at <= ? for update skip locked",
                UUID.class, Timestamp.from(Instant.now(clock)));
        due.forEach(this::send);
        return due.size();
    }

    private void send(UUID id) {
        Map<String, Object> b = jdbc.queryForMap("select * from engagement_broadcast where id = ?", id);
        String audience = (String) b.get("audience");
        List<UUID> recipients = switch (audience) {
            case "USER" -> List.of((UUID) b.get("user_id"));
            case "ROLE" -> users.audience(Role.valueOf((String) b.get("role")), null);
            case "DISTRICT" -> users.audience(null, (String) b.get("district"));
            default -> users.audience(null, null);
        };
        Map<String, String> params = Map.of("title", (String) b.get("title"), "body", (String) b.get("body"));
        for (UUID u : recipients) {
            notifications.notify(u, NotificationTab.TRANIX, "BROADCAST", params, null);
        }
        jdbc.update("update engagement_broadcast set sent_at = ?, recipients = ? where id = ?", Timestamp.from(Instant.now(clock)),
                recipients.size(), id);
    }

    private Map<String, Object> get(UUID id) {
        return view(jdbc.queryForMap("select * from engagement_broadcast where id = ?", id));
    }

    private static Map<String, Object> view(Map<String, Object> r) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", r.get("id"));
        m.put("title", r.get("title"));
        m.put("body", r.get("body"));
        m.put("audience", r.get("audience"));
        m.put("role", r.get("role"));
        m.put("district", r.get("district"));
        m.put("userId", r.get("user_id"));
        m.put("sendAt", ((Timestamp) r.get("send_at")).toInstant());
        m.put("sentAt", r.get("sent_at") == null ? null : ((Timestamp) r.get("sent_at")).toInstant());
        m.put("recipients", r.get("recipients"));
        return m;
    }

    private static void require(boolean ok, String field, String message) {
        if (!ok) {
            throw ApiException.invalidField(field, message);
        }
    }
}

/** B-1103 scheduled broadcasts (server timer, hard rule 10). */
@Component
@ConditionalOnProperty(name = "tranix.jobs.enabled", havingValue = "true", matchIfMissing = true)
class BroadcastJob {

    private final BroadcastService broadcasts;

    BroadcastJob(BroadcastService broadcasts) {
        this.broadcasts = broadcasts;
    }

    @Scheduled(fixedDelayString = "${tranix.jobs.matching-delay:60000}", initialDelay = 50_000)
    void run() {
        broadcasts.sendDue();
    }
}
