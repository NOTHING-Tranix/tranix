package com.nothing.tranix.fleet.internal;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import com.nothing.tranix.engagement.api.Notifier;
import com.nothing.tranix.identity.api.DocumentRegistry;
import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.integrations.SmsSender;
import com.nothing.tranix.shared.types.DocumentType;
import com.nothing.tranix.shared.types.LoadStatus;
import com.nothing.tranix.shared.types.NotificationTab;
import com.nothing.tranix.shared.types.Role;
import com.nothing.tranix.shared.types.TruckStatus;
import com.nothing.tranix.shared.types.VehicleType;
import com.nothing.tranix.wallet.api.WalletApi;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Organization side: trucks (B-502), invitations (B-503), allocations (B-504), dashboard/drivers/trips (B-506…B-508). */
@Service
public class OrgService {

    private final FleetService fleet;
    private final UserDirectory users;
    private final LoadDirectory loads;
    private final WalletApi wallet;
    private final Notifier notifier;
    private final SmsSender sms;
    private final org.springframework.jdbc.core.JdbcTemplate jdbc;
    private final DocumentRegistry documents;
    private final java.time.Clock clock;

    OrgService(FleetService fleet, UserDirectory users, LoadDirectory loads, WalletApi wallet, Notifier notifier, SmsSender sms,
               org.springframework.jdbc.core.JdbcTemplate jdbc, DocumentRegistry documents, java.time.Clock clock) {
        this.jdbc = jdbc;
        this.documents = documents;
        this.clock = clock;
        this.fleet = fleet;
        this.users = users;
        this.loads = loads;
        this.wallet = wallet;
        this.notifier = notifier;
        this.sms = sms;
    }

    private Instant now() {
        return Instant.now(clock);
    }

    UserDirectory.UserView requireOrg(UUID userId) {
        UserDirectory.UserView u = users.get(userId);
        if (u.role() != Role.ORGANIZATION) {
            throw new ApiException(ErrorCode.FORBIDDEN, "Organizations only");
        }
        return u;
    }

    private FleetService.Truck orgTruck(UUID orgId, UUID truckId) {
        return fleet.truckRow(truckId).filter(t -> "ORG".equals(t.ownerType()) && t.ownerId().equals(orgId))
                .orElseThrow(() -> ApiException.notFound("Truck"));
    }

    // ------------------------------------------------------------------ trucks (B-502)

    @Transactional(readOnly = true)
    public List<Map<String, Object>> trucks(UUID orgId) {
        requireOrg(orgId);
        return jdbc.query("select * from fleet_truck where owner_type = 'ORG' and owner_id = ? order by number",
                FleetService.TRUCK, orgId).stream().map(fleet::truckView).toList();
    }

    @Transactional
    public Map<String, Object> addTruck(UUID orgId, String number, VehicleType type, BigDecimal capacity) {
        requireOrg(orgId);
        return fleet.truckView(fleet.insertTruck("ORG", orgId, number, type, capacity));
    }

    @Transactional
    public Map<String, Object> updateTruck(UUID orgId, UUID truckId, String number, VehicleType type, BigDecimal capacity) {
        requireOrg(orgId);
        FleetService.Truck t = orgTruck(orgId, truckId);
        fleet.updateTruck(t, number, type, capacity);
        return fleet.truckView(fleet.truckRow(truckId).orElseThrow());
    }

