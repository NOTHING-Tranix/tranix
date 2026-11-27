package com.nothing.tranix.shared;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;
import com.nothing.tranix.TripFixtures;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

/** B-1612 … B-1616: findings of the complete backend test. */
@IntegrationTest
@Import({TestApi.class, TripFixtures.class})
class SmallFixesIT {

    @Autowired
    TestApi api;

    @Autowired
    TripFixtures trips;

    @Autowired
    MockMvc mvc;

    Map<String, Object> load(double lat, double lng) {
        Instant start = Instant.now().plus(2, ChronoUnit.HOURS);
        Map<String, Object> b = new HashMap<>();
        b.put("pickupWindowStart", start.toString());
        b.put("pickupWindowEnd", start.plus(3, ChronoUnit.HOURS).toString());
        b.put("pickup", Map.of("lat", lat, "lng", lng, "address", "Yard 2, Market, District"));
        b.put("senderName", "Sender");
        b.put("senderMobile", TestApi.newMobile());
        b.put("goodsType", "Fruits");
        b.put("quantity", 10);
        b.put("quantityUnit", "BOXES");
        b.put("weightTonnes", 2);
        b.put("vehicleType", "OPEN_BODY");
        b.put("drop", Map.of("lat", lat + 0.2, "lng", lng + 0.2, "address", "Depot, City"));
        b.put("receiverName", "Receiver");
        b.put("receiverMobile", TestApi.newMobile());
        b.put("freightPaidBy", "SHIPPER");
        b.put("amountInr", 5000);
        return b;
    }

    /** B-1612: a driver who accepted a load no longer sees the other open loads. */
    @Test
    void busyDriverGetsNoSuggestions() throws Exception {
        double lat = 9.51, lng = 76.33;
        TestApi.Session d = trips.driverAt(lat + 0.01, lng);
        TestApi.Session s = api.verified("LOAD_PROVIDER");
        api.fund(s, 200);
        String l1 = JsonPath.read(api.body(api.send("/api/v1/loads", load(lat, lng), s).andExpect(status().isOk())), "$.id");
        String l2 = JsonPath.read(api.body(api.send("/api/v1/loads", load(lat, lng), s).andExpect(status().isOk())), "$.id");
        List<String> before = JsonPath.read(api.body(api.get("/api/v1/driver/suggestions", d)), "$[*].loadId");
        assertThat(before).contains(l1, l2);
        api.send("/api/v1/driver/suggestions/" + l1 + "/accept", Map.of(), d).andExpect(status().isOk());
        api.get("/api/v1/driver/suggestions", d).andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(0));
    }

    /** B-1615: bad requests are 4xx with a code, never 500. */
    @Test
    void badRequestsGetClearErrors() throws Exception {
        TripFixtures.Trip t = trips.accepted("LOAD_PROVIDER", "SHIPPER", null);
        api.send("/api/v1/driver/trips/" + t.loadId() + "/locations", Arrays.asList((Object) null), t.driver())
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("VALIDATION_FAILED"));

        api.send("/api/v1/files", Map.of(), t.shipper())
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("VALIDATION_FAILED"));

        String bearer = "Bearer " + t.shipper().accessToken();
        mvc.perform(get("/api/v1/org/trips/export").header("Authorization", bearer).accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotAcceptable()).andExpect(jsonPath("$.code").value("VALIDATION_FAILED"));
        mvc.perform(get("/api/v1/org/trips/export").header("Authorization", bearer).accept(MediaType.ALL))
                .andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("FORBIDDEN"));
        mvc.perform(get("/api/v1/wallet/statement?month=2026-11").header("Authorization", bearer).accept(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotAcceptable());
        mvc.perform(get("/api/v1/wallet/statement?month=bad").header("Authorization", bearer).accept(MediaType.ALL))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("VALIDATION_FAILED"));

        mvc.perform(post("/api/v1/webhooks/payments").contentType(MediaType.TEXT_PLAIN).content("evt|x|PAID|1"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("VALIDATION_FAILED"));
    }

    /** B-1615: the same mobile signing up 5 times at once → one account, the others MOBILE_IN_USE (not 500). */
    @Test
    void simultaneousSignUpsOfOneMobile() throws Exception {
        String mobile = TestApi.newMobile();
        api.send("/api/v1/auth/otp/send", Map.of("mobile", mobile, "purpose", "SIGN_UP"), null).andExpect(status().isNoContent());
        String otp = api.lastOtp(mobile);
        List<Integer> codes = burst(5, i -> api.send("/api/v1/auth/sign-up", Map.of("mobile", mobile, "otp", otp,
                "name", "Twin " + i, "role", "RECEIVER", "consent", true), null).andReturn().getResponse().getStatus());
        assertThat(codes).doesNotContain(500);
        assertThat(codes.stream().filter(c -> c == 200)).hasSize(1);
    }

    /** B-1613: a ticket reopened twice at the same moment is reopened once. */
    @Test
    void ticketReopenedOnce() throws Exception {
        TestApi.Session u = api.verified("LOAD_PROVIDER");
        TestApi.Session admin = api.admin();
        String id = JsonPath.read(api.body(api.send("/api/v1/tickets", Map.of("type", "FEEDBACK", "description", "Burst reopen",
                "fileIds", List.of()), u).andExpect(status().isOk())), "$.id");
        api.send("/api/v1/admin/tickets/" + id + "/reply", Map.of("body", "Done", "close", true), admin).andExpect(status().isOk());
        List<Integer> codes = burst(5, i -> api.send("/api/v1/tickets/" + id + "/reopen", Map.of(), u).andReturn().getResponse().getStatus());
        assertThat(codes.stream().filter(c -> c == 200)).hasSize(1);
        assertThat(codes).doesNotContain(500);
    }

    /** B-1614: the delivery estimate is a shipper tool. */
    @Test
    void estimateIsForShippers() throws Exception {
        Map<String, Object> body = Map.of("pickup", Map.of("lat", 12.0, "lng", 78.0), "drop", Map.of("lat", 12.5, "lng", 78.5),
                "pickupWindowStart", Instant.now().plus(1, ChronoUnit.HOURS).toString());
        api.send("/api/v1/loads/estimate", body, api.verified("DRIVER")).andExpect(status().isForbidden());
        api.send("/api/v1/loads/estimate", body, api.verified("LOAD_PROVIDER")).andExpect(status().isOk());
    }

    interface Call {
        int run(int i) throws Exception;
    }

    List<Integer> burst(int n, Call call) throws Exception {
        CountDownLatch start = new CountDownLatch(1);
        ExecutorService pool = Executors.newFixedThreadPool(n);
        List<Future<Integer>> fs = new ArrayList<>();
        for (int i = 0; i < n; i++) {
            int k = i;
            Callable<Integer> c = () -> {
                start.await();
                return call.run(k);
            };
            fs.add(pool.submit(c));
        }
        start.countDown();
        List<Integer> out = new ArrayList<>();
        for (Future<Integer> f : fs) {
            out.add(f.get());
        }
        pool.shutdown();
        return out;
    }
}
