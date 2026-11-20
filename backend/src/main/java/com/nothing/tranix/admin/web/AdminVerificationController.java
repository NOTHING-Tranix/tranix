package com.nothing.tranix.admin.web;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.identity.api.DocumentRegistry;
import com.nothing.tranix.identity.api.VerificationReview;
import com.nothing.tranix.shared.security.CurrentUser;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** B-203: verification queue and per-document decisions (role ADMIN via SecurityConfig). */
@RestController
@RequestMapping("/api/v1/admin")
@Tag(name = "Admin · Verification")
class AdminVerificationController {

    private final VerificationReview documents;

    AdminVerificationController(VerificationReview documents) {
        this.documents = documents;
    }

    record Reason(String reason) {
    }

    @GetMapping("/verifications")
    @Operation(summary = "Users UNDER_REVIEW by tab (VEHICLE = pending truck documents)")
    List<Map<String, Object>> queue(@RequestParam(defaultValue = "IDENTITY") VerificationReview.Tab tab) {
        return documents.queue(tab);
    }

    @PostMapping("/documents/{id}/approve")
    DocumentRegistry.DocumentView approve(@PathVariable UUID id) {
        return documents.review(CurrentUser.id(), id, true, null);
    }

    @PostMapping("/documents/{id}/reject")
    DocumentRegistry.DocumentView reject(@PathVariable UUID id, @RequestBody Reason body) {
        return documents.review(CurrentUser.id(), id, false, body.reason());
    }
}
