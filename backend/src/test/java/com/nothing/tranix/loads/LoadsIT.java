package com.nothing.tranix.loads;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;
import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.loads.api.LoadEvents;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.types.LoadStatus;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.event.ApplicationEvents;
import org.springframework.test.context.event.RecordApplicationEvents;

/** B-401…B-407, B-409. */
@IntegrationTest
@Import(TestApi.class)
@RecordApplicationEvents
class LoadsIT {

    @Autowired
    TestApi api;

    @Autowired
    LoadDirectory loads;

    @Autowired
    JdbcTemplate jdbc;

    @Autowired
    ApplicationEvents events;

    static Map<String, Object> body() {
        Instant start = Instant.now().plus(1, ChronoUnit.DAYS).truncatedTo(ChronoUnit.HOURS);
        Map<String, Object> m = new HashMap<>();
        m.put("pickupWindowStart", start.toString());
        m.put("pickupWindowEnd", start.plus(3, ChronoUnit.HOURS).toString());
        m.put("pickup", Map.of("lat", 10.4893, "lng", 77.7471, "address", "Gandhi Market, Oddanchatram, Dindigul", "landmark", "Bus stand"));
        m.put("senderName", "Murugan");
        m.put("senderMobile", "9876543210");
        m.put("goodsType", "Vegetables");
        m.put("description", "Tomatoes");
        m.put("quantity", 120);
        m.put("quantityUnit", "CRATES");
        m.put("weightTonnes", 3.6);
        m.put("vehicleType", "OPEN_BODY");
        m.put("drop", Map.of("lat", 13.0694, "lng", 80.1948, "address", "Koyambedu Market, Chennai"));
        m.put("receiverName", "Selvi");
        m.put("receiverMobile", "9123456780");
        m.put("freightPaidBy", "SHIPPER");
        m.put("amountInr", 18000);
        return m;
    }

    String post(TestApi.Session s) throws Exception {
        return JsonPath.read(api.body(api.send("/api/v1/loads", body(), s).andExpect(status().isOk())), "$.id");
    }

