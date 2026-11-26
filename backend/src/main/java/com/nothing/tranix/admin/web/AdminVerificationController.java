package com.nothing.tranix.admin.web;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.fleet.api.FleetApi;
import com.nothing.tranix.identity.api.DocumentRegistry;
import com.nothing.tranix.identity.api.UserDirectory;
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
    private final FleetApi fleet;
    private final UserDirectory users;

    AdminVerificationController(VerificationReview documents, FleetApi fleet, UserDirectory users) {
        this.documents = documents;
        this.fleet = fleet;
        this.users = users;
    }

    record Reason(String reason) {
    }

    @GetMapping("/verifications")
    @Operation(summary = "Users UNDER_REVIEW by tab (VEHICLE = pending truck documents)")
    List<Map<String, Object>> queue(@RequestParam(defaultValue = "IDENTITY") VerificationReview.Tab tab) {
        List<Map<String, Object>> queue = documents.queue(tab);
        return tab == VerificationReview.Tab.VEHICLE ? queue.stream().map(this::withTruck).toList() : queue;
    }

    /** B-1609: a VEHICLE entry says which truck it is and whose — the identity module only knows the truck id. */
    private Map<String, Object> withTruck(Map<String, Object> entry) {
        Map<String, Object> m = new LinkedHashMap<>();
        Object ownerId = entry.get("ownerId");
        fleet.truck(ownerId instanceof UUID id ? id : UUID.fromString(String.valueOf(ownerId))).ifPresent(t -> {
            m.put("truckId", t.id());
            m.put("truckNumber", t.number());
            m.put("vehicleType", t.vehicleType());
            m.put("capacityTonnes", t.capacityTonnes());
            UUID owner = t.orgId() != null ? t.orgId() : t.ownerDriverId();
            m.put("ownerRole", t.orgId() != null ? "ORGANIZATION" : "DRIVER");
            users.find(owner).ifPresent(u -> {
                m.put("ownerName", u.name());
                m.put("ownerMobile", u.mobile());
            });
        });
        m.putAll(entry);
        return m;
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
