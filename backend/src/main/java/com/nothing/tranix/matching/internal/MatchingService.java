package com.nothing.tranix.matching.internal;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import com.nothing.tranix.engagement.api.Notifier;
import com.nothing.tranix.fleet.api.FleetApi;
import com.nothing.tranix.identity.api.DocumentRegistry;
import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.geo.GeoPoint;
import com.nothing.tranix.shared.geo.Haversine;
import com.nothing.tranix.shared.integrations.SmsSender;
import com.nothing.tranix.shared.settings.SettingKeys;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.shared.types.DocumentType;
import com.nothing.tranix.shared.types.LoadStatus;
import com.nothing.tranix.shared.types.NotificationTab;
import com.nothing.tranix.shared.types.SuggestionRejectReason;
import com.nothing.tranix.shared.types.VehicleType;
import com.nothing.tranix.wallet.api.WalletApi;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** B-601…B-606: eligibility, ranking, batches, suggestions, atomic accept, reject. */
@Service
public class MatchingService {

    static final ZoneId IST = ZoneId.of("Asia/Kolkata");
    /** Fake/default road speed for "minutes to pickup" (same as the fake maps service, Q-05). */
    static final double ROAD_FACTOR = 1.3;
    static final double SPEED_KMH = 40.0;

    final JdbcTemplate jdbc;
    final LoadDirectory loads;
    final FleetApi fleet;
    final UserDirectory users;
    final DocumentRegistry documents;
    final WalletApi wallet;
    final Settings settings;
    final Notifier notifier;
    final SmsSender sms;
    final Clock clock;
    final List<RankingBonus> bonuses;

    MatchingService(JdbcTemplate jdbc, LoadDirectory loads, FleetApi fleet, UserDirectory users, DocumentRegistry documents,
                    WalletApi wallet, Settings settings, Notifier notifier, SmsSender sms, Clock clock,
                    org.springframework.beans.factory.ObjectProvider<RankingBonus> bonuses) {
        this.jdbc = jdbc;
        this.loads = loads;
        this.fleet = fleet;
        this.users = users;
        this.documents = documents;
        this.wallet = wallet;
        this.settings = settings;
        this.notifier = notifier;
        this.sms = sms;
        this.clock = clock;
        this.bonuses = bonuses.orderedStream().toList();
    }

    /** Extension point for the wish list (M9): restricts the audience, adds a bonus, relaxes the radius. */
    public interface RankingBonus {
        /** Drivers that count as "preferred" for this load (empty = none). */
        Set<UUID> preferredDrivers(LoadDirectory.LoadInfo load);

        /** When non-null, only these drivers may be suggested right now (WISHLIST_FIRST window / WISHLIST_ONLY). */
        default Set<UUID> restrictTo(LoadDirectory.LoadInfo load, Instant now) {
            return null;
        }

        default double bonus() {
            return 0;
        }

        default int relaxedRadiusKm() {
            return 0;
        }
    }

    record Candidate(FleetApi.DriverContext driver, double distanceKm, double score, boolean preferred) {
    }

    // ------------------------------------------------------------------ eligibility + ranking (B-601, B-602)

