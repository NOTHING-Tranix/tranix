package com.nothing.tranix.shared.integrations;

import java.util.Map;

/** Sends a push notification to one device (real provider: FCM). */
public interface PushSender {

    /** @param data payload for the app, e.g. {@code route} for deep links */
    void send(String fcmToken, String title, String body, Map<String, String> data);
}
