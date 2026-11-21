package com.nothing.tranix.loads.internal;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.loads.api.LoadEvents;
import com.nothing.tranix.loads.api.PostingHooks;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.geo.GeoPoint;
import com.nothing.tranix.shared.integrations.MapsService;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.shared.types.FreightPayer;
import com.nothing.tranix.shared.types.LoadAudience;
import com.nothing.tranix.shared.types.LoadStatus;
import com.nothing.tranix.shared.types.QuantityUnit;
import com.nothing.tranix.shared.types.Role;
import com.nothing.tranix.shared.types.VehicleType;
import com.nothing.tranix.wallet.api.WalletApi;

import org.springframework.beans.factory.ObjectProvider;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

interface LoadRepository extends JpaRepository<Load, UUID> {
}

/** B-401…B-407: posting, estimate, list/detail, edit, cancel, repost and the status machine. */
@Service
public class LoadService implements LoadDirectory {

    static final EnumSet<LoadStatus> ACTIVE_FOR_DRIVER = EnumSet.of(LoadStatus.ACCEPTED, LoadStatus.WAITING_FOR_PICKUP,
            LoadStatus.AMOUNT_NEGOTIATION, LoadStatus.LOCATION_REACHED, LoadStatus.PICKED_UP, LoadStatus.TRAVELING,
            LoadStatus.ARRIVED_DESTINATION);

    private final LoadRepository loads;
    private final JdbcTemplate jdbc;
    private final MapsService maps;
    private final Settings settings;
    private final UserDirectory users;
    private final WalletApi wallet;
    private final ApplicationEventPublisher events;
    private final ObjectProvider<PostingHooks.AudienceValidator> audienceValidator;
    private final ObjectProvider<PostingHooks.FarmerValidator> farmerValidator;
    private final ObjectProvider<LoadEvents.DetailContributor> contributors;
    private final Clock clock;

    @jakarta.persistence.PersistenceContext
    private jakarta.persistence.EntityManager entityManager;

    LoadService(LoadRepository loads, JdbcTemplate jdbc, MapsService maps, Settings settings, UserDirectory users,
                WalletApi wallet, ApplicationEventPublisher events,
                ObjectProvider<PostingHooks.AudienceValidator> audienceValidator,
                ObjectProvider<PostingHooks.FarmerValidator> farmerValidator,
                ObjectProvider<LoadEvents.DetailContributor> contributors, Clock clock) {
        this.loads = loads;
        this.jdbc = jdbc;
        this.maps = maps;
        this.settings = settings;
        this.users = users;
        this.wallet = wallet;
        this.events = events;
        this.audienceValidator = audienceValidator;
        this.farmerValidator = farmerValidator;
        this.contributors = contributors;
        this.clock = clock;
    }

    // ------------------------------------------------------------------ estimate (B-402)

    public record Estimate(double distanceKm, int driveMinutes, Instant deliveryEta, Map<String, Long> suggestedAmountRange) {
    }

    @Transactional(readOnly = true)
    public Estimate estimate(GeoPoint pickup, GeoPoint drop, Instant pickupWindowStart, VehicleType vehicleType) {
        MapsService.RouteEstimate r = maps.route(pickup, drop);
        Instant eta = pickupWindowStart.plus(Duration.ofMinutes(r.driveMinutes() + settings.getInt("loads.loading_buffer_minutes")));
        return new Estimate(r.distanceKm(), r.driveMinutes(), eta, suggestedRange(r.distanceKm(), vehicleType));
    }

    /** From past delivered trips with a similar distance (±20 %); needs at least 3 trips. */
    private Map<String, Long> suggestedRange(double km, VehicleType vehicleType) {
        String sql = "select agreed_amount_inr from loads_load where status = 'DELIVERED' and distance_km between ? and ?"
                + (vehicleType == null ? "" : " and vehicle_type = ?") + " order by delivered_at desc limit 50";
        List<Long> amounts = vehicleType == null
                ? jdbc.queryForList(sql, Long.class, km * 0.8, km * 1.2)
                : jdbc.queryForList(sql, Long.class, km * 0.8, km * 1.2, vehicleType.name());
        if (amounts.size() < 3) {
            return null;
        }
        List<Long> sorted = amounts.stream().sorted().toList();
        long low = sorted.get(sorted.size() / 4);
        long high = sorted.get(Math.min(sorted.size() - 1, sorted.size() * 3 / 4));
        return Map.of("minInr", low / 100 * 100, "maxInr", (high + 99) / 100 * 100);
    }