    List<Candidate> rank(LoadDirectory.LoadInfo load, int radiusKm) {
        Instant now = Instant.now(clock);
        LocalDate pickupDate = load.pickupWindowStart().atZone(IST).toLocalDate();
        Set<UUID> already = new HashSet<>(jdbc.queryForList("select driver_id from matching_suggestion where load_id = ?", UUID.class, load.id()));
        Set<UUID> preferred = new HashSet<>();
        Set<UUID> restrict = null;
        int relaxed = 0;
        double bonus = 0;
        for (RankingBonus b : bonuses) {
            preferred.addAll(b.preferredDrivers(load));
            Set<UUID> r = b.restrictTo(load, now);
            if (r != null) {
                restrict = restrict == null ? new HashSet<>(r) : restrict;
                restrict.retainAll(r);
            }
            relaxed = Math.max(relaxed, b.relaxedRadiusKm());
            bonus = Math.max(bonus, b.bonus());
        }
        long tripCharge = wallet.chargeAmount(WalletApi.ChargeType.TRIP_CHARGE);
        Haversine.BoundingBox box = Haversine.boundingBox(load.pickup(), Math.max(radiusKm, relaxed));
        List<Candidate> out = new ArrayList<>();
        for (FleetApi.DriverContext d : fleet.onDutyDrivers(pickupDate)) {
            if (already.contains(d.driverId()) || d.driverId().equals(load.shipperId()) || d.lastLocation() == null
                    || !box.contains(d.lastLocation()) || (restrict != null && !restrict.contains(d.driverId()))) {
                continue;
            }
            double km = Haversine.distanceKm(d.lastLocation(), load.pickup());
            boolean isPreferred = preferred.contains(d.driverId());
            if (km > (isPreferred ? Math.max(radiusKm, relaxed) : radiusKm)) {
                continue;
            }
            if (!eligible(d, load, pickupDate, tripCharge)) {
                continue;
            }
            double score = score(d, load, km, Math.max(radiusKm, 1), now) + (isPreferred ? bonus : 0);
            out.add(new Candidate(d, km, score, isPreferred));
        }
        out.sort(Comparator.comparing(Candidate::preferred).reversed().thenComparing(Comparator.comparingDouble(Candidate::score).reversed()));
        return out;
    }

    boolean eligible(FleetApi.DriverContext d, LoadDirectory.LoadInfo load, LocalDate pickupDate, long tripCharge) {
        Optional<UserDirectory.UserView> u = users.find(d.driverId());
        if (u.isEmpty() || !u.get().verified() || !d.onDuty() || d.truckId() == null || !d.truckDocumentsValid()) {
            return false;
        }
        if (load.vehicleType() != VehicleType.ANY && load.vehicleType() != d.vehicleType()) {
            return false;
        }
        if (d.capacityTonnes() == null || d.capacityTonnes().compareTo(load.weightTonnes()) < 0) {
            return false;
        }
        if (!documents.allApprovedAndValid(DocumentRegistry.Owner.USER, d.driverId(), List.of(DocumentType.DRIVING_LICENCE), pickupDate)) {
            return false;
        }
        if (!loads.activeForDriver(d.driverId()).isEmpty()) {
            return false;
        }
        return wallet.balance(d.payerUserId()) >= tripCharge;
    }

    /** Σ weight% × factor (0–1), weights from settings (§6). */
    double score(FleetApi.DriverContext d, LoadDirectory.LoadInfo load, double km, int radiusKm, Instant now) {
        double distance = Math.max(0, 1 - km / radiusKm);
        double minutesToPickup = km * ROAD_FACTOR / SPEED_KMH * 60;
        Instant arrive = now.plusSeconds((long) (minutesToPickup * 60));
        double timeFit = !arrive.isAfter(load.pickupWindowStart()) ? 1
                : !arrive.isAfter(load.pickupWindowEnd()) ? 0.5 : 0;
        BigDecimal trustScore = users.find(d.driverId()).map(UserDirectory.UserView::trustScore).orElse(BigDecimal.valueOf(70));
        double trust = trustScore.doubleValue() / 100;
        double capacityFit = Math.min(1, load.weightTonnes().doubleValue() / d.capacityTonnes().doubleValue());
        double returnLoad = 0.5; // no home-base data yet (D-27)
        double idle = d.lastTripEndedAt() == null ? 1
                : Math.min(1, Duration.between(d.lastTripEndedAt(), now).toMinutes() / (24.0 * 60));
        return w("distance") * distance + w("time_fit") * timeFit + w("trust") * trust + w("capacity_fit") * capacityFit
                + w("return_load") * returnLoad + w("idle_time") * idle;
    }

    private double w(String key) {
        return settings.getDecimal("matching.weight." + key).doubleValue() / 100;
    }

