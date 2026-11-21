package com.nothing.tranix.matching;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicInteger;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;
import com.nothing.tranix.matching.internal.MatchingService;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.wallet.api.WalletApi;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;

/** B-601…B-607. Each test uses its own area so drivers from other tests are out of range. */
@IntegrationTest
@Import(TestApi.class)
class MatchingIT {

    @Autowired
    TestApi api;

    @Autowired
    JdbcTemplate jdbc;

    @Autowired
    MatchingService matching;

    @Autowired
    WalletApi wallet;

    @Autowired
    Settings settings;

    static final AtomicInteger AREA = new AtomicInteger();

    /** A unique pickup point per test (≈ 2° of latitude apart). */
    static double[] area() {
        int n = AREA.incrementAndGet();
        return new double[] {8.5 + n * 0.9, 76.5 + (n % 3) * 0.9};
    }

    /** Verified owner-driver with a valid truck and licence, on duty at (lat, lng), wallet funded. */
    TestApi.Session driver(double lat, double lng, String vehicleType, double capacity) throws Exception {
        TestApi.Session d = api.verified("DRIVER");
        UUID truck = UUID.randomUUID();
        String plate = "KA" + (10 + (int) (Math.random() * 89)) + "MX" + (1000 + (int) (Math.random() * 8999));
        jdbc.update("""
                insert into fleet_truck (id, owner_type, owner_id, number, vehicle_type, capacity_tonnes, active, created_at, updated_at, version)
                values (?, 'DRIVER', ?, ?, ?, ?, true, now(), now(), 0)""", truck, d.userId(), plate, vehicleType, capacity);
        for (String type : List.of("RC", "INSURANCE", "NATIONAL_PERMIT")) {
            doc("TRUCK", truck, d.userId(), type);
        }
        doc("USER", d.userId(), d.userId(), "DRIVING_LICENCE");
        jdbc.update("""
                insert into fleet_driver_state (driver_id, on_duty, last_lat, last_lng, last_location_at, updated_at)
                values (?, true, ?, ?, now(), now())""", d.userId(), lat, lng);
        api.fund(d, 100);
        return d;
    }

    void doc(String ownerType, UUID owner, UUID user, String type) {
        jdbc.update("""
                insert into identity_document (id, owner_type, owner_id, user_id, type, file_ids, expires_on, status, created_at, updated_at, version)
                values (?, ?, ?, ?, ?, '', ?, 'APPROVED', now(), now(), 0)""", UUID.randomUUID(), ownerType, owner, user, type,
                LocalDate.now().plusYears(1));
    }

    TestApi.Session shipper() throws Exception {
        TestApi.Session s = api.verified("LOAD_PROVIDER");
        api.fund(s, 200);
        return s;
    }

    String post(TestApi.Session shipper, double lat, double lng, String vehicleType, double weight) throws Exception {
        Instant start = Instant.now().plus(1, ChronoUnit.DAYS);
        Map<String, Object> b = new HashMap<>();
        b.put("pickupWindowStart", start.toString());
        b.put("pickupWindowEnd", start.plus(3, ChronoUnit.HOURS).toString());
        b.put("pickup", Map.of("lat", lat, "lng", lng, "address", "Market Road, Town, District"));
        b.put("senderName", "Sender");
        b.put("senderMobile", "9876543210");
        b.put("goodsType", "Vegetables");
        b.put("quantity", 100);
        b.put("quantityUnit", "BAGS");
        b.put("weightTonnes", weight);
        b.put("vehicleType", vehicleType);
        b.put("drop", Map.of("lat", lat + 1, "lng", lng + 1, "address", "Big Market, City"));
        b.put("receiverName", "Receiver");
        b.put("receiverMobile", "9123456780");
        b.put("freightPaidBy", "SHIPPER");
        b.put("amountInr", 15000);
        return JsonPath.read(api.body(api.send("/api/v1/loads", b, shipper).andExpect(status().isOk())), "$.id");
    }

