package com.nothing.tranix.trips.web;

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
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.shared.geo.GeoPoint;
import com.nothing.tranix.shared.security.CurrentUser;
import com.nothing.tranix.shared.types.OtpPurpose;
import com.nothing.tranix.shared.types.Role;
import com.nothing.tranix.trips.internal.MapLayerService;
import com.nothing.tranix.trips.internal.TripService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

final class TripBodies {
    private TripBodies() {
    }

    record Revision(@NotNull @Min(1) @Max(10_000_000) Long amountInr, @NotBlank @Size(max = 300) String reason) {
    }

    record Reached(@NotNull OtpPurpose purpose, @NotNull @DecimalMin("-90") @DecimalMax("90") Double lat,
                   @NotNull @DecimalMin("-180") @DecimalMax("180") Double lng, @Size(max = 300) String reason) {
    }

    record Verify(@NotNull OtpPurpose purpose, @NotBlank @Pattern(regexp = "^[0-9]{6}$", message = "Enter the 6-digit OTP") String code,
                  @NotNull @DecimalMin("-90") @DecimalMax("90") Double lat, @NotNull @DecimalMin("-180") @DecimalMax("180") Double lng,
                  @Size(max = 300) String reason) {
    }

    record Purpose(@NotNull OtpPurpose purpose) {
    }

    record Help(@NotNull OtpPurpose purpose, Double lat, Double lng, @NotBlank @Size(max = 500) String note) {
    }

    record Point(@NotNull @DecimalMin("-90") @DecimalMax("90") Double lat, @NotNull @DecimalMin("-180") @DecimalMax("180") Double lng,
                 Double speed, @NotNull Instant at) {
    }

    record Cancel(@NotBlank String reason, @Size(max = 500) String note) {
    }
}

/** Contract §8 (trip execution). */
@RestController
@RequestMapping("/api/v1/driver")
@Tag(name = "Driver · Trip")
class DriverTripController {

    private final TripService trips;
    private final LoadDirectory loads;

    DriverTripController(TripService trips, LoadDirectory loads) {
        this.trips = trips;
        this.loads = loads;
    }

    @GetMapping("/current-trip")
    @Operation(summary = "Active trip with exact pins and contacts (only after acceptance); 204 when none")
    ResponseEntity<Map<String, Object>> current() {
        Map<String, Object> t = trips.currentTrip(CurrentUser.id());
        return t == null ? ResponseEntity.noContent().build() : ResponseEntity.ok(t);
    }

    @PostMapping("/trips/{id}/revisions")
    Map<String, Object> revision(@PathVariable UUID id, @Valid @RequestBody TripBodies.Revision req) {
        return trips.requestRevision(CurrentUser.id(), id, req.amountInr(), req.reason());
    }

    @PostMapping("/trips/{id}/reached")
    TripService.ReachedResult reached(@PathVariable UUID id, @Valid @RequestBody TripBodies.Reached req) {
        return trips.reached(CurrentUser.id(), id, req.purpose(), GeoPoint.of(req.lat(), req.lng()), req.reason());
    }

    @PostMapping("/trips/{id}/otp/verify")
    Map<String, Object> verify(@PathVariable UUID id, @Valid @RequestBody TripBodies.Verify req) {
        return trips.verifyOtp(CurrentUser.id(), id, req.purpose(), req.code(), GeoPoint.of(req.lat(), req.lng()), req.reason());
    }

    @PostMapping("/trips/{id}/otp/resend")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void resend(@PathVariable UUID id, @Valid @RequestBody TripBodies.Purpose req) {
        trips.resendOtp(CurrentUser.id(), id, req.purpose());
    }

    @PostMapping("/trips/{id}/otp/help")
    Map<String, Object> help(@PathVariable UUID id, @Valid @RequestBody TripBodies.Help req) {
        return trips.otpHelp(CurrentUser.id(), id, req.purpose(),
                req.lat() == null || req.lng() == null ? null : GeoPoint.of(req.lat(), req.lng()), req.note());
    }

    @PostMapping("/trips/{id}/locations")
    Map<String, Object> locations(@PathVariable UUID id, @Valid @RequestBody @NotEmpty List<TripBodies.Point> points) {
        return Map.of("accepted", trips.locations(CurrentUser.id(), id,
                points.stream().map(p -> new TripService.Point(p.lat(), p.lng(), p.speed(), p.at())).toList()));
    }

    @PostMapping("/trips/{id}/cancel")
    Map<String, Object> cancel(@PathVariable UUID id, @Valid @RequestBody TripBodies.Cancel req) {
        return loads.cancel(CurrentUser.id(), id, req.reason(), req.note());
    }
}

/** Shipper/receiver side of a trip (contract §6). */
@RestController
@RequestMapping("/api/v1/loads/{id}")
@Tag(name = "Loads")
class LoadTripController {

    private final TripService trips;

    LoadTripController(TripService trips) {
        this.trips = trips;
    }

    @GetMapping("/tracking")
    Map<String, Object> tracking(@PathVariable UUID id) {
        return trips.tracking(CurrentUser.id(), id, CurrentUser.role().filter(r -> r == Role.ADMIN).isPresent());
    }

    @GetMapping("/otp")
    @Operation(summary = "Pickup OTP for the sender / delivery OTP for the registered receiver while that step is active")
    Map<String, Object> otp(@PathVariable UUID id) {
        return trips.viewOtp(CurrentUser.id(), id);
    }

    @PostMapping("/revisions/{revisionId}/confirm")
    Map<String, Object> confirm(@PathVariable UUID id, @PathVariable UUID revisionId) {
        return trips.answerRevision(CurrentUser.id(), id, revisionId, true);
    }

    @PostMapping("/revisions/{revisionId}/reject")
    Map<String, Object> reject(@PathVariable UUID id, @PathVariable UUID revisionId) {
        return trips.answerRevision(CurrentUser.id(), id, revisionId, false);
    }
}

/** B-710 map layers. */
@RestController
@RequestMapping("/api/v1/map")
@Tag(name = "Map")
class MapController {

    private final MapLayerService layers;

    MapController(MapLayerService layers) {
        this.layers = layers;
    }

    @GetMapping("/route-services")
    List<Map<String, Object>> services(@RequestParam String bbox, @RequestParam(required = false) List<String> types) {
        return layers.services(bbox, types);
    }

    @GetMapping("/restrictions")
    List<Map<String, Object>> restrictions(@RequestParam String bbox) {
        return layers.restrictions(bbox);
    }
}
