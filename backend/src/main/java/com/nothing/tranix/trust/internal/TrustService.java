package com.nothing.tranix.trust.internal;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.engagement.api.Notifier;
import com.nothing.tranix.fleet.api.FleetApi;
import com.nothing.tranix.identity.api.MeContributor;
import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.shared.audit.AuditLog;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.settings.SettingKeys;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.shared.types.NotificationTab;
import com.nothing.tranix.shared.types.Role;
import com.nothing.tranix.trust.api.TrustApi;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * B-803…B-806: Trust Score ledger (start 70, points from settings §12, clamp 0–100), ratings and pending ratings,
 * Organization score from its drivers.
 */
@Service
public class TrustService implements TrustApi, MeContributor {

    static final BigDecimal MIN = BigDecimal.ZERO;
    static final BigDecimal MAX = BigDecimal.valueOf(100);

    private final JdbcTemplate jdbc;
    private final UserDirectory users;
    private final LoadDirectory loads;
    private final FleetApi fleet;
    private final Settings settings;
    private final AuditLog audit;
    private final Notifier notifier;
    private final Clock clock;

    TrustService(JdbcTemplate jdbc, UserDirectory users, LoadDirectory loads, FleetApi fleet, Settings settings, AuditLog audit,
                 Notifier notifier, Clock clock) {
        this.jdbc = jdbc;
        this.users = users;
        this.loads = loads;
        this.fleet = fleet;
        this.settings = settings;
        this.audit = audit;
        this.notifier = notifier;
        this.clock = clock;
    }

    static boolean hasScore(Role r) {
        return r == Role.DRIVER || r == Role.LOAD_PROVIDER || r == Role.FARMER_NETWORK || r == Role.ORGANIZATION;
    }

    BigDecimal points(String key) {
        return settings.getDecimal("trust.points." + key);
    }

    // ------------------------------------------------------------------ ledger (B-804)

    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public BigDecimal record(UUID userId, UUID loadId, String event, BigDecimal pts, String reason, UUID createdBy) {
        UserDirectory.UserView u = users.find(userId).orElse(null);
        if (u == null || !hasScore(u.role()) || pts.signum() == 0) {
            return u == null ? null : u.trustScore();
        }
        BigDecimal current = score(userId);
        BigDecimal next = current.add(pts).max(MIN).min(MAX).setScale(2, RoundingMode.HALF_UP);
        try {
            jdbc.update("""
                    insert into trust_event (id, user_id, load_id, event, points, reason, score_after, created_by, created_at)
                    values (?, ?, ?, ?, ?, ?, ?, ?, ?)""", UUID.randomUUID(), userId, loadId, event, pts, reason, next, createdBy,
                    Timestamp.from(Instant.now(clock)));
        } catch (DuplicateKeyException e) {
            return current; // already recorded for this trip
        }
        users.updateTrustScore(userId, next);
        if (u.role() == Role.ORGANIZATION) {
            recomputeOrg(userId);
        }
        if (u.role() == Role.DRIVER) {
            fleet.driver(userId, LocalDate.now(clock)).map(FleetApi.DriverContext::orgId).ifPresent(this::recomputeOrg);
        }
        return next;
    }

    /** Score = clamp(start + Σ points) computed from the ledger (the stored value is a cache). */
    BigDecimal score(UUID userId) {
        BigDecimal start = BigDecimal.valueOf(settings.getInt(SettingKeys.TRUST_START_SCORE));
        BigDecimal sum = jdbc.queryForObject("select coalesce(sum(points), 0) from trust_event where user_id = ? and event <> 'ORG_DERIVED'",
                BigDecimal.class, userId);
        return start.add(sum).max(MIN).min(MAX).setScale(2, RoundingMode.HALF_UP);
    }

    @Override
    @Transactional
    public BigDecimal adjust(UUID userId, BigDecimal pts, String reason, UUID adminId) {
        if (reason == null || reason.isBlank()) {
            throw ApiException.invalidField("reason", "Give a reason");
        }
        BigDecimal before = users.get(userId).trustScore();
        BigDecimal after = record(userId, null, "ADMIN_ADJUSTMENT", pts, reason.trim(), adminId);
        audit.record(adminId, "TRUST_ADJUSTED", "USER", userId, String.valueOf(before), String.valueOf(after), reason.trim());
        return after;
    }

