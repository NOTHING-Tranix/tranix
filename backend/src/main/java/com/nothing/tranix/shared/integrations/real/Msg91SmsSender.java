package com.nothing.tranix.shared.integrations.real;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.nothing.tranix.shared.integrations.Masking;
import com.nothing.tranix.shared.integrations.SmsSender;
import com.nothing.tranix.shared.types.Language;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.env.Environment;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * B-1301 (Q-03): MSG91 Flow API. Each of our template keys maps to a DLT-approved MSG91 template per language:
 * {@code tranix.msg91.templates.<KEY>.<en|ta|hi>}. Variables are sent as-is; nothing with an OTP or a full mobile is logged.
 * Enabled with {@code tranix.integrations.sms=msg91}.
 */
@Component
@ConditionalOnProperty(name = "tranix.integrations.sms", havingValue = "msg91")
public class Msg91SmsSender implements SmsSender {

    private static final Logger log = LoggerFactory.getLogger(Msg91SmsSender.class);

    private final RestClient http;
    private final Environment env;

    public Msg91SmsSender(RestClient.Builder builder, Environment env,
                          @Value("${tranix.msg91.base-url:https://control.msg91.com}") String baseUrl,
                          @Value("${tranix.msg91.auth-key}") String authKey) {
        this.http = builder.baseUrl(baseUrl).defaultHeader("authkey", authKey).build();
        this.env = env;
    }

    @Override
    public void send(String mobile, String templateKey, Map<String, String> params, Language language) {
        String templateId = env.getProperty("tranix.msg91.templates." + templateKey + "." + language.name(),
                env.getProperty("tranix.msg91.templates." + templateKey + ".en"));
        if (templateId == null) {
            log.warn("[msg91] no template configured for {} — SMS to {} skipped", templateKey, Masking.mobile(mobile));
            return;
        }
        Map<String, Object> recipient = new LinkedHashMap<>();
        recipient.put("mobiles", "91" + mobile);
        recipient.putAll(params);
        try {
            http.post().uri("/api/v5/flow").contentType(MediaType.APPLICATION_JSON)
                    .body(Map.of("template_id", templateId, "short_url", "0", "recipients", List.of(recipient)))
                    .retrieve().toBodilessEntity();
        } catch (RuntimeException e) {
            // never include the body/params: they may hold an OTP
            log.error("[msg91] {} to {} failed: {}", templateKey, Masking.mobile(mobile), e.getClass().getSimpleName());
            throw e;
        }
    }
}
