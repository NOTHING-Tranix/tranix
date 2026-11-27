package com.nothing.tranix.loads.web;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import com.nothing.tranix.identity.api.RequiresVerified;
import com.nothing.tranix.loads.internal.LoadService;
import com.nothing.tranix.shared.geo.GeoPoint;
import com.nothing.tranix.shared.security.CurrentUser;
import com.nothing.tranix.shared.types.FreightPayer;
import com.nothing.tranix.shared.types.LoadAudience;
import com.nothing.tranix.shared.types.QuantityUnit;
import com.nothing.tranix.shared.types.VehicleType;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** Contract §6 (shipper side). */
@RestController
@RequestMapping("/api/v1/loads")
@Tag(name = "Loads")
class LoadsController {

    static final String MOBILE = "^[6-9][0-9]{9}$";

    private final LoadService loads;

    LoadsController(LoadService loads) {
        this.loads = loads;
    }

    record Place(@NotNull @DecimalMin("-90") @DecimalMax("90") Double lat,
                 @NotNull @DecimalMin("-180") @DecimalMax("180") Double lng,
                 @NotBlank @Size(max = 300) String address, @Size(max = 120) String landmark) {
        LoadService.PlaceInput input() {
            return new LoadService.PlaceInput(lat, lng, address.trim(), landmark == null || landmark.isBlank() ? null : landmark.trim());
        }
    }

    record LoadCreate(@NotNull Instant pickupWindowStart, @NotNull Instant pickupWindowEnd, @NotNull @Valid Place pickup,
                      @NotBlank @Size(min = 2, max = 60) String senderName,
                      @NotBlank @Pattern(regexp = MOBILE, message = "Enter a valid 10-digit mobile") String senderMobile,
                      @NotBlank @Size(max = 60) String goodsType, @Size(max = 300) String description,
                      @NotNull @Positive @DecimalMax("1000000") BigDecimal quantity, @NotNull QuantityUnit quantityUnit,
                      @NotNull @Positive BigDecimal weightTonnes, @NotNull VehicleType vehicleType,
                      @NotNull @Valid Place drop, @NotBlank @Size(min = 2, max = 60) String receiverName,
                      @NotBlank @Pattern(regexp = MOBILE, message = "Enter a valid 10-digit mobile") String receiverMobile,
                      @NotNull FreightPayer freightPaidBy, @NotNull @Min(1) @Max(10_000_000) Long amountInr,
                      UUID postedForFarmerId, LoadAudience audience, List<UUID> wishlistEntryIds) {
        LoadService.LoadInput input() {
            return new LoadService.LoadInput(pickupWindowStart, pickupWindowEnd, pickup.input(), senderName.trim(), senderMobile,
                    goodsType, description == null || description.isBlank() ? null : description.trim(), quantity,
                    quantityUnit, weightTonnes, vehicleType, drop.input(), receiverName.trim(), receiverMobile, freightPaidBy,
                    amountInr, postedForFarmerId, audience, wishlistEntryIds);
        }
    }

    record EstimateRequest(@NotNull @Valid GeoPoint pickup, @NotNull @Valid GeoPoint drop, @NotNull Instant pickupWindowStart,
                           VehicleType vehicleType) {
    }

    record Cancel(@NotBlank String reason, @Size(max = 500) String note) {
    }

    @PostMapping("/estimate")
    @Operation(summary = "Distance, drive time and delivery estimate (+ suggested amount range when history exists)")
    LoadService.Estimate estimate(@Valid @RequestBody EstimateRequest req) {
        return loads.estimate(CurrentUser.id(), req.pickup(), req.drop(), req.pickupWindowStart(), req.vehicleType());
    }

    @PostMapping
    @RequiresVerified
    Map<String, Object> create(@Valid @RequestBody LoadCreate req) {
        return loads.create(CurrentUser.id(), req.input());
    }

    @GetMapping
    Map<String, Object> list(@RequestParam(defaultValue = "ONGOING") @Pattern(regexp = "ONGOING|HISTORY") String scope,
                             @RequestParam(required = false) UUID farmerId, @RequestParam(required = false) String q,
                             @RequestParam(defaultValue = "0") @Min(0) int page,
                             @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return loads.list(CurrentUser.id(), "ONGOING".equals(scope), farmerId, q, page, size);
    }

    @GetMapping("/{id}")
    Map<String, Object> detail(@PathVariable UUID id) {
        return loads.shipperDetail(CurrentUser.id(), id);
    }

    @PutMapping("/{id}")
    @RequiresVerified
    Map<String, Object> update(@PathVariable UUID id, @Valid @RequestBody LoadCreate req) {
        return loads.update(CurrentUser.id(), id, req.input());
    }

    @PostMapping("/{id}/cancel")
    Map<String, Object> cancel(@PathVariable UUID id, @Valid @RequestBody Cancel req) {
        return loads.cancel(CurrentUser.id(), id, req.reason(), req.note());
    }

    @PostMapping("/{id}/repost")
    @RequiresVerified
    Map<String, Object> repost(@PathVariable UUID id) {
        return loads.repost(CurrentUser.id(), id);
    }

    @PostMapping("/{id}/open-to-everyone")
    Map<String, Object> openToEveryone(@PathVariable UUID id) {
        return loads.openToEveryone(CurrentUser.id(), id);
    }
}
