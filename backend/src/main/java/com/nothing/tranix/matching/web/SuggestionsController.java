package com.nothing.tranix.matching.web;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import jakarta.validation.constraints.Pattern;

import com.nothing.tranix.identity.api.RequiresVerified;
import com.nothing.tranix.matching.internal.MatchingService;
import com.nothing.tranix.shared.security.CurrentUser;
import com.nothing.tranix.shared.types.SuggestionRejectReason;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** Contract §8 (suggestions). */
@RestController
@RequestMapping("/api/v1/driver/suggestions")
@Tag(name = "Driver")
class SuggestionsController {

    private final MatchingService matching;

    SuggestionsController(MatchingService matching) {
        this.matching = matching;
    }

    record Reject(SuggestionRejectReason reason) {
    }

    @GetMapping
    @Operation(summary = "Area-only suggestions; empty when off duty, not verified or wallet below the trip charge")
    List<Map<String, Object>> list(@RequestParam(defaultValue = "NEAREST") @Pattern(regexp = "NEAREST|AMOUNT|EARLIEST") String sort) {
        return matching.suggestions(CurrentUser.id(), sort);
    }

    @PostMapping("/{loadId}/accept")
    @RequiresVerified
    @Operation(summary = "First accept wins; deducts posting + trip charges. LOAD_TAKEN / INSUFFICIENT_BALANCE")
    Map<String, Object> accept(@PathVariable UUID loadId) {
        return matching.accept(CurrentUser.id(), loadId);
    }

    @PostMapping("/{loadId}/reject")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void reject(@PathVariable UUID loadId, @RequestBody(required = false) Reject body) {
        matching.reject(CurrentUser.id(), loadId, body == null ? null : body.reason());
    }
}
