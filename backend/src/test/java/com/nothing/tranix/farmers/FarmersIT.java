package com.nothing.tranix.farmers;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.Map;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;
import com.nothing.tranix.TripFixtures;
import com.nothing.tranix.shared.integrations.fake.FakeSmsSender;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;

/** B-901…B-904: farmers CRUD (consent, Aadhaar last 4 only), post for a farmer, farmer SMS, farmer filter. */
@IntegrationTest
@Import({TestApi.class, TripFixtures.class})
class FarmersIT {

    @Autowired
    TestApi api;

    @Autowired
    TripFixtures trips;

    @Autowired
    JdbcTemplate jdbc;

    @Autowired
    FakeSmsSender sms;

    Map<String, Object> farmer(String mobile) {
        Map<String, Object> b = new HashMap<>();
        b.put("name", "Raman");
        b.put("mobile", mobile);
        b.put("aadhaarLast4", "1234");
        b.put("landAcres", 2.5);
        b.put("village", "Kallupatti");
        b.put("consent", true);
        return b;
    }

    @Test
    void crudWithConsentAndLast4Only() throws Exception {
        TestApi.Session fn = api.verified("FARMER_NETWORK");
        Map<String, Object> noConsent = farmer("9811100001");
        noConsent.put("consent", false);
        api.send("/api/v1/farmers", noConsent, fn).andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("consent"));
        Map<String, Object> fullAadhaar = farmer("9811100001");
        fullAadhaar.put("aadhaarLast4", "123412341234");
        api.send("/api/v1/farmers", fullAadhaar, fn).andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("aadhaarLast4"));

        String id = JsonPath.read(api.body(api.send("/api/v1/farmers", farmer("9811100001"), fn).andExpect(status().isOk())
                .andExpect(jsonPath("$.aadhaarLast4").value("1234"))), "$.id");
        api.send("/api/v1/farmers", farmer("9811100001"), fn).andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("mobile"));
        Map<String, Object> edit = farmer("9811100002");
        edit.put("name", "Raman K");
        api.put("/api/v1/farmers/" + id, edit, fn).andExpect(jsonPath("$.name").value("Raman K"));
        api.get("/api/v1/farmers?q=raman", fn).andExpect(jsonPath("$.items", hasSize(1))).andExpect(jsonPath("$.total").value(1));

        TestApi.Session lp = api.verified("LOAD_PROVIDER");
        api.get("/api/v1/farmers", lp).andExpect(status().isForbidden());
        api.send("/api/v1/farmers", farmer("9811100003"), api.signUp("FARMER_NETWORK")).andExpect(status().isForbidden()); // not verified

        api.send("/api/v1/farmers/" + id + "/deactivate", Map.of(), fn).andExpect(jsonPath("$.active").value(false));
        api.get("/api/v1/farmers", fn).andExpect(jsonPath("$.items", hasSize(0)));
        api.get("/api/v1/farmers?includeInactive=true", fn).andExpect(jsonPath("$.items", hasSize(1)));
    }

    @Test
    void postForFarmerMakesFarmerTheSenderAndFiltersByFarmer() throws Exception {
        TestApi.Session fn = api.verified("FARMER_NETWORK");
        api.fund(fn, 200);
        String farmerId = JsonPath.read(api.body(api.send("/api/v1/farmers", farmer("9822200001"), fn)), "$.id");
        TestApi.Session other = api.verified("FARMER_NETWORK");
        String othersFarmer = JsonPath.read(api.body(api.send("/api/v1/farmers", farmer("9822200002"), other)), "$.id");

        double lat = 26.5;
        double lng = 92.0;
        TestApi.Session driver = trips.driverAt(lat + 0.01, lng);
        Instant start = Instant.now().plus(2, ChronoUnit.HOURS);
        Map<String, Object> b = new HashMap<>();
        b.put("pickupWindowStart", start.toString());
        b.put("pickupWindowEnd", start.plus(3, ChronoUnit.HOURS).toString());
        b.put("pickup", Map.of("lat", lat, "lng", lng, "address", "Farm gate, Village, District"));
        b.put("senderName", "Someone else");
        b.put("senderMobile", "9000099999");
        b.put("goodsType", "Vegetables");
        b.put("quantity", 50);
        b.put("quantityUnit", "BAGS");
        b.put("weightTonnes", 2);
        b.put("vehicleType", "OPEN_BODY");
        b.put("drop", Map.of("lat", lat + 0.3, "lng", lng + 0.3, "address", "Mandi, City"));
        b.put("receiverName", "Trader");
        b.put("receiverMobile", "9833300001");
        b.put("freightPaidBy", "SHIPPER");
        b.put("amountInr", 9000);
        b.put("postedForFarmerId", othersFarmer);
        api.send("/api/v1/loads", b, fn).andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("postedForFarmerId"));

        b.put("postedForFarmerId", farmerId);
        String load = JsonPath.read(api.body(api.send("/api/v1/loads", b, fn).andExpect(status().isOk())
                .andExpect(jsonPath("$.senderName").value("Raman")).andExpect(jsonPath("$.senderMobile").value("9822200001"))
                .andExpect(jsonPath("$.postedForFarmerName").value("Raman"))), "$.id");
        api.get("/api/v1/loads?farmerId=" + farmerId, fn).andExpect(jsonPath("$.items", hasSize(1)));
        api.get("/api/v1/loads?farmerId=" + othersFarmer, fn).andExpect(jsonPath("$.items", hasSize(0)));

        // accept: the FN wallet pays the posting charge; the farmer gets the trip SMS and later the pickup OTP
        long before = jdbc.queryForObject("select cached_balance_inr from wallet_account where owner_id = ?", Long.class, fn.userId());
        api.send("/api/v1/driver/suggestions/" + load + "/accept", Map.of(), driver).andExpect(status().isOk());
        long after = jdbc.queryForObject("select cached_balance_inr from wallet_account where owner_id = ?", Long.class, fn.userId());
        assertThat(before - after).isEqualTo(50);
        assertThat(sms.sent()).anyMatch(m -> m.mobile().equals("9822200001") && m.templateKey().equals("SENDER_TRACKING"));
        api.send("/api/v1/driver/trips/" + load + "/reached", Map.of("purpose", "PICKUP", "lat", lat, "lng", lng), driver)
                .andExpect(status().isOk());
        assertThat(sms.sent()).anyMatch(m -> m.mobile().equals("9822200001") && m.templateKey().equals("TRIP_OTP_PICKUP"));
    }
}
