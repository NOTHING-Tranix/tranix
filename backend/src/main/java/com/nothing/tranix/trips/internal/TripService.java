package com.nothing.tranix.trips.internal;

import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import com.nothing.tranix.engagement.api.Notifier;
import com.nothing.tranix.fleet.api.FleetApi;
import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.geo.GeoPoint;
import com.nothing.tranix.shared.geo.Haversine;
import com.nothing.tranix.shared.integrations.MapsService;
import com.nothing.tranix.shared.integrations.Masking;
import com.nothing.tranix.shared.integrations.SmsSender;
import com.nothing.tranix.shared.settings.SettingKeys;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.shared.types.Language;
import com.nothing.tranix.shared.types.LoadStatus;
import com.nothing.tranix.shared.types.NotificationTab;
import com.nothing.tranix.shared.types.OtpPurpose;
import com.nothing.tranix.shared.types.RouteStatus;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** B-701…B-709 + B-408: current trip, revisions, reached/OTP, help, locations, ETA/route status, tracking. */
@Service
public class TripService {

    private static final SecureRandom RANDOM = new SecureRandom();

    final JdbcTemplate jdbc;
    final LoadDirectory loads;
    final FleetApi fleet;
    final UserDirectory users;
    final MapsService maps;
    final Settings settings;
    final Notifier notifier;
    final SmsSender sms;
    final Clock clock;
    private final byte[] key;
    private final String devOtp;

    TripService(JdbcTemplate jdbc, LoadDirectory loads, FleetApi fleet, UserDirectory users, MapsService maps, Settings settings,
                Notifier notifier, SmsSender sms, Clock clock, @Value("${tranix.jwt.secret}") String secret,
                @Value("${tranix.dev.otp:}") String devOtp) {
        this.jdbc = jdbc;
        this.loads = loads;
        this.fleet = fleet;
        this.users = users;
        this.maps = maps;
        this.settings = settings;
        this.notifier = notifier;
        this.sms = sms;
        this.clock = clock;
        this.key = sha256Bytes(secret + ":trip-otp");
        this.devOtp = devOtp == null || devOtp.isBlank() ? null : devOtp;
    }

    Instant now() {
        return Instant.now(clock);
    }

    LoadDirectory.LoadInfo driverLoad(UUID driverId, UUID loadId) {
        LoadDirectory.LoadInfo l = loads.find(loadId).filter(x -> driverId.equals(x.driverId()))
                .orElseThrow(() -> ApiException.notFound("Trip"));
        return l;
    }

    // ------------------------------------------------------------------ current trip (B-701)

    @Transactional(readOnly = true)
    public Map<String, Object> currentTrip(UUID driverId) {
        List<LoadDirectory.LoadInfo> active = loads.activeForDriver(driverId);
        if (active.isEmpty()) {
            return null;
        }
        return loads.detail(active.getFirst().id(), LoadDirectory.Viewer.DRIVER);
    }

    // ------------------------------------------------------------------ amount revisions (B-702)

