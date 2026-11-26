package com.nothing.tranix.admin.internal;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.shared.audit.AuditLog;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.trips.api.TripAdmin;
import com.nothing.tranix.trips.api.TripTracking;
import com.nothing.tranix.trust.api.TrustApi;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * B-1201…B-1212 back office. Reads are reporting queries across module tables (read-only); state changes go
 * through the owning module's API; every admin write is audited (hard rule 12).
 */
@Service
public class AdminService {

    static final ZoneId IST = ZoneId.of("Asia/Kolkata");
    static final int PAGE = 10;

    private final JdbcTemplate jdbc;
    private final LoadDirectory loads;
    private final TripAdmin trips;
    private final TripTracking tracking;
    private final UserDirectory users;
    private final TrustApi trust;
    private final Settings settings;
    private final AuditLog audit;
    private final Clock clock;

    AdminService(JdbcTemplate jdbc, LoadDirectory loads, TripAdmin trips, TripTracking tracking, UserDirectory users, TrustApi trust,
                 Settings settings, AuditLog audit, Clock clock) {
        this.jdbc = jdbc;
        this.loads = loads;
        this.trips = trips;
        this.tracking = tracking;
        this.users = users;
        this.trust = trust;
        this.settings = settings;
        this.audit = audit;
        this.clock = clock;
    }

    // ------------------------------------------------------------------ dashboard (B-1202)

    @Transactional(readOnly = true)
    public Map<String, Object> dashboard() {
        Timestamp today = Timestamp.from(Instant.now(clock).atZone(IST).toLocalDate().atStartOfDay(IST).toInstant());
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("openLoads", count("select count(*) from loads_load where status = 'NOT_ACCEPTED'"));
        m.put("activeLoads", count("select count(*) from loads_load where status not in ('NOT_ACCEPTED','DELIVERED','CANCELLED')"));
        m.put("activeFleet", Map.of(
                "driversOnDuty", count("select count(*) from fleet_driver_state where on_duty"),
                "trucks", count("select count(*) from fleet_truck where active")));
        m.put("pendingVerifications", count("select count(*) from identity_user where verification_status = 'UNDER_REVIEW'"));
        m.put("openSupport", count("select count(*) from support_ticket where status = 'OPEN'"));
        Map<String, Object> freight = new LinkedHashMap<>();
        freight.put("totalInr", jdbc.queryForObject("""
                select coalesce(sum(agreed_amount_inr), 0) from loads_load where accepted_at is not null and status <> 'CANCELLED'""", Long.class));
        for (Map<String, Object> r : jdbc.queryForList("select status, count(*) n from payments_record group by status")) {
            freight.put(String.valueOf(r.get("status")).toLowerCase(Locale.ROOT), r.get("n"));
        }
        m.put("freight", freight);
        Map<String, Object> route = new LinkedHashMap<>(Map.of("NORMAL", 0L, "SLOW", 0L, "FAST", 0L));
        for (Map<String, Object> r : jdbc.queryForList("""
                select r.route_status s, count(*) n from trips_route r join loads_load l on l.id = r.load_id
                where l.status in ('PICKED_UP','TRAVELING','ARRIVED_DESTINATION') and r.route_status is not null group by r.route_status""")) {
            route.put(String.valueOf(r.get("s")), r.get("n"));
        }
        m.put("routeStatus", route);
        m.put("reminders", Map.of(
                "cancellationsToReview", count("select count(*) from loads_cancellation where admin_decision is null and charges_kept and by_role <> 'ADMIN'"),
                "locationExceptionsToReview", count("select count(*) from trips_location_exception where review_status = 'PENDING'"),
                "paymentDisputes", count("select count(*) from payments_record where status = 'DISPUTED'"),
                "otpHelpRequests", count("select count(*) from trips_otp_help where status = 'OPEN'")));
        m.put("topupsTodayInr", jdbc.queryForObject("select coalesce(sum(amount_inr), 0) from wallet_topup_order where status = 'PAID' and paid_at >= ?",
                Long.class, today));
        m.put("cancellationsToday", jdbc.queryForObject("select count(*) from loads_cancellation where created_at >= ?", Long.class, today));
        return m;
    }

    // ------------------------------------------------------------------ loads (B-1203)

