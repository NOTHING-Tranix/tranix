package com.nothing.tranix.trust.web;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import com.nothing.tranix.shared.security.CurrentUser;
import com.nothing.tranix.trust.internal.TrustService;

import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** Contract §11: ratings and Trust Score; admin adjustment (§13). */
@RestController
@Tag(name = "Ratings · Trust Score")
class TrustController {

    private final TrustService trust;

    TrustController(TrustService trust) {
        this.trust = trust;
    }

    record Rating(@NotNull UUID loadId, @NotNull UUID rateeUserId, @NotNull @Min(1) @Max(5) Integer stars,
                  @Size(max = 6) List<@Size(max = 40) String> tags, @Size(max = 500) String comment) {
    }

    record Adjust(@NotNull BigDecimal points, @NotBlank @Size(max = 300) String reason) {
    }

    @GetMapping("/api/v1/ratings/pending")
    List<Map<String, Object>> pending() {
        return trust.pendingFor(CurrentUser.id());
    }

    @PostMapping("/api/v1/ratings")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void rate(@Valid @RequestBody Rating req) {
        trust.rate(CurrentUser.id(), req.loadId(), req.rateeUserId(), req.stars(), req.tags(), req.comment());
    }

    @PostMapping("/api/v1/ratings/{loadId}/later")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void later(@PathVariable UUID loadId) {
        trust.later(CurrentUser.id(), loadId);
    }

    @GetMapping("/api/v1/trust-score")
    Map<String, Object> score() {
        return trust.trustScore(CurrentUser.id());
    }

    @GetMapping("/api/v1/trust-score/events")
    Map<String, Object> events(@RequestParam(defaultValue = "0") @Min(0) int page,
                               @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return trust.events(CurrentUser.id(), page, size);
    }

    @PostMapping("/api/v1/admin/trust-score/{userId}/adjust")
    Map<String, Object> adjust(@PathVariable UUID userId, @Valid @RequestBody Adjust req) {
        return Map.of("score", trust.adjust(userId, req.points(), req.reason(), CurrentUser.id()));
    }
}

