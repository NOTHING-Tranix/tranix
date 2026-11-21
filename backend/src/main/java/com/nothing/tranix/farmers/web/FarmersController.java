package com.nothing.tranix.farmers.web;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.farmers.internal.FarmerService;
import com.nothing.tranix.identity.api.RequiresVerified;
import com.nothing.tranix.shared.security.CurrentUser;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/** Contract §7 — Farmer Network farmers. */
@RestController
@RequestMapping("/api/v1/farmers")
class FarmersController {

    private final FarmerService farmers;

    FarmersController(FarmerService farmers) {
        this.farmers = farmers;
    }

    record Body(String name, String mobile, String aadhaarLast4, BigDecimal landAcres, String village, Boolean consent) {
        FarmerService.FarmerInput input() {
            return new FarmerService.FarmerInput(name, mobile, aadhaarLast4, landAcres, village, consent);
        }
    }

    @GetMapping
    Map<String, Object> list(@RequestParam(required = false) String q, @RequestParam(defaultValue = "false") boolean includeInactive,
                             @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "20") int size) {
        return farmers.list(CurrentUser.id(), q, includeInactive, Math.max(0, page), Math.min(Math.max(1, size), 100));
    }

    @PostMapping
    @RequiresVerified
    Map<String, Object> create(@RequestBody Body req) {
        return farmers.create(CurrentUser.id(), req.input());
    }

    @PutMapping("/{id}")
    @RequiresVerified
    Map<String, Object> update(@PathVariable UUID id, @RequestBody Body req) {
        return farmers.update(CurrentUser.id(), id, req.input());
    }

    @PostMapping("/{id}/deactivate")
    Map<String, Object> deactivate(@PathVariable UUID id) {
        return farmers.deactivate(CurrentUser.id(), id);
    }
}