    @Transactional(readOnly = true)
    public Map<String, Object> loads(String status, String q, int page) {
        StringBuilder where = new StringBuilder(" from loads_load l where 1 = 1");
        List<Object> args = new ArrayList<>();
        if (status != null && !status.isBlank()) {
            where.append(" and l.status = ?");
            args.add(status);
        } else {
            where.append(" and l.status not in ('DELIVERED','CANCELLED')");
        }
        if (q != null && !q.isBlank()) {
            where.append(" and (upper(l.code) like ? or l.pickup_area ilike ? or l.drop_area ilike ? or l.sender_mobile = ? or l.receiver_mobile = ?)");
            String like = "%" + q.trim().replace("%", "") + "%";
            args.addAll(List.of(like.toUpperCase(Locale.ROOT), like, like, q.trim(), q.trim()));
        }
        Long total = jdbc.queryForObject("select count(*)" + where, Long.class, args.toArray());
        List<Object> pageArgs = new ArrayList<>(args);
        pageArgs.addAll(List.of(PAGE, page * PAGE));
        List<Map<String, Object>> items = jdbc.queryForList("""
                select l.id, l.code, l.status, l.pickup_area as "pickupArea", l.drop_area as "dropArea", l.pickup_window_start as "pickupWindowStart",
                       l.agreed_amount_inr as "agreedAmountInr", l.shipper_id as "shipperId", l.driver_id as "driverId", l.delivery_eta as "deliveryEta",
                       r.route_status as "routeStatus"
                """ + where.toString().replace(" from loads_load l", " from loads_load l left join trips_route r on r.load_id = l.id")
                + " order by l.pickup_window_start desc limit ? offset ?", pageArgs.toArray());
        return Map.of("items", items, "page", page, "size", PAGE, "total", total == null ? 0 : total);
    }

    @Transactional(readOnly = true)
    public Map<String, Object> load(UUID loadId) {
        Map<String, Object> m = new LinkedHashMap<>(loads.detail(loadId, LoadDirectory.Viewer.ADMIN));
        m.put("tracking", tracking.trackingOf(loadId));
        m.put("cancellations", jdbc.queryForList("select * from loads_cancellation where load_id = ? order by created_at", loadId));
        m.put("locationExceptionsReview", jdbc.queryForList("select * from trips_location_exception where load_id = ? order by created_at", loadId));
        m.put("otpHelp", jdbc.queryForList("select id, purpose, note, status, created_at from trips_otp_help where load_id = ? order by created_at", loadId));
        return m;
    }

    @Transactional
    public Map<String, Object> cancelLoad(UUID adminId, UUID loadId, String reason) {
        Map<String, Object> out = loads.adminCancel(loadId, adminId, reason);
        audit.record(adminId, "LOAD_CANCEL", "LOAD", loadId, null, "CANCELLED", reason);
        return out;
    }

    @Transactional
    public Map<String, Object> otpOverride(UUID adminId, UUID loadId, String purpose, String reason) {
        Map<String, Object> out = trips.otpOverride(loadId, purpose, adminId);
        audit.record(adminId, "OTP_OVERRIDE", "LOAD", loadId, null, purpose, reason);
        return out;
    }

    // ------------------------------------------------------------------ fleet (B-1204)

    @Transactional(readOnly = true)
    public Map<String, Object> fleet(String q, int page) {
        String where = " from fleet_truck t where t.active" + (q == null || q.isBlank() ? "" : " and upper(t.number) like ?");
        Object[] args = q == null || q.isBlank() ? new Object[0] : new Object[] {"%" + q.trim().toUpperCase(Locale.ROOT).replace("%", "") + "%"};
        Long total = jdbc.queryForObject("select count(*)" + where, Long.class, args);
        List<Object> pageArgs = new ArrayList<>(List.of(args));
        pageArgs.addAll(List.of(PAGE, page * PAGE));
        List<Map<String, Object>> items = jdbc.queryForList("""
                select t.id, t.number, t.vehicle_type as "vehicleType", t.capacity_tonnes as "capacityTonnes", t.owner_type as "ownerType",
                       t.owner_id as "ownerId",
                       coalesce(a.driver_id, case when t.owner_type = 'DRIVER' then t.owner_id end) as "driverId",
                       s.on_duty as "onDuty", s.last_lat as "lastLat", s.last_lng as "lastLng", s.last_location_at as "lastLocationAt",
                       (select l.code from loads_load l where l.truck_id = t.id and l.status not in ('NOT_ACCEPTED','DELIVERED','CANCELLED') limit 1) as "activeLoadCode"
                """ + where.replace(" from fleet_truck t", """
                 from fleet_truck t
                 left join fleet_allocation a on a.truck_id = t.id and a.status = 'ACTIVE'
                 left join fleet_driver_state s on s.driver_id = coalesce(a.driver_id, case when t.owner_type = 'DRIVER' then t.owner_id end)""")
                + " order by t.number limit ? offset ?", pageArgs.toArray());
        return Map.of("items", items, "page", page, "size", PAGE, "total", total == null ? 0 : total);
    }

