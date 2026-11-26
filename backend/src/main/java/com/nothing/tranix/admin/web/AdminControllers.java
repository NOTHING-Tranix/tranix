package com.nothing.tranix.admin.web;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.admin.internal.AdminService;
import com.nothing.tranix.shared.security.CurrentUser;
import com.nothing.tranix.shared.types.LoadStatus;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import org.springframework.http.HttpStatus;
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

/** §13 admin back office (ADMIN role enforced by security for /api/v1/admin/**). Reasons are required where an action affects a user. */
@RestController
@RequestMapping("/api/v1/admin")
class AdminControllers {

    private final AdminService admin;

    AdminControllers(AdminService admin) {
        this.admin = admin;
    }

    record Reason(@NotBlank @Size(max = 500) String reason) {
    }

    record OtpOverride(@NotBlank @Pattern(regexp = "PICKUP|DELIVERY") String purpose, @NotBlank @Size(max = 500) String reason) {
    }

    record Decision(@NotBlank String decision, @NotBlank @Size(max = 500) String reason) {
    }

    record Review(@NotBlank @Pattern(regexp = "OK|FLAGGED") String decision, @Size(max = 500) String note) {
    }

    record SettingValue(@NotNull String value, @NotBlank @Size(max = 500) String reason) {
    }

    record Restriction(@NotBlank @Size(max = 120) String name, double lat, double lng, @NotNull BigDecimal radiusKm, LocalTime noEntryFrom,
                       LocalTime noEntryTo, List<String> vehicleTypes, @Size(max = 300) String note, Boolean active) {
        AdminService.Restriction toModel() {
            return new AdminService.Restriction(name, lat, lng, radiusKm, noEntryFrom, noEntryTo, vehicleTypes, note, active);
        }
    }

    @GetMapping("/dashboard")
    Map<String, Object> dashboard() {
        return admin.dashboard();
    }

    @GetMapping("/loads")
    Map<String, Object> loads(@RequestParam(required = false) LoadStatus status, @RequestParam(required = false) String q,
                              @RequestParam(defaultValue = "0") @Min(0) int page) {
        // B-1605: an unknown status is a 400 (enum binding), not an empty list
        return admin.loads(status == null ? null : status.name(), q, page);
    }

    @GetMapping("/loads/{id}")
    Map<String, Object> load(@PathVariable UUID id) {
        return admin.load(id);
    }

    @PostMapping("/loads/{id}/cancel")
    Map<String, Object> cancel(@PathVariable UUID id, @Valid @RequestBody Reason req) {
        return admin.cancelLoad(CurrentUser.id(), id, req.reason());
    }

    @PostMapping("/loads/{id}/otp-override")
    Map<String, Object> otpOverride(@PathVariable UUID id, @Valid @RequestBody OtpOverride req) {
        return admin.otpOverride(CurrentUser.id(), id, req.purpose(), req.reason());
    }

    @GetMapping("/fleet")
    Map<String, Object> fleet(@RequestParam(required = false) String q, @RequestParam(defaultValue = "0") @Min(0) int page) {
        return admin.fleet(q, page);
    }

    @GetMapping("/users")
    Map<String, Object> users(@RequestParam(required = false) String q, @RequestParam(required = false) String role,
                              @RequestParam(defaultValue = "0") @Min(0) int page) {
        return admin.users(q, role, page);
    }

    @PostMapping("/users/{id}/suspend")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void suspend(@PathVariable UUID id, @Valid @RequestBody Reason req) {
        admin.suspend(CurrentUser.id(), id, true, req.reason());
    }

    @PostMapping("/users/{id}/reactivate")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void reactivate(@PathVariable UUID id, @Valid @RequestBody Reason req) {
        admin.suspend(CurrentUser.id(), id, false, req.reason());
    }

    @GetMapping("/cancellations")
    List<Map<String, Object>> cancellations(@RequestParam(defaultValue = "true") boolean pending) {
        return admin.cancellations(pending);
    }

    @PostMapping("/cancellations/{id}/decide")
    Map<String, Object> decide(@PathVariable UUID id, @Valid @RequestBody Decision req) {
        return admin.decideCancellation(CurrentUser.id(), id, req.decision(), req.reason());
    }

    @GetMapping("/payment-disputes")
    List<Map<String, Object>> disputes() {
        return admin.paymentDisputes();
    }

    @GetMapping("/location-exceptions")
    List<Map<String, Object>> exceptions(@RequestParam(defaultValue = "PENDING") @Pattern(regexp = "PENDING|OK|FLAGGED") String status) {
        return admin.locationExceptions(status);
    }

    @PostMapping("/location-exceptions/{id}/review")
    Map<String, Object> review(@PathVariable UUID id, @Valid @RequestBody Review req) {
        return admin.reviewException(CurrentUser.id(), id, req.decision(), req.note());
    }

    @GetMapping("/settings")
    List<Map<String, Object>> settings() {
        return admin.settingsList();
    }

    @PutMapping("/settings/{key}")
    Map<String, Object> setting(@PathVariable String key, @Valid @RequestBody SettingValue req) {
        return admin.updateSetting(CurrentUser.id(), key, req.value(), req.reason());
    }

    @GetMapping("/map-restrictions")
    List<Map<String, Object>> restrictions() {
        return admin.restrictions();
    }

    @PostMapping("/map-restrictions")
    Map<String, Object> addRestriction(@Valid @RequestBody Restriction req) {
        return admin.saveRestriction(CurrentUser.id(), null, req.toModel());
    }

    @PutMapping("/map-restrictions/{id}")
    Map<String, Object> updateRestriction(@PathVariable UUID id, @Valid @RequestBody Restriction req) {
        return admin.saveRestriction(CurrentUser.id(), id, req.toModel());
    }

    @DeleteMapping("/map-restrictions/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void deactivateRestriction(@PathVariable UUID id) {
        admin.deactivateRestriction(CurrentUser.id(), id);
    }

    @GetMapping("/audit")
    Map<String, Object> audit(@RequestParam(required = false) String entity, @RequestParam(required = false) UUID actorId,
                              @RequestParam(required = false) String action, @RequestParam(defaultValue = "0") @Min(0) int page) {
        return admin.audit(entity, actorId, action, page);
    }
}
