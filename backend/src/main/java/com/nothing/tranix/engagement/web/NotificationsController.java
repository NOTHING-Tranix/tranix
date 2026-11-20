package com.nothing.tranix.engagement.web;

import java.util.Map;
import java.util.UUID;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

import com.nothing.tranix.engagement.internal.NotificationService;
import com.nothing.tranix.shared.security.CurrentUser;
import com.nothing.tranix.shared.types.NotificationTab;

import io.swagger.v3.oas.annotations.tags.Tag;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

/** Contract §11 (notifications). */
@RestController
@RequestMapping("/api/v1/notifications")
@Tag(name = "Notifications")
class NotificationsController {

    private final NotificationService notifications;

    NotificationsController(NotificationService notifications) {
        this.notifications = notifications;
    }

    @GetMapping
    Map<String, Object> list(@RequestParam(required = false) NotificationTab tab,
                             @RequestParam(defaultValue = "0") @Min(0) int page,
                             @RequestParam(defaultValue = "20") @Min(1) @Max(100) int size) {
        return notifications.list(CurrentUser.id(), tab, page, size);
    }

    @GetMapping("/summary")
    Map<String, Object> summary() {
        return notifications.summary(CurrentUser.id());
    }

    @PostMapping("/{id}/read")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void read(@PathVariable UUID id) {
        notifications.markRead(CurrentUser.id(), id);
    }

    @PostMapping("/read-all")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    void readAll() {
        notifications.markAllRead(CurrentUser.id());
    }
}