    /**
     * B-806 (D-29): Organization score = average of its drivers' scores + the Org's own events (e.g. its cancellations);
     * 70 + own events when it has no drivers.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recomputeOrg(UUID orgId) {
        List<UUID> drivers = fleet.driversOfOrg(orgId);
        BigDecimal base = drivers.isEmpty() ? BigDecimal.valueOf(settings.getInt(SettingKeys.TRUST_START_SCORE))
                : drivers.stream().map(d -> users.find(d).map(UserDirectory.UserView::trustScore).orElse(BigDecimal.valueOf(70)))
                .reduce(BigDecimal.ZERO, BigDecimal::add).divide(BigDecimal.valueOf(drivers.size()), 2, RoundingMode.HALF_UP);
        BigDecimal own = jdbc.queryForObject("select coalesce(sum(points), 0) from trust_event where user_id = ?", BigDecimal.class, orgId);
        users.updateTrustScore(orgId, base.add(own).max(MIN).min(MAX).setScale(2, RoundingMode.HALF_UP));
    }

    // ------------------------------------------------------------------ trip events (listeners call these)

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void onDelivered(UUID loadId) {
        LoadDirectory.LoadInfo l = loads.get(loadId);
        Instant eta = l.deliveryEta();
        boolean late = eta != null && l.deliveredAt() != null
                && l.deliveredAt().isAfter(eta.plus(Duration.ofMinutes(settings.getInt("trips.late_grace_minutes"))));
        if (late) {
            record(l.driverId(), loadId, "LATE_DELIVERY", points("driver.late_delivery"), "Late delivery on " + l.code(), null);
        } else {
            record(l.driverId(), loadId, "ON_TIME", points("driver.on_time"), "Trip completed on time: " + l.code(), null);
            record(l.shipperId(), loadId, "ON_TIME", points("shipper.on_time"), "Trip completed on time: " + l.code(), null);
        }
        // pending ratings (§12): shipper and receiver rate the driver; the driver rates shipper and receiver
        pending(loadId, l.shipperId(), l.driverId(), Role.DRIVER);
        pending(loadId, l.driverId(), l.shipperId(), users.find(l.shipperId()).map(UserDirectory.UserView::role).orElse(Role.LOAD_PROVIDER));
        if (l.receiverUserId() != null) {
            pending(loadId, l.receiverUserId(), l.driverId(), Role.DRIVER);
            pending(loadId, l.driverId(), l.receiverUserId(), Role.RECEIVER);
        }
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void onPickedUp(UUID loadId) {
        LoadDirectory.LoadInfo l = loads.get(loadId);
        if (l.pickedUpAt() != null && l.pickedUpAt().isAfter(l.pickupWindowEnd())) {
            record(l.driverId(), loadId, "LATE_PICKUP", points("driver.late_pickup"), "Late pickup on " + l.code(), null);
        }
    }

    private void pending(UUID loadId, UUID rater, UUID ratee, Role rateeRole) {
        jdbc.update("""
                insert into trust_pending_rating (id, load_id, rater_id, ratee_id, ratee_role, created_at) values (?, ?, ?, ?, ?, ?)
                on conflict do nothing""", UUID.randomUUID(), loadId, rater, ratee, rateeRole.name(), Timestamp.from(Instant.now(clock)));
    }

    // ------------------------------------------------------------------ ratings (B-803)

    @Transactional(readOnly = true)
    public List<Map<String, Object>> pendingFor(UUID userId) {
        List<Map<String, Object>> out = new ArrayList<>();
        for (Map<String, Object> p : jdbc.queryForList(
                "select * from trust_pending_rating where rater_id = ? and not done order by created_at", userId)) {
            UUID ratee = (UUID) p.get("ratee_id");
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("loadId", p.get("load_id"));
            m.put("loadCode", loads.find((UUID) p.get("load_id")).map(LoadDirectory.LoadInfo::code).orElse(null));
            m.put("rateeUserId", ratee);
            m.put("rateeName", users.find(ratee).map(UserDirectory.UserView::name).orElse(""));
            m.put("rateeRole", p.get("ratee_role"));
            m.put("laterUsed", p.get("later_used"));
            out.add(m);
        }
        return out;
    }

    @Transactional
    public void rate(UUID raterId, UUID loadId, UUID rateeId, int stars, List<String> tags, String comment) {
        int n = jdbc.update("update trust_pending_rating set done = true where load_id = ? and rater_id = ? and ratee_id = ? and not done",
                loadId, raterId, rateeId);
        if (n == 0) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Nothing to rate for this trip");
        }
        if (stars < 1 || stars > 5) {
            throw ApiException.invalidField("stars", "1 to 5 stars");
        }
        jdbc.update("insert into trust_rating (id, load_id, rater_id, ratee_id, stars, tags, comment, created_at) values (?, ?, ?, ?, ?, ?, ?, ?)",
                UUID.randomUUID(), loadId, raterId, rateeId, stars, tags == null ? null : String.join(",", tags),
                comment == null || comment.isBlank() ? null : comment.trim(), Timestamp.from(Instant.now(clock)));
        String key = switch (stars) {
            case 5 -> "rating_5";
            case 4 -> "rating_4";
            case 2 -> "rating_2";
            case 1 -> "rating_1";
            default -> null;
        };
        if (key != null) {
            String code = loads.find(loadId).map(LoadDirectory.LoadInfo::code).orElse("");
            record(rateeId, loadId, "RATING_FROM_" + raterId.toString().substring(0, 8), points(key), stars + "★ rating on " + code, raterId);
        }
    }

    @Override
    @Transactional
    public void rateFromLink(UUID loadId, UUID raterId, UUID rateeId, int stars, List<String> tags, String comment) {
        pending(loadId, raterId, rateeId, Role.DRIVER);
        rate(raterId, loadId, rateeId, stars, tags, comment);
    }

    @Transactional
    public void later(UUID raterId, UUID loadId) {
        int n = jdbc.update("update trust_pending_rating set later_used = true where load_id = ? and rater_id = ? and not done and not later_used",
                loadId, raterId);
        if (n == 0) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Later is allowed once — please rate now");
        }
    }

    /** B-1106: one reminder in Notifications after "Later". */
    @Transactional
    public int remindPendingRatings() {
        int sent = 0;
        for (Map<String, Object> p : jdbc.queryForList("""
                select id, rater_id, load_id from trust_pending_rating where not done and later_used and not reminder_sent
                and created_at < ?""", Timestamp.from(Instant.now(clock).minus(Duration.ofHours(12))))) {
            jdbc.update("update trust_pending_rating set reminder_sent = true where id = ?", p.get("id"));
            notifier.notify((UUID) p.get("rater_id"), NotificationTab.ACCOUNT, "RATING_REMINDER",
                    Map.of("code", loads.find((UUID) p.get("load_id")).map(LoadDirectory.LoadInfo::code).orElse("")), "/");
            sent++;
        }
        return sent;
    }

