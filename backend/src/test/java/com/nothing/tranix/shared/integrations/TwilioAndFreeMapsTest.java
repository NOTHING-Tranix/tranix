package com.nothing.tranix.shared.integrations;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.content;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withServerError;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Map;

import com.nothing.tranix.shared.integrations.real.TwilioSmsSender;
import com.nothing.tranix.shared.types.Language;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

/** Twilio SMS (with the testing redirect) and SMS wording; no network (MockRestServiceServer). */
class TwilioAndFreeMapsTest {

    static final String AUTH = "Basic " + Base64.getEncoder().encodeToString("ACtest:token".getBytes(StandardCharsets.UTF_8));

    @Test
    void sendsTheTamilOtpTextToTheUser() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        server.expect(requestTo("https://twilio.test/2010-04-01/Accounts/ACtest/Messages.json")).andExpect(method(HttpMethod.POST))
                .andExpect(header("Authorization", AUTH))
                .andExpect(content().formDataContains(Map.of("To", "+919876543210", "From", "+15550000000",
                        "Body", "481516 உங்கள் டிரானிக்ஸ் சரிபார்ப்பு குறியீடு. 5 நிமிடங்களுக்கு செல்லும். யாரிடமும் பகிர வேண்டாம்.")))
                .andRespond(withSuccess("{\"sid\":\"SM1\"}", MediaType.APPLICATION_JSON));
        new TwilioSmsSender(builder, "https://twilio.test", "ACtest", "token", "+15550000000", "")
                .send("9876543210", "OTP_SIGN_IN", Map.of("otp", "481516"), Language.ta);
        server.verify();
    }

    @Test
    void testingRedirectSendsEverythingToOneNumber() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        server.expect(requestTo("https://twilio.test/2010-04-01/Accounts/ACtest/Messages.json"))
                .andExpect(content().formDataContains(Map.of("To", "+919000011111",
                        "Body", "[to " + Masking.mobile("9876543210") + "] Tranix TRX-000123: delivery OTP 2468. Give it to the driver only after checking the goods.")))
                .andRespond(withSuccess());
        new TwilioSmsSender(builder, "https://twilio.test", "ACtest", "token", "+15550000000", "9000011111")
                .send("9876543210", "TRIP_OTP_DELIVERY", Map.of("otp", "2468", "code", "TRX-000123"), Language.en);
        server.verify();
    }

    @Test
    void providerErrorsDoNotBreakTheCaller() {
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        server.expect(requestTo("https://twilio.test/2010-04-01/Accounts/ACtest/Messages.json")).andRespond(withServerError());
        new TwilioSmsSender(builder, "https://twilio.test", "ACtest", "token", "+15550000000", "")
                .send("9876543210", "NOTIFY_LOAD_ACCEPTED", Map.of("text", "TRX-1 accepted"), Language.hi);
        server.verify();
    }

    @Test
    void everySmsKeyHasWordingInAllLanguages() {
        for (String key : new String[] {"OTP_SIGN_UP", "OTP_SIGN_IN", "OTP_CHANGE_MOBILE", "TRIP_OTP_PICKUP", "TRIP_OTP_DELIVERY",
                "RECEIVER_TRACKING", "SENDER_TRACKING", "ORG_INVITE", "NOTIFY_ANYTHING"}) {
            for (Language lang : Language.values()) {
                String text = SmsTexts.render(key, lang, Map.of("otp", "1", "code", "C", "shipper", "S", "truck", "T", "link", "L",
                        "network", "N", "org", "O", "text", "X"));
                assertThat(text).as(key + " " + lang).isNotBlank().doesNotContain("{");
            }
        }
        assertThat(SmsTexts.render("UNKNOWN", Language.en, Map.of())).isNull();
    }
}
