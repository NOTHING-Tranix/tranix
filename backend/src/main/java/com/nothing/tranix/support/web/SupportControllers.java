package com.nothing.tranix.support.web;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.shared.security.CurrentUser;
import com.nothing.tranix.shared.types.TicketType;
import com.nothing.tranix.support.internal.SupportService;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

final class SupportBodies {

    private SupportBodies() {
    }

    record NewTicket(@NotNull TicketType type, @Size(max = 60) String otherText, UUID loadId, @NotBlank @Size(max = 1000) String description,
                     @Size(max = 3) List<UUID> fileIds) {
    }

    record Message(@NotBlank @Size(max = 1000) String body, @Size(max = 3) List<UUID> fileIds) {
    }

    record Reply(@NotBlank @Size(max = 1000) String body, Boolean close) {
    }

    record Ignore(@NotBlank @Size(max = 300) String reason) {
    }
}

/** Contract §11 support (any signed-in user). */
@RestController
@RequestMapping("/api/v1/tickets")
class TicketsController {

    private final SupportService support;

    TicketsController(SupportService support) {
        this.support = support;
    }

    @GetMapping
    List<Map<String, Object>> list() {
        return support.list(CurrentUser.id());
    }

    @PostMapping
    Map<String, Object> create(@Valid @RequestBody SupportBodies.NewTicket req) {
        return support.create(CurrentUser.id(), req.type(), req.otherText(), req.loadId(), req.description(), req.fileIds());
    }

    @GetMapping("/{id}")
    Map<String, Object> detail(@PathVariable UUID id) {
        return support.detail(CurrentUser.id(), id);
    }

    @PostMapping("/{id}/messages")
    Map<String, Object> message(@PathVariable UUID id, @Valid @RequestBody SupportBodies.Message req) {
        return support.message(CurrentUser.id(), id, req.body(), req.fileIds());
    }

    @PostMapping("/{id}/reopen")
    Map<String, Object> reopen(@PathVariable UUID id) {
        return support.reopen(CurrentUser.id(), id);
    }
}

/** §13 admin: tickets (ADMIN role enforced by security). */
@RestController
@RequestMapping("/api/v1/admin/tickets")
class AdminTicketsController {

    private final SupportService support;

    AdminTicketsController(SupportService support) {
        this.support = support;
    }

    @GetMapping
    List<Map<String, Object>> list(@RequestParam(required = false) @Pattern(regexp = "OPEN|CLOSED") String status) {
        return support.adminList(status);
    }

    @GetMapping("/{id}")
    Map<String, Object> detail(@PathVariable UUID id) {
        return support.adminDetail(id);
    }

    @PostMapping("/{id}/reply")
    Map<String, Object> reply(@PathVariable UUID id, @Valid @RequestBody SupportBodies.Reply req) {
        return support.reply(CurrentUser.id(), id, req.body(), Boolean.TRUE.equals(req.close()));
    }

    @PostMapping("/{id}/ignore")
    Map<String, Object> ignore(@PathVariable UUID id, @Valid @RequestBody SupportBodies.Ignore req) {
        return support.ignore(CurrentUser.id(), id, req.reason());
    }
}

/**
 * B-1408 (Q-08): privacy policy and terms (public; text is a draft until legal review) and the in-app account
 * deletion request, which opens a support ticket for Tranix to process within the legal retention rules.
 */
@RestController
class LegalController {

    private final SupportService support;

    LegalController(SupportService support) {
        this.support = support;
    }

    record DeletionRequest(@Size(max = 500) String reason) {
    }

    @GetMapping("/api/v1/legal/{doc}")
    Map<String, Object> legal(@PathVariable @Pattern(regexp = "privacy|terms") String doc) {
        return Map.of("doc", doc, "version", "draft-2026-11-21", "status", "DRAFT_PENDING_LEGAL_REVIEW",
                "text", "privacy".equals(doc) ? PRIVACY : TERMS);
    }

    @PostMapping("/api/v1/me/deletion-request")
    Map<String, Object> deletion(@Valid @RequestBody(required = false) DeletionRequest req) {
        String reason = req == null || req.reason() == null || req.reason().isBlank() ? "No reason given" : req.reason().trim();
        return support.create(CurrentUser.id(), com.nothing.tranix.shared.types.TicketType.OTHERS, "Account deletion", null,
                "Please delete my Tranix account and personal data. Reason: " + reason, List.of());
    }

    static final String PRIVACY = """
            Tranix collects your name, mobile number, role details and documents to verify you; trip details and, during an \
            active trip only, the driver's location. Aadhaar: only the last 4 digits and the verification result are kept. \
            Phone numbers and exact addresses are shared with the other party only after a load is accepted. Location detail \
            is kept for 90 days. You can ask for your account to be deleted from the app (Profile → Support or Delete account). \
            This is a draft pending legal review.""";

    static final String TERMS = """
            Tranix connects verified load providers, Farmer Networks, drivers, Organizations and receivers. The posting and \
            trip charges are deducted from the wallet when a load is accepted. Freight is paid directly between the parties; \
            Tranix records the payment status. First accept wins. This is a draft pending legal review.""";
}