    // ------------------------------------------------------------------ users (B-1207)

    @Transactional(readOnly = true)
    public Map<String, Object> users(String q, String role, int page) {
        StringBuilder where = new StringBuilder(" from identity_user u where 1 = 1");
        List<Object> args = new ArrayList<>();
        if (role != null && !role.isBlank()) {
            where.append(" and u.role = ?");
            args.add(role);
        }
        if (q != null && !q.isBlank()) {
            where.append(" and (u.name ilike ? or u.mobile = ?)");
            args.add("%" + q.trim().replace("%", "") + "%");
            args.add(q.trim());
        }
        Long total = jdbc.queryForObject("select count(*)" + where, Long.class, args.toArray());
        List<Object> pageArgs = new ArrayList<>(args);
        pageArgs.addAll(List.of(PAGE, page * PAGE));
        List<Map<String, Object>> items = jdbc.queryForList("""
                select u.id, u.name, u.mobile, u.role, u.verification_status as "verificationStatus", u.trust_score as "trustScore",
                       u.suspended_at is not null as "suspended", u.created_at as "createdAt"
                """ + where + " order by u.created_at desc limit ? offset ?", pageArgs.toArray());
        return Map.of("items", items, "page", page, "size", PAGE, "total", total == null ? 0 : total);
    }

    @Transactional
    public void suspend(UUID adminId, UUID userId, boolean suspend, String reason) {
        users.setSuspended(userId, suspend);
        audit.record(adminId, suspend ? "USER_SUSPEND" : "USER_REACTIVATE", "USER", userId, null, null, reason);
    }

    // ------------------------------------------------------------------ cancellations, disputes, exceptions (B-1208, B-1209)

    @Transactional(readOnly = true)
    public List<Map<String, Object>> cancellations(boolean pendingOnly) {
        return jdbc.queryForList("""
                select c.id, c.load_id as "loadId", l.code as "loadCode", c.by_user_id as "byUserId", c.by_role as "byRole", c.stage, c.reason,
                       c.note, c.charges_kept as "chargesKept", c.penalty_points as "penaltyPoints", c.admin_decision as "adminDecision",
                       c.admin_reason as "adminReason", c.created_at as "createdAt"
                from loads_cancellation c join loads_load l on l.id = c.load_id
                where c.by_role <> 'ADMIN'""" + (pendingOnly ? " and c.admin_decision is null and c.charges_kept" : "")
                + " order by c.created_at desc limit 200");
    }

