package com.nothing.tranix.shared.integrations.real;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.Map;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import com.nothing.tranix.shared.integrations.PaymentGateway;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

/**
 * B-1302 (Q-02): Razorpay Payment Links for wallet top-ups (web checkout, D-13) and the {@code payment_link.paid}
 * webhook, verified with HMAC-SHA256 of the raw body (hard rule 4). Enabled with {@code tranix.integrations.payments=razorpay}.
 */
@Component
@ConditionalOnProperty(name = "tranix.integrations.payments", havingValue = "razorpay")
public class RazorpayGateway implements PaymentGateway {

    private final RestClient http;
    private final byte[] webhookSecret;
    private final String callbackUrl;
    private final JsonMapper json = JsonMapper.builder().build();

    public RazorpayGateway(RestClient.Builder builder,
                           @Value("${tranix.razorpay.base-url:https://api.razorpay.com}") String baseUrl,
                           @Value("${tranix.razorpay.key-id}") String keyId,
                           @Value("${tranix.razorpay.key-secret}") String keySecret,
                           @Value("${tranix.razorpay.webhook-secret}") String webhookSecret,
                           @Value("${tranix.public-base-url:http://localhost:8080}") String publicBaseUrl) {
        this.http = builder.baseUrl(baseUrl).defaultHeaders(h -> h.setBasicAuth(keyId, keySecret)).build();
        this.webhookSecret = webhookSecret.getBytes(StandardCharsets.UTF_8);
        this.callbackUrl = publicBaseUrl + "/p/wallet/topup/done";
    }

    @Override
    public GatewayOrder createOrder(String receipt, long amountInr) {
        JsonNode res = http.post().uri("/v1/payment_links").contentType(MediaType.APPLICATION_JSON)
                .body(Map.of("amount", amountInr * 100, "currency", "INR", "reference_id", receipt, "description", "Tranix wallet top-up",
                        "callback_url", callbackUrl, "callback_method", "get"))
                .retrieve().body(JsonNode.class);
        if (res == null || res.path("id").asString("").isEmpty()) {
            throw new IllegalStateException("Razorpay did not return a payment link");
        }
        return new GatewayOrder(res.path("id").asString(), res.path("short_url").asString());
    }

    @Override
    public WebhookEvent verifyWebhook(String rawBody, String signature) {
        if (rawBody == null || signature == null) {
            return null;
        }
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(webhookSecret, "HmacSHA256"));
            byte[] expected = HexFormat.of().formatHex(mac.doFinal(rawBody.getBytes(StandardCharsets.UTF_8))).getBytes(StandardCharsets.UTF_8);
            if (!MessageDigest.isEqual(expected, signature.trim().getBytes(StandardCharsets.UTF_8))) {
                return null;
            }
            JsonNode root = json.readTree(rawBody);
            JsonNode link = root.path("payload").path("payment_link").path("entity");
            JsonNode payment = root.path("payload").path("payment").path("entity");
            boolean paid = "payment_link.paid".equals(root.path("event").asString("")) && "paid".equals(link.path("status").asString(""));
            String eventId = payment.path("id").asString("");
            if (eventId.isEmpty()) {
                eventId = link.path("id").asString("") + ":" + root.path("created_at").asString("");
            }
            return new WebhookEvent(eventId, link.path("id").asString(), paid, link.path("amount_paid").asLong(0) / 100);
        } catch (Exception e) {
            return null;
        }
    }
}
