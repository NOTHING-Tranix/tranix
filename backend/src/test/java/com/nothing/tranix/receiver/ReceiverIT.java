package com.nothing.tranix.receiver;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;
import com.nothing.tranix.TripFixtures;
import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.shared.integrations.fake.FakeSmsSender;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;

/** B-1001…B-1006: tracking links, link page JSON (never the delivery OTP), receipt/rating/mark paid, expiry, app receiver. */
@IntegrationTest
@Import({TestApi.class, TripFixtures.class})
class ReceiverIT {

    static final byte[] PNG = {(byte) 0x89, 'P', 'N', 'G', 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 0};

    @Autowired
    TestApi api;

    @Autowired
    TripFixtures trips;

    @Autowired
    JdbcTemplate jdbc;

    @Autowired
    FakeSmsSender sms;

    @Autowired
    MockMvc mvc;

    @Autowired
    UserDirectory users;

    String tokenFor(String mobile) {
        String link = sms.sent().reversed().stream().filter(m -> m.mobile().equals(mobile) && m.templateKey().equals("RECEIVER_TRACKING"))
                .findFirst().orElseThrow().params().get("link");
        assertThat(link).contains("/p/track/");
        return link.substring(link.lastIndexOf('/') + 1);
    }

    @Test
    void linkPageFlowNeverShowsTheDeliveryOtp() throws Exception {
        TripFixtures.Trip t = trips.accepted("LOAD_PROVIDER", "RECEIVER", null);
        String token = tokenFor(t.receiverMobile());
        String pub = "/api/v1/public/track/" + token;
        mvc.perform(get(pub)).andExpect(status().isOk()).andExpect(jsonPath("$.status").value("WAITING_FOR_PICKUP"))
                .andExpect(jsonPath("$.driver.truckNumber").exists()).andExpect(jsonPath("$.canSubmitReceipt").value(false));
        mvc.perform(get("/p/track/" + token)).andExpect(status().isOk());

        // pickup, then arrive at the drop: the OTP is announced but never in the JSON
        String base = "/api/v1/driver/trips/" + t.loadId();
        api.send(base + "/reached", Map.of("purpose", "PICKUP", "lat", t.pickup()[0], "lng", t.pickup()[1]), t.driver()).andExpect(status().isOk());
        api.send(base + "/otp/verify", Map.of("purpose", "PICKUP", "code", trips.smsOtp(t.senderMobile(), "TRIP_OTP_PICKUP"),
                "lat", t.pickup()[0], "lng", t.pickup()[1]), t.driver()).andExpect(status().isOk());
        api.send(base + "/reached", Map.of("purpose", "DELIVERY", "lat", t.drop()[0], "lng", t.drop()[1]), t.driver()).andExpect(status().isOk());
        String code = trips.smsOtp(t.receiverMobile(), "TRIP_OTP_DELIVERY");
        String body = mvc.perform(get(pub)).andExpect(jsonPath("$.deliveryOtpNotice").value(true)).andReturn().getResponse().getContentAsString();
        assertThat(body).doesNotContain(code).doesNotContainIgnoringCase("otpCode").doesNotContain("\"code\":\"" + code);
        api.send(base + "/otp/verify", Map.of("purpose", "DELIVERY", "code", code, "lat", t.drop()[0], "lng", t.drop()[1]), t.driver())
                .andExpect(jsonPath("$.status").value("DELIVERED"));

        // after delivery: receipt (shortage needs remarks), rating once, mark paid (receiver pays)
        mvc.perform(get(pub)).andExpect(jsonPath("$.canSubmitReceipt").value(true)).andExpect(jsonPath("$.canRate").value(true))
                .andExpect(jsonPath("$.canMarkPaid").value(true)).andExpect(jsonPath("$.tracking").doesNotExist());
        String fileId = JsonPath.read(mvc.perform(multipart(pub + "/files").file(new MockMultipartFile("file", "r.png", "image/png", PNG)))
                .andExpect(status().isOk()).andReturn().getResponse().getContentAsString(), "$.id");
        api.send(pub + "/receipt", Map.of("fileIds", List.of(fileId), "condition", "SHORTAGE_DAMAGE"), null)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("remarks"));
        api.send(pub + "/receipt", Map.of("fileIds", List.of(fileId), "condition", "SHORTAGE_DAMAGE", "remarks", "2 boxes crushed"), null)
                .andExpect(jsonPath("$.condition").value("SHORTAGE_DAMAGE"));
        api.send(pub + "/receipt", Map.of("fileIds", List.of(fileId), "condition", "FULL"), null).andExpect(status().isConflict());

