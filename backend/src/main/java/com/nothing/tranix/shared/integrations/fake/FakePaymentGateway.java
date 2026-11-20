package com.nothing.tranix.shared.integrations.fake;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.UUID;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import com.nothing.tranix.shared.integrations.PaymentGateway;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/**
 * Q-02 default. Orders get id {@code fake_order_<uuid>}. Webhooks are "signed" with HMAC-SHA256 of the raw body
 * using a fake secret, so the real verify-then-credit path is exercised. The body format is
 * {@code eventId|gatewayOrderId|PAID or FAILED|amountInr}. The dev endpoint
 * {@code POST /dev/payments/{orderId}/succeed} (wallet module, M3) builds and posts such a webhook.
 */
@Component
@ConditionalOnProperty(name = "tranix.integrations.payments", havingValue = "fake", matchIfMissing = true)
public class FakePaymentGateway implements PaymentGateway {

    private final String secret;
    private final String publicBaseUrl;

    public FakePaymentGateway(@Value("${tranix.payments.fake-secret:fake-gateway-secret}") String secret,
                              @Value("${tranix.public-base-url:http://localhost:8080}") String publicBaseUrl) {
        this.secret = secret;
        this.publicBaseUrl = publicBaseUrl;
    }

    @Override
    public GatewayOrder createOrder(String receipt, long amountInr) {
        String id = "fake_order_" + UUID.randomUUID();
        return new GatewayOrder(id, publicBaseUrl + "/dev/payments/" + id);
    }

    @Override
    public WebhookEvent verifyWebhook(String rawBody, String signature) {
        if (rawBody == null || signature == null) {
            return null;
        }
        byte[] expected = sign(rawBody).getBytes(StandardCharsets.UTF_8);
        if (!MessageDigest.isEqual(expected, signature.getBytes(StandardCharsets.UTF_8))) {
            return null;
        }
        String[] parts = rawBody.split("\\|");
        if (parts.length != 4) {
            return null;
        }
        try {
            return new WebhookEvent(parts[0], parts[1], "PAID".equals(parts[2]), Long.parseLong(parts[3]));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /** HMAC-SHA256 hex of the body; used by the dev endpoint and tests to build valid webhooks. */
    public String sign(String rawBody) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return HexFormat.of().formatHex(mac.doFinal(rawBody.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new IllegalStateException("HMAC failed", e);
        }
    }
}