    // ------------------------------------------------------------------ batches (B-603)

    @Transactional(propagation = org.springframework.transaction.annotation.Propagation.REQUIRES_NEW)
    public void start(UUID loadId) {
        Instant now = Instant.now(clock);
        jdbc.update("insert into matching_load_state (load_id, radius_km, batches, next_batch_at) values (?, ?, 0, ?) on conflict do nothing",
                loadId, settings.getInt(SettingKeys.MATCHING_INITIAL_RADIUS_KM), Timestamp.from(now));
        runBatch(loadId);
    }

    /** Runs due batches; called every minute by the job (and by tests). */
    @Transactional
    public void runDueBatches() {
        for (UUID id : jdbc.queryForList("select load_id from matching_load_state where not done and next_batch_at <= ?",
                UUID.class, Timestamp.from(Instant.now(clock)))) {
            runBatch(id);
        }
    }

    void runBatch(UUID loadId) {
        Optional<LoadDirectory.LoadInfo> found = loads.find(loadId);
        Map<String, Object> state = jdbc.queryForList("select * from matching_load_state where load_id = ? for update", loadId)
                .stream().findFirst().orElse(null);
        if (state == null) {
            return;
        }
        if (found.isEmpty() || found.get().status() != LoadStatus.NOT_ACCEPTED) {
            jdbc.update("update matching_load_state set done = true where load_id = ?", loadId);
            return;
        }
        LoadDirectory.LoadInfo load = found.get();
        int radius = ((Number) state.get("radius_km")).intValue();
        int maxRadius = settings.getInt("matching.max_radius_km");
        int step = settings.getInt("matching.radius_step_km");
        int batchSize = settings.getInt(SettingKeys.MATCHING_BATCH_SIZE);
        int batchNo = ((Number) state.get("batches")).intValue() + 1;
        List<Candidate> ranked = rank(load, radius);
        // Wish-list window (M9): only wish-list drivers (relaxed radius already applied) — no widening, no "no driver" notice.
        Instant at = Instant.now(clock);
        boolean restricted = bonuses.stream().anyMatch(b -> b.restrictTo(load, at) != null);
        while (!restricted && ranked.isEmpty() && radius < maxRadius) {
            radius = Math.min(maxRadius, radius + step);
            ranked = rank(load, radius);
        }
        Instant now = Instant.now(clock);
        List<Candidate> batch = ranked.subList(0, Math.min(batchSize, ranked.size()));
        int rank = 1;
        for (Candidate c : batch) {
            jdbc.update("""
                    insert into matching_suggestion (id, load_id, driver_id, truck_id, batch_no, rank, score, preferred, status, shown_at)
                    values (?, ?, ?, ?, ?, ?, ?, ?, 'SHOWN', ?) on conflict do nothing""",
                    UUID.randomUUID(), loadId, c.driver().driverId(), c.driver().truckId(), batchNo, rank++,
                    BigDecimal.valueOf(c.score()).setScale(3, java.math.RoundingMode.HALF_UP), c.preferred(), Timestamp.from(now));
            notifier.notify(c.driver().driverId(), NotificationTab.TRIPS, c.preferred() ? "PREFERRED_SUGGESTION" : "NEW_SUGGESTION",
                    Map.of("pickup", load.pickupArea(), "drop", load.dropArea(), "amount", String.valueOf(load.agreedAmountInr())),
                    "/driver/suggestions");
        }
        boolean notify = !restricted && batch.isEmpty() && radius >= maxRadius && !Boolean.TRUE.equals(state.get("no_driver_notified"));
        if (notify) {
            notifier.notify(load.shipperId(), NotificationTab.TRIPS, "NO_DRIVER_FOUND", Map.of("code", load.code()), "/loads/" + loadId);
        }
        jdbc.update("""
                update matching_load_state set radius_km = ?, batches = ?, next_batch_at = ?, no_driver_notified = no_driver_notified or ?
                where load_id = ?""", radius, batch.isEmpty() ? batchNo - 1 : batchNo,
                Timestamp.from(now.plus(Duration.ofMinutes(settings.getInt(SettingKeys.MATCHING_BATCH_INTERVAL_MINUTES)))), notify, loadId);
    }