        BigDecimal before = users.get(t.driver().userId()).trustScore();
        api.send(pub + "/rating", Map.of("stars", 5, "tags", List.of("On time")), null).andExpect(status().isNoContent());
        api.send(pub + "/rating", Map.of("stars", 5), null).andExpect(status().isConflict());
        assertThat(users.get(t.driver().userId()).trustScore()).isGreaterThan(before);

        api.send(pub + "/payment/mark-paid", Map.of("amountInr", 10000, "mode", "UPI"), null).andExpect(jsonPath("$.status").value("PAID"));
        mvc.perform(get(pub)).andExpect(jsonPath("$.canMarkPaid").value(false)).andExpect(jsonPath("$.canRate").value(false))
                .andExpect(jsonPath("$.receipt.remarks").value("2 boxes crushed"));
        assertThat(jdbc.queryForObject("select expires_at is not null from receiver_tracking_token where token = ?", Boolean.class, token)).isTrue();

        // expired → 410, no load data
        jdbc.update("update receiver_tracking_token set expires_at = now() - interval '1 minute' where token = ?", token);
        String gone = mvc.perform(get(pub)).andExpect(status().isGone()).andExpect(jsonPath("$.code").value("LINK_EXPIRED"))
                .andReturn().getResponse().getContentAsString();
        assertThat(gone).doesNotContain("TRX-");
        mvc.perform(get("/p/track/" + token)).andExpect(status().isGone());
        mvc.perform(get("/api/v1/public/track/unknown-token")).andExpect(status().isNotFound());
    }

    @Test
    void registeredReceiverSeesLoadsAndSendsReceiptInApp() throws Exception {
        TestApi.Session receiver = api.verified("RECEIVER");
        TripFixtures.Trip t = trips.accepted("LOAD_PROVIDER", "SHIPPER", receiver.mobile());
        api.get("/api/v1/receiver/loads", receiver).andExpect(jsonPath("$", hasSize(1))).andExpect(jsonPath("$[0].id").value(t.loadId()))
                .andExpect(jsonPath("$[0].deliveryEta").exists());
        api.get("/api/v1/receiver/loads/" + t.loadId(), receiver).andExpect(jsonPath("$.canSubmitReceipt").value(false));
        api.get("/api/v1/receiver/loads/" + t.loadId(), api.verified("RECEIVER")).andExpect(status().isNotFound());
        api.get("/api/v1/receiver/loads", t.shipper()).andExpect(status().isForbidden());

        trips.deliver(t);
        api.get("/api/v1/receiver/loads?scope=HISTORY", receiver).andExpect(jsonPath("$", hasSize(1)));
        String fileId = api.uploadPng(receiver);
        api.send("/api/v1/receiver/loads/" + t.loadId() + "/receipt", Map.of("fileIds", List.of(fileId), "condition", "FULL"), receiver)
                .andExpect(jsonPath("$.condition").value("FULL"));
        api.get("/api/v1/receiver/loads/" + t.loadId(), receiver).andExpect(jsonPath("$.receipt.condition").value("FULL"))
                .andExpect(jsonPath("$.canSubmitReceipt").value(false));
        // the shipper-paid freight: no payment block for the receiver
        api.get("/api/v1/receiver/loads/" + t.loadId(), receiver).andExpect(jsonPath("$.payment").doesNotExist());
    }
}