    @Test
    void postNeedsVerifiedAndBalanceButDeductsNothing() throws Exception {
        TestApi.Session unverified = api.signUp("LOAD_PROVIDER");
        api.send("/api/v1/loads", body(), unverified).andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("NOT_VERIFIED"));
        TestApi.Session lp = api.verified("LOAD_PROVIDER");
        api.send("/api/v1/loads", body(), lp).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("INSUFFICIENT_BALANCE"));
        api.fund(lp, 100);
        String detail = api.body(api.send("/api/v1/loads", body(), lp).andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(org.hamcrest.Matchers.startsWith("TRX-")))
                .andExpect(jsonPath("$.status").value("NOT_ACCEPTED"))
                .andExpect(jsonPath("$.pickupArea").value("Oddanchatram, Dindigul"))
                .andExpect(jsonPath("$.dropArea").value("Chennai"))
                .andExpect(jsonPath("$.canEdit").value(true))
                .andExpect(jsonPath("$.cancelInfo.chargesKept").value(false))
                .andExpect(jsonPath("$.timeline[0].status").value("NOT_ACCEPTED")));
        assertThat((Integer) JsonPath.read(detail, "$.agreedAmountInr")).isEqualTo(18000);
        api.get("/api/v1/wallet", lp).andExpect(jsonPath("$.balanceInr").value(100));
        assertThat(events.stream(LoadEvents.LoadPosted.class)).isNotEmpty();
    }

    @Test
    void validationAndOwnership() throws Exception {
        TestApi.Session lp = api.verified("LOAD_PROVIDER");
        api.fund(lp, 100);
        Map<String, Object> bad = body();
        bad.put("pickupWindowEnd", bad.get("pickupWindowStart"));
        api.send("/api/v1/loads", bad, lp).andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("pickupWindowEnd"));
        bad = body();
        bad.put("goodsType", "Gold");
        api.send("/api/v1/loads", bad, lp).andExpect(jsonPath("$.fields[0].field").value("goodsType"));
        bad = body();
        bad.put("receiverMobile", "123");
        api.send("/api/v1/loads", bad, lp).andExpect(jsonPath("$.fields[0].field").value("receiverMobile"));
        bad = body();
        bad.put("audience", "WISHLIST_ONLY");
        api.send("/api/v1/loads", bad, lp).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("WISHLIST_EMPTY"));
        TestApi.Session driver = api.verified("DRIVER");
        api.send("/api/v1/loads", body(), driver).andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("FORBIDDEN"));

        String id = post(lp);
        TestApi.Session other = api.verified("LOAD_PROVIDER");
        api.get("/api/v1/loads/" + id, other).andExpect(status().isNotFound());
        api.get("/api/v1/loads?scope=ONGOING", lp).andExpect(jsonPath("$.total").value(1))
                .andExpect(jsonPath("$.items[0].pickupArea").value("Oddanchatram, Dindigul"));
        api.get("/api/v1/loads?scope=BAD", lp).andExpect(status().isBadRequest());
    }

    @Test
    void estimateUsesMapsAndLoadingBuffer() throws Exception {
        TestApi.Session lp = api.verified("LOAD_PROVIDER");
        Instant start = Instant.parse("2030-01-01T04:00:00Z");
        String body = api.body(api.send("/api/v1/loads/estimate", Map.of("pickup", Map.of("lat", 10.4893, "lng", 77.7471),
                "drop", Map.of("lat", 13.0694, "lng", 80.1948), "pickupWindowStart", start.toString()), lp).andExpect(status().isOk()));
        double km = ((Number) JsonPath.read(body, "$.distanceKm")).doubleValue();
        int minutes = JsonPath.read(body, "$.driveMinutes");
        assertThat(km).isBetween(450.0, 520.0);
        assertThat(Instant.parse(JsonPath.read(body, "$.deliveryEta"))).isEqualTo(start.plusSeconds((minutes + 60) * 60L));
    }

    @Test
    void editOnlyWhileNotAcceptedAndCancelRules() throws Exception {
        TestApi.Session lp = api.verified("LOAD_PROVIDER");
        api.fund(lp, 200);
        String id = post(lp);
        Map<String, Object> changed = body();
        changed.put("amountInr", 19000);
        api.put("/api/v1/loads/" + id, changed, lp).andExpect(status().isOk()).andExpect(jsonPath("$.agreedAmountInr").value(19000));

        // simulate acceptance + pickup through the status machine
        jdbc.update("update loads_load set status = 'ACCEPTED', driver_id = ? where id = ?", UUID.randomUUID(), UUID.fromString(id));
        api.put("/api/v1/loads/" + id, changed, lp).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("INVALID_STATE"));
        api.get("/api/v1/loads/" + id, lp).andExpect(jsonPath("$.cancelInfo.chargesKept").value(true))
                .andExpect(jsonPath("$.cancelInfo.trustScorePenalty").value(-5));
        loads.transition(UUID.fromString(id), LoadStatus.WAITING_FOR_PICKUP, null);
        assertThatThrownBy(() -> loads.transition(UUID.fromString(id), LoadStatus.DELIVERED, null))
                .isInstanceOf(ApiException.class);
        api.send("/api/v1/loads/" + id + "/cancel", Map.of("reason", "BAD"), lp).andExpect(status().isBadRequest());
        api.send("/api/v1/loads/" + id + "/cancel", Map.of("reason", "PLANS_CHANGED"), lp).andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("CANCELLED"));
        LoadEvents.LoadCancelled c = events.stream(LoadEvents.LoadCancelled.class)
                .filter(e -> e.loadId().toString().equals(id)).findFirst().orElseThrow();
        assertThat(c.chargesKept()).isTrue();
        assertThat(c.penaltyPoints()).isEqualByComparingTo("-5");

        // before acceptance: free, no penalty; driver-fault reason after acceptance: no penalty
        String free = post(lp);
        api.send("/api/v1/loads/" + free + "/cancel", Map.of("reason", "GOODS_NOT_READY"), lp).andExpect(status().isOk());
        assertThat(events.stream(LoadEvents.LoadCancelled.class).filter(e -> e.loadId().toString().equals(free))
                .findFirst().orElseThrow().chargesKept()).isFalse();

        // after pickup: support only
        String picked = post(lp);
        jdbc.update("update loads_load set status = 'PICKED_UP' where id = ?", UUID.fromString(picked));
        api.send("/api/v1/loads/" + picked + "/cancel", Map.of("reason", "PLANS_CHANGED"), lp)
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("INVALID_STATE"));

        // D-34: a running trip can not be reposted (no duplicates); a delivered one can ("post the same again")
        api.send("/api/v1/loads/" + picked + "/repost", Map.of(), lp)
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("INVALID_STATE"));
        String done = post(lp);
        jdbc.update("update loads_load set status = 'DELIVERED' where id = ?", UUID.fromString(done));
        api.send("/api/v1/loads/" + done + "/repost", Map.of(), lp).andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("NOT_ACCEPTED"));

        // repost creates a new open load
        api.send("/api/v1/loads/" + id + "/repost", Map.of(), lp).andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("NOT_ACCEPTED"))
                .andExpect(jsonPath("$.id").value(org.hamcrest.Matchers.not(id)));
        api.get("/api/v1/loads?scope=HISTORY", lp).andExpect(jsonPath("$.total").value(2));
    }

    @Test
    void registeredReceiverIsLinked() throws Exception {
        TestApi.Session receiver = api.signUp("RECEIVER");
        TestApi.Session lp = api.verified("LOAD_PROVIDER");
        api.fund(lp, 100);
        Map<String, Object> b = body();
        b.put("receiverMobile", receiver.mobile());
        String id = JsonPath.read(api.body(api.send("/api/v1/loads", b, lp)), "$.id");
        assertThat(loads.get(UUID.fromString(id)).receiverUserId()).isEqualTo(receiver.userId());
    }
}
