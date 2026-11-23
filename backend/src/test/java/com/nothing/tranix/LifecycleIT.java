package com.nothing.tranix;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.jayway.jsonpath.JsonPath;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;

/** B-1406: the whole lifecycle — post → accept → revision → OTPs → delivered → paid → rated — plus B-1402/B-1408 checks. */
@IntegrationTest
@Import({TestApi.class, TripFixtures.class})
class LifecycleIT {

    @Autowired
    TestApi api;

    @Autowired
    TripFixtures trips;

    @Autowired
    JdbcTemplate jdbc;

    @Autowired
    MockMvc mvc;

    @Test
    void fullLifecycle() throws Exception {
        TripFixtures.Trip t = trips.accepted("LOAD_PROVIDER", "SHIPPER", null);
        String base = "/api/v1/driver/trips/" + t.loadId();
        String rid = JsonPath.read(api.body(api.send(base + "/revisions", Map.of("amountInr", 11000, "reason", "Toll increase"), t.driver())
                .andExpect(jsonPath("$.status").value("AMOUNT_NEGOTIATION"))), "$.revisions[0].id");
        api.send("/api/v1/loads/" + t.loadId() + "/revisions/" + rid + "/confirm", Map.of(), t.shipper())
                .andExpect(jsonPath("$.agreedAmountInr").value(11000));

        trips.deliver(t);
        api.get("/api/v1/loads/" + t.loadId(), t.shipper()).andExpect(jsonPath("$.status").value("DELIVERED"));

        api.send("/api/v1/loads/" + t.loadId() + "/payment/mark-paid", Map.of("amountInr", 11000, "mode", "UPI", "reference", "UTR1"), t.shipper())
                .andExpect(jsonPath("$.status").value("PAID"));
        api.send(base + "/payment/confirm", Map.of("amountInr", 11000), t.driver()).andExpect(jsonPath("$.status").value("CONFIRMED"));

        api.send("/api/v1/ratings", Map.of("loadId", t.loadId(), "rateeUserId", t.driver().userId(), "stars", 5, "tags", List.of("On time")),
                t.shipper()).andExpect(status().isNoContent());
        api.send("/api/v1/ratings", Map.of("loadId", t.loadId(), "rateeUserId", t.shipper().userId(), "stars", 4), t.driver())
                .andExpect(status().isNoContent());

        UUID load = UUID.fromString(t.loadId());
        assertThat(jdbc.queryForObject("select closed_at is not null from loads_load where id = ?", Boolean.class, load)).isTrue();
        assertThat(jdbc.queryForObject("select count(*) from wallet_entry where load_id = ?", Long.class, load)).isGreaterThanOrEqualTo(2);
        assertThat(jdbc.queryForObject("select count(*) from trust_event where load_id = ?", Long.class, load)).isGreaterThanOrEqualTo(4);
        api.get("/api/v1/driver/history", t.driver()).andExpect(jsonPath("$.items[?(@.id == '" + t.loadId() + "')].paymentStatus").value("CONFIRMED"));
    }

    @Test
    void requestIdLegalAndDeletionRequest() throws Exception {
        mvc.perform(get("/api/v1/settings/public")).andExpect(header().exists("X-Request-Id"));
        mvc.perform(get("/api/v1/settings/public").header("X-Request-Id", "abc-12345")).andExpect(header().string("X-Request-Id", "abc-12345"));
        mvc.perform(get("/api/v1/legal/privacy")).andExpect(status().isOk()).andExpect(jsonPath("$.status").value("DRAFT_PENDING_LEGAL_REVIEW"));
        mvc.perform(get("/actuator/health")).andExpect(status().isOk());

        TestApi.Session user = api.verified("DRIVER");
        api.get("/api/v1/map/geocode?q=koyambedu", user).andExpect(jsonPath("$[0].name").value(org.hamcrest.Matchers.containsString("Koyambedu")))
                .andExpect(jsonPath("$[0].lat").value(13.0694));
        api.get("/api/v1/map/reverse?lat=10.49&lng=77.75", user).andExpect(jsonPath("$.address").value("Near 10.4900, 77.7500"));
        // going on duty with the phone position sets the location used for suggestions
        api.put("/api/v1/driver/duty", Map.of("onDuty", true, "lat", 12.97, "lng", 77.59), user).andExpect(status().isOk());
        assertThat(jdbc.queryForObject("select last_lat from fleet_driver_state where driver_id = ?", Double.class, user.userId())).isEqualTo(12.97);
        api.send("/api/v1/me/deletion-request", Map.of("reason", "Leaving the business"), user)
                .andExpect(jsonPath("$.type").value("OTHERS")).andExpect(jsonPath("$.otherText").value("Account deletion"));
    }
}