    /** UPHOLD keeps the outcome; REVERSE gives the Trust Score points back (charges are refunded separately via wallet refund). */
    @Transactional
    public Map<String, Object> decideCancellation(UUID adminId, UUID id, String decision, String reason) {
        Map<String, Object> c = jdbc.queryForList("select * from loads_cancellation where id = ? and admin_decision is null", id).stream()
                .findFirst().orElseThrow(() -> ApiException.notFound("Cancellation to decide"));
        if (!"UPHOLD".equals(decision) && !"REVERSE".equals(decision)) {
            throw ApiException.invalidField("decision", "UPHOLD or REVERSE");
        }
        jdbc.update("update loads_cancellation set admin_decision = ?, admin_reason = ?, decided_by = ?, decided_at = ? where id = ?",
                decision, reason, adminId, Timestamp.from(Instant.now(clock)), id);
        BigDecimal penalty = (BigDecimal) c.get("penalty_points");
        if ("REVERSE".equals(decision) && penalty != null && penalty.signum() < 0) {
            trust.record((UUID) c.get("by_user_id"), (UUID) c.get("load_id"), "ADMIN_ADJUSTMENT", penalty.negate(),
                    "Cancellation penalty reversed by Tranix: " + reason, adminId);
        }
        audit.record(adminId, "CANCELLATION_DECIDE", "CANCELLATION", id, null, decision, reason);
        return cancellations(false).stream().filter(x -> id.equals(x.get("id"))).findFirst().orElseThrow();
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> paymentDisputes() {
        return jdbc.queryForList("""
                select p.load_id as "loadId", l.code as "loadCode", p.payer, p.payee_driver_id as "driverId", p.amount_inr as "amountInr",
                       p.mode, p.reference, p.dispute_reason as "disputeReason", p.updated_at as "updatedAt"
                from payments_record p join loads_load l on l.id = p.load_id where p.status = 'DISPUTED' order by p.updated_at""");
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> locationExceptions(String status) {
        return jdbc.queryForList("""
                select e.id, e.load_id as "loadId", l.code as "loadCode", e.purpose, e.distance_m as "distanceM", e.driver_reason as "driverReason",
                       e.review_status as "reviewStatus", e.admin_note as "adminNote", e.created_at as "createdAt"
                from trips_location_exception e join loads_load l on l.id = e.load_id where e.review_status = ? order by e.created_at""",
                status == null ? "PENDING" : status);
    }

    @Transactional
    public Map<String, Object> reviewException(UUID adminId, UUID id, String decision, String note) {
        Map<String, Object> out = trips.reviewLocationException(id, decision, note);
        audit.record(adminId, "LOCATION_EXCEPTION_REVIEW", "LOCATION_EXCEPTION", id, "PENDING", decision, note);
        return out;
    }

    // ------------------------------------------------------------------ settings (B-1210)

    @Transactional(readOnly = true)
    public List<Map<String, Object>> settingsList() {
        return jdbc.queryForList("select key, value, type, description, updated_by as \"updatedBy\", updated_at as \"updatedAt\" from admin_setting order by key");
    }

    @Transactional
    public Map<String, Object> updateSetting(UUID adminId, String key, String value, String reason) {
        Map<String, Object> s = jdbc.queryForList("select * from admin_setting where key = ?", key).stream().findFirst()
                .orElseThrow(() -> ApiException.notFound("Setting"));
        String v = value == null ? "" : value.trim();
        String type = (String) s.get("type");
        validate(type, v);
        if (key.startsWith("matching.weight.")) {
            BigDecimal sum = jdbc.queryForList("select key, value from admin_setting where key like 'matching.weight.%'").stream()
                    .map(r -> key.equals(r.get("key")) ? new BigDecimal(v) : new BigDecimal((String) r.get("value")))
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            if (sum.compareTo(BigDecimal.valueOf(100)) != 0) {
                throw ApiException.invalidField("value", "Ranking weights must add up to 100% (now " + sum.stripTrailingZeros().toPlainString() + "%)");
            }
        }
        jdbc.update("update admin_setting set value = ?, updated_by = ?, updated_at = ? where key = ?", v, adminId, Timestamp.from(Instant.now(clock)), key);
        settings.reload();
        audit.record(adminId, "SETTING_UPDATE", "SETTING", key, (String) s.get("value"), v, reason);
        return settingsList().stream().filter(r -> key.equals(r.get("key"))).findFirst().orElseThrow();
    }

    private static void validate(String type, String v) {
        try {
            switch (type) {
                case "INT" -> Integer.parseInt(v);
                case "DECIMAL" -> new BigDecimal(v);
                case "BOOLEAN" -> {
                    if (!"true".equals(v) && !"false".equals(v)) {
                        throw new IllegalArgumentException();
                    }
                }
                case "INT_LIST" -> {
                    for (String p : v.split(",")) {
                        Integer.parseInt(p.trim());
                    }
                }
                case "STRING_LIST" -> {
                    if (v.isBlank()) {
                        throw new IllegalArgumentException();
                    }
                }
                default -> { }
            }
        } catch (RuntimeException e) {
            throw ApiException.invalidField("value", "Not a valid " + type + " value");
        }
    }

    // ------------------------------------------------------------------ map restrictions (B-1211)

    public record Restriction(String name, double lat, double lng, BigDecimal radiusKm, LocalTime noEntryFrom, LocalTime noEntryTo,
                              List<String> vehicleTypes, String note, Boolean active) {
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> restrictions() {
        return jdbc.queryForList("""
                select id, name, lat, lng, radius_km as "radiusKm", no_entry_from as "noEntryFrom", no_entry_to as "noEntryTo",
                       vehicle_types as "vehicleTypes", note, active from admin_map_restriction order by name""");
    }

    @Transactional
    public Map<String, Object> saveRestriction(UUID adminId, UUID id, Restriction r) {
        if (r.lat() < -90 || r.lat() > 90 || r.lng() < -180 || r.lng() > 180) {
            throw ApiException.invalidField("lat", "Invalid location");
        }
        if (r.radiusKm() == null || r.radiusKm().signum() <= 0 || r.radiusKm().compareTo(BigDecimal.valueOf(100)) > 0) {
            throw ApiException.invalidField("radiusKm", "0 to 100 km");
        }
        String types = r.vehicleTypes() == null || r.vehicleTypes().isEmpty() ? null : String.join(",", r.vehicleTypes());
        Object from = r.noEntryFrom() == null ? null : java.sql.Time.valueOf(r.noEntryFrom());
        Object to = r.noEntryTo() == null ? null : java.sql.Time.valueOf(r.noEntryTo());
        UUID rid = id == null ? UUID.randomUUID() : id;
        if (id == null) {
            jdbc.update("""
                    insert into admin_map_restriction (id, name, lat, lng, radius_km, no_entry_from, no_entry_to, vehicle_types, note, active)
                    values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""", rid, r.name(), r.lat(), r.lng(), r.radiusKm(), from, to, types, r.note(),
                    r.active() == null || r.active());
        } else if (jdbc.update("""
                update admin_map_restriction set name = ?, lat = ?, lng = ?, radius_km = ?, no_entry_from = ?, no_entry_to = ?, vehicle_types = ?,
                note = ?, active = ? where id = ?""", r.name(), r.lat(), r.lng(), r.radiusKm(), from, to, types, r.note(),
                r.active() == null || r.active(), id) == 0) {
            throw ApiException.notFound("Restriction");
        }
        audit.record(adminId, id == null ? "RESTRICTION_CREATE" : "RESTRICTION_UPDATE", "MAP_RESTRICTION", rid, null, r.name(), null);
        return restrictions().stream().filter(x -> rid.equals(x.get("id"))).findFirst().orElseThrow();
    }

    @Transactional
    public void deactivateRestriction(UUID adminId, UUID id) {
        if (jdbc.update("update admin_map_restriction set active = false where id = ?", id) == 0) {
            throw ApiException.notFound("Restriction");
        }
        audit.record(adminId, "RESTRICTION_DEACTIVATE", "MAP_RESTRICTION", id, "active", "inactive", null);
    }

    // ------------------------------------------------------------------ audit (B-1212)

    @Transactional(readOnly = true)
    public Map<String, Object> audit(String entity, UUID actorId, String action, int page) {
        StringBuilder where = new StringBuilder(" from admin_audit where 1 = 1");
        List<Object> args = new ArrayList<>();
        if (entity != null && !entity.isBlank()) {
            where.append(" and upper(entity) = upper(?)"); // B-1604: older rows were saved in lowercase
            args.add(entity);
        }
        if (actorId != null) {
            where.append(" and actor_id = ?");
            args.add(actorId);
        }
        if (action != null && !action.isBlank()) {
            where.append(" and action = ?");
            args.add(action);
        }
        Long total = jdbc.queryForObject("select count(*)" + where, Long.class, args.toArray());
        List<Object> pageArgs = new ArrayList<>(args);
        pageArgs.addAll(List.of(50, page * 50));
        List<Map<String, Object>> items = jdbc.queryForList("""
                select id, actor_id as "actorId", action, entity, entity_id as "entityId", before, after, reason, at
                """ + where + " order by at desc limit ? offset ?", pageArgs.toArray());
        return Map.of("items", items, "page", page, "size", 50, "total", total == null ? 0 : total);
    }

    private long count(String sql) {
        Long n = jdbc.queryForObject(sql, Long.class);
        return n == null ? 0 : n;
    }

    static void requireReason(String reason) {
        if (reason == null || reason.isBlank()) {
            throw ApiException.invalidField("reason", "A reason is required");
        }
    }
}
