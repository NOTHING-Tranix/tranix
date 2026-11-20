package com.nothing.tranix.loads.internal;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.EnumSet;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;

import com.nothing.tranix.shared.domain.BaseEntity;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.types.FreightPayer;
import com.nothing.tranix.shared.types.LoadAudience;
import com.nothing.tranix.shared.types.LoadStatus;
import com.nothing.tranix.shared.types.QuantityUnit;
import com.nothing.tranix.shared.types.VehicleType;

import static com.nothing.tranix.shared.types.LoadStatus.ACCEPTED;
import static com.nothing.tranix.shared.types.LoadStatus.AMOUNT_NEGOTIATION;
import static com.nothing.tranix.shared.types.LoadStatus.ARRIVED_DESTINATION;
import static com.nothing.tranix.shared.types.LoadStatus.CANCELLED;
import static com.nothing.tranix.shared.types.LoadStatus.DELIVERED;
import static com.nothing.tranix.shared.types.LoadStatus.LOCATION_REACHED;
import static com.nothing.tranix.shared.types.LoadStatus.NOT_ACCEPTED;
import static com.nothing.tranix.shared.types.LoadStatus.PICKED_UP;
import static com.nothing.tranix.shared.types.LoadStatus.TRAVELING;
import static com.nothing.tranix.shared.types.LoadStatus.WAITING_FOR_PICKUP;

@Entity
@Table(name = "loads_load")
public class Load extends BaseEntity {

    /** B-407: allowed transitions (docs/domain-model.md "Load status machine"). */
    static final Map<LoadStatus, Set<LoadStatus>> ALLOWED = Map.of(
            NOT_ACCEPTED, EnumSet.of(ACCEPTED, CANCELLED),
            ACCEPTED, EnumSet.of(WAITING_FOR_PICKUP, CANCELLED),
            WAITING_FOR_PICKUP, EnumSet.of(AMOUNT_NEGOTIATION, LOCATION_REACHED, CANCELLED),
            AMOUNT_NEGOTIATION, EnumSet.of(WAITING_FOR_PICKUP, LOCATION_REACHED, CANCELLED),
            LOCATION_REACHED, EnumSet.of(PICKED_UP, CANCELLED),
            PICKED_UP, EnumSet.of(TRAVELING),
            TRAVELING, EnumSet.of(ARRIVED_DESTINATION),
            ARRIVED_DESTINATION, EnumSet.of(DELIVERED),
            DELIVERED, EnumSet.noneOf(LoadStatus.class),
            CANCELLED, EnumSet.noneOf(LoadStatus.class));

    /** Statuses a shipper or driver may cancel from (§11); after pickup only Admin via support. */
    static final Set<LoadStatus> CANCELLABLE = EnumSet.of(NOT_ACCEPTED, ACCEPTED, WAITING_FOR_PICKUP, AMOUNT_NEGOTIATION, LOCATION_REACHED);
    static final Set<LoadStatus> AFTER_PICKUP = EnumSet.of(PICKED_UP, TRAVELING, ARRIVED_DESTINATION);

    @Column(nullable = false, unique = true, updatable = false)
    private String code;
    @Column(name = "shipper_id", nullable = false, updatable = false)
    private UUID shipperId;
    @Column(name = "posted_for_farmer_id")
    private UUID postedForFarmerId;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private LoadStatus status = NOT_ACCEPTED;

