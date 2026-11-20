package com.nothing.tranix.engagement.api;

import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.shared.types.NotificationTab;

/** B-1102: event → template (en/ta/hi) → inbox + FCM push (and SMS where the template says so). */
public interface Notifier {

    /**
     * @param type   template key, e.g. {@code TOPUP_SUCCESS}
     * @param params template variables
     * @param route  app route to open on tap (deep link), may be null
     */
    void notify(UUID userId, NotificationTab tab, String type, Map<String, String> params, String route);
}
