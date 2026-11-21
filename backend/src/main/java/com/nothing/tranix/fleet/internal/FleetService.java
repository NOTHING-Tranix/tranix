package com.nothing.tranix.fleet.internal;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import com.nothing.tranix.fleet.api.FleetApi;
import com.nothing.tranix.identity.api.DocumentRegistry;
import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.geo.GeoPoint;
import com.nothing.tranix.shared.types.DocumentType;
import com.nothing.tranix.shared.types.Role;
import com.nothing.tranix.shared.types.TruckStatus;
import com.nothing.tranix.shared.types.VehicleType;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Trucks (B-501, B-502), truck status, driver duty/home (B-505) and the {@link FleetApi} for other modules. */
@Service
public class FleetService implements FleetApi {

    static final ZoneId IST = ZoneId.of("Asia/Kolkata");
    static final List<DocumentType> TRUCK_DOCS = List.of(DocumentType.RC, DocumentType.INSURANCE, DocumentType.NATIONAL_PERMIT);
    /** Indian registration number, e.g. TN57AB1234 (spaces removed). */
    static final String TRUCK_NUMBER = "^[A-Z]{2}[0-9]{1,2}[A-Z]{0,3}[0-9]{4}$";

    final JdbcTemplate jdbc;
    final UserDirectory users;
    final DocumentRegistry documents;
    final LoadDirectory loads;
    final Clock clock;

    FleetService(JdbcTemplate jdbc, UserDirectory users, DocumentRegistry documents, LoadDirectory loads, Clock clock) {
        this.jdbc = jdbc;
        this.users = users;
        this.documents = documents;
        this.loads = loads;
        this.clock = clock;
    }

    record Truck(UUID id, String ownerType, UUID ownerId, String number, VehicleType vehicleType, BigDecimal capacity,
                 boolean active) {
    }

    static final RowMapper<Truck> TRUCK = (rs, i) -> new Truck(rs.getObject("id", UUID.class), rs.getString("owner_type"),
            rs.getObject("owner_id", UUID.class), rs.getString("number"), VehicleType.valueOf(rs.getString("vehicle_type")),
            rs.getBigDecimal("capacity_tonnes"), rs.getBoolean("active"));

    LocalDate today() {
        return LocalDate.now(clock.withZone(IST));
    }

    // ------------------------------------------------------------------ trucks

    static String normaliseNumber(String number) {
        String n = number == null ? "" : number.replaceAll("[\\s-]", "").toUpperCase();
        if (!n.matches(TRUCK_NUMBER)) {
            throw ApiException.invalidField("number", "Enter a valid truck number, e.g. TN57AB1234");
        }
        return n;
    }

    Truck insertTruck(String ownerType, UUID ownerId, String number, VehicleType type, BigDecimal capacity) {
        if (type == VehicleType.ANY) {
            throw ApiException.invalidField("vehicleType", "Choose the truck body type");
        }
        if (capacity == null || capacity.signum() <= 0 || capacity.compareTo(BigDecimal.valueOf(60)) > 0) {
            throw ApiException.invalidField("capacityTonnes", "Enter capacity between 1 and 60 tonnes");
        }
        UUID id = UUID.randomUUID();
        Timestamp now = Timestamp.from(Instant.now(clock));
        try {
            jdbc.update("""
                    insert into fleet_truck (id, owner_type, owner_id, number, vehicle_type, capacity_tonnes, active, created_at, updated_at, version)
                    values (?, ?, ?, ?, ?, ?, true, ?, ?, 0)""", id, ownerType, ownerId, normaliseNumber(number), type.name(),
                    capacity, now, now);
        } catch (DuplicateKeyException e) {
            if (e.getMessage() != null && e.getMessage().contains("fleet_truck_one_per_driver")) {
                throw new ApiException(ErrorCode.INVALID_STATE, "An owner-driver can have one truck only");
            }
            throw ApiException.invalidField("number", "This truck is already registered");
        }
        return truckRow(id).orElseThrow();
    }

