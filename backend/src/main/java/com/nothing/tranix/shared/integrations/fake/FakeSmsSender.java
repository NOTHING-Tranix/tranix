package com.nothing.tranix.shared.integrations.fake;

import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;

import com.nothing.tranix.shared.integrations.Masking;
import com.nothing.tranix.shared.integrations.SmsSender;
import com.nothing.tranix.shared.types.Language;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/**
 * Keeps sent messages in memory (tests read {@link #sent()}) and logs the template key with a masked number only —
 * never the params, which may hold an OTP. In dev the OTP is always {@code 123456} (B-102).
 */
@Component
@ConditionalOnProperty(name = "tranix.integrations.sms", havingValue = "fake", matchIfMissing = true)
public class FakeSmsSender implements SmsSender {

    private static final Logger log = LoggerFactory.getLogger(FakeSmsSender.class);
    private static final int MAX_KEPT = 200;

    private final List<SentSms> sent = new CopyOnWriteArrayList<>();

    @Override
    public void send(String mobile, String templateKey, Map<String, String> params, Language language) {
        if (sent.size() >= MAX_KEPT) {
            sent.remove(0);
        }
        sent.add(new SentSms(mobile, templateKey, Map.copyOf(params), language));
        log.info("[fake-sms] {} -> {} ({})", templateKey, Masking.mobile(mobile), language);
    }

    public List<SentSms> sent() {
        return List.copyOf(sent);
    }

    public void clear() {
        sent.clear();
    }

    public record SentSms(String mobile, String templateKey, Map<String, String> params, Language language) {
    }
}