    @Column(name = "pickup_lat") private double pickupLat;
    @Column(name = "pickup_lng") private double pickupLng;
    @Column(name = "pickup_address") private String pickupAddress;
    @Column(name = "pickup_landmark") private String pickupLandmark;
    @Column(name = "pickup_area") private String pickupArea;
    @Column(name = "drop_lat") private double dropLat;
    @Column(name = "drop_lng") private double dropLng;
    @Column(name = "drop_address") private String dropAddress;
    @Column(name = "drop_landmark") private String dropLandmark;
    @Column(name = "drop_area") private String dropArea;
    @Column(name = "pickup_window_start") private Instant pickupWindowStart;
    @Column(name = "pickup_window_end") private Instant pickupWindowEnd;
    @Column(name = "sender_name") private String senderName;
    @Column(name = "sender_mobile") private String senderMobile;
    @Column(name = "receiver_name") private String receiverName;
    @Column(name = "receiver_mobile") private String receiverMobile;
    @Column(name = "receiver_user_id") private UUID receiverUserId;
    @Column(name = "goods_type") private String goodsType;
    private String description;
    private BigDecimal quantity;
    @Enumerated(EnumType.STRING) @Column(name = "quantity_unit") private QuantityUnit quantityUnit;
    @Column(name = "weight_tonnes") private BigDecimal weightTonnes;
    @Enumerated(EnumType.STRING) @Column(name = "vehicle_type") private VehicleType vehicleType;
    @Enumerated(EnumType.STRING) @Column(name = "freight_paid_by") private FreightPayer freightPaidBy;
    @Column(name = "posted_amount_inr") private long postedAmountInr;
    @Column(name = "agreed_amount_inr") private long agreedAmountInr;
    @Column(name = "driver_id") private UUID driverId;
    @Column(name = "truck_id") private UUID truckId;
    @Column(name = "org_id") private UUID orgId;
    @Column(name = "distance_km") private BigDecimal distanceKm;
    @Column(name = "drive_minutes") private int driveMinutes;
    @Column(name = "delivery_eta") private Instant deliveryEta;
    @Enumerated(EnumType.STRING) private LoadAudience audience = LoadAudience.EVERYONE;
    @Column(name = "wishlist_entry_ids") private String wishlistEntryIds;
    @Column(name = "wishlist_until") private Instant wishlistUntil;
    @Column(name = "opened_to_everyone_at") private Instant openedToEveryoneAt;
    @Column(name = "accepted_at") private Instant acceptedAt;
    @Column(name = "picked_up_at") private Instant pickedUpAt;
    @Column(name = "delivered_at") private Instant deliveredAt;
    @Column(name = "cancelled_at") private Instant cancelledAt;
    @Column(name = "closed_at") private Instant closedAt;

    protected Load() {
    }

    Load(String code, UUID shipperId) {
        this.code = code;
        this.shipperId = shipperId;
    }

