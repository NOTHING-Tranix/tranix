package com.nothing.tranix.loads.api;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import com.nothing.tranix.shared.geo.GeoPoint;
import com.nothing.tranix.shared.types.FreightPayer;
import com.nothing.tranix.shared.types.LoadAudience;
import com.nothing.tranix.shared.types.LoadStatus;
import com.nothing.tranix.shared.types.QuantityUnit;
import com.nothing.tranix.shared.types.VehicleType;

/** Read and status access to loads for other modules (matching, trips, payments, trust, receiver pages). */
public interface LoadDirectory {

    Optional<LoadInfo> find(UUID loadId);

    LoadInfo get(UUID loadId);

    /** Status change through the load's single domain method (B-407); writes a timeline row. */
    void transition(UUID loadId, LoadStatus next, UUID actorId);

    /** Sets the agreed amount after a confirmed revision. */
    void setAgreedAmount(UUID loadId, long amountInr);

    void setDeliveryEta(UUID loadId, Instant eta);

    /** Marks the trip closed (payment confirmed or dispute resolved). */
    void close(UUID loadId);

    /** Loads in an active status for this driver (at most one by the matching rules). */
    List<LoadInfo> activeForDriver(UUID driverId);

    /**
     * B-605: first accept wins — one atomic UPDATE (NOT_ACCEPTED → ACCEPTED) then WAITING_FOR_PICKUP, with timeline
     * rows. Returns false when another driver was faster (caller answers LOAD_TAKEN). Joins the caller's transaction.
     */
    boolean acceptAtomically(UUID loadId, UUID driverId, UUID truckId, UUID orgId);

    /** Shipper or driver cancels (B-406 / B-708 rules). */
    Map<String, Object> cancel(UUID userId, UUID loadId, String reason, String note);

    /** Open loads (NOT_ACCEPTED) — for the matching job. */
    List<UUID> openLoadIds();

    List<LoadInfo> activeForTruck(UUID truckId);

    /** Loads carried by an Organization (B-507), newest pickup first, as {@code LoadSummary} maps + driverId/truckId. */
    List<Map<String, Object>> forOrg(UUID orgId, UUID driverId, UUID truckId, Instant from, Instant to, LoadStatus status,
                                     int limit);

    /** Driver's finished trips (delivered or cancelled) picked up in [from, to), newest first, as LoadSummary maps. */
    List<Map<String, Object>> historyForDriver(UUID driverId, Instant from, Instant to, int limit);

    /** Delivered/cancelled counts and money for a driver (performance). */
    DriverStats driverStats(UUID driverId);

    record DriverStats(long tripsDelivered, long onTime, long cancelledByDriver, long agreedTotalInr) {
    }


    /** M9: the shipper's finished trips (delivered or cancelled after acceptance) that had a truck — wish-list sources. */
    List<PastTrip> pastTripsOfShipper(UUID shipperId);

    record PastTrip(UUID loadId, UUID truckId, UUID orgId, UUID driverId, Instant at) {
    }

    /** M9: wish-list load → normal matching now (shipper button or the WISHLIST_FIRST window job). */
    void openToEveryone(UUID loadId);

    /** M9: open wish-list loads (NOT_ACCEPTED, audience ≠ EVERYONE). */
    List<LoadInfo> openWishlistLoads();

    /** M12 RC-01: loads addressed to a registered receiver (ongoing = not delivered/cancelled), as LoadSummary + deliveryEta. */
    List<Map<String, Object>> forReceiver(UUID receiverUserId, boolean ongoing);

    /** M14 admin: cancel any load before delivery (also after pickup); charges stay, no Trust Score penalty. */
    Map<String, Object> adminCancel(UUID loadId, UUID adminId, String reason);

    /** The contract {@code LoadDetail} map for a viewer (shipper/receiver/driver/admin). */
    Map<String, Object> detail(UUID loadId, Viewer viewer);

    enum Viewer { SHIPPER, RECEIVER, DRIVER, ORGANIZATION, ADMIN }

    record LoadInfo(UUID id, String code, UUID shipperId, UUID postedForFarmerId, LoadStatus status, UUID driverId,
                    UUID truckId, UUID orgId, GeoPoint pickup, GeoPoint drop, String pickupArea, String dropArea,
                    Instant pickupWindowStart, Instant pickupWindowEnd, String goodsType, String description,
                    BigDecimal quantity, QuantityUnit quantityUnit, BigDecimal weightTonnes, VehicleType vehicleType,
                    FreightPayer freightPaidBy, long postedAmountInr, long agreedAmountInr, String senderName,
                    String senderMobile, String receiverName, String receiverMobile, UUID receiverUserId,
                    BigDecimal distanceKm, int driveMinutes, Instant deliveryEta, LoadAudience audience,
                    List<UUID> wishlistEntryIds, Instant wishlistUntil, Instant acceptedAt, Instant pickedUpAt,
                    Instant deliveredAt, Instant closedAt, Instant createdAt) {
    }
}
