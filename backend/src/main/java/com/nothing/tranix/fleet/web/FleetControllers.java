package com.nothing.tranix.fleet.web;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import com.nothing.tranix.fleet.api.DriverHomeContributor;
import com.nothing.tranix.fleet.internal.FleetService;
import com.nothing.tranix.fleet.internal.OrgService;
import com.nothing.tranix.identity.api.DocumentRegistry;
import com.nothing.tranix.identity.api.RequiresVerified;
import com.nothing.tranix.shared.security.CurrentUser;
import com.nothing.tranix.shared.types.DocumentType;
import com.nothing.tranix.shared.types.LoadStatus;
import com.nothing.tranix.shared.types.VehicleType;
import com.nothing.tranix.wallet.api.WalletApi;

import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.beans.factory.ObjectProvider;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

final class FleetBodies {
    private FleetBodies() {
    }

    record TruckBody(@NotBlank @Size(max = 16) String number, @NotNull VehicleType vehicleType,
                     @NotNull @Positive BigDecimal capacityTonnes) {
    }

    record TruckDocument(@NotNull DocumentType type, @NotEmpty @Size(max = 3) List<UUID> fileIds,
                         @Size(max = 30) String number, LocalDate expiresOn) {
    }
}

/** Contract §8 (driver fleet parts). */
@RestController
@RequestMapping("/api/v1/driver")
@Tag(name = "Driver")
class DriverFleetController {

    private final FleetService fleet;
    private final OrgService orgs;
    private final ObjectProvider<DriverHomeContributor> contributors;
    private final WalletApi wallet;

    DriverFleetController(FleetService fleet, OrgService orgs, ObjectProvider<DriverHomeContributor> contributors, WalletApi wallet) {
        this.fleet = fleet;
        this.orgs = orgs;
        this.contributors = contributors;
        this.wallet = wallet;
    }

    /** lat/lng: the phone's position when going on duty (so nearby loads can be suggested before any trip). */
    record Duty(@NotNull Boolean onDuty, Double lat, Double lng) {
    }

    @PutMapping("/duty")
    Map<String, Object> duty(@Valid @RequestBody Duty req) {
        return fleet.setDuty(CurrentUser.id(), req.onDuty(), req.lat(), req.lng());
    }

    @GetMapping("/home")
    Map<String, Object> home() {
        return fleet.driverHome(CurrentUser.id(), contributors, wallet, id -> orgs.orgName(id, ""));
    }

    @GetMapping("/truck")
    ResponseEntity<Map<String, Object>> truck() {
        Map<String, Object> t = fleet.driverTruck(CurrentUser.id());
        return t == null ? ResponseEntity.noContent().build() : ResponseEntity.ok(t);
    }

    @PostMapping("/truck")
    Map<String, Object> addTruck(@Valid @RequestBody FleetBodies.TruckBody req) {
        return fleet.createOwnTruck(CurrentUser.id(), req.number(), req.vehicleType(), req.capacityTonnes());
    }

    @PutMapping("/truck")
    Map<String, Object> updateTruck(@Valid @RequestBody FleetBodies.TruckBody req) {
        return fleet.updateOwnTruck(CurrentUser.id(), req.number(), req.vehicleType(), req.capacityTonnes());
    }

    @PostMapping("/truck/documents")
    DocumentRegistry.DocumentView truckDocument(@Valid @RequestBody FleetBodies.TruckDocument req) {
        return fleet.ownTruckDocument(CurrentUser.id(), req.type(), req.fileIds(), req.number(), req.expiresOn());
    }

    @GetMapping("/invitations")
    List<Map<String, Object>> invitations() {
        return orgs.invitationsForDriver(CurrentUser.id());
    }

    @PostMapping("/invitations/{id}/accept")
    Map<String, Object> accept(@PathVariable UUID id) {
        return orgs.respond(CurrentUser.id(), id, true);
    }

    @PostMapping("/invitations/{id}/reject")
    Map<String, Object> reject(@PathVariable UUID id) {
        return orgs.respond(CurrentUser.id(), id, false);
    }
}

/** Contract §9. */
@RestController
@RequestMapping("/api/v1/org")
@Tag(name = "Organization")
class OrgController {

    private final OrgService orgs;

    OrgController(OrgService orgs) {
        this.orgs = orgs;
    }