    // ------------------------------------------------------------------ reads (B-805)

    @Transactional(readOnly = true)
    public Map<String, Object> trustScore(UUID userId) {
        UserDirectory.UserView u = users.get(userId);
        List<BigDecimal> trend = jdbc.queryForList(
                "select score_after from trust_event where user_id = ? order by created_at desc limit 10", BigDecimal.class, userId);
        Timestamp updated = jdbc.queryForObject("select max(created_at) from trust_event where user_id = ?", Timestamp.class, userId);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("score", u.trustScore());
        m.put("updatedAt", updated == null ? null : updated.toInstant());
        m.put("trend", trend.reversed());
        return m;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> events(UUID userId, int page, int size) {
        long total = jdbc.queryForObject("select count(*) from trust_event where user_id = ?", Long.class, userId);
        List<Map<String, Object>> items = jdbc.query(
                "select * from trust_event where user_id = ? order by created_at desc limit ? offset ?", (rs, i) -> {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("at", rs.getTimestamp("created_at").toInstant());
                    m.put("loadId", rs.getObject("load_id"));
                    String event = rs.getString("event");
                    m.put("event", event.startsWith("RATING_FROM_") ? "RATING" : event);
                    m.put("points", rs.getBigDecimal("points"));
                    m.put("reason", rs.getString("reason"));
                    return m;
                }, userId, size, (long) page * size);
        return Map.of("items", items, "page", page, "size", size, "total", total);
    }

    @Override
    public Map<String, Object> contribute(UUID userId, Role role) {
        Integer n = jdbc.queryForObject("select count(*) from trust_pending_rating where rater_id = ? and not done", Integer.class, userId);
        return Map.of("pendingRatingsCount", n == null ? 0 : n);
    }
}
