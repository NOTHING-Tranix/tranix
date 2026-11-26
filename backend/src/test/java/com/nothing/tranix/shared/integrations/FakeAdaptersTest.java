package com.nothing.tranix.shared.integrations;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.ByteArrayInputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

import com.nothing.tranix.shared.geo.GeoPoint;
import com.nothing.tranix.shared.integrations.fake.FakeMapsService;
import com.nothing.tranix.shared.integrations.fake.FakePaymentGateway;
import com.nothing.tranix.shared.integrations.fake.FakeSmsSender;
import com.nothing.tranix.shared.integrations.fake.LocalFileStorage;
import com.nothing.tranix.shared.types.Language;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

class FakeAdaptersTest {

    @Test
    void fakeMapsUsesRoadFactorAndFortyKmh() {
        MapsService.RouteEstimate r = new FakeMapsService()
                .route(GeoPoint.of(13.0827, 80.2707), GeoPoint.of(9.9252, 78.1198));
        // ~421 km straight × 1.3 ≈ 547 km; at 40 km/h ≈ 821 min
        assertThat(r.distanceKm()).isBetween(540.0, 555.0);
        assertThat(r.driveMinutes()).isBetween(810, 835);
    }

    /** B-1607: the area drivers see before accepting never contains the street, a door number or a PIN. */
    @Test
    void areaNeverShowsStreetLevelText() {
        FakeMapsService maps = new FakeMapsService();
        GeoPoint p = GeoPoint.of(11.6234, 92.7265);
        assertThat(maps.area(p, "Haddo Wharf, Port Blair")).isEqualTo("Port Blair");
        assertThat(maps.area(p, "Door 12 Kumar Street, Vellore")).isEqualTo("Vellore");
        assertThat(maps.area(p, "12, Main Road, Gandhi Nagar, Vellore, Tamil Nadu, 632001")).isEqualTo("Vellore, Tamil Nadu");
        assertThat(maps.area(p, "Gandhi Market, Oddanchatram, Dindigul")).isEqualTo("Oddanchatram, Dindigul");
        assertThat(maps.area(p, "Kumar Street near bus stand")).isEqualTo("Near 11.6, 92.7");
        assertThat(maps.area(p, "")).isEqualTo("Near 11.6, 92.7");
        assertThat(maps.area(p, null)).isEqualTo("Near 11.6, 92.7");
    }

    @Test
    void fakeSmsKeepsMessages() {
        FakeSmsSender sms = new FakeSmsSender();
        sms.send("9876543210", "OTP_SIGN_IN", Map.of("otp", "123456"), Language.en);
        assertThat(sms.sent()).singleElement()
                .satisfies(s -> assertThat(s.templateKey()).isEqualTo("OTP_SIGN_IN"));
    }

    @Test
    void maskingHidesAllButLastFour() {
        assertThat(Masking.mobile("9876543210")).isEqualTo("******3210");
        assertThat(Masking.mobile(null)).isEqualTo("****");
    }

    @Test
    void fakeGatewayAcceptsOnlyCorrectlySignedWebhooks() {
        FakePaymentGateway gw = new FakePaymentGateway("secret", "http://localhost:8080");
        PaymentGateway.GatewayOrder order = gw.createOrder("r1", 500);
        String body = "evt_1|" + order.gatewayOrderId() + "|PAID|500";

        PaymentGateway.WebhookEvent ok = gw.verifyWebhook(body, gw.sign(body));
        assertThat(ok).isNotNull();
        assertThat(ok.paid()).isTrue();
        assertThat(ok.amountInr()).isEqualTo(500);

        assertThat(gw.verifyWebhook(body, "bad")).isNull();
        assertThat(gw.verifyWebhook(body.replace("|500", "|5000"), gw.sign(body))).isNull();
    }

    @Test
    void localStorageRoundTrip(@TempDir Path dir) throws Exception {
        LocalFileStorage storage = new LocalFileStorage(dir.toString());
        String key = storage.store(new ByteArrayInputStream(new byte[] {1, 2, 3}), "image/png");
        try (var in = storage.open(key)) {
            assertThat(in.readAllBytes()).containsExactly(1, 2, 3);
        }
        storage.delete(key);
        assertThat(Files.list(dir)).isEmpty();
    }
}
