package com.nothing.tranix.matching;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;
import com.nothing.tranix.TripFixtures;
import com.nothing.tranix.matching.internal.MatchingService;
import com.nothing.tranix.matching.internal.WishlistService;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;

/** B-651…B-656: wish list CRUD, audiences, windows, eligibility still enforced. Own area (lat 30+) per test. */
@IntegrationTest
@Import({TestApi.class, TripFixtures.class})
class WishlistIT {

    @Autowired
    TestApi api;

    @Autowired
    TripFixtures trips;

    @Autowired
    JdbcTemplate jdbc;

    @Autowired
    MatchingService matching;

    @Autowired
    WishlistService wishlist;

    @Autowired
    com.nothing.tranix.shared.settings.Settings settings;

    static final AtomicInteger AREA = new AtomicInteger();

    static double[] area() {
        int n = AREA.incrementAndGet();
        return new double[] {30.0 + n * 0.9, 70.0};
    }

    /** A delivered trip; its driver is moved to {@code a}, funded, and the shipper is funded. */
    TripFixtures.Trip pastTrip(double[] a) throws Exception {
        TripFixtures.Trip t = trips.accepted("LOAD_PROVIDER", "SHIPPER", null);
        trips.deliver(t);
        moveTo(t.driver(), a[0] + 0.02, a[1]);
        api.fund(t.driver(), 200);
        api.fund(t.shipper(), 300);
        return t;
    }

    void moveTo(TestApi.Session d, double lat, double lng) {
        jdbc.update("update fleet_driver_state set last_lat = ?, last_lng = ?, last_location_at = now(), on_duty = true where driver_id = ?",
                lat, lng, d.userId());
    }

    UUID truckOf(TestApi.Session d) {
        return jdbc.queryForObject("select id from fleet_truck where owner_id = ?", UUID.class, d.userId());
    }

    String post(TestApi.Session shipper, double[] a, String audience) throws Exception {
        Instant start = Instant.now().plus(1, ChronoUnit.DAYS);
        Map<String, Object> b = new HashMap<>();
        b.put("pickupWindowStart", start.toString());
        b.put("pickupWindowEnd", start.plus(3, ChronoUnit.HOURS).toString());
        b.put("pickup", Map.of("lat", a[0], "lng", a[1], "address", "Market Road, Town, District"));
        b.put("senderName", "Sender");
        b.put("senderMobile", "9876543210");
        b.put("goodsType", "Vegetables");
        b.put("quantity", 100);
        b.put("quantityUnit", "BAGS");
        b.put("weightTonnes", 2);
        b.put("vehicleType", "OPEN_BODY");
        b.put("drop", Map.of("lat", a[0] + 1, "lng", a[1] + 1, "address", "Big Market, City"));
        b.put("receiverName", "Receiver");
        b.put("receiverMobile", "9123456780");
        b.put("freightPaidBy", "SHIPPER");
        b.put("amountInr", 15000);
        b.put("audience", audience);
        return JsonPath.read(api.body(api.send("/api/v1/loads", b, shipper).andExpect(status().isOk())), "$.id");
    }

    int suggested(String loadId, TestApi.Session d) {
        Integer n = jdbc.queryForObject("select count(*) from matching_suggestion where load_id = ? and driver_id = ?", Integer.class,
                UUID.fromString(loadId), d.userId());
        return n == null ? 0 : n;
    }

    int notifications(TestApi.Session u, String type) {
        Integer n = jdbc.queryForObject("select count(*) from engagement_notification where user_id = ? and type = ?", Integer.class,
                u.userId(), type);
        return n == null ? 0 : n;
    }