    /** One place for status changes; returns the previous status. Timeline rows are written by the caller. */
    LoadStatus transition(LoadStatus next, Instant now) {
        if (!ALLOWED.getOrDefault(status, Set.of()).contains(next)) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Load is " + status + "; can not move to " + next);
        }
        LoadStatus previous = status;
        status = next;
        switch (next) {
            case PICKED_UP -> pickedUpAt = now;
            case DELIVERED -> deliveredAt = now;
            case CANCELLED -> {
                cancelledAt = now;
                closedAt = now;
            }
            default -> {
            }
        }
        return previous;
    }

    /** Admin cancel after pickup (support decision). */
    void adminCancel(Instant now) {
        if (status == DELIVERED || status == CANCELLED) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Load is already " + status);
        }
        status = CANCELLED;
        cancelledAt = now;
        closedAt = now;
    }

    void place(double pLat, double pLng, String pAddress, String pLandmark, String pArea,
               double dLat, double dLng, String dAddress, String dLandmark, String dArea) {
        pickupLat = pLat;
        pickupLng = pLng;
        pickupAddress = pAddress;
        pickupLandmark = pLandmark;
        pickupArea = pArea;
        dropLat = dLat;
        dropLng = dLng;
        dropAddress = dAddress;
        dropLandmark = dLandmark;
        dropArea = dArea;
    }

    void details(Instant start, Instant end, String senderName, String senderMobile, String receiverName,
                 String receiverMobile, UUID receiverUserId, String goodsType, String description, BigDecimal quantity,
                 QuantityUnit unit, BigDecimal weight, VehicleType vehicleType, FreightPayer payer, long amount,
                 UUID farmerId) {
        this.pickupWindowStart = start;
        this.pickupWindowEnd = end;
        this.senderName = senderName;
        this.senderMobile = senderMobile;
        this.receiverName = receiverName;
        this.receiverMobile = receiverMobile;
        this.receiverUserId = receiverUserId;
        this.goodsType = goodsType;
        this.description = description;
        this.quantity = quantity;
        this.quantityUnit = unit;
        this.weightTonnes = weight;
        this.vehicleType = vehicleType;
        this.freightPaidBy = payer;
        this.postedAmountInr = amount;
        this.agreedAmountInr = amount;
        this.postedForFarmerId = farmerId;
    }

    void estimate(BigDecimal distanceKm, int driveMinutes, Instant eta) {
        this.distanceKm = distanceKm;
        this.driveMinutes = driveMinutes;
        this.deliveryEta = eta;
    }

    void audience(LoadAudience audience, String entryIds, Instant wishlistUntil) {
        this.audience = audience;
        this.wishlistEntryIds = entryIds;
        this.wishlistUntil = wishlistUntil;
    }

    // getters
    public String getCode() { return code; }
    public UUID getShipperId() { return shipperId; }
    public UUID getPostedForFarmerId() { return postedForFarmerId; }
    public LoadStatus getStatus() { return status; }
    public double getPickupLat() { return pickupLat; }
    public double getPickupLng() { return pickupLng; }
    public String getPickupAddress() { return pickupAddress; }
    public String getPickupLandmark() { return pickupLandmark; }
    public String getPickupArea() { return pickupArea; }
    public double getDropLat() { return dropLat; }
    public double getDropLng() { return dropLng; }
    public String getDropAddress() { return dropAddress; }
    public String getDropLandmark() { return dropLandmark; }
    public String getDropArea() { return dropArea; }
    public Instant getPickupWindowStart() { return pickupWindowStart; }
    public Instant getPickupWindowEnd() { return pickupWindowEnd; }
    public String getSenderName() { return senderName; }
    public String getSenderMobile() { return senderMobile; }
    public String getReceiverName() { return receiverName; }
    public String getReceiverMobile() { return receiverMobile; }
    public UUID getReceiverUserId() { return receiverUserId; }
    public String getGoodsType() { return goodsType; }
    public String getDescription() { return description; }
    public BigDecimal getQuantity() { return quantity; }
    public QuantityUnit getQuantityUnit() { return quantityUnit; }
    public BigDecimal getWeightTonnes() { return weightTonnes; }
    public VehicleType getVehicleType() { return vehicleType; }
    public FreightPayer getFreightPaidBy() { return freightPaidBy; }
    public long getPostedAmountInr() { return postedAmountInr; }
    public long getAgreedAmountInr() { return agreedAmountInr; }
    void setAgreedAmountInr(long a) { agreedAmountInr = a; }
    public UUID getDriverId() { return driverId; }
    public UUID getTruckId() { return truckId; }
    public UUID getOrgId() { return orgId; }
    public BigDecimal getDistanceKm() { return distanceKm; }
    public int getDriveMinutes() { return driveMinutes; }
    public Instant getDeliveryEta() { return deliveryEta; }
    void setDeliveryEta(Instant eta) { deliveryEta = eta; }
    public LoadAudience getAudience() { return audience; }
    public String getWishlistEntryIds() { return wishlistEntryIds; }
    public Instant getWishlistUntil() { return wishlistUntil; }
    public Instant getOpenedToEveryoneAt() { return openedToEveryoneAt; }
    void openToEveryone(Instant now) { openedToEveryoneAt = now; audience = LoadAudience.EVERYONE; }
    public Instant getAcceptedAt() { return acceptedAt; }
    public Instant getPickedUpAt() { return pickedUpAt; }
    public Instant getDeliveredAt() { return deliveredAt; }
    public Instant getCancelledAt() { return cancelledAt; }
    public Instant getClosedAt() { return closedAt; }
    void close(Instant now) { if (closedAt == null) closedAt = now; }
}