    @Test
    void eligibleDriversGetAreaOnlySuggestionsAndFirstAcceptWins() throws Exception {
        double[] a = area();
        TestApi.Session near = driver(a[0] + 0.02, a[1], "OPEN_BODY", 9);
        TestApi.Session wrongType = driver(a[0] + 0.01, a[1], "TANKER", 9);
        TestApi.Session tooSmall = driver(a[0] + 0.01, a[1] + 0.01, "OPEN_BODY", 2);
        TestApi.Session far = driver(a[0] + 0.9, a[1], "OPEN_BODY", 9);
        TestApi.Session second = driver(a[0] + 0.05, a[1], "OPEN_BODY", 12);
        TestApi.Session shipper = shipper();
        String load = post(shipper, a[0], a[1], "OPEN_BODY", 3.5);

        String list = api.body(api.get("/api/v1/driver/suggestions", near).andExpect(status().isOk())
                .andExpect(jsonPath("$[0].loadId").value(load))
                .andExpect(jsonPath("$[0].pickupArea").value("Town, District"))
                .andExpect(jsonPath("$[0].preferredByShipper").value(false)));
        assertThat(list).doesNotContain("9876543210").doesNotContain("Market Road").doesNotContain("Sender");
        api.get("/api/v1/driver/suggestions", wrongType).andExpect(jsonPath("$.length()").value(0));
        api.get("/api/v1/driver/suggestions", tooSmall).andExpect(jsonPath("$.length()").value(0));
        api.get("/api/v1/driver/suggestions", far).andExpect(jsonPath("$.length()").value(0));
        api.get("/api/v1/driver/home", near).andExpect(jsonPath("$.suggestionsCount").value(1));

        api.send("/api/v1/driver/suggestions/" + load + "/accept", Map.of(), near).andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("WAITING_FOR_PICKUP"));
        api.send("/api/v1/driver/suggestions/" + load + "/accept", Map.of(), second)
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("LOAD_TAKEN"));
        assertThat(wallet.balance(shipper.userId())).isEqualTo(150);
        assertThat(wallet.balance(near.userId())).isEqualTo(50);
        assertThat(wallet.balance(second.userId())).isEqualTo(100);
        api.get("/api/v1/loads/" + load, shipper)
                .andExpect(jsonPath("$.timeline[1].status").value("ACCEPTED"))
                .andExpect(jsonPath("$.timeline[2].status").value("WAITING_FOR_PICKUP"))
                .andExpect(jsonPath("$.driver.mobile").value(near.mobile()))
                .andExpect(jsonPath("$.driver.truckNumber").isString());
        api.get("/api/v1/driver/suggestions", second).andExpect(jsonPath("$.length()").value(0));
    }

    @Test
    void acceptNeedsBothChargesOtherwiseNothingChanges() throws Exception {
        double[] a = area();
        TestApi.Session d = driver(a[0], a[1] + 0.02, "OPEN_BODY", 9);
        TestApi.Session shipper = api.verified("LOAD_PROVIDER");
        api.fund(shipper, 50);
        String load = post(shipper, a[0], a[1], "OPEN_BODY", 3);
        // shipper spends the balance elsewhere before the driver accepts
        wallet.charge(shipper.userId(), WalletApi.ChargeType.POSTING_CHARGE, UUID.randomUUID());
        api.send("/api/v1/driver/suggestions/" + load + "/accept", Map.of(), d)
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("INSUFFICIENT_BALANCE"));
        api.get("/api/v1/loads/" + load, shipper).andExpect(jsonPath("$.status").value("NOT_ACCEPTED"));
        assertThat(wallet.balance(d.userId())).isEqualTo(100);
    }

    @Test
    void rejectAndBatchesWidenRadiusThenNotifyShipper() throws Exception {
        double[] a = area();
        TestApi.Session shipper = shipper();
        TestApi.Session d = driver(a[0] + 0.3, a[1], "OPEN_BODY", 9); // ~33 km: outside the first 25 km radius
        String load = post(shipper, a[0], a[1], "OPEN_BODY", 3);
        // first batch already widened to 50 km and found the driver
        api.get("/api/v1/driver/suggestions", d).andExpect(jsonPath("$.length()").value(1));
        api.send("/api/v1/driver/suggestions/" + load + "/reject", Map.of("reason", "TOO_FAR"), d).andExpect(status().isNoContent());
        api.get("/api/v1/driver/suggestions", d).andExpect(jsonPath("$.length()").value(0));
        assertThat(jdbc.queryForObject("select reject_reason from matching_suggestion where load_id = ?::uuid", String.class, load))
                .isEqualTo("TOO_FAR");

        String lonely = post(shipper, a[0] - 0.45, a[1] + 0.45, "REFRIGERATED", 3);
        jdbc.update("update matching_load_state set next_batch_at = now() - interval '1 minute' where load_id = ?::uuid", lonely);
        matching.runDueBatches();
        matching.runDueBatches();
        assertThat(jdbc.queryForObject("select radius_km from matching_load_state where load_id = ?::uuid", Integer.class, lonely))
                .isEqualTo(100);
        api.get("/api/v1/notifications?tab=TRIPS", shipper)
                .andExpect(jsonPath("$.items[?(@.type=='NO_DRIVER_FOUND')]", org.hamcrest.Matchers.hasSize(1)));
    }

    @Test
    void tenDriversAcceptAtOnceExactlyOneWins() throws Exception {
        double[] a = area();
        jdbc.update("update admin_setting set value = '10' where key = 'matching.batch_size'");
        settings.reload();
        try {
            List<TestApi.Session> drivers = new ArrayList<>();
            for (int i = 0; i < 10; i++) {
                drivers.add(driver(a[0] + 0.001 * i, a[1], "OPEN_BODY", 9));
            }
            TestApi.Session shipper = shipper();
            UUID load = UUID.fromString(post(shipper, a[0], a[1], "OPEN_BODY", 3));
            assertThat(jdbc.queryForObject("select count(*) from matching_suggestion where load_id = ?", Integer.class, load)).isEqualTo(10);
            ExecutorService pool = Executors.newFixedThreadPool(10);
            CountDownLatch go = new CountDownLatch(1);
            List<Future<Boolean>> results = new ArrayList<>();
            for (TestApi.Session d : drivers) {
                results.add(pool.submit(() -> {
                    go.await();
                    try {
                        matching.accept(d.userId(), load);
                        return true;
                    } catch (ApiException e) {
                        return false;
                    }
                }));
            }
            go.countDown();
            int wins = 0;
            for (Future<Boolean> f : results) {
                wins += f.get() ? 1 : 0;
            }
            pool.shutdown();
            assertThat(wins).isEqualTo(1);
            assertThat(wallet.balance(shipper.userId())).isEqualTo(150);
            assertThat(jdbc.queryForObject("select count(*) from wallet_entry where load_id = ?", Integer.class, load)).isEqualTo(2);
            assertThat(jdbc.queryForObject("select count(*) from matching_suggestion where load_id = ? and status = 'ACCEPTED'",
                    Integer.class, load)).isEqualTo(1);
        } finally {
            jdbc.update("update admin_setting set value = '5' where key = 'matching.batch_size'");
            settings.reload();
        }
    }
}