    record Invite(@NotBlank @Size(min = 2, max = 60) String name,
                  @NotBlank @Pattern(regexp = "^[6-9][0-9]{9}$", message = "Enter a valid 10-digit mobile") String mobile) {
    }

    record Allocate(@NotNull UUID driverId, @NotNull UUID truckId) {
    }

    record AllocationChange(UUID driverId, UUID truckId, @Pattern(regexp = "ACTIVE|PAUSED") String status) {
    }

    @GetMapping("/dashboard")
    Map<String, Object> dashboard() {
        return orgs.dashboard(CurrentUser.id());
    }

    @GetMapping("/trucks")
    List<Map<String, Object>> trucks() {
        return orgs.trucks(CurrentUser.id());
    }

    @PostMapping("/trucks")
    Map<String, Object> addTruck(@Valid @RequestBody FleetBodies.TruckBody req) {
        return orgs.addTruck(CurrentUser.id(), req.number(), req.vehicleType(), req.capacityTonnes());
    }

    @PutMapping("/trucks/{id}")
    Map<String, Object> updateTruck(@PathVariable UUID id, @Valid @RequestBody FleetBodies.TruckBody req) {
        return orgs.updateTruck(CurrentUser.id(), id, req.number(), req.vehicleType(), req.capacityTonnes());
    }

    @PostMapping("/trucks/{id}/deactivate")
    Map<String, Object> deactivate(@PathVariable UUID id) {
        return orgs.deactivateTruck(CurrentUser.id(), id);
    }

    @PostMapping("/trucks/{id}/documents")
    DocumentRegistry.DocumentView truckDocument(@PathVariable UUID id, @Valid @RequestBody FleetBodies.TruckDocument req) {
        return orgs.truckDocument(CurrentUser.id(), id, req.type(), req.fileIds(), req.number(), req.expiresOn());
    }

    @GetMapping("/trucks/{id}/location")
    Map<String, Object> location(@PathVariable UUID id) {
        return orgs.truckLocation(CurrentUser.id(), id);
    }

    @GetMapping("/drivers")
    List<Map<String, Object>> drivers() {
        return orgs.drivers(CurrentUser.id());
    }

    @PostMapping("/drivers")
    Map<String, Object> invite(@Valid @RequestBody Invite req) {
        return orgs.invite(CurrentUser.id(), req.name(), req.mobile());
    }

    @GetMapping("/drivers/{id}/performance")
    Map<String, Object> performance(@PathVariable UUID id) {
        return orgs.performance(CurrentUser.id(), id);
    }

    @PostMapping("/allocations")
    @RequiresVerified
    Map<String, Object> allocate(@Valid @RequestBody Allocate req) {
        return orgs.allocate(CurrentUser.id(), req.driverId(), req.truckId());
    }

    @GetMapping("/allocations")
    List<Map<String, Object>> allocations() {
        return orgs.allocations(CurrentUser.id());
    }

    @PutMapping("/allocations/{id}")
    @RequiresVerified
    Map<String, Object> updateAllocation(@PathVariable UUID id, @Valid @RequestBody AllocationChange req) {
        return orgs.updateAllocation(CurrentUser.id(), id, req.driverId(), req.truckId(), req.status());
    }

    @DeleteMapping("/allocations/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void removeAllocation(@PathVariable UUID id) {
        orgs.removeAllocation(CurrentUser.id(), id);
    }

    @GetMapping("/trips")
    List<Map<String, Object>> trips(@RequestParam(required = false) @Pattern(regexp = "DRIVER|TRUCK") String by,
                                    @RequestParam(required = false) UUID id, @RequestParam(required = false) Instant from,
                                    @RequestParam(required = false) Instant to, @RequestParam(required = false) LoadStatus status) {
        return orgs.trips(CurrentUser.id(), by, id, from, to, status);
    }

    @GetMapping(value = "/trips/export", produces = "text/csv")
    ResponseEntity<String> export(@RequestParam(required = false) @Pattern(regexp = "DRIVER|TRUCK") String by,
                                  @RequestParam(required = false) UUID id, @RequestParam(required = false) Instant from,
                                  @RequestParam(required = false) Instant to, @RequestParam(required = false) LoadStatus status) {
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=tranix-trips.csv")
                .contentType(MediaType.parseMediaType("text/csv; charset=UTF-8"))
                .body(orgs.tripsCsv(CurrentUser.id(), by, id, from, to, status));
    }
}