    @Transactional(propagation = org.springframework.transaction.annotation.Propagation.REQUIRES_NEW)
    public void stop(UUID loadId, String suggestionStatus) {
        jdbc.update("update matching_load_state set done = true where load_id = ?", loadId);
        jdbc.update("update matching_suggestion set status = ?, responded_at = ? where load_id = ? and status = 'SHOWN'",
                suggestionStatus, Timestamp.from(Instant.now(clock)), loadId);
    }

    /** Load details changed: suggestions stay, batches continue with the new details. */
    @Transactional(propagation = org.springframework.transaction.annotation.Propagation.REQUIRES_NEW)
    public void restart(UUID loadId) {
        jdbc.update("update matching_load_state set next_batch_at = ?, done = false where load_id = ?", Timestamp.from(Instant.now(clock)), loadId);
    }

    // ------------------------------------------------------------------ driver side (B-604…B-606)

    @Transactional(readOnly = true)
    public List<Map<String, Object>> suggestions(UUID driverId, String sort) {
        FleetApi.DriverContext d = fleet.driver(driverId, LocalDate.now(clock.withZone(IST)))
                .orElseThrow(() -> new ApiException(ErrorCode.FORBIDDEN, "Drivers only"));
        if (!d.onDuty() || !users.get(driverId).verified()
                || wallet.balance(d.payerUserId()) < wallet.chargeAmount(WalletApi.ChargeType.TRIP_CHARGE)) {
            return List.of();
        }
        List<Map<String, Object>> out = new ArrayList<>();
        for (Map<String, Object> s : jdbc.queryForList("select load_id, preferred from matching_suggestion where driver_id = ? and status = 'SHOWN'", driverId)) {
            loads.find((UUID) s.get("load_id")).filter(l -> l.status() == LoadStatus.NOT_ACCEPTED)
                    .ifPresent(l -> out.add(card(l, d, Boolean.TRUE.equals(s.get("preferred")))));
        }
        Comparator<Map<String, Object>> order = switch (sort == null ? "NEAREST" : sort) {
            case "AMOUNT" -> Comparator.comparing((Map<String, Object> m) -> (Long) m.get("amountInr")).reversed();
            case "EARLIEST" -> Comparator.comparing(m -> (Instant) m.get("pickupWindowStart"));
            default -> Comparator.comparing(m -> (Double) m.get("distanceToPickupKm"));
        };
        out.sort(order);
        return out;
    }

    /** Area-only card (hard rule 7): never exact pins, names or phone numbers. */
    Map<String, Object> card(LoadDirectory.LoadInfo l, FleetApi.DriverContext d, boolean preferred) {
        double km = d.lastLocation() == null ? 0 : Haversine.distanceKm(d.lastLocation(), l.pickup());
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("loadId", l.id());
        m.put("goodsType", l.goodsType());
        m.put("description", l.description());
        m.put("quantity", l.quantity());
        m.put("unit", l.quantityUnit());
        m.put("weightTonnes", l.weightTonnes());
        m.put("pickupArea", l.pickupArea());
        m.put("dropArea", l.dropArea());
        m.put("pickupWindowStart", l.pickupWindowStart());
        m.put("distanceToPickupKm", Math.round(km * 10) / 10.0);
        m.put("minutesToPickup", (int) Math.ceil(km * ROAD_FACTOR / SPEED_KMH * 60));
        m.put("deliveryEta", l.deliveryEta());
        m.put("amountInr", l.agreedAmountInr());
        m.put("shipperTrustScore", users.find(l.shipperId()).map(UserDirectory.UserView::trustScore).orElse(null));
        m.put("preferredByShipper", preferred);
        return m;
    }

