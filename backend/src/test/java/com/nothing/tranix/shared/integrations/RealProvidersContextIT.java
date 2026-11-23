package com.nothing.tranix.shared.integrations;

import static org.assertj.core.api.Assertions.assertThat;

import com.nothing.tranix.IntegrationTest;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.TestPropertySource;

/** The app starts with the real dev-testing connectors switched on (no calls are made; dummy credentials). */
@IntegrationTest
@TestPropertySource(properties = {
        "tranix.integrations.sms=twilio",
        "tranix.integrations.maps=osrm",
        "tranix.integrations.geocoding=nominatim",
        "tranix.twilio.account-sid=ACtest",
        "tranix.twilio.auth-token=test",
        "tranix.twilio.from=+15550000000"})
class RealProvidersContextIT {

    @Autowired
    SmsSender sms;

    @Autowired
    MapsService maps;

    @Autowired
    Geocoder geocoder;

    @Test
    void realConnectorsAreWired() {
        assertThat(sms.getClass().getSimpleName()).isEqualTo("TwilioSmsSender");
        assertThat(maps.getClass().getSimpleName()).isEqualTo("OsrmMapsService");
        assertThat(geocoder.getClass().getSimpleName()).isEqualTo("NominatimGeocoder");
    }
}