    void updateTruck(Truck t, String number, VehicleType type, BigDecimal capacity) {
        if (!loads.activeForTruck(t.id()).isEmpty()) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Truck is on a trip");
        }
        if (type == VehicleType.ANY) {
            throw ApiException.invalidField("vehicleType", "Choose the truck body type");
        }
        try {
            jdbc.update("update fleet_truck set number = ?, vehicle_type = ?, capacity_tonnes = ?, updated_at = ?, version = version + 1 where id = ?",
                    normaliseNumber(number), type.name(), capacity, Timestamp.from(Instant.now(clock)), t.id());
        } catch (DuplicateKeyException e) {
            throw ApiException.invalidField("number", "This truck is already registered");
        }
    }

    Optional<Truck> truckRow(UUID id) {
        return jdbc.query("select * from fleet_truck where id = ?", TRUCK, id).stream().findFirst();
    }

    Optional<Truck> ownTruck(UUID driverId) {
        return jdbc.query("select * from fleet_truck where owner_type = 'DRIVER' and owner_id = ? and active", TRUCK, driverId)
                .stream().findFirst();
    }

    Optional<UUID> liveAllocationTruck(UUID driverId, boolean activeOnly) {
        return jdbc.queryForList("select truck_id from fleet_allocation where driver_id = ? and status "
                + (activeOnly ? "= 'ACTIVE'" : "<> 'REMOVED'"), UUID.class, driverId).stream().findFirst();
    }

    Optional<UUID> orgOf(UUID driverId) {
        return jdbc.queryForList("select org_id from fleet_org_driver where driver_id = ? and removed_at is null", UUID.class, driverId)
                .stream().findFirst();
    }

    boolean docsValid(UUID truckId) {
        return documents.allApprovedAndValid(DocumentRegistry.Owner.TRUCK, truckId, TRUCK_DOCS, today());
    }

    TruckStatus status(Truck t) {
        if (!t.active()) {
            return TruckStatus.INACTIVE;
        }
        if (!docsValid(t.id())) {
            return TruckStatus.DOCUMENTS_PENDING;
        }
        if (!loads.activeForTruck(t.id()).isEmpty()) {
            return TruckStatus.ON_TRIP;
        }
        if ("ORG".equals(t.ownerType()) && !jdbc.queryForList(
                "select id from fleet_allocation where truck_id = ? and status = 'ACTIVE'", UUID.class, t.id()).isEmpty()) {
            return TruckStatus.ALLOCATED;
        }
        return TruckStatus.AVAILABLE;
    }

    Map<String, Object> truckView(Truck t) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", t.id());
        m.put("number", t.number());
        m.put("vehicleType", t.vehicleType());
        m.put("capacityTonnes", t.capacity());
        m.put("status", status(t));
        m.put("documents", documents.list(DocumentRegistry.Owner.TRUCK, t.id()));
        List<Map<String, Object>> driver = jdbc.queryForList(
                "select driver_id from fleet_allocation where truck_id = ? and status <> 'REMOVED'", t.id());
        m.put("allocatedDriver", driver.isEmpty() ? null : users.find((UUID) driver.getFirst().get("driver_id"))
                .map(u -> Map.of("id", u.id(), "name", u.name())).orElse(null));
        return m;
    }

    // ------------------------------------------------------------------ owner-driver truck (B-501)

    UserDirectory.UserView requireDriver(UUID userId) {
        UserDirectory.UserView u = users.get(userId);
        if (u.role() != Role.DRIVER) {
            throw new ApiException(ErrorCode.FORBIDDEN, "Drivers only");
        }
        return u;
    }

    @Transactional
    public Map<String, Object> createOwnTruck(UUID driverId, String number, VehicleType type, BigDecimal capacity) {
        requireDriver(driverId);
        if (orgOf(driverId).isPresent()) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Organization drivers use the truck allocated to them");
        }
        return truckView(insertTruck("DRIVER", driverId, number, type, capacity));
    }

    @Transactional
    public Map<String, Object> updateOwnTruck(UUID driverId, String number, VehicleType type, BigDecimal capacity) {
        requireDriver(driverId);
        Truck t = ownTruck(driverId).orElseThrow(() -> ApiException.notFound("Truck"));
        updateTruck(t, number, type, capacity);
        return truckView(truckRow(t.id()).orElseThrow());
    }

    @Transactional
    public DocumentRegistry.DocumentView ownTruckDocument(UUID driverId, DocumentType type, List<UUID> fileIds, String number,
                                                         LocalDate expiresOn) {
        requireDriver(driverId);
        Truck t = ownTruck(driverId).orElseThrow(() -> ApiException.notFound("Truck"));
        return documents.submit(DocumentRegistry.Owner.TRUCK, t.id(), driverId, type, fileIds, number, expiresOn);
    }

    /** The driver's truck: own truck, or the Organization truck allocated to them (read-only). */
    @Transactional(readOnly = true)
    public Map<String, Object> driverTruck(UUID driverId) {
        Optional<Truck> t = ownTruck(driverId)
                .or(() -> liveAllocationTruck(driverId, false).flatMap(this::truckRow));
        if (t.isEmpty()) {
            return null;
        }
        Map<String, Object> m = truckView(t.get());
        m.put("ownedByMe", "DRIVER".equals(t.get().ownerType()));
        return m;
    }

    // ------------------------------------------------------------------ duty and home (B-505)

    void ensureState(UUID driverId) {
        jdbc.update("insert into fleet_driver_state (driver_id, on_duty, updated_at) values (?, false, ?) on conflict do nothing",
                driverId, Timestamp.from(Instant.now(clock)));
    }

    @Transactional
    public Map<String, Object> setDuty(UUID driverId, boolean onDuty) {
        requireDriver(driverId);
        ensureState(driverId);
        jdbc.update("update fleet_driver_state set on_duty = ?, updated_at = ? where driver_id = ?", onDuty,
                Timestamp.from(Instant.now(clock)), driverId);
        return Map.of("onDuty", onDuty);
    }

    boolean onDuty(UUID driverId) {
        List<Boolean> b = jdbc.queryForList("select on_duty from fleet_driver_state where driver_id = ?", Boolean.class, driverId);
        return !b.isEmpty() && b.getFirst();
    }

    @Transactional(readOnly = true)
    public Map<String, Object> driverHome(UUID driverId, org.springframework.beans.factory.ObjectProvider<com.nothing.tranix.fleet.api.DriverHomeContributor> contributors,
                                          com.nothing.tranix.wallet.api.WalletApi wallet, java.util.function.Function<UUID, String> orgName) {
        UserDirectory.UserView d = requireDriver(driverId);
        Optional<UUID> org = orgOf(driverId);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("onDuty", onDuty(driverId));
        m.put("truck", driverTruck(driverId));
        m.put("walletBalanceInr", org.isPresent() ? null : wallet.balance(driverId));
        m.put("orgName", org.map(orgName).orElse(null));
        m.put("currentLoadId", loads.activeForDriver(driverId).stream().findFirst().map(LoadDirectory.LoadInfo::id).orElse(null));
        m.put("suggestionsCount", 0);
        m.put("trustScore", d.trustScore());
        LocalDate soon = today().plusDays(30);
        List<DocumentRegistry.DocumentView> docs = new ArrayList<>(documents.list(DocumentRegistry.Owner.USER, driverId));
        ownTruck(driverId).or(() -> liveAllocationTruck(driverId, false).flatMap(this::truckRow))
                .ifPresent(t -> docs.addAll(documents.list(DocumentRegistry.Owner.TRUCK, t.id())));
        m.put("expiringDocuments", docs.stream().filter(x -> x.expiresOn() != null && x.expiresOn().isBefore(soon)).toList());
        for (com.nothing.tranix.fleet.api.DriverHomeContributor c : contributors.orderedStream().toList()) {
            c.contribute(driverId, m);
        }
        return m;
    }

    // ------------------------------------------------------------------ FleetApi

    @Override
    @Transactional(readOnly = true)
    public Optional<DriverContext> driver(UUID driverId, LocalDate onDate) {
        Optional<UserDirectory.UserView> u = users.find(driverId);
        if (u.isEmpty() || u.get().role() != Role.DRIVER) {
            return Optional.empty();
        }
        Optional<UUID> org = orgOf(driverId);
        Optional<Truck> truck = ownTruck(driverId).or(() -> liveAllocationTruck(driverId, true).flatMap(this::truckRow))
                .filter(Truck::active);
        Map<String, Object> state = jdbc.queryForList("select * from fleet_driver_state where driver_id = ?", driverId)
                .stream().findFirst().orElse(Map.of());
        Double lat = (Double) state.get("last_lat");
        Double lng = (Double) state.get("last_lng");
        boolean docsOk = truck.map(t -> documents.allApprovedAndValid(DocumentRegistry.Owner.TRUCK, t.id(), TRUCK_DOCS, onDate))
                .orElse(false);
        return Optional.of(new DriverContext(driverId, Boolean.TRUE.equals(state.get("on_duty")),
                truck.map(Truck::id).orElse(null), truck.map(Truck::number).orElse(null),
                truck.map(Truck::vehicleType).orElse(null), truck.map(Truck::capacity).orElse(null), docsOk,
                org.orElse(null), org.orElse(driverId),
                lat == null || lng == null ? null : GeoPoint.of(lat, lng),
                state.get("last_location_at") == null ? null : ((Timestamp) state.get("last_location_at")).toInstant(),
                state.get("last_trip_ended_at") == null ? null : ((Timestamp) state.get("last_trip_ended_at")).toInstant()));
    }

    @Override
    @Transactional(readOnly = true)
    public List<DriverContext> onDutyDrivers(LocalDate onDate) {
        List<DriverContext> out = new ArrayList<>();
        for (UUID id : jdbc.queryForList("select driver_id from fleet_driver_state where on_duty", UUID.class)) {
            driver(id, onDate).filter(d -> d.truckId() != null).ifPresent(out::add);
        }
        return out;
    }

    @Override
    @Transactional(readOnly = true)
    public List<UUID> driversForTruck(UUID truckId) {
        return truckRow(truckId).map(t -> "DRIVER".equals(t.ownerType()) ? List.of(t.ownerId())
                : jdbc.queryForList("select driver_id from fleet_allocation where truck_id = ? and status = 'ACTIVE'", UUID.class, truckId))
                .orElse(List.of());
    }

    @Override
    @Transactional(readOnly = true)
    public int activeTruckCount(UUID orgId) {
        Integer n = jdbc.queryForObject("select count(*) from fleet_truck where owner_type = 'ORG' and owner_id = ? and active", Integer.class, orgId);
        return n == null ? 0 : n;
    }

    @Override
    @Transactional(readOnly = true)
    public List<UUID> driversOfOrg(UUID orgId) {
        return jdbc.queryForList("select driver_id from fleet_org_driver where org_id = ? and removed_at is null", UUID.class, orgId);
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<TruckView> truck(UUID truckId) {
        return truckRow(truckId).map(t -> new TruckView(t.id(), t.number(), t.vehicleType(), t.capacity(),
                "DRIVER".equals(t.ownerType()) ? t.ownerId() : null, "ORG".equals(t.ownerType()) ? t.ownerId() : null));
    }

    @Override
    @Transactional
    public void updateLocation(UUID driverId, GeoPoint point, Instant at) {
        ensureState(driverId);
        jdbc.update("update fleet_driver_state set last_lat = ?, last_lng = ?, last_location_at = ?, updated_at = ? where driver_id = ?"
                + " and (last_location_at is null or last_location_at <= ?)",
                point.lat(), point.lng(), Timestamp.from(at), Timestamp.from(Instant.now(clock)), driverId, Timestamp.from(at));
    }

    @Override
    @Transactional
    public void tripEnded(UUID driverId, Instant at) {
        ensureState(driverId);
        jdbc.update("update fleet_driver_state set last_trip_ended_at = ?, updated_at = ? where driver_id = ?",
                Timestamp.from(at), Timestamp.from(Instant.now(clock)), driverId);
    }
}