    @Transactional
    public Map<String, Object> requestRevision(UUID driverId, UUID loadId, long amountInr, String reason) {
        LoadDirectory.LoadInfo l = driverLoad(driverId, loadId);
        if (l.status() == LoadStatus.AMOUNT_NEGOTIATION) {
            throw new ApiException(ErrorCode.REVISION_PENDING);
        }
        if (l.status() != LoadStatus.WAITING_FOR_PICKUP) { // Q-11 default
            throw new ApiException(ErrorCode.INVALID_STATE, "Amount requests only before you reach the pickup");
        }
        Integer used = jdbc.queryForObject("select count(*) from trips_revision where load_id = ?", Integer.class, loadId);
        if (used != null && used >= settings.getInt(SettingKeys.REVISION_LIMIT)) {
            throw new ApiException(ErrorCode.REVISION_LIMIT_REACHED);
        }
        if (amountInr == l.agreedAmountInr()) {
            throw ApiException.invalidField("amountInr", "Ask for a different amount");
        }
        Instant now = now();
        UUID id = UUID.randomUUID();
        try {
            jdbc.update("""
                    insert into trips_revision (id, load_id, driver_id, previous_amount_inr, requested_amount_inr, reason, status, created_at, respond_by)
                    values (?, ?, ?, ?, ?, ?, 'PENDING', ?, ?)""", id, loadId, driverId, l.agreedAmountInr(), amountInr, reason.trim(),
                    Timestamp.from(now), Timestamp.from(now.plus(Duration.ofMinutes(settings.getInt(SettingKeys.REVISION_RESPONSE_MINUTES)))));
        } catch (DuplicateKeyException e) {
            throw new ApiException(ErrorCode.REVISION_PENDING);
        }
        loads.transition(loadId, LoadStatus.AMOUNT_NEGOTIATION, driverId);
        notifier.notify(l.shipperId(), NotificationTab.TRIPS, "AMOUNT_REQUEST",
                Map.of("code", l.code(), "amount", String.valueOf(amountInr), "reason", reason.trim(),
                        "minutes", String.valueOf(settings.getInt(SettingKeys.REVISION_RESPONSE_MINUTES))), "/loads/" + loadId);
        return loads.detail(loadId, LoadDirectory.Viewer.DRIVER);
    }

    @Transactional
    public Map<String, Object> answerRevision(UUID shipperId, UUID loadId, UUID revisionId, boolean confirm) {
        LoadDirectory.LoadInfo l = loads.find(loadId).filter(x -> x.shipperId().equals(shipperId))
                .orElseThrow(() -> ApiException.notFound("Load"));
        Map<String, Object> r = jdbc.queryForList("select * from trips_revision where id = ? and load_id = ? for update", revisionId, loadId)
                .stream().findFirst().orElseThrow(() -> ApiException.notFound("Request"));
        if (!"PENDING".equals(r.get("status")) || ((Timestamp) r.get("respond_by")).toInstant().isBefore(now())) {
            throw new ApiException(ErrorCode.INVALID_STATE, "This request is no longer open");
        }
        jdbc.update("update trips_revision set status = ?, responded_at = ? where id = ?", confirm ? "CONFIRMED" : "REJECTED",
                Timestamp.from(now()), revisionId);
        long amount = ((Number) r.get("requested_amount_inr")).longValue();
        if (confirm) {
            loads.setAgreedAmount(loadId, amount);
        }
        // Reject keeps the last amount; the trip continues either way (D-05).
        loads.transition(loadId, LoadStatus.WAITING_FOR_PICKUP, shipperId);
        notifier.notify(l.driverId(), NotificationTab.TRIPS, confirm ? "AMOUNT_CONFIRMED" : "AMOUNT_REJECTED",
                Map.of("code", l.code(), "amount", String.valueOf(confirm ? amount : l.agreedAmountInr())), "/driver/trip");
        return loads.detail(loadId, LoadDirectory.Viewer.SHIPPER);
    }

    /** 15-minute expiry (server timer, hard rule 10). */
    @Transactional
    public int expireRevisions() {
        int n = 0;
        for (Map<String, Object> r : jdbc.queryForList(
                "select id, load_id from trips_revision where status = 'PENDING' and respond_by < ? for update skip locked", Timestamp.from(now()))) {
            UUID loadId = (UUID) r.get("load_id");
            jdbc.update("update trips_revision set status = 'EXPIRED', responded_at = ? where id = ?", Timestamp.from(now()), r.get("id"));
            loads.find(loadId).filter(l -> l.status() == LoadStatus.AMOUNT_NEGOTIATION).ifPresent(l -> {
                loads.transition(loadId, LoadStatus.WAITING_FOR_PICKUP, null);
                notifier.notify(l.driverId(), NotificationTab.TRIPS, "AMOUNT_EXPIRED",
                        Map.of("code", l.code(), "amount", String.valueOf(l.agreedAmountInr())), "/driver/trip");
            });
            n++;
        }
        return n;
    }