    // ------------------------------------------------------------------ create / update (B-403, B-405)

    public record PlaceInput(double lat, double lng, String address, String landmark) {
    }

    public record LoadInput(Instant pickupWindowStart, Instant pickupWindowEnd, PlaceInput pickup, String senderName,
                            String senderMobile, String goodsType, String description, BigDecimal quantity,
                            QuantityUnit quantityUnit, BigDecimal weightTonnes, VehicleType vehicleType, PlaceInput drop,
                            String receiverName, String receiverMobile, FreightPayer freightPaidBy, long amountInr,
                            UUID postedForFarmerId, LoadAudience audience, List<UUID> wishlistEntryIds) {
    }

    @Transactional
    public Map<String, Object> create(UUID shipperId, LoadInput in) {
        UserDirectory.UserView shipper = requireShipper(shipperId);
        if (!wallet.hasBalance(shipperId, WalletApi.ChargeType.POSTING_CHARGE)) {
            throw new ApiException(ErrorCode.INSUFFICIENT_BALANCE,
                    "Posting needs ₹" + wallet.chargeAmount(WalletApi.ChargeType.POSTING_CHARGE));
        }
        String code = "TRX-" + String.format("%06d", jdbc.queryForObject("select nextval('loads_code_seq')", Long.class));
        Load load = new Load(code, shipperId);
        apply(load, shipper, in);
        loads.saveAndFlush(load);
        timeline(load.getId(), LoadStatus.NOT_ACCEPTED, shipperId);
        events.publishEvent(new LoadEvents.LoadPosted(load.getId(), shipperId));
        return detail(load, Viewer.SHIPPER);
    }

