package com.nothing.tranix.payments.web;

import java.time.YearMonth;
import java.util.Map;
import java.util.UUID;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import com.nothing.tranix.payments.internal.PaymentService;
import com.nothing.tranix.shared.security.CurrentUser;
import com.nothing.tranix.shared.types.PaymentMode;

import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** Contract §6/§8 payments + driver history (B-801, B-802, B-807). */
@RestController
@Tag(name = "Payments")
class PaymentController {

    private final PaymentService payments;

    PaymentController(PaymentService payments) {
        this.payments = payments;
    }

    record MarkPaid(@NotNull @Positive Long amountInr, @NotNull PaymentMode mode, @Size(max = 60) String reference) {
    }

    record Confirm(@NotNull @Positive Long amountInr) {
    }

    record Dispute(@NotBlank @Size(max = 500) String reason) {
    }

    record Decide(@NotBlank String decision) {
    }

    @PostMapping("/api/v1/loads/{id}/payment/mark-paid")
    Map<String, Object> markPaid(@PathVariable UUID id, @Valid @RequestBody MarkPaid req) {
        return payments.markPaid(CurrentUser.id(), id, req.amountInr(), req.mode(), req.reference());
    }

    @PostMapping("/api/v1/driver/trips/{id}/payment/confirm")
    Map<String, Object> confirm(@PathVariable UUID id, @Valid @RequestBody Confirm req) {
        return payments.confirm(CurrentUser.id(), id, req.amountInr());
    }

    @PostMapping("/api/v1/driver/trips/{id}/payment/dispute")
    Map<String, Object> dispute(@PathVariable UUID id, @Valid @RequestBody Dispute req) {
        return payments.dispute(CurrentUser.id(), id, req.reason());
    }

    @GetMapping("/api/v1/driver/history")
    Map<String, Object> history(@RequestParam(required = false) YearMonth month) {
        return payments.driverHistory(CurrentUser.id(), month);
    }

    @PostMapping("/api/v1/admin/payment-disputes/{loadId}/decide")
    Map<String, Object> decide(@PathVariable UUID loadId, @Valid @RequestBody Decide req) {
        return payments.decideDispute(CurrentUser.id(), loadId, req.decision());
    }
}
