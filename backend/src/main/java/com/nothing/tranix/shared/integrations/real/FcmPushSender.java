package com.nothing.tranix.shared.integrations.real;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.Signature;
import java.security.spec.PKCS8EncodedKeySpec;
import java.time.Clock;
import java.time.Instant;
import java.util.Base64;
import java.util.Map;

import com.nothing.tranix.shared.integrations.PushSender;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.web.client.RestClient;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

/**
 * B-1303: FCM HTTP v1 with a service-account key file ({@code tranix.fcm.service-account-file}, never in git).
 * The OAuth access token comes from a self-signed JWT (RS256) exchanged at Google's token endpoint and is cached
 * until shortly before it expires. Tokens are never logged. Enabled with {@code tranix.integrations.push=fcm}.
 */
@Component
@ConditionalOnProperty(name = "tranix.integrations.push", havingValue = "fcm")
public class FcmPushSender implements PushSender {

    private static final Logger log = LoggerFactory.getLogger(FcmPushSender.class);
    static final String SCOPE = "https://www.googleapis.com/auth/firebase.messaging";

    private final RestClient fcm;
    private final RestClient oauth;
    private final Clock clock;
    private final String projectId;
    private final String clientEmail;
    private final PrivateKey key;
    private final String tokenUri;
    private volatile String accessToken;
    private volatile Instant accessTokenExpires = Instant.EPOCH;

    public FcmPushSender(RestClient.Builder builder, Clock clock,
                         @Value("${tranix.fcm.service-account-file}") String serviceAccountFile,
                         @Value("${tranix.fcm.base-url:https://fcm.googleapis.com}") String baseUrl) throws Exception {
        JsonNode sa = JsonMapper.builder().build().readTree(Files.readString(Path.of(serviceAccountFile)));
        this.projectId = sa.path("project_id").asString();
        this.clientEmail = sa.path("client_email").asString();
        this.tokenUri = sa.path("token_uri").asString("https://oauth2.googleapis.com/token");
        String pem = sa.path("private_key").asString().replaceAll("-----[A-Z ]+-----", "").replaceAll("\\s", "");
        this.key = KeyFactory.getInstance("RSA").generatePrivate(new PKCS8EncodedKeySpec(Base64.getDecoder().decode(pem)));
        this.fcm = builder.clone().baseUrl(baseUrl).build();
        this.oauth = builder.clone().build();
        this.clock = clock;
    }

    @Override
    public void send(String fcmToken, String title, String body, Map<String, String> data) {
        Map<String, Object> message = Map.of("message", Map.of("token", fcmToken,
                "notification", Map.of("title", title, "body", body),
                "data", data == null ? Map.of() : data,
                "android", Map.of("priority", "HIGH")));
        try {
            fcm.post().uri("/v1/projects/{p}/messages:send", projectId).contentType(MediaType.APPLICATION_JSON)
                    .header("Authorization", "Bearer " + accessToken()).body(message).retrieve().toBodilessEntity();
        } catch (RuntimeException e) {
            log.warn("[fcm] push failed: {}", e.getClass().getSimpleName()); // a stale device token must not break the caller
        }
    }

    synchronized String accessToken() {
        Instant now = Instant.now(clock);
        if (accessToken != null && now.isBefore(accessTokenExpires.minusSeconds(60))) {
            return accessToken;
        }
        LinkedMultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", "urn:ietf:params:oauth:grant-type:jwt-bearer");
        form.add("assertion", assertion(now));
        JsonNode res = oauth.post().uri(tokenUri).contentType(MediaType.APPLICATION_FORM_URLENCODED).body(form).retrieve().body(JsonNode.class);
        accessToken = res.path("access_token").asString();
        accessTokenExpires = now.plusSeconds(res.path("expires_in").asLong(3600));
        return accessToken;
    }

    String assertion(Instant now) {
        Base64.Encoder b64 = Base64.getUrlEncoder().withoutPadding();
        String header = b64.encodeToString("{\"alg\":\"RS256\",\"typ\":\"JWT\"}".getBytes(StandardCharsets.UTF_8));
        String claims = b64.encodeToString(("{\"iss\":\"" + clientEmail + "\",\"scope\":\"" + SCOPE + "\",\"aud\":\"" + tokenUri
                + "\",\"iat\":" + now.getEpochSecond() + ",\"exp\":" + (now.getEpochSecond() + 3600) + "}").getBytes(StandardCharsets.UTF_8));
        try {
            Signature s = Signature.getInstance("SHA256withRSA");
            s.initSign(key);
            s.update((header + "." + claims).getBytes(StandardCharsets.UTF_8));
            return header + "." + claims + "." + b64.encodeToString(s.sign());
        } catch (Exception e) {
            throw new IllegalStateException("Could not sign the FCM token request", e);
        }
    }
}
