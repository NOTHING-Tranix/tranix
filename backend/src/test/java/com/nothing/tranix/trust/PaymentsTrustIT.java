package com.nothing.tranix.trust;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.math.BigDecimal;
import java.time.YearMonth;
import java.util.List;
import java.util.Map;

import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;
import com.nothing.tranix.TripFixtures;
import com.nothing.tranix.identity.api.UserDirectory;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;

/** B-801…B-808. */
@IntegrationTest
@Import({TestApi.class, TripFixtures.class})
class PaymentsTrustIT {

    @Autowired
    TestApi api;

    @Autowired
    TripFixtures trips;

    @Autowired
    UserDirectory users;

    @Autowired
    JdbcTemplate jdbc;

    BigDecimal score(TestApi.Session s) {
        return users.get(s.userId()).trustScore();
    }

    @Test
    void deliveredOnTimeThenPaidConfirmedRatedAndClosed() throws Exception {
        TripFixtures.Trip t = trips.accepted("LOAD_PROVIDER", "SHIPPER", null);
        api.get("/api/v1/loads/" + t.loadId(), t.shipper()).andExpect(jsonPath("$.payment.status").value("PENDING"))
                .andExpect(jsonPath("$.paymentStatus").value("PENDING"));
        trips.deliver(t);
        assertThat(score(t.driver())).isEqualByComparingTo("72");
        assertThat(score(t.shipper())).isEqualByComparingTo("71");

        // only the payer marks paid; driver confirms; trip closes
        api.send("/api/v1/loads/" + t.loadId() + "/payment/mark-paid", Map.of("amountInr", 10000, "mode", "UPI"), t.driver())
                .andExpect(status().isForbidden());
        api.send("/api/v1/driver/trips/" + t.loadId() + "/payment/confirm", Map.of("amountInr", 10000), t.driver())
                .andExpect(status().isConflict());
        api.send("/api/v1/loads/" + t.loadId() + "/payment/mark-paid", Map.of("amountInr", 10000, "mode", "UPI", "reference", "UTR123"), t.shipper())
                .andExpect(jsonPath("$.status").value("PAID"));
        api.send("/api/v1/driver/trips/" + t.loadId() + "/payment/confirm", Map.of("amountInr", 10000), t.driver())
                .andExpect(jsonPath("$.status").value("CONFIRMED"));
        assertThat(score(t.shipper())).isEqualByComparingTo("72"); // + payment on time
        api.get("/api/v1/loads?scope=HISTORY", t.shipper()).andExpect(jsonPath("$.items[0].paymentStatus").value("CONFIRMED"));

        // ratings: pending for both; Later once; then rate 5★ → +1
        api.get("/api/v1/me", t.shipper()).andExpect(jsonPath("$.pendingRatingsCount").value(1));
        api.get("/api/v1/ratings/pending", t.shipper()).andExpect(jsonPath("$[0].rateeUserId").value(t.driver().userId().toString()))
                .andExpect(jsonPath("$[0].rateeRole").value("DRIVER"));
        api.send("/api/v1/ratings/" + t.loadId() + "/later", Map.of(), t.shipper()).andExpect(status().isNoContent());
        api.send("/api/v1/ratings/" + t.loadId() + "/later", Map.of(), t.shipper()).andExpect(status().isConflict());
        api.send("/api/v1/ratings", Map.of("loadId", t.loadId(), "rateeUserId", t.driver().userId(), "stars", 5,
                "tags", List.of("On time")), t.shipper()).andExpect(status().isNoContent());
        api.send("/api/v1/ratings", Map.of("loadId", t.loadId(), "rateeUserId", t.driver().userId(), "stars", 5), t.shipper())
                .andExpect(status().isConflict());
        assertThat(score(t.driver())).isEqualByComparingTo("73");
        api.send("/api/v1/ratings", Map.of("loadId", t.loadId(), "rateeUserId", t.shipper().userId(), "stars", 1), t.driver())
                .andExpect(status().isNoContent());
        assertThat(score(t.shipper())).isEqualByComparingTo("70");

        api.get("/api/v1/trust-score", t.driver()).andExpect(jsonPath("$.score").value(73.0))
                .andExpect(jsonPath("$.trend", hasSize(2)));
        api.get("/api/v1/trust-score/events", t.driver()).andExpect(jsonPath("$.total").value(2))
                .andExpect(jsonPath("$.items[0].event").value("RATING"));
        api.get("/api/v1/driver/history?month=" + YearMonth.now(), t.driver())
                .andExpect(jsonPath("$.summary.trips").value(1))
                .andExpect(jsonPath("$.summary.confirmedInr").value(10000))
                .andExpect(jsonPath("$.summary.pendingInr").value(0));
    }

    @Test
    void disputeDecidedAgainstPayerAndCancelPenaltyAndAdminAdjust() throws Exception {
        TripFixtures.Trip t = trips.accepted("FARMER_NETWORK", "SHIPPER", null);
        trips.deliver(t);
        api.send("/api/v1/driver/trips/" + t.loadId() + "/payment/dispute", Map.of("reason", "Not paid at all"), t.driver())
                .andExpect(jsonPath("$.status").value("DISPUTED"));
        TestApi.Session admin = api.admin();
        api.send("/api/v1/admin/payment-disputes/" + t.loadId() + "/decide", Map.of("decision", "AGAINST_PAYER"), admin)
                .andExpect(jsonPath("$.status").value("CONFIRMED"));
        assertThat(score(t.shipper())).isEqualByComparingTo("66"); // 70 +1 on time −5 dispute

        TripFixtures.Trip c = trips.accepted("LOAD_PROVIDER", "SHIPPER", null);
        api.send("/api/v1/loads/" + c.loadId() + "/cancel", Map.of("reason", "PLANS_CHANGED"), c.shipper()).andExpect(status().isOk());
        assertThat(score(c.shipper())).isEqualByComparingTo("65");
        api.get("/api/v1/trust-score/events", c.shipper()).andExpect(jsonPath("$.items[0].event").value("CANCELLED_OWN_FAULT"));

        api.send("/api/v1/admin/trust-score/" + c.driver().userId() + "/adjust", Map.of("points", 40, "reason", "Goodwill"), admin)
                .andExpect(jsonPath("$.score").value(100.0)); // clamped
        assertThat(jdbc.queryForObject("select count(*) from admin_audit where action = 'TRUST_ADJUSTED' and entity_id = ?",
                Integer.class, c.driver().userId().toString())).isEqualTo(1);
    }

    @Test
    void registeredReceiverPaysAndRates() throws Exception {
        TestApi.Session receiver = api.signUp("RECEIVER");
        TripFixtures.Trip t = trips.accepted("LOAD_PROVIDER", "RECEIVER", receiver.mobile());
        trips.deliver(t);
        api.send("/api/v1/loads/" + t.loadId() + "/payment/mark-paid", Map.of("amountInr", 10000, "mode", "CASH"), t.shipper())
                .andExpect(status().isForbidden());
        api.send("/api/v1/loads/" + t.loadId() + "/payment/mark-paid", Map.of("amountInr", 10000, "mode", "CASH"), receiver)
                .andExpect(jsonPath("$.status").value("PAID"));
        api.get("/api/v1/ratings/pending", receiver).andExpect(jsonPath("$", hasSize(1)));
    }
}