    @Transactional
    public Map<String, Object> accept(UUID driverId, UUID loadId) {
        Map<String, Object> s = jdbc.queryForList("select * from matching_suggestion where load_id = ? and driver_id = ?", loadId, driverId)
                .stream().findFirst().orElseThrow(() -> ApiException.notFound("Suggestion"));
        if ("TAKEN".equals(s.get("status")) || "EXPIRED".equals(s.get("status"))) {
            throw new ApiException(ErrorCode.LOAD_TAKEN);
        }
        if (!"SHOWN".equals(s.get("status"))) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Already answered");
        }
        FleetApi.DriverContext d = fleet.driver(driverId, LocalDate.now(clock.withZone(IST))).orElseThrow();
        if (d.truckId() == null || !loads.activeForDriver(driverId).isEmpty()) {
            throw new ApiException(ErrorCode.INVALID_STATE, "You already have an active trip or no truck");
        }
        LoadDirectory.LoadInfo load = loads.get(loadId);
        if (!loads.acceptAtomically(loadId, driverId, d.truckId(), d.orgId())) {
            jdbc.update("update matching_suggestion set status = 'TAKEN', responded_at = ? where id = ?",
                    Timestamp.from(Instant.now(clock)), s.get("id"));
            throw new ApiException(ErrorCode.LOAD_TAKEN);
        }
        // Both charges in the same transaction (hard rule 2); a failure rolls back the acceptance too.
        wallet.charge(load.shipperId(), WalletApi.ChargeType.POSTING_CHARGE, loadId);
        wallet.charge(d.payerUserId(), WalletApi.ChargeType.TRIP_CHARGE, loadId);
        Timestamp now = Timestamp.from(Instant.now(clock));
        jdbc.update("update matching_suggestion set status = 'ACCEPTED', responded_at = ? where id = ?", now, s.get("id"));
        jdbc.update("update matching_suggestion set status = 'TAKEN', responded_at = ? where load_id = ? and status = 'SHOWN'", now, loadId);
        jdbc.update("update matching_load_state set done = true where load_id = ?", loadId);
        UserDirectory.UserView driver = users.get(driverId);
        notifier.notify(load.shipperId(), NotificationTab.TRIPS, "LOAD_ACCEPTED",
                Map.of("code", load.code(), "driver", driver.name(), "truck", d.truckNumber()), "/loads/" + loadId);
        String shipperName = users.find(load.shipperId()).map(UserDirectory.UserView::name).orElse("");
        sms.send(load.receiverMobile(), "RECEIVER_TRACKING", Map.of("code", load.code(), "shipper", shipperName,
                "truck", d.truckNumber()), users.find(load.shipperId()).map(UserDirectory.UserView::language)
                .orElse(com.nothing.tranix.shared.types.Language.en));
        return loads.detail(loadId, LoadDirectory.Viewer.DRIVER);
    }

    @Transactional
    public void reject(UUID driverId, UUID loadId, SuggestionRejectReason reason) {
        int n = jdbc.update("update matching_suggestion set status = 'REJECTED', reject_reason = ?, responded_at = ? where load_id = ? and driver_id = ? and status = 'SHOWN'",
                reason == null ? null : reason.name(), Timestamp.from(Instant.now(clock)), loadId, driverId);
        if (n == 0) {
            throw ApiException.notFound("Suggestion");
        }
    }

    @Transactional(readOnly = true)
    public int shownCount(UUID driverId) {
        return suggestionsSafe(driverId).size();
    }

    private List<Map<String, Object>> suggestionsSafe(UUID driverId) {
        try {
            return suggestions(driverId, null);
        } catch (ApiException e) {
            return List.of();
        }
    }

    /** For tests and the location layer: a driver's last known point. */
    GeoPoint lastLocation(UUID driverId) {
        return fleet.driver(driverId, LocalDate.now(clock.withZone(IST))).map(FleetApi.DriverContext::lastLocation).orElse(null);
    }
}
