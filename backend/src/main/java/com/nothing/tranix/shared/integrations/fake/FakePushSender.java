package com.nothing.tranix.shared.integrations.fake;

import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;

import com.nothing.tranix.shared.integrations.PushSender;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/** Records pushes in memory and logs only the title. */
@Component
@ConditionalOnProperty(name = "tranix.integrations.push", havingValue = "fake", matchIfMissing = true)
public class FakePushSender implements PushSender {

    private static final Logger log = LoggerFactory.getLogger(FakePushSender.class);
    private static final int MAX_KEPT = 200;

    private final List<SentPush> sent = new CopyOnWriteArrayList<>();

    @Override
    public void send(String fcmToken, String title, String body, Map<String, String> data) {
        if (sent.size() >= MAX_KEPT) {
            sent.remove(0);
        }
        sent.add(new SentPush(fcmToken, title, body, Map.copyOf(data)));
        log.info("[fake-push] {}", title);
    }

    public List<SentPush> sent() {
        return List.copyOf(sent);
    }

    public void clear() {
        sent.clear();
    }

    public record SentPush(String fcmToken, String title, String body, Map<String, String> data) {
    }
}