    @Test
    void crudOnlyOwnTrucksLimitAndCandidates() throws Exception {
        TripFixtures.Trip t = pastTrip(area());
        TestApi.Session s = t.shipper();
        UUID truck = truckOf(t.driver());
        api.get("/api/v1/wishlist/candidates", s).andExpect(jsonPath("$[0].targetType").value("TRUCK"))
                .andExpect(jsonPath("$[0].truckId").value(truck.toString())).andExpect(jsonPath("$[0].tripsTogether").value(1));

        TestApi.Session stranger = trips.driverAt(area()[0], 70);
        api.send("/api/v1/wishlist", Map.of("targetType", "TRUCK", "truckId", truckOf(stranger)), s).andExpect(status().isForbidden());
        String id = JsonPath.read(api.body(api.send("/api/v1/wishlist", Map.of("targetType", "TRUCK", "truckId", truck, "note", "good"), s)
                .andExpect(status().isOk()).andExpect(jsonPath("$.truckNumber").exists())
                .andExpect(jsonPath("$.tripsTogether").value(1)).andExpect(jsonPath("$.available").value(true))), "$.id");
        api.send("/api/v1/wishlist", Map.of("targetType", "TRUCK", "truckId", truck), s).andExpect(status().isConflict());
        api.get("/api/v1/wishlist/candidates", s).andExpect(jsonPath("$", hasSize(0)));
        api.put("/api/v1/wishlist/" + id, Map.of("note", "careful with fruits"), s).andExpect(jsonPath("$.note").value("careful with fruits"));
        api.get("/api/v1/wishlist", s).andExpect(jsonPath("$", hasSize(1)));
        api.get("/api/v1/wishlist", t.driver()).andExpect(status().isForbidden());
        api.delete("/api/v1/wishlist/" + id, s).andExpect(status().isNoContent());
        api.get("/api/v1/wishlist", s).andExpect(jsonPath("$", hasSize(0)));

        // limit (setting wishlist.max_entries) → WISHLIST_FULL
        jdbc.update("update admin_setting set value = '0' where key = 'wishlist.max_entries'");
        settings.reload();
        try {
            api.send("/api/v1/wishlist", Map.of("targetType", "TRUCK", "truckId", truck), s)
                    .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("WISHLIST_FULL"));
        } finally {
            jdbc.update("update admin_setting set value = '20' where key = 'wishlist.max_entries'");
            settings.reload();
        }
    }

    @Test
    void wishlistOnlyRestrictsUntilOpenedAndNotifiesOnce() throws Exception {
        double[] a = area();
        TripFixtures.Trip t = pastTrip(a);
        TestApi.Session other = trips.driverAt(a[0] + 0.03, a[1]);
        api.send("/api/v1/wishlist", Map.of("targetType", "TRUCK", "truckId", truckOf(t.driver())), t.shipper()).andExpect(status().isOk());

        String load = post(t.shipper(), a, "WISHLIST_ONLY");
        api.get("/api/v1/loads/" + load, t.shipper()).andExpect(jsonPath("$.audience").value("WISHLIST_ONLY"));
        assertThat(suggested(load, t.driver())).isEqualTo(1);
        assertThat(suggested(load, other)).isZero();
        api.get("/api/v1/driver/suggestions", t.driver()).andExpect(jsonPath("$[?(@.loadId == '" + load + "')].preferredByShipper").value(true));

        // notify once after the setting's minutes
        jdbc.update("update loads_load set created_at = created_at - interval '31 minutes' where id = ?", UUID.fromString(load));
        wishlist.runWindows();
        wishlist.runWindows();
        assertThat(notifications(t.shipper(), "WISHLIST_NO_RESPONSE")).isEqualTo(1);

        api.send("/api/v1/loads/" + load + "/open-to-everyone", Map.of(), t.shipper())
                .andExpect(jsonPath("$.audience").value("EVERYONE")).andExpect(jsonPath("$.openedToEveryoneAt").exists());
        api.send("/api/v1/loads/" + load + "/open-to-everyone", Map.of(), t.shipper()).andExpect(status().isConflict());
        matching.runDueBatches();
        assertThat(suggested(load, other)).isEqualTo(1);
    }

    @Test
    void wishlistFirstOpensToEveryoneAfterTheWindow() throws Exception {
        double[] a = area();
        TripFixtures.Trip t = pastTrip(a);
        TestApi.Session other = trips.driverAt(a[0] + 0.03, a[1]);
        api.send("/api/v1/wishlist", Map.of("targetType", "TRUCK", "truckId", truckOf(t.driver())), t.shipper()).andExpect(status().isOk());

        String load = post(t.shipper(), a, "WISHLIST_FIRST");
        api.get("/api/v1/loads/" + load, t.shipper()).andExpect(jsonPath("$.wishlistUntil").exists());
        assertThat(suggested(load, other)).isZero();
        wishlist.runWindows(); // window not over yet
        api.get("/api/v1/loads/" + load, t.shipper()).andExpect(jsonPath("$.audience").value("WISHLIST_FIRST"));

        jdbc.update("update loads_load set wishlist_until = now() - interval '1 minute' where id = ?", UUID.fromString(load));
        wishlist.runWindows();
        api.get("/api/v1/loads/" + load, t.shipper()).andExpect(jsonPath("$.audience").value("EVERYONE"));
        assertThat(notifications(t.shipper(), "WISHLIST_OPENED")).isEqualTo(1);
        matching.runDueBatches();
        assertThat(suggested(load, other)).isEqualTo(1);
    }

    @Test
    void eligibilityStillAppliesAndEmptyListIsRejected() throws Exception {
        double[] a = area();
        TripFixtures.Trip t = pastTrip(a);
        api.send("/api/v1/wishlist", Map.of("targetType", "TRUCK", "truckId", truckOf(t.driver())), t.shipper()).andExpect(status().isOk());
        jdbc.update("update fleet_driver_state set on_duty = false where driver_id = ?", t.driver().userId());
        String load = post(t.shipper(), a, "WISHLIST_ONLY");
        assertThat(suggested(load, t.driver())).isZero();

        TestApi.Session fresh = api.verified("LOAD_PROVIDER");
        api.fund(fresh, 100);
        Map<String, Object> b = new HashMap<>();
        b.put("audience", "WISHLIST_FIRST");
        Instant start = Instant.now().plus(1, ChronoUnit.DAYS);
        b.put("pickupWindowStart", start.toString());
        b.put("pickupWindowEnd", start.plus(3, ChronoUnit.HOURS).toString());
        b.put("pickup", Map.of("lat", a[0], "lng", a[1], "address", "Market Road, Town, District"));
        b.put("senderName", "Sender");
        b.put("senderMobile", "9876543210");
        b.put("goodsType", "Vegetables");
        b.put("quantity", 100);
        b.put("quantityUnit", "BAGS");
        b.put("weightTonnes", 2);
        b.put("vehicleType", "OPEN_BODY");
        b.put("drop", Map.of("lat", a[0] + 1, "lng", a[1] + 1, "address", "Big Market, City"));
        b.put("receiverName", "Receiver");
        b.put("receiverMobile", "9123456780");
        b.put("freightPaidBy", "SHIPPER");
        b.put("amountInr", 15000);
        api.send("/api/v1/loads", b, fresh).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("WISHLIST_EMPTY"));
    }

    @Test
    void organizationSearchAddAndDashboardCount() throws Exception {
        TestApi.Session org = api.verified("ORGANIZATION");
        String name = "Kaveri Logistics " + UUID.randomUUID().toString().substring(0, 6);
        jdbc.update("""
                insert into identity_role_profile (user_id, role, data, updated_at) values (?, 'ORGANIZATION', ?, now())
                on conflict (user_id) do update set data = excluded.data""", org.userId(),
                "{\"orgName\":\"" + name + "\",\"contactPerson\":\"Ravi\"}");
        TestApi.Session s = api.verified("FARMER_NETWORK");
        api.get("/api/v1/wishlist/org-search?q=" + name.substring(0, 12).toLowerCase(), s)
                .andExpect(jsonPath("$[?(@.orgId == '" + org.userId() + "')].orgName").value(name));
        String code = "ORG-" + org.userId().toString().substring(0, 6).toUpperCase();
        api.get("/api/v1/wishlist/org-search?q=" + code, s).andExpect(jsonPath("$[0].orgCode").value(code));
        api.send("/api/v1/wishlist", Map.of("targetType", "ORGANIZATION", "orgId", org.userId()), s)
                .andExpect(status().isOk()).andExpect(jsonPath("$.orgName").value(name));
        api.get("/api/v1/org/dashboard", org).andExpect(jsonPath("$.preferredByShippersCount").value(1));
    }
}