    @Transactional
    public Map<String, Object> update(UUID shipperId, UUID loadId, LoadInput in) {
        Load load = owned(shipperId, loadId);
        if (load.getStatus() != LoadStatus.NOT_ACCEPTED) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Only a load that is not accepted can be edited");
        }
        apply(load, requireShipper(shipperId), in);
        events.publishEvent(new LoadEvents.LoadUpdated(loadId));
        return detail(load, Viewer.SHIPPER);
    }

    private void apply(Load load, UserDirectory.UserView shipper, LoadInput in) {
        Instant now = Instant.now(clock);
        if (!in.pickupWindowStart().isAfter(now.minus(Duration.ofMinutes(5)))) {
            throw ApiException.invalidField("pickupWindowStart", "Pick a time in the future");
        }
        if (!in.pickupWindowEnd().isAfter(in.pickupWindowStart())) {
            throw ApiException.invalidField("pickupWindowEnd", "End must be after start");
        }
        if (in.weightTonnes().compareTo(BigDecimal.valueOf(settings.getInt("loads.max_weight_tonnes"))) > 0) {
            throw ApiException.invalidField("weightTonnes", "Too heavy for one truck");
        }
        if (!settings.getStringList("lists.goods_types").contains(in.goodsType())) {
            throw ApiException.invalidField("goodsType", "Choose a goods type from the list");
        }
        String senderName = in.senderName();
        String senderMobile = in.senderMobile();
        UUID farmerId = in.postedForFarmerId();
        if (farmerId != null) {
            if (shipper.role() != Role.FARMER_NETWORK) {
                throw ApiException.invalidField("postedForFarmerId", "Only a Farmer Network can post for a farmer");
            }
            PostingHooks.FarmerValidator v = farmerValidator.getIfAvailable();
            if (v == null) {
                throw ApiException.invalidField("postedForFarmerId", "Unknown farmer");
            }
            PostingHooks.FarmerSender f = v.sender(shipper.id(), farmerId);
            senderName = f.name();   // sender = farmer (locked), FN-03
            senderMobile = f.mobile();
        }
        GeoPoint p = GeoPoint.of(in.pickup().lat(), in.pickup().lng());
        GeoPoint d = GeoPoint.of(in.drop().lat(), in.drop().lng());
        load.place(p.lat(), p.lng(), in.pickup().address(), in.pickup().landmark(), maps.area(p, in.pickup().address()),
                d.lat(), d.lng(), in.drop().address(), in.drop().landmark(), maps.area(d, in.drop().address()));
        UUID receiverUser = users.findByMobile(in.receiverMobile()).filter(u -> u.role() == Role.RECEIVER)
                .map(UserDirectory.UserView::id).orElse(null);
        load.details(in.pickupWindowStart(), in.pickupWindowEnd(), senderName, senderMobile, in.receiverName(),
                in.receiverMobile(), receiverUser, in.goodsType(), in.description(), in.quantity(), in.quantityUnit(),
                in.weightTonnes(), in.vehicleType(), in.freightPaidBy(), in.amountInr(), farmerId);
        Estimate e = estimate(p, d, in.pickupWindowStart(), null);
        load.estimate(BigDecimal.valueOf(e.distanceKm()).setScale(1, RoundingMode.HALF_UP), e.driveMinutes(), e.deliveryEta());
        LoadAudience audience = in.audience() == null ? LoadAudience.EVERYONE : in.audience();
        if (audience == LoadAudience.EVERYONE) {
            load.audience(audience, null, null);
        } else {
            PostingHooks.AudienceValidator v = audienceValidator.getIfAvailable();
            if (v == null) {
                throw new ApiException(ErrorCode.WISHLIST_EMPTY, "Your wish list has no usable entries");
            }
            PostingHooks.Audience a = v.resolve(shipper.id(), audience, in.wishlistEntryIds(), now);
            load.audience(audience, a.entryIds().stream().map(UUID::toString).collect(Collectors.joining(",")), a.wishlistUntil());
        }
    }

    // ------------------------------------------------------------------ list / detail (B-404)

    @Transactional(readOnly = true)
    public Map<String, Object> list(UUID shipperId, boolean ongoing, UUID farmerId, String q, int page, int size) {
        requireShipper(shipperId);
        StringBuilder where = new StringBuilder(" from loads_load where shipper_id = ?");
        List<Object> args = new ArrayList<>(List.of(shipperId));
        where.append(ongoing ? " and closed_at is null and status <> 'CANCELLED'" : " and (closed_at is not null or status = 'CANCELLED')");
        if (farmerId != null) {
            where.append(" and posted_for_farmer_id = ?");
            args.add(farmerId);
        }
        if (q != null && !q.isBlank()) {
            where.append(" and (code ilike ? or goods_type ilike ? or pickup_area ilike ? or drop_area ilike ?)");
            String like = "%" + q.trim() + "%";
            args.addAll(List.of(like, like, like, like));
        }
        long total = jdbc.queryForObject("select count(*)" + where, Long.class, args.toArray());
        List<Object> pageArgs = new ArrayList<>(args);
        pageArgs.add(size);
        pageArgs.add((long) page * size);
        List<UUID> ids = jdbc.queryForList("select id" + where + " order by pickup_window_start " + (ongoing ? "asc" : "desc")
                + " limit ? offset ?", UUID.class, pageArgs.toArray());
        List<Map<String, Object>> items = loads.findAllById(ids).stream()
                .sorted((a, b) -> ids.indexOf(a.getId()) - ids.indexOf(b.getId()))
                .map(l -> summary(info(l))).toList();
        return Map.of("items", items, "page", page, "size", size, "total", total);
    }

    @Transactional(readOnly = true)
    public Map<String, Object> shipperDetail(UUID shipperId, UUID loadId) {
        return detail(owned(shipperId, loadId), Viewer.SHIPPER);
    }

    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> detail(UUID loadId, Viewer viewer) {
        return detail(loads.findById(loadId).orElseThrow(() -> ApiException.notFound("Load")), viewer);
    }

    Map<String, Object> summary(LoadInfo l) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", l.id());
        m.put("code", l.code());
        m.put("status", l.status());
        m.put("goodsType", l.goodsType());
        m.put("description", l.description());
        m.put("quantity", l.quantity());
        m.put("quantityUnit", l.quantityUnit());
        m.put("pickupArea", l.pickupArea());
        m.put("dropArea", l.dropArea());
        m.put("pickupWindowStart", l.pickupWindowStart());
        m.put("agreedAmountInr", l.agreedAmountInr());
        m.put("paymentStatus", null);
        m.put("postedForFarmerName", l.postedForFarmerId() == null ? null : l.senderName()); // farmer = locked sender (FN-03)
        for (LoadEvents.DetailContributor c : contributors.orderedStream().toList()) {
            c.contribute(l, Viewer.SHIPPER, m);
        }
        m.keySet().retainAll(List.of("id", "code", "status", "goodsType", "description", "quantity", "quantityUnit",
                "pickupArea", "dropArea", "pickupWindowStart", "agreedAmountInr", "paymentStatus", "postedForFarmerName"));
        return m;
    }

    Map<String, Object> detail(Load load, Viewer viewer) {
        LoadInfo l = info(load);
        Map<String, Object> m = new LinkedHashMap<>(summary(l));
        m.put("pickup", place(load.getPickupLat(), load.getPickupLng(), load.getPickupAddress(), load.getPickupLandmark()));
        m.put("drop", place(load.getDropLat(), load.getDropLng(), load.getDropAddress(), load.getDropLandmark()));
        m.put("senderName", l.senderName());
        m.put("senderMobile", l.senderMobile());
        m.put("receiverName", l.receiverName());
        m.put("receiverMobile", l.receiverMobile());
        m.put("weightTonnes", l.weightTonnes());
        m.put("vehicleType", l.vehicleType());
        m.put("freightPaidBy", l.freightPaidBy());
        m.put("postedAmountInr", l.postedAmountInr());
        m.put("deliveryEta", l.deliveryEta());
        m.put("timeline", jdbc.query("select status, at from loads_timeline where load_id = ? order by at, id",
                (rs, i) -> Map.of("status", rs.getString("status"), "at", rs.getTimestamp("at").toInstant()), l.id()));
        m.put("driver", null);
        m.put("revisions", List.of());
        m.put("revisionsUsed", 0);
        m.put("payment", null);
        m.put("otpEvents", List.of());
        m.put("locationExceptions", List.of());
        boolean shipper = viewer == Viewer.SHIPPER;
        m.put("canEdit", shipper && l.status() == LoadStatus.NOT_ACCEPTED);
        m.put("canCancel", shipper && Load.CANCELLABLE.contains(l.status()));
        m.put("cancelInfo", shipper ? cancelInfo(l.status()) : null);
        m.put("audience", l.audience());
        m.put("wishlistUntil", l.wishlistUntil());
        m.put("openedToEveryoneAt", load.getOpenedToEveryoneAt());
        for (LoadEvents.DetailContributor c : contributors.orderedStream().toList()) {
            c.contribute(l, viewer, m);
        }
        return m;
    }

    private static Map<String, Object> place(double lat, double lng, String address, String landmark) {
        Map<String, Object> p = new LinkedHashMap<>();
        p.put("lat", lat);
        p.put("lng", lng);
        p.put("address", address);
        p.put("landmark", landmark);
        return p;
    }

    /** What happens if the shipper cancels now (§11), shown before confirming. */
    private Map<String, Object> cancelInfo(LoadStatus status) {
        Map<String, Object> m = new HashMap<>();
        if (status == LoadStatus.NOT_ACCEPTED) {
            m.put("chargesKept", false);
            m.put("trustScorePenalty", 0);
            m.put("supportOnly", false);
        } else if (Load.CANCELLABLE.contains(status)) {
            m.put("chargesKept", true);
            m.put("trustScorePenalty", settings.getDecimal("trust.points.cancel_own_fault"));
            m.put("supportOnly", false);
        } else {
            m.put("chargesKept", true);
            m.put("trustScorePenalty", null);
            m.put("supportOnly", status != LoadStatus.DELIVERED && status != LoadStatus.CANCELLED);
        }
        return m;
    }

    // ------------------------------------------------------------------ cancel / repost (B-406)

    @Override
    @Transactional
    public Map<String, Object> cancel(UUID userId, UUID loadId, String reason, String note) {
        UserDirectory.UserView user = users.get(userId);
        Load load = loads.findById(loadId).orElseThrow(() -> ApiException.notFound("Load"));
        boolean isShipper = load.getShipperId().equals(userId);
        boolean isDriver = userId.equals(load.getDriverId());
        if (!isShipper && !isDriver) {
            throw ApiException.notFound("Load");
        }
        List<String> reasons = settings.getStringList(isShipper ? "lists.cancel_reasons_shipper" : "lists.cancel_reasons_driver");
        if (reason == null || !reasons.contains(reason)) {
            throw ApiException.invalidField("reason", "Choose a reason");
        }
        if ("OTHER".equals(reason) && (note == null || note.isBlank())) {
            throw ApiException.invalidField("note", "Tell us the reason");
        }
        LoadStatus stage = load.getStatus();
        if (Load.AFTER_PICKUP.contains(stage)) {
            throw new ApiException(ErrorCode.INVALID_STATE, "After pickup, cancel only through Support");
        }
        if (isDriver && stage == LoadStatus.NOT_ACCEPTED) {
            throw ApiException.notFound("Load");
        }
        Instant now = Instant.now(clock);
        load.transition(LoadStatus.CANCELLED, now);
        timeline(loadId, LoadStatus.CANCELLED, userId);
        boolean accepted = stage != LoadStatus.NOT_ACCEPTED;
        boolean otherAtFault = settings.getStringList("lists.counterparty_fault_reasons").contains(reason);
        BigDecimal penalty = accepted && !otherAtFault ? settings.getDecimal("trust.points.cancel_own_fault") : BigDecimal.ZERO;
        jdbc.update("""
                insert into loads_cancellation (id, load_id, by_user_id, by_role, stage, reason, note, charges_kept, penalty_points, created_at)
                values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                UUID.randomUUID(), loadId, userId, user.role().name(), stage.name(), reason, note, accepted, penalty,
                Timestamp.from(now));
        events.publishEvent(new LoadEvents.StatusChanged(loadId, stage, LoadStatus.CANCELLED, userId));
        events.publishEvent(new LoadEvents.LoadCancelled(loadId, userId, user.role(), stage, reason, accepted, penalty,
                load.getShipperId(), load.getDriverId()));
        return detail(load, isShipper ? Viewer.SHIPPER : Viewer.DRIVER);
    }

    /** "Post again": copies the load; a past pickup window moves to the same time tomorrow or later. */
    @Transactional
    public Map<String, Object> repost(UUID shipperId, UUID loadId) {
        Load o = owned(shipperId, loadId);
        if (o.getStatus() == LoadStatus.NOT_ACCEPTED) {
            throw new ApiException(ErrorCode.INVALID_STATE, "This load is still open");
        }
        Instant now = Instant.now(clock);
        Duration window = Duration.between(o.getPickupWindowStart(), o.getPickupWindowEnd());
        Instant start = o.getPickupWindowStart();
        while (!start.isAfter(now.plus(Duration.ofHours(1)))) {
            start = start.plus(Duration.ofDays(1));
        }
        LoadInput in = new LoadInput(start, start.plus(window),
                new PlaceInput(o.getPickupLat(), o.getPickupLng(), o.getPickupAddress(), o.getPickupLandmark()),
                o.getSenderName(), o.getSenderMobile(), o.getGoodsType(), o.getDescription(), o.getQuantity(),
                o.getQuantityUnit(), o.getWeightTonnes(), o.getVehicleType(),
                new PlaceInput(o.getDropLat(), o.getDropLng(), o.getDropAddress(), o.getDropLandmark()),
                o.getReceiverName(), o.getReceiverMobile(), o.getFreightPaidBy(), o.getPostedAmountInr(),
                o.getPostedForFarmerId(), LoadAudience.EVERYONE, null);
        return create(shipperId, in);
    }

    // ------------------------------------------------------------------ LoadDirectory

    @Override
    @Transactional(readOnly = true)
    public Optional<LoadInfo> find(UUID loadId) {
        return loads.findById(loadId).map(LoadService::info);
    }

    @Override
    public LoadInfo get(UUID loadId) {
        return find(loadId).orElseThrow(() -> ApiException.notFound("Load"));
    }

    @Override
    @Transactional
    public void transition(UUID loadId, LoadStatus next, UUID actorId) {
        Load load = loads.findById(loadId).orElseThrow(() -> ApiException.notFound("Load"));
        LoadStatus previous = load.transition(next, Instant.now(clock));
        timeline(loadId, next, actorId);
        events.publishEvent(new LoadEvents.StatusChanged(loadId, previous, next, actorId));
    }

    @Override
    @Transactional
    public void setAgreedAmount(UUID loadId, long amountInr) {
        loads.findById(loadId).orElseThrow(() -> ApiException.notFound("Load")).setAgreedAmountInr(amountInr);
    }

    @Override
    @Transactional
    public void setDeliveryEta(UUID loadId, Instant eta) {
        loads.findById(loadId).orElseThrow(() -> ApiException.notFound("Load")).setDeliveryEta(eta);
    }

    @Override
    @Transactional
    public void close(UUID loadId) {
        loads.findById(loadId).orElseThrow(() -> ApiException.notFound("Load")).close(Instant.now(clock));
    }

    @Override
    @Transactional(readOnly = true)
    public List<LoadInfo> activeForDriver(UUID driverId) {
        List<UUID> ids = jdbc.queryForList("select id from loads_load where driver_id = ? and status in ("
                + ACTIVE_FOR_DRIVER.stream().map(s -> "'" + s + "'").collect(Collectors.joining(",")) + ")", UUID.class, driverId);
        return loads.findAllById(ids).stream().map(LoadService::info).toList();
    }

    @Override
    @Transactional
    public boolean acceptAtomically(UUID loadId, UUID driverId, UUID truckId, UUID orgId) {
        Timestamp now = Timestamp.from(Instant.now(clock));
        int updated = jdbc.update("""
                update loads_load set status = 'WAITING_FOR_PICKUP', driver_id = ?, truck_id = ?, org_id = ?, accepted_at = ?,
                updated_at = ?, version = version + 1 where id = ? and status = 'NOT_ACCEPTED'""",
                driverId, truckId, orgId, now, now, loadId);
        if (updated == 0) {
            return false;
        }
        // the row changed underneath the persistence context — reload it
        loads.findById(loadId).ifPresent(entityManager::refresh);
        timeline(loadId, LoadStatus.ACCEPTED, driverId);
        timeline(loadId, LoadStatus.WAITING_FOR_PICKUP, driverId);
        events.publishEvent(new LoadEvents.StatusChanged(loadId, LoadStatus.NOT_ACCEPTED, LoadStatus.WAITING_FOR_PICKUP, driverId));
        return true;
    }

    @Override
    @Transactional(readOnly = true)
    public List<UUID> openLoadIds() {
        return jdbc.queryForList("select id from loads_load where status = 'NOT_ACCEPTED'", UUID.class);
    }

    @Override
    @Transactional(readOnly = true)
    public List<LoadInfo> activeForTruck(UUID truckId) {
        List<UUID> ids = jdbc.queryForList("select id from loads_load where truck_id = ? and status in ("
                + ACTIVE_FOR_DRIVER.stream().map(s -> "'" + s + "'").collect(Collectors.joining(",")) + ")", UUID.class, truckId);
        return loads.findAllById(ids).stream().map(LoadService::info).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> forOrg(UUID orgId, UUID driverId, UUID truckId, Instant from, Instant to,
                                            LoadStatus status, int limit) {
        StringBuilder sql = new StringBuilder("select id from loads_load where org_id = ?");
        List<Object> args = new ArrayList<>(List.of(orgId));
        if (driverId != null) { sql.append(" and driver_id = ?"); args.add(driverId); }
        if (truckId != null) { sql.append(" and truck_id = ?"); args.add(truckId); }
        if (from != null) { sql.append(" and pickup_window_start >= ?"); args.add(Timestamp.from(from)); }
        if (to != null) { sql.append(" and pickup_window_start < ?"); args.add(Timestamp.from(to)); }
        if (status != null) { sql.append(" and status = ?"); args.add(status.name()); }
        sql.append(" order by pickup_window_start desc limit ?");
        args.add(limit);
        List<UUID> ids = jdbc.queryForList(sql.toString(), UUID.class, args.toArray());
        return loads.findAllById(ids).stream().sorted((a, b) -> ids.indexOf(a.getId()) - ids.indexOf(b.getId()))
                .map(l -> {
                    Map<String, Object> m = new LinkedHashMap<>(summary(info(l)));
                    m.put("driverId", l.getDriverId());
                    m.put("truckId", l.getTruckId());
                    return m;
                }).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> historyForDriver(UUID driverId, Instant from, Instant to, int limit) {
        List<UUID> ids = jdbc.queryForList("""
                select id from loads_load where driver_id = ? and (status = 'DELIVERED' or status = 'CANCELLED')
                and pickup_window_start >= ? and pickup_window_start < ? order by pickup_window_start desc limit ?""",
                UUID.class, driverId, Timestamp.from(from), Timestamp.from(to), limit);
        return loads.findAllById(ids).stream().sorted((a, b) -> ids.indexOf(a.getId()) - ids.indexOf(b.getId()))
                .map(l -> new LinkedHashMap<>(summary(info(l)))).map(m -> (Map<String, Object>) m).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public DriverStats driverStats(UUID driverId) {
        return jdbc.queryForObject("""
                select count(*) filter (where status = 'DELIVERED') delivered,
                       count(*) filter (where status = 'DELIVERED' and delivered_at <= delivery_eta) on_time,
                       coalesce(sum(agreed_amount_inr) filter (where status = 'DELIVERED'), 0) agreed,
                       (select count(*) from loads_cancellation c where c.by_user_id = ?) cancelled
                from loads_load where driver_id = ?""",
                (rs, i) -> new DriverStats(rs.getLong("delivered"), rs.getLong("on_time"), rs.getLong("cancelled"),
                        rs.getLong("agreed")), driverId, driverId);
    }

    void timeline(UUID loadId, LoadStatus status, UUID actorId) {
        jdbc.update("insert into loads_timeline (id, load_id, status, at, actor_id) values (?, ?, ?, ?, ?)",
                UUID.randomUUID(), loadId, status.name(), Timestamp.from(Instant.now(clock)), actorId);
    }

    // ------------------------------------------------------------------ wish list support (M9)

    @Override
    @Transactional(readOnly = true)
    public List<PastTrip> pastTripsOfShipper(UUID shipperId) {
        return jdbc.query("""
                select id, truck_id, org_id, driver_id, coalesce(delivered_at, cancelled_at, accepted_at) at from loads_load
                where shipper_id = ? and truck_id is not null and (status = 'DELIVERED' or status = 'CANCELLED')
                order by at desc""",
                (rs, i) -> new PastTrip(rs.getObject(1, UUID.class), rs.getObject(2, UUID.class), rs.getObject(3, UUID.class),
                        rs.getObject(4, UUID.class), rs.getTimestamp(5).toInstant()), shipperId);
    }

    /** Shipper button: {@code POST /loads/{id}/open-to-everyone}. */
    @Transactional
    public Map<String, Object> openToEveryone(UUID shipperId, UUID loadId) {
        Load load = owned(shipperId, loadId);
        if (load.getStatus() != LoadStatus.NOT_ACCEPTED || load.getAudience() == LoadAudience.EVERYONE) {
            throw new ApiException(ErrorCode.INVALID_STATE, "This load is already open to everyone");
        }
        load.openToEveryone(Instant.now(clock));
        events.publishEvent(new LoadEvents.LoadUpdated(loadId));
        return detail(load, Viewer.SHIPPER);
    }

    @Override
    @Transactional
    public void openToEveryone(UUID loadId) {
        loads.findById(loadId).filter(l -> l.getStatus() == LoadStatus.NOT_ACCEPTED && l.getAudience() != LoadAudience.EVERYONE)
                .ifPresent(l -> {
                    l.openToEveryone(Instant.now(clock));
                    events.publishEvent(new LoadEvents.LoadUpdated(loadId));
                });
    }

    @Override
    @Transactional(readOnly = true)
    public List<LoadInfo> openWishlistLoads() {
        return loads.findAllById(jdbc.queryForList(
                "select id from loads_load where status = 'NOT_ACCEPTED' and audience <> 'EVERYONE'", UUID.class))
                .stream().map(LoadService::info).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<Map<String, Object>> forReceiver(UUID receiverUserId, boolean ongoing) {
        List<UUID> ids = jdbc.queryForList("select id from loads_load where receiver_user_id = ? and status <> 'NOT_ACCEPTED' and "
                + (ongoing ? "status not in ('DELIVERED','CANCELLED')" : "status in ('DELIVERED','CANCELLED')")
                + " order by pickup_window_start desc limit 200", UUID.class, receiverUserId);
        return loads.findAllById(ids).stream().sorted((a, b) -> ids.indexOf(a.getId()) - ids.indexOf(b.getId())).map(l -> {
            Map<String, Object> m = new LinkedHashMap<>(summary(info(l)));
            m.put("deliveryEta", l.getDeliveryEta());
            return m;
        }).toList();
    }

    @Override
    @Transactional
    public Map<String, Object> adminCancel(UUID loadId, UUID adminId, String reason) {
        Load load = loads.findById(loadId).orElseThrow(() -> ApiException.notFound("Load"));
        Instant now = Instant.now(clock);
        LoadStatus stage = load.cancelByAdmin(now);
        timeline(loadId, LoadStatus.CANCELLED, adminId);
        boolean accepted = stage != LoadStatus.NOT_ACCEPTED;
        jdbc.update("""
                insert into loads_cancellation (id, load_id, by_user_id, by_role, stage, reason, note, charges_kept, penalty_points, created_at)
                values (?, ?, ?, 'ADMIN', ?, 'ADMIN', ?, ?, 0, ?)""",
                UUID.randomUUID(), loadId, adminId, stage.name(), reason, accepted, Timestamp.from(now));
        events.publishEvent(new LoadEvents.StatusChanged(loadId, stage, LoadStatus.CANCELLED, adminId));
        events.publishEvent(new LoadEvents.LoadCancelled(loadId, adminId, Role.ADMIN, stage, "ADMIN", accepted, BigDecimal.ZERO,
                load.getShipperId(), load.getDriverId()));
        return detail(load, Viewer.ADMIN);
    }

    private Load owned(UUID shipperId, UUID loadId) {
        return loads.findById(loadId).filter(l -> l.getShipperId().equals(shipperId))
                .orElseThrow(() -> ApiException.notFound("Load"));
    }

    private UserDirectory.UserView requireShipper(UUID userId) {
        UserDirectory.UserView u = users.get(userId);
        if (u.role() != Role.LOAD_PROVIDER && u.role() != Role.FARMER_NETWORK) {
            throw new ApiException(ErrorCode.FORBIDDEN, "Only Load Providers and Farmer Networks post loads");
        }
        return u;
    }

    static LoadInfo info(Load l) {
        List<UUID> entries = l.getWishlistEntryIds() == null || l.getWishlistEntryIds().isBlank() ? List.of()
                : Arrays.stream(l.getWishlistEntryIds().split(",")).map(UUID::fromString).toList();
        return new LoadInfo(l.getId(), l.getCode(), l.getShipperId(), l.getPostedForFarmerId(), l.getStatus(), l.getDriverId(),
                l.getTruckId(), l.getOrgId(), GeoPoint.of(l.getPickupLat(), l.getPickupLng()),
                GeoPoint.of(l.getDropLat(), l.getDropLng()), l.getPickupArea(), l.getDropArea(), l.getPickupWindowStart(),
                l.getPickupWindowEnd(), l.getGoodsType(), l.getDescription(), l.getQuantity(), l.getQuantityUnit(),
                l.getWeightTonnes(), l.getVehicleType(), l.getFreightPaidBy(), l.getPostedAmountInr(), l.getAgreedAmountInr(),
                l.getSenderName(), l.getSenderMobile(), l.getReceiverName(), l.getReceiverMobile(), l.getReceiverUserId(),
                l.getDistanceKm(), l.getDriveMinutes(), l.getDeliveryEta(), l.getAudience(), entries, l.getWishlistUntil(),
                l.getAcceptedAt(), l.getPickedUpAt(), l.getDeliveredAt(), l.getClosedAt(), l.getCreatedAt());
    }
}