    // ------------------------------------------------------------------ reached + OTP (B-703…B-705)

    public record ReachedResult(int distanceM, boolean outsideRadius, String otpSentTo) {
    }

    @Transactional
    public ReachedResult reached(UUID driverId, UUID loadId, OtpPurpose purpose, GeoPoint at, String reason) {
        LoadDirectory.LoadInfo l = driverLoad(driverId, loadId);
        GeoPoint pin = purpose == OtpPurpose.PICKUP ? l.pickup() : l.drop();
        int distance = (int) Math.round(Haversine.distanceMeters(at, pin));
        boolean outside = distance > settings.getInt(SettingKeys.GEOFENCE_METERS);
        boolean pickup = purpose == OtpPurpose.PICKUP;
        boolean ok = pickup ? (l.status() == LoadStatus.WAITING_FOR_PICKUP || l.status() == LoadStatus.AMOUNT_NEGOTIATION)
                : l.status() == LoadStatus.TRAVELING;
        if (purpose != OtpPurpose.PICKUP && purpose != OtpPurpose.DELIVERY || !ok) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Not the right step for this trip");
        }
        if (outside && (reason == null || reason.isBlank())) {
            return new ReachedResult(distance, true, null); // app asks for a reason and resends
        }
        if (outside) {
            exception(loadId, purpose, distance, reason);
        }
        if (l.status() == LoadStatus.AMOUNT_NEGOTIATION) {
            // a pending amount request ends when the driver reaches pickup (Q-11 default)
            jdbc.update("update trips_revision set status = 'EXPIRED', responded_at = ? where load_id = ? and status = 'PENDING'",
                    Timestamp.from(now()), loadId);
        }
        loads.transition(loadId, pickup ? LoadStatus.LOCATION_REACHED : LoadStatus.ARRIVED_DESTINATION, driverId);
        String to = sendOtp(l, purpose, "SENT", at, distance);
        return new ReachedResult(distance, outside, Masking.mobile(to));
    }

    /** New code (old ones invalidated); SMS to sender/receiver + in-app notice. Returns the mobile it went to. */
    String sendOtp(LoadDirectory.LoadInfo l, OtpPurpose purpose, String eventType, GeoPoint at, Integer distance) {
        Instant now = now();
        jdbc.update("update trips_otp set invalidated_at = ? where load_id = ? and purpose = ? and consumed_at is null and invalidated_at is null",
                Timestamp.from(now), l.id(), purpose.name());
        String code = devOtp != null ? devOtp : String.format("%06d", RANDOM.nextInt(1_000_000));
        jdbc.update("""
                insert into trips_otp (id, load_id, purpose, code_hash, code_enc, expires_at, created_at) values (?, ?, ?, ?, ?, ?, ?)""",
                UUID.randomUUID(), l.id(), purpose.name(), hash(l.id(), code), encrypt(code),
                Timestamp.from(now.plusSeconds(settings.getInt(SettingKeys.OTP_TTL_SECONDS))), Timestamp.from(now));
        event(l.id(), purpose, eventType, at, distance);
        boolean pickup = purpose == OtpPurpose.PICKUP;
        String mobile = pickup ? l.senderMobile() : l.receiverMobile();
        Language lang = users.find(l.shipperId()).map(UserDirectory.UserView::language).orElse(Language.en);
        sms.send(mobile, pickup ? "TRIP_OTP_PICKUP" : "TRIP_OTP_DELIVERY", Map.of("otp", code, "code", l.code()), lang);
        UUID appUser = pickup ? l.shipperId() : l.receiverUserId();
        if (appUser != null) {
            notifier.notify(appUser, NotificationTab.TRIPS, pickup ? "DRIVER_REACHED_PICKUP" : "DRIVER_REACHED_DROP",
                    Map.of("code", l.code()), pickup ? "/loads/" + l.id() : "/receiver/loads/" + l.id());
        }
        return mobile;
    }

    @Transactional(noRollbackFor = ApiException.class)
    public Map<String, Object> verifyOtp(UUID driverId, UUID loadId, OtpPurpose purpose, String code, GeoPoint at, String reason) {
        LoadDirectory.LoadInfo l = driverLoad(driverId, loadId);
        boolean pickup = purpose == OtpPurpose.PICKUP;
        if (l.status() != (pickup ? LoadStatus.LOCATION_REACHED : LoadStatus.ARRIVED_DESTINATION)) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Not the right step for this trip");
        }
        GeoPoint pin = pickup ? l.pickup() : l.drop();
        int distance = (int) Math.round(Haversine.distanceMeters(at, pin));
        boolean outside = distance > settings.getInt(SettingKeys.GEOFENCE_METERS);
        if (outside && (reason == null || reason.isBlank()) && !hasException(loadId, purpose)) {
            throw ApiException.invalidField("reason", "You are " + distance + " m from the pin. Tell us why.");
        }
        Map<String, Object> otp = jdbc.queryForList("""
                select * from trips_otp where load_id = ? and purpose = ? and consumed_at is null and invalidated_at is null
                order by created_at desc limit 1 for update""", loadId, purpose.name()).stream().findFirst()
                .orElseThrow(() -> new ApiException(ErrorCode.OTP_EXPIRED, "Ask for a new OTP"));
        UUID otpId = (UUID) otp.get("id");
        event(loadId, purpose, "ATTEMPT", at, distance);
        if (((Timestamp) otp.get("expires_at")).toInstant().isBefore(now())) {
            jdbc.update("update trips_otp set invalidated_at = ? where id = ?", Timestamp.from(now()), otpId);
            throw new ApiException(ErrorCode.OTP_EXPIRED);
        }
        if (code == null || !MessageDigest.isEqual(hash(loadId, code).getBytes(StandardCharsets.UTF_8),
                ((String) otp.get("code_hash")).getBytes(StandardCharsets.UTF_8))) {
            int attempts = ((Number) otp.get("attempts")).intValue() + 1;
            jdbc.update("update trips_otp set attempts = ? where id = ?", attempts, otpId);
            if (attempts >= settings.getInt(SettingKeys.OTP_MAX_ATTEMPTS)) {
                jdbc.update("update trips_otp set invalidated_at = ? where id = ?", Timestamp.from(now()), otpId);
                throw new ApiException(ErrorCode.OTP_LOCKED, "Too many wrong tries. Ask for a new OTP.");
            }
            throw new ApiException(ErrorCode.OTP_INVALID);
        }
        jdbc.update("update trips_otp set consumed_at = ? where id = ?", Timestamp.from(now()), otpId);
        event(loadId, purpose, "VERIFIED", at, distance);
        if (outside && !hasException(loadId, purpose)) {
            exception(loadId, purpose, distance, reason); // accepted, flagged for review (§9)
        }
        if (pickup) {
            loads.transition(loadId, LoadStatus.PICKED_UP, driverId);
            loads.transition(loadId, LoadStatus.TRAVELING, driverId);
            if (l.receiverUserId() != null) {
                notifier.notify(l.receiverUserId(), NotificationTab.TRIPS, "PICKED_UP", Map.of("code", l.code()), "/receiver/loads/" + loadId);
            }
            notifier.notify(l.shipperId(), NotificationTab.TRIPS, "PICKED_UP", Map.of("code", l.code()), "/loads/" + loadId);
        } else {
            loads.transition(loadId, LoadStatus.DELIVERED, driverId);
            fleet.tripEnded(driverId, now());
            notifier.notify(l.shipperId(), NotificationTab.TRIPS, "DELIVERED", Map.of("code", l.code()), "/loads/" + loadId);
        }
        return loads.detail(loadId, LoadDirectory.Viewer.DRIVER);
    }

    @Transactional
    public void resendOtp(UUID driverId, UUID loadId, OtpPurpose purpose) {
        LoadDirectory.LoadInfo l = driverLoad(driverId, loadId);
        if (l.status() != (purpose == OtpPurpose.PICKUP ? LoadStatus.LOCATION_REACHED : LoadStatus.ARRIVED_DESTINATION)) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Not the right step for this trip");
        }
        Timestamp last = jdbc.queryForList("select max(created_at) from trips_otp where load_id = ? and purpose = ?", Timestamp.class,
                loadId, purpose.name()).getFirst();
        if (last != null && last.toInstant().plusSeconds(settings.getInt(SettingKeys.OTP_RESEND_SECONDS)).isAfter(now())) {
            throw new ApiException(ErrorCode.RATE_LIMITED, "Wait before sending a new OTP");
        }
        sendOtp(l, purpose, "RESENT", null, null);
    }

    @Transactional
    public Map<String, Object> otpHelp(UUID driverId, UUID loadId, OtpPurpose purpose, GeoPoint at, String note) {
        LoadDirectory.LoadInfo l = driverLoad(driverId, loadId);
        UUID id = UUID.randomUUID();
        jdbc.update("insert into trips_otp_help (id, load_id, purpose, lat, lng, note, created_at) values (?, ?, ?, ?, ?, ?, ?)",
                id, l.id(), purpose.name(), at == null ? null : at.lat(), at == null ? null : at.lng(), note.trim(), Timestamp.from(now()));
        return Map.of("id", id, "status", "OPEN");
    }

    /** B-408: the code for the sender (pickup) or the registered receiver (delivery) while that step is active. */
    @Transactional(readOnly = true)
    public Map<String, Object> viewOtp(UUID userId, UUID loadId) {
        LoadDirectory.LoadInfo l = loads.find(loadId).orElseThrow(() -> ApiException.notFound("Load"));
        OtpPurpose purpose;
        if (l.status() == LoadStatus.LOCATION_REACHED && userId.equals(l.shipperId())) {
            purpose = OtpPurpose.PICKUP;
        } else if (l.status() == LoadStatus.ARRIVED_DESTINATION && userId.equals(l.receiverUserId())) {
            purpose = OtpPurpose.DELIVERY;
        } else if (userId.equals(l.shipperId()) || userId.equals(l.receiverUserId())) {
            throw new ApiException(ErrorCode.INVALID_STATE, "No OTP to show right now");
        } else {
            throw ApiException.notFound("Load");
        }
        Map<String, Object> otp = jdbc.queryForList("""
                select code_enc, expires_at from trips_otp where load_id = ? and purpose = ? and consumed_at is null and invalidated_at is null
                order by created_at desc limit 1""", loadId, purpose.name()).stream().findFirst()
                .orElseThrow(() -> new ApiException(ErrorCode.INVALID_STATE, "No OTP to show right now"));
        return Map.of("purpose", purpose, "code", decrypt((String) otp.get("code_enc")),
                "expiresAt", ((Timestamp) otp.get("expires_at")).toInstant());
    }

    // ------------------------------------------------------------------ locations, ETA, route status (B-706, B-707, B-709)

    public record Point(double lat, double lng, Double speed, Instant at) {
    }

    @Transactional
    public int locations(UUID driverId, UUID loadId, List<Point> points) {
        LoadDirectory.LoadInfo l = driverLoad(driverId, loadId);
        if (points.size() > settings.getInt("trips.max_location_batch")) {
            throw ApiException.invalidField("points", "Too many points in one upload");
        }
        if (l.status() == LoadStatus.DELIVERED || l.status() == LoadStatus.CANCELLED) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Trip has ended");
        }
        Instant now = now();
        Point latest = null;
        for (Point p : points) {
            if (p.at() == null || Math.abs(p.lat()) > 90 || Math.abs(p.lng()) > 180) {
                throw ApiException.invalidField("points", "Invalid point");
            }
            if (p.at().isAfter(now.plusSeconds(120))) {
                continue; // clock skew guard
            }
            jdbc.update("insert into trips_location_point (load_id, lat, lng, speed, at) values (?, ?, ?, ?, ?)",
                    loadId, p.lat(), p.lng(), p.speed(), Timestamp.from(p.at()));
            if (latest == null || p.at().isAfter(latest.at())) {
                latest = p;
            }
        }
        if (latest != null) {
            fleet.updateLocation(driverId, GeoPoint.of(latest.lat(), latest.lng()), latest.at());
            if (l.status() == LoadStatus.TRAVELING) {
                updateEta(l, GeoPoint.of(latest.lat(), latest.lng()));
            }
        }
        return points.size();
    }

    /** ETA from the maps service; route status per D-11 (±10 %, settings); one "running late" notice (B-707). */
    void updateEta(LoadDirectory.LoadInfo l, GeoPoint current) {
        Instant now = now();
        Instant eta = now.plus(Duration.ofMinutes(maps.route(current, l.drop()).driveMinutes()));
        Instant start = l.pickedUpAt() != null ? l.pickedUpAt() : now;
        double planned = Math.max(1, l.driveMinutes());
        double expected = Duration.between(start, eta).toMinutes();
        double slow = 1 + settings.getInt(SettingKeys.ROUTE_SLOW_THRESHOLD_PCT) / 100.0;
        double fast = 1 - settings.getInt(SettingKeys.ROUTE_FAST_THRESHOLD_PCT) / 100.0;
        RouteStatus status = expected > planned * slow ? RouteStatus.SLOW : expected < planned * fast ? RouteStatus.FAST : RouteStatus.NORMAL;
        jdbc.update("""
                insert into trips_route (load_id, current_eta, route_status, updated_at) values (?, ?, ?, ?)
                on conflict (load_id) do update set current_eta = excluded.current_eta, route_status = excluded.route_status,
                updated_at = excluded.updated_at""", l.id(), Timestamp.from(eta), status.name(), Timestamp.from(now));
        boolean late = l.deliveryEta() != null
                && eta.isAfter(l.deliveryEta().plus(Duration.ofMinutes(settings.getInt("trips.late_grace_minutes"))));
        if (late && jdbc.update("update trips_route set late_notified = true where load_id = ? and not late_notified", l.id()) == 1) {
            Map<String, String> p = Map.of("code", l.code(), "eta", eta.toString());
            notifier.notify(l.shipperId(), NotificationTab.TRIPS, "RUNNING_LATE", p, "/loads/" + l.id());
            if (l.receiverUserId() != null) {
                notifier.notify(l.receiverUserId(), NotificationTab.TRIPS, "RUNNING_LATE", p, "/receiver/loads/" + l.id());
            }
        }
    }

    @Transactional(readOnly = true)
    public Map<String, Object> tracking(UUID userId, UUID loadId, boolean admin) {
        LoadDirectory.LoadInfo l = loads.find(loadId)
                .filter(x -> admin || userId.equals(x.shipperId()) || userId.equals(x.receiverUserId()) || userId.equals(x.orgId()))
                .orElseThrow(() -> ApiException.notFound("Load"));
        return trackingOf(l);
    }

    public Map<String, Object> trackingOf(LoadDirectory.LoadInfo l) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("driverLocation", null);
        m.put("etaAt", l.deliveryEta());
        m.put("routeStatus", null);
        if (l.driverId() == null) {
            return m;
        }
        jdbc.queryForList("select lat, lng, at from trips_location_point where load_id = ? order by at desc limit 1", l.id()).stream()
                .findFirst().ifPresent(p -> m.put("driverLocation", Map.of("lat", p.get("lat"), "lng", p.get("lng"),
                        "at", ((Timestamp) p.get("at")).toInstant())));
        jdbc.queryForList("select current_eta, route_status from trips_route where load_id = ?", l.id()).stream().findFirst()
                .ifPresent(r -> {
                    if (r.get("current_eta") != null) {
                        m.put("etaAt", ((Timestamp) r.get("current_eta")).toInstant());
                    }
                    m.put("routeStatus", r.get("route_status"));
                });
        return m;
    }

    /** Detail location kept 90 days (Q-08 default, setting). */
    @Transactional
    public int purgeOldLocations() {
        return jdbc.update("delete from trips_location_point where at < ?",
                Timestamp.from(now().minus(Duration.ofDays(settings.getInt(SettingKeys.LOCATION_RETENTION_DAYS)))));
    }

    // ------------------------------------------------------------------ LoadDetail parts

    List<Map<String, Object>> revisions(UUID loadId) {
        return jdbc.query("select * from trips_revision where load_id = ? order by created_at", (rs, i) -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", rs.getObject("id"));
            m.put("requestedAmountInr", rs.getLong("requested_amount_inr"));
            m.put("reason", rs.getString("reason"));
            m.put("status", rs.getString("status"));
            m.put("createdAt", rs.getTimestamp("created_at").toInstant());
            m.put("respondBy", rs.getTimestamp("respond_by").toInstant());
            return m;
        }, loadId);
    }

    List<Map<String, Object>> otpEvents(UUID loadId) {
        return jdbc.query("select purpose, type, distance_m, at from trips_otp_event where load_id = ? order by at", (rs, i) -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("purpose", rs.getString("purpose"));
            m.put("type", rs.getString("type"));
            m.put("distanceM", rs.getObject("distance_m"));
            m.put("at", rs.getTimestamp("at").toInstant());
            return m;
        }, loadId);
    }

    List<Map<String, Object>> locationExceptions(UUID loadId) {
        return jdbc.query("select * from trips_location_exception where load_id = ? order by created_at", (rs, i) -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("purpose", rs.getString("purpose"));
            m.put("distanceM", rs.getInt("distance_m"));
            m.put("reason", rs.getString("driver_reason"));
            m.put("reviewStatus", rs.getString("review_status"));
            return m;
        }, loadId);
    }

    // ------------------------------------------------------------------ helpers

    private boolean hasException(UUID loadId, OtpPurpose purpose) {
        return !jdbc.queryForList("select id from trips_location_exception where load_id = ? and purpose = ?", UUID.class,
                loadId, purpose.name()).isEmpty();
    }

    private void exception(UUID loadId, OtpPurpose purpose, int distance, String reason) {
        if (!hasException(loadId, purpose)) {
            jdbc.update("insert into trips_location_exception (id, load_id, purpose, distance_m, driver_reason, created_at) values (?, ?, ?, ?, ?, ?)",
                    UUID.randomUUID(), loadId, purpose.name(), distance, reason.trim(), Timestamp.from(now()));
        }
    }

    private void event(UUID loadId, OtpPurpose purpose, String type, GeoPoint at, Integer distance) {
        jdbc.update("insert into trips_otp_event (id, load_id, purpose, type, lat, lng, distance_m, at) values (?, ?, ?, ?, ?, ?, ?, ?)",
                UUID.randomUUID(), loadId, purpose.name(), type, at == null ? null : at.lat(), at == null ? null : at.lng(), distance,
                Timestamp.from(now()));
    }

    private String hash(UUID loadId, String code) {
        return HexFormat.of().formatHex(sha256Bytes(loadId + ":" + code + ":" + Base64.getEncoder().encodeToString(key)));
    }

    String encrypt(String code) {
        try {
            byte[] iv = new byte[12];
            RANDOM.nextBytes(iv);
            Cipher c = Cipher.getInstance("AES/GCM/NoPadding");
            c.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(key, "AES"), new GCMParameterSpec(128, iv));
            byte[] enc = c.doFinal(code.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(ByteBuffer.allocate(iv.length + enc.length).put(iv).put(enc).array());
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    String decrypt(String value) {
        try {
            byte[] all = Base64.getDecoder().decode(value);
            Cipher c = Cipher.getInstance("AES/GCM/NoPadding");
            c.init(Cipher.DECRYPT_MODE, new SecretKeySpec(key, "AES"), new GCMParameterSpec(128, all, 0, 12));
            return new String(c.doFinal(all, 12, all.length - 12), StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private static byte[] sha256Bytes(String v) {
        try {
            return MessageDigest.getInstance("SHA-256").digest(v.getBytes(StandardCharsets.UTF_8));
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }
}
