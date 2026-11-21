package com.nothing.tranix.shared.integrations;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.content;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withServerError;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.KeyPairGenerator;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Base64;
import java.util.HexFormat;
import java.util.Map;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import com.nothing.tranix.shared.geo.GeoPoint;
import com.nothing.tranix.shared.integrations.real.FcmPushSender;
import com.nothing.tranix.shared.integrations.real.GoogleMapsService;
import com.nothing.tranix.shared.integrations.real.Msg91SmsSender;
import com.nothing.tranix.shared.integrations.real.RazorpayGateway;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.shared.types.Language;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.mock.env.MockEnvironment;
import org.springframework.test.web.client.ExpectedCount;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

/** B-1301…B-1304: the real adapters talk the providers' wire formats (no network: MockRestServiceServer). */
class RealAdaptersTest {

    final Clock clock = Clock.fixed(Instant.parse("2026-11-21T10:00:00Z"), ZoneOffset.UTC);

    @Test
    void msg91SendsTheDltTemplateForTheLanguage() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        MockEnvironment env = new MockEnvironment().withProperty("tranix.msg91.templates.OTP_SIGN_IN.ta", "tpl-ta")
                .withProperty("tranix.msg91.templates.OTP_SIGN_IN.en", "tpl-en");
        server.expect(requestTo("https://msg.test/api/v5/flow")).andExpect(method(HttpMethod.POST))
                .andExpect(header("authkey", "k1"))
                .andExpect(content().json("{\"template_id\":\"tpl-ta\",\"recipients\":[{\"mobiles\":\"919876543210\",\"otp\":\"123456\"}]}"))
                .andRespond(withSuccess("{\"type\":\"success\"}", MediaType.APPLICATION_JSON));
        new Msg91SmsSender(builder, env, "https://msg.test", "k1").send("9876543210", "OTP_SIGN_IN", Map.of("otp", "123456"), Language.ta);
        server.verify();
    }

    @Test
    void razorpayCreatesLinksAndChecksWebhookSignatures() throws Exception {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        server.expect(requestTo("https://rzp.test/v1/payment_links"))
                .andExpect(header("Authorization", "Basic " + Base64.getEncoder().encodeToString("key:secret".getBytes(StandardCharsets.UTF_8))))
                .andExpect(content().json("{\"amount\":50000,\"currency\":\"INR\",\"reference_id\":\"r1\"}"))
                .andRespond(withSuccess("{\"id\":\"plink_1\",\"short_url\":\"https://rzp.io/i/abc\"}", MediaType.APPLICATION_JSON));
        RazorpayGateway gw = new RazorpayGateway(builder, "https://rzp.test", "key", "secret", "whsec", "https://tranix.test");
        PaymentGateway.GatewayOrder order = gw.createOrder("r1", 500);
        assertThat(order.gatewayOrderId()).isEqualTo("plink_1");
        assertThat(order.checkoutUrl()).isEqualTo("https://rzp.io/i/abc");

        String body = "{\"event\":\"payment_link.paid\",\"payload\":{\"payment_link\":{\"entity\":{\"id\":\"plink_1\",\"status\":\"paid\",\"amount_paid\":50000}},"
                + "\"payment\":{\"entity\":{\"id\":\"pay_9\"}}}}";
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec("whsec".getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        String sig = HexFormat.of().formatHex(mac.doFinal(body.getBytes(StandardCharsets.UTF_8)));
        PaymentGateway.WebhookEvent e = gw.verifyWebhook(body, sig);
        assertThat(e).isEqualTo(new PaymentGateway.WebhookEvent("pay_9", "plink_1", true, 500));
        assertThat(gw.verifyWebhook(body, "0".repeat(64))).isNull();
        assertThat(gw.verifyWebhook(body.replace("50000", "90000"), sig)).isNull();
    }

    @Test
    void googleRoutesParsesCachesAndFallsBack() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        Settings settings = mock(Settings.class);
        when(settings.getInt("maps.monthly_route_calls")).thenReturn(2);
        server.expect(ExpectedCount.once(), requestTo("https://routes.test/directions/v2:computeRoutes"))
                .andExpect(header("X-Goog-Api-Key", "gk"))
                .andRespond(withSuccess("{\"routes\":[{\"distanceMeters\":512340,\"duration\":\"34560s\"}]}", MediaType.APPLICATION_JSON));
        server.expect(ExpectedCount.once(), requestTo("https://routes.test/directions/v2:computeRoutes")).andRespond(withServerError());
        GoogleMapsService maps = new GoogleMapsService(builder, settings, clock, "https://routes.test", "gk");
        GeoPoint a = GeoPoint.of(10.49, 77.75);
        GeoPoint b = GeoPoint.of(13.07, 80.20);
        assertThat(maps.route(a, b)).isEqualTo(new MapsService.RouteEstimate(512.3, 576));
        assertThat(maps.route(a, b)).isEqualTo(new MapsService.RouteEstimate(512.3, 576)); // cached, no call
        MapsService.RouteEstimate failed = maps.route(b, a); // provider error → straight-line estimate
        assertThat(failed.distanceKm()).isPositive();
        MapsService.RouteEstimate overBudget = maps.route(GeoPoint.of(11.0, 78.0), b); // 3rd call > budget 2 → no request
        assertThat(overBudget.distanceKm()).isPositive();
        server.verify();
    }

    @Test
    void fcmSignsATokenRequestAndSendsTheMessage(@TempDir Path dir) throws Exception {
        KeyPairGenerator gen = KeyPairGenerator.getInstance("RSA");
        gen.initialize(2048);
        String pem = "-----BEGIN PRIVATE KEY-----\n" + Base64.getEncoder().encodeToString(gen.generateKeyPair().getPrivate().getEncoded())
                + "\n-----END PRIVATE KEY-----\n";
        Path sa = dir.resolve("sa.json");
        Files.writeString(sa, "{\"project_id\":\"tranix-test\",\"client_email\":\"push@tranix-test.iam\",\"token_uri\":\"https://oauth.test/token\","
                + "\"private_key\":\"" + pem.replace("\n", "\\n") + "\"}");
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        server.expect(requestTo("https://oauth.test/token")).andExpect(method(HttpMethod.POST))
                .andRespond(withSuccess("{\"access_token\":\"ya29.t\",\"expires_in\":3600}", MediaType.APPLICATION_JSON));
        server.expect(requestTo("https://fcm.test/v1/projects/tranix-test/messages:send")).andExpect(header("Authorization", "Bearer ya29.t"))
                .andExpect(content().json("{\"message\":{\"token\":\"dev-token\",\"notification\":{\"title\":\"T\",\"body\":\"B\"},\"data\":{\"route\":\"/x\"}}}"))
                .andRespond(withSuccess());
        server.expect(requestTo("https://fcm.test/v1/projects/tranix-test/messages:send")).andRespond(withSuccess()); // token cached
        FcmPushSender push = new FcmPushSender(builder, clock, sa.toString(), "https://fcm.test");
        push.send("dev-token", "T", "B", Map.of("route", "/x"));
        push.send("dev-token", "T2", "B2", Map.of());
        server.verify();
    }
}
