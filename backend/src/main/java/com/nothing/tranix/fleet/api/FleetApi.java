package com.nothing.tranix.fleet.api;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import com.nothing.tranix.shared.geo.GeoPoint;
import com.nothing.tranix.shared.types.VehicleType;

/** Fleet facts other modules need (matching eligibility, trips, payments). */
public interface FleetApi {

    /** Everything matching needs to know about one driver right now. */
    record DriverContext(UUID driverId, boolean onDuty, UUID truckId, String truckNumber, VehicleType vehicleType,
                         BigDecimal capacityTonnes, boolean truckDocumentsValid, UUID orgId, UUID payerUserId,
                         GeoPoint lastLocation, Instant lastLocationAt, Instant lastTripEndedAt) {
    }

    record TruckView(UUID id, String number, VehicleType vehicleType, BigDecimal capacityTonnes, UUID ownerDriverId,
                     UUID orgId) {
    }

    Optional<DriverContext> driver(UUID driverId, LocalDate onDate);

    /** On-duty drivers that have a truck (own or allocated) — matching filters the rest. */
    List<DriverContext> onDutyDrivers(LocalDate onDate);

    /** Drivers who can drive this truck now (owner-driver or the allocated Organization driver). */
    List<UUID> driversForTruck(UUID truckId);

    /** Active (non-removed) drivers of an Organization. */
    List<UUID> driversOfOrg(UUID orgId);

    Optional<TruckView> truck(UUID truckId);

    void updateLocation(UUID driverId, GeoPoint point, Instant at);

    void tripEnded(UUID driverId, Instant at);
}
