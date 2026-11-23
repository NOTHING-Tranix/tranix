package com.nothing.tranix.shared.integrations.real;

import java.util.Map;

import com.nothing.tranix.shared.integrations.Masking;
import com.nothing.tranix.shared.integrations.SmsSender;
import com.nothing.tranix.shared.integrations.SmsTexts;
import com.nothing.tranix.shared.types.Language;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.web.client.RestClient;

/**
 * Twilio Programmable Messaging. Enabled with {@code tranix.integrations.sms=twilio} (env {@code SMS_PROVIDER}).
 * Secrets come from the environment only: {@code TWILIO_ACCOUNT_SID}, {@code TWILIO_AUTH_TOKEN}, {@code TWILIO_FROM}.
 * <p>Dev/testing: when {@code SMS_REDIRECT_TO} is set (e.g. your own verified number on a trial account), every SMS
 * goes to that number instead, prefixed with the intended recipient's masked number. Leave it empty in production.
 * Nothing with an OTP or a full mobile is ever logged.
 */
@Component
@ConditionalOnProperty(name = "tranix.integrations.sms", havingValue = "twilio")
public class TwilioSmsSender implements SmsSender {

    private static final Logger log = LoggerFactory.getLogger(TwilioSmsSender.class);

    private final RestClient http;
    private final String accountSid;
    private final String from;
    private final String redirectTo;

    public TwilioSmsSender(RestClient.Builder builder,
                           @Value("${tranix.twilio.base-url:https://api.twilio.com}") String baseUrl,
                           @Value("${tranix.twilio.account-sid}") String accountSid,
                           @Value("${tranix.twilio.auth-token}") String authToken,
                           @Value("${tranix.twilio.from}") String from,
                           @Value("${tranix.sms.redirect-to:}") String redirectTo) {
        this.http = builder.baseUrl(baseUrl).defaultHeaders(h -> h.setBasicAuth(accountSid, authToken)).build();
        this.accountSid = accountSid;
        this.from = from;
        this.redirectTo = redirectTo == null ? "" : redirectTo.trim();
    }

    @Override
    public void send(String mobile, String templateKey, Map<String, String> params, Language language) {
        String text = SmsTexts.render(templateKey, language, params);
        if (text == null) {
            log.warn("[twilio] no SMS text for {}; SMS to {} skipped", templateKey, Masking.mobile(mobile));
            return;
        }
        String to = "+91" + mobile;
        if (!redirectTo.isEmpty()) {
            text = "[to " + Masking.mobile(mobile) + "] " + text;
            to = redirectTo.startsWith("+") ? redirectTo : "+91" + redirectTo;
        }
        LinkedMultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("To", to);
        form.add("From", from);
        form.add("Body", text);
        try {
            http.post().uri("/2010-04-01/Accounts/{sid}/Messages.json", accountSid).contentType(MediaType.APPLICATION_FORM_URLENCODED)
                    .body(form).retrieve().toBodilessEntity();
            log.info("[twilio] {} sent to {}{}", templateKey, Masking.mobile(mobile), redirectTo.isEmpty() ? "" : " (redirected for testing)");
        } catch (RuntimeException e) {
            // Never include the body: it may hold an OTP. A failed SMS must not break sign-in on a trial account.
            log.error("[twilio] {} to {} failed: {}", templateKey, Masking.mobile(mobile), e.getMessage() == null ? e.getClass().getSimpleName()
                    : e.getMessage().replaceAll("[0-9]{4,}", "…"));
        }
    }
}