    @Transactional
    public Map<String, Object> deactivateTruck(UUID orgId, UUID truckId) {
        requireOrg(orgId);
        FleetService.Truck t = orgTruck(orgId, truckId);
        if (!loads.activeForTruck(truckId).isEmpty()) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Truck is on a trip");
        }
        jdbc.update("update fleet_allocation set status = 'REMOVED', updated_at = ? where truck_id = ? and status <> 'REMOVED'",
                Timestamp.from(now()), truckId);
        jdbc.update("update fleet_truck set active = false, updated_at = ? where id = ?", Timestamp.from(now()), t.id());
        return fleet.truckView(fleet.truckRow(truckId).orElseThrow());
    }

    @Transactional
    public DocumentRegistry.DocumentView truckDocument(UUID orgId, UUID truckId, DocumentType type, List<UUID> fileIds,
                                                      String number, LocalDate expiresOn) {
        requireOrg(orgId);
        orgTruck(orgId, truckId);
        return documents.submit(DocumentRegistry.Owner.TRUCK, truckId, orgId, type, fileIds, number, expiresOn);
    }

    /** B-508: live location while the truck is on a trip. */
    @Transactional(readOnly = true)
    public Map<String, Object> truckLocation(UUID orgId, UUID truckId) {
        requireOrg(orgId);
        orgTruck(orgId, truckId);
        List<LoadDirectory.LoadInfo> active = loads.activeForTruck(truckId);
        if (active.isEmpty()) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Truck is not on a trip");
        }
        LoadDirectory.LoadInfo load = active.getFirst();
        Map<String, Object> m = new HashMap<>();
        m.put("loadId", load.id());
        m.put("loadCode", load.code());
        fleet.driver(load.driverId(), fleet.today()).filter(d -> d.lastLocation() != null).ifPresentOrElse(d -> {
            m.put("lat", d.lastLocation().lat());
            m.put("lng", d.lastLocation().lng());
            m.put("at", d.lastLocationAt());
        }, () -> m.put("at", null));
        return m;
    }

    // ------------------------------------------------------------------ invitations (B-503)

    @Transactional
    public Map<String, Object> invite(UUID orgId, String name, String mobile) {
        UserDirectory.UserView org = requireOrg(orgId);
        Optional<UserDirectory.UserView> driver = users.findByMobile(mobile);
        if (driver.isPresent() && driver.get().role() != Role.DRIVER) {
            throw ApiException.invalidField("mobile", "This number belongs to a non-driver account");
        }
        if (driver.isPresent() && fleet.orgOf(driver.get().id()).filter(orgId::equals).isPresent()) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Already your driver");
        }
        UUID id = UUID.randomUUID();
        try {
            jdbc.update("""
                    insert into fleet_invitation (id, org_id, driver_mobile, driver_name, driver_user_id, status, created_at)
                    values (?, ?, ?, ?, ?, 'PENDING', ?)""", id, orgId, mobile, name.trim(),
                    driver.map(UserDirectory.UserView::id).orElse(null), Timestamp.from(now()));
        } catch (DuplicateKeyException e) {
            throw new ApiException(ErrorCode.INVALID_STATE, "An invitation is already pending for this number");
        }
        String orgName = orgName(orgId, org.name());
        if (driver.isPresent()) {
            notifier.notify(driver.get().id(), NotificationTab.TRIPS, "ORG_INVITE", Map.of("org", orgName), "/driver");
        } else {
            sms.send(mobile, "ORG_INVITE", Map.of("org", orgName), org.language());
        }
        return invitationView(id);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> invitationsForDriver(UUID driverId) {
        UserDirectory.UserView d = fleet.requireDriver(driverId);
        return jdbc.queryForList("select id from fleet_invitation where driver_mobile = ? and status = 'PENDING' order by created_at desc",
                UUID.class, d.mobile()).stream().map(this::invitationView).toList();
    }

    @Transactional
    public Map<String, Object> respond(UUID driverId, UUID invitationId, boolean accept) {
        UserDirectory.UserView d = fleet.requireDriver(driverId);
        Map<String, Object> inv = jdbc.queryForList("select * from fleet_invitation where id = ? and driver_mobile = ?",
                invitationId, d.mobile()).stream().findFirst().orElseThrow(() -> ApiException.notFound("Invitation"));
        if (!"PENDING".equals(inv.get("status"))) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Invitation already answered");
        }
        UUID orgId = (UUID) inv.get("org_id");
        if (accept) {
            if (fleet.orgOf(driverId).isPresent()) {
                throw new ApiException(ErrorCode.INVALID_STATE, "Leave your current Organization first");
            }
            if (fleet.ownTruck(driverId).isPresent()) {
                throw new ApiException(ErrorCode.INVALID_STATE, "Owner-drivers with a truck can not join an Organization");
            }
            if (!loads.activeForDriver(driverId).isEmpty()) {
                throw new ApiException(ErrorCode.INVALID_STATE, "Finish your current trip first");
            }
            jdbc.update("insert into fleet_org_driver (id, org_id, driver_id, joined_at) values (?, ?, ?, ?)",
                    UUID.randomUUID(), orgId, driverId, Timestamp.from(now()));
        }
        jdbc.update("update fleet_invitation set status = ?, driver_user_id = ?, responded_at = ? where id = ?",
                accept ? "ACCEPTED" : "REJECTED", driverId, Timestamp.from(now()), invitationId);
        notifier.notify(orgId, NotificationTab.ACCOUNT, accept ? "INVITE_ACCEPTED" : "INVITE_REJECTED",
                Map.of("driver", d.name()), "/org/drivers");
        return invitationView(invitationId);
    }

    private Map<String, Object> invitationView(UUID id) {
        Map<String, Object> r = jdbc.queryForMap("select * from fleet_invitation where id = ?", id);
        UUID orgId = (UUID) r.get("org_id");
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", id);
        m.put("orgId", orgId);
        m.put("orgName", orgName(orgId, users.find(orgId).map(UserDirectory.UserView::name).orElse("")));
        m.put("driverName", r.get("driver_name"));
        m.put("driverMobile", r.get("driver_mobile"));
        m.put("status", r.get("status"));
        m.put("createdAt", ((Timestamp) r.get("created_at")).toInstant());
        return m;
    }

    public String orgName(UUID orgId, String fallback) {
        Object n = users.roleProfile(orgId).get("orgName");
        return n instanceof String s && !s.isBlank() ? s : fallback;
    }

    // ------------------------------------------------------------------ allocations (B-504)

    @Transactional
    public Map<String, Object> allocate(UUID orgId, UUID driverId, UUID truckId) {
        requireOrg(orgId);
        checkAllocatable(orgId, driverId, truckId);
        UUID id = UUID.randomUUID();
        try {
            jdbc.update("insert into fleet_allocation (id, org_id, driver_id, truck_id, status, created_at, updated_at) values (?, ?, ?, ?, 'ACTIVE', ?, ?)",
                    id, orgId, driverId, truckId, Timestamp.from(now()), Timestamp.from(now()));
        } catch (DuplicateKeyException e) {
            throw new ApiException(ErrorCode.ALLOCATION_CONFLICT, "Driver or truck is already allocated");
        }
        return allocationView(id);
    }

    @Transactional
    public Map<String, Object> updateAllocation(UUID orgId, UUID allocationId, UUID driverId, UUID truckId, String status) {
        requireOrg(orgId);
        Map<String, Object> a = allocation(orgId, allocationId);
        UUID currentDriver = (UUID) a.get("driver_id");
        UUID currentTruck = (UUID) a.get("truck_id");
        requireNoActiveTrip(currentDriver, currentTruck);
        UUID newDriver = driverId == null ? currentDriver : driverId;
        UUID newTruck = truckId == null ? currentTruck : truckId;
        if (!newDriver.equals(currentDriver) || !newTruck.equals(currentTruck)) {
            checkAllocatable(orgId, newDriver, newTruck);
        }
        String newStatus = status == null ? (String) a.get("status") : status;
        if (!List.of("ACTIVE", "PAUSED").contains(newStatus)) {
            throw ApiException.invalidField("status", "ACTIVE or PAUSED");
        }
        try {
            jdbc.update("update fleet_allocation set driver_id = ?, truck_id = ?, status = ?, updated_at = ? where id = ?",
                    newDriver, newTruck, newStatus, Timestamp.from(now()), allocationId);
        } catch (DuplicateKeyException e) {
            throw new ApiException(ErrorCode.ALLOCATION_CONFLICT, "Driver or truck is already allocated");
        }
        return allocationView(allocationId);
    }

    @Transactional
    public void removeAllocation(UUID orgId, UUID allocationId) {
        requireOrg(orgId);
        Map<String, Object> a = allocation(orgId, allocationId);
        requireNoActiveTrip((UUID) a.get("driver_id"), (UUID) a.get("truck_id"));
        jdbc.update("update fleet_allocation set status = 'REMOVED', updated_at = ? where id = ?", Timestamp.from(now()), allocationId);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> allocations(UUID orgId) {
        requireOrg(orgId);
        return jdbc.queryForList("select id from fleet_allocation where org_id = ? and status <> 'REMOVED' order by created_at",
                UUID.class, orgId).stream().map(this::allocationView).toList();
    }

    private void checkAllocatable(UUID orgId, UUID driverId, UUID truckId) {
        if (fleet.orgOf(driverId).filter(orgId::equals).isEmpty()) {
            throw ApiException.invalidField("driverId", "Not your driver");
        }
        if (!users.get(driverId).verified()) {
            throw ApiException.invalidField("driverId", "Driver is not verified yet");
        }
        FleetService.Truck t = orgTruck(orgId, truckId);
        if (!t.active() || !fleet.docsValid(truckId)) {
            throw ApiException.invalidField("truckId", "Truck is not verified or not active");
        }
        requireNoActiveTrip(driverId, truckId);
    }

    private void requireNoActiveTrip(UUID driverId, UUID truckId) {
        if (!loads.activeForDriver(driverId).isEmpty() || !loads.activeForTruck(truckId).isEmpty()) {
            throw new ApiException(ErrorCode.ALLOCATION_CONFLICT, "No changes during an active trip");
        }
    }

    private Map<String, Object> allocation(UUID orgId, UUID id) {
        return jdbc.queryForList("select * from fleet_allocation where id = ? and org_id = ? and status <> 'REMOVED'", id, orgId)
                .stream().findFirst().orElseThrow(() -> ApiException.notFound("Allocation"));
    }

    private Map<String, Object> allocationView(UUID id) {
        Map<String, Object> a = jdbc.queryForMap("select * from fleet_allocation where id = ?", id);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", id);
        m.put("status", a.get("status"));
        UUID driverId = (UUID) a.get("driver_id");
        UUID truckId = (UUID) a.get("truck_id");
        m.put("driver", Map.of("id", driverId, "name", users.find(driverId).map(UserDirectory.UserView::name).orElse("")));
        m.put("truck", Map.of("id", truckId, "number", fleet.truckRow(truckId).map(FleetService.Truck::number).orElse("")));
        return m;
    }

    // ------------------------------------------------------------------ drivers, dashboard, trips (B-506, B-507)

    @Transactional(readOnly = true)
    public List<Map<String, Object>> drivers(UUID orgId) {
        requireOrg(orgId);
        List<Map<String, Object>> out = new ArrayList<>();
        for (UUID id : fleet.driversOfOrg(orgId)) {
            users.find(id).ifPresent(u -> {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", u.id());
                m.put("name", u.name());
                m.put("mobile", u.mobile());
                m.put("verificationStatus", u.verificationStatus());
                m.put("trustScore", u.trustScore());
                m.put("onDuty", fleet.onDuty(id));
                m.put("onTrip", !loads.activeForDriver(id).isEmpty());
                Optional<UUID> truck = fleet.liveAllocationTruck(id, false);
                m.put("allocationStatus", truck.isPresent() ? "ALLOCATED" : "UNALLOCATED");
                m.put("truckNumber", truck.flatMap(fleet::truckRow).map(FleetService.Truck::number).orElse(null));
                out.add(m);
            });
        }
        // pending invitations are listed too so the Org sees who has not joined yet
        for (Map<String, Object> inv : jdbc.queryForList(
                "select id, driver_name, driver_mobile from fleet_invitation where org_id = ? and status = 'PENDING'", orgId)) {
            out.add(Map.of("invitationId", inv.get("id"), "name", inv.get("driver_name"), "mobile", inv.get("driver_mobile"),
                    "allocationStatus", "INVITED"));
        }
        return out;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> performance(UUID orgId, UUID driverId) {
        requireOrg(orgId);
        if (fleet.orgOf(driverId).filter(orgId::equals).isEmpty()) {
            throw ApiException.notFound("Driver");
        }
        LoadDirectory.DriverStats s = loads.driverStats(driverId);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("trips", s.tripsDelivered());
        m.put("onTimePct", s.tripsDelivered() == 0 ? null : Math.round(s.onTime() * 100.0 / s.tripsDelivered()));
        m.put("earnedInr", s.agreedTotalInr());
        m.put("cancellations", s.cancelledByDriver());
        m.put("trustScore", users.get(driverId).trustScore());
        return m;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> dashboard(UUID orgId) {
        requireOrg(orgId);
        List<FleetService.Truck> trucks = jdbc.query("select * from fleet_truck where owner_type = 'ORG' and owner_id = ? and active",
                FleetService.TRUCK, orgId);
        Map<TruckStatus, Integer> byStatus = new HashMap<>();
        trucks.forEach(t -> byStatus.merge(fleet.status(t), 1, Integer::sum));
        long expiring = trucks.stream().filter(t -> documents.list(DocumentRegistry.Owner.TRUCK, t.id()).stream()
                .anyMatch(d -> d.expiresOn() != null && d.expiresOn().isBefore(fleet.today().plusDays(30)))).count();
        List<UUID> driverIds = fleet.driversOfOrg(orgId);
        long onDuty = driverIds.stream().filter(fleet::onDuty).count();
        long onTrip = driverIds.stream().filter(d -> !loads.activeForDriver(d).isEmpty()).count();
        long unallocated = driverIds.stream().filter(d -> fleet.liveAllocationTruck(d, false).isEmpty()).count();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("trucks", Map.of("total", trucks.size(), "onTrip", byStatus.getOrDefault(TruckStatus.ON_TRIP, 0),
                "idle", byStatus.getOrDefault(TruckStatus.AVAILABLE, 0) + byStatus.getOrDefault(TruckStatus.ALLOCATED, 0),
                "documentsPending", byStatus.getOrDefault(TruckStatus.DOCUMENTS_PENDING, 0), "documentsExpiring", expiring));
        m.put("drivers", Map.of("total", driverIds.size(), "onDuty", onDuty, "onTrip", onTrip, "unallocated", unallocated));
        m.put("activeTrips", onTrip);
        m.put("walletBalanceInr", wallet.balance(orgId));
        // B-655: read-only count from the matching wish-list table (fleet must not depend on matching).
        Long preferred = jdbc.queryForObject("""
                select count(distinct shipper_id) from matching_wishlist_entry where org_id = ?
                   or truck_id in (select id from fleet_truck where owner_type = 'ORG' and owner_id = ?)""", Long.class, orgId, orgId);
        m.put("preferredByShippersCount", preferred == null ? 0 : preferred);
        return m;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> trips(UUID orgId, String by, UUID id, Instant from, Instant to, LoadStatus status) {
        requireOrg(orgId);
        return loads.forOrg(orgId, "DRIVER".equals(by) ? id : null, "TRUCK".equals(by) ? id : null, from, to, status, 500);
    }

    @Transactional(readOnly = true)
    public String tripsCsv(UUID orgId, String by, UUID id, Instant from, Instant to, LoadStatus status) {
        StringBuilder csv = new StringBuilder("code,status,goods,pickup_area,drop_area,pickup_time,amount_inr,driver,truck\n");
        for (Map<String, Object> t : trips(orgId, by, id, from, to, status)) {
            String driver = t.get("driverId") == null ? "" : users.find((UUID) t.get("driverId")).map(UserDirectory.UserView::name).orElse("");
            String truck = t.get("truckId") == null ? "" : fleet.truckRow((UUID) t.get("truckId")).map(FleetService.Truck::number).orElse("");
            csv.append(String.join(",", List.of(str(t.get("code")), str(t.get("status")), str(t.get("goodsType")),
                    str(t.get("pickupArea")), str(t.get("dropArea")), str(t.get("pickupWindowStart")), str(t.get("agreedAmountInr")),
                    csvCell(driver), csvCell(truck)))).append('\n');
        }
        return csv.toString();
    }

    private static String str(Object o) {
        return o == null ? "" : csvCell(o.toString());
    }

    private static String csvCell(String s) {
        String safe = s.startsWith("=") || s.startsWith("+") || s.startsWith("-") || s.startsWith("@") ? "'" + s : s;
        return safe.contains(",") || safe.contains("\"") ? "\"" + safe.replace("\"", "\"\"") + "\"" : safe;
    }
}
