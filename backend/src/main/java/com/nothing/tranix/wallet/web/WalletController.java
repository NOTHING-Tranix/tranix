package com.nothing.tranix.wallet.web;

import java.time.YearMonth;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import com.nothing.tranix.shared.security.CurrentUser;
import com.nothing.tranix.shared.types.TxnType;
import com.nothing.tranix.wallet.internal.TopupService;
import com.nothing.tranix.wallet.internal.WalletService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** Contract §5 + admin wallet actions (§13). */
@RestController
@Tag(name = "Wallet")
class WalletController {

    private final WalletService wallet;
    private final TopupService topups;

    WalletController(WalletService wallet, TopupService topups) {
        this.wallet = wallet;
        this.topups = topups;
    }

    record TopupRequest(@NotNull @Positive Long amountInr) {
    }

    record AdminAmount(@NotNull @Positive @Max(1_000_000) Long amountInr, String reason, UUID loadId) {
    }

    @GetMapping("/api/v1/wallet")
    Map<String, Object> wallet() {
        return wallet.wallet(CurrentUser.id());
    }

    @GetMapping("/api/v1/wallet/transactions")
    Map<String, Object> transactions(@RequestParam(required = false) TxnType type,
                                     @RequestParam(required = false) YearMonth month,
                                     @RequestParam(defaultValue = "0") @Min(0) int page,
                                     @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return wallet.transactions(CurrentUser.id(), type, month, page, size);
    }

    @GetMapping(value = "/api/v1/wallet/statement", produces = MediaType.APPLICATION_PDF_VALUE)
    ResponseEntity<byte[]> statement(@RequestParam YearMonth month) {
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=tranix-statement-" + month + ".pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(wallet.statementPdf(CurrentUser.id(), month));
    }

    @PostMapping("/api/v1/wallet/topup-link")
    @Operation(summary = "Signed 15-minute link to the web top-up page (open in the external browser)")
    TopupService.Link topupLink(@Valid @RequestBody TopupRequest req) {
        return topups.createLink(CurrentUser.id(), req.amountInr());
    }

    @PostMapping("/api/v1/webhooks/payments")
    @Operation(summary = "Gateway webhook (signature-verified, idempotent). Not called by the app")
    @SecurityRequirements
    ResponseEntity<Map<String, Object>> webhook(@RequestBody String rawBody,
                                                @RequestHeader(value = "X-Signature", required = false) String signature,
                                                @RequestHeader(value = "X-Razorpay-Signature", required = false) String razorpaySignature) {
        TopupService.WebhookResult r = topups.handleWebhook(rawBody, razorpaySignature != null ? razorpaySignature : signature);
        // B-1616: a refused webhook is a normal problem body with a code (result kept for the gateway logs)
        return r == TopupService.WebhookResult.BAD_SIGNATURE
                ? ResponseEntity.badRequest().contentType(MediaType.APPLICATION_PROBLEM_JSON).body(Map.of(
                        "type", "about:blank", "title", "Validation failed", "status", 400, "code", "VALIDATION_FAILED",
                        "detail", "Bad or missing signature", "fields", List.of(), "result", r.name()))
                : ResponseEntity.ok(Map.of("result", r.name()));
    }

    @PostMapping("/api/v1/admin/wallet/{userId}/credit")
    Map<String, String> adminCredit(@PathVariable UUID userId, @Valid @RequestBody AdminAmount req) {
        return Map.of("txnId", wallet.adminCredit(userId, req.amountInr(), req.reason(), CurrentUser.id()));
    }

    @PostMapping("/api/v1/admin/wallet/{userId}/refund")
    Map<String, String> adminRefund(@PathVariable UUID userId, @Valid @RequestBody AdminAmount req) {
        return Map.of("txnId", wallet.adminRefund(userId, req.amountInr(), req.loadId(), req.reason(), CurrentUser.id()));
    }
}
