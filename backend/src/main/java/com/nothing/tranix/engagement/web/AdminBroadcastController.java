package com.nothing.tranix.engagement.web;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.engagement.internal.BroadcastService;
import com.nothing.tranix.shared.security.CurrentUser;
import com.nothing.tranix.shared.types.Role;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** B-1103 / §13 admin: broadcasts (ADMIN role enforced by security for /api/v1/admin/**). */
@RestController
@RequestMapping("/api/v1/admin/broadcasts")
class AdminBroadcastController {

    private final BroadcastService broadcasts;

    AdminBroadcastController(BroadcastService broadcasts) {
        this.broadcasts = broadcasts;
    }

    record Body(@NotBlank @Size(max = 80) String title, @NotBlank @Size(max = 500) String body,
                @NotBlank @Pattern(regexp = "ALL|ROLE|DISTRICT|USER") String audience, Role role, @Size(max = 100) String district,
                UUID userId, Instant sendAt) {
    }

    @PostMapping
    Map<String, Object> create(@Valid @RequestBody Body b) {
        return broadcasts.create(CurrentUser.id(), new BroadcastService.Input(b.title(), b.body(), b.audience(), b.role(), b.district(),
                b.userId(), b.sendAt()));
    }

    @GetMapping
    List<Map<String, Object>> list() {
        return broadcasts.list();
    }
}
