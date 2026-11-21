package com.nothing.tranix.trips;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;
import com.nothing.tranix.shared.integrations.fake.FakeSmsSender;
import com.nothing.tranix.trips.internal.TripService;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;

/** B-701…B-711, B-408: full trip happy path, OTP failures, revision limits, driver cancel. */
@IntegrationTest
@Import(TestApi.class)
class TripIT {

    @Autowired
    TestApi api;

    @Autowired
    JdbcTemplate jdbc;

    @Autowired
    TripService trips;

    @Autowired
    FakeSmsSender sms;

    static int area = 0;

    record Trip(TestApi.Session shipper, TestApi.Session driver, String loadId, double[] pickup, double[] drop) {
    }

    /** Posts a load in a fresh area and lets a nearby verified driver accept it. */
    Trip acceptedTrip() throws Exception {
        area++;
        double lat = 22.0 + area * 0.9;
        double lng = 72.0 + area * 0.9;
        TestApi.Session d = api.verified("DRIVER");
        UUID truck = UUID.randomUUID();
        jdbc.update("""
                insert into fleet_truck (id, owner_type, owner_id, number, vehicle_type, capacity_tonnes, active, created_at, updated_at, version)
                values (?, 'DRIVER', ?, ?, 'OPEN_BODY', 10, true, now(), now(), 0)""", truck, d.userId(),
                "GJ" + (10 + area) + "TR" + (1000 + (int) (Math.random() * 8999)));
        for (String t : List.of("RC", "INSURANCE", "NATIONAL_PERMIT")) {
            doc("TRUCK", truck, d.userId(), t);
        }
        doc("USER", d.userId(), d.userId(), "DRIVING_LICENCE");
        jdbc.update("insert into fleet_driver_state (driver_id, on_duty, last_lat, last_lng, last_location_at, updated_at) values (?, true, ?, ?, now(), now())",
                d.userId(), lat + 0.01, lng);
        api.fund(d, 100);
        TestApi.Session s = api.verified("LOAD_PROVIDER");
        api.fund(s, 100);
        Instant start = Instant.now().plus(2, ChronoUnit.HOURS);
        Map<String, Object> b = new HashMap<>();
        b.put("pickupWindowStart", start.toString());
        b.put("pickupWindowEnd", start.plus(3, ChronoUnit.HOURS).toString());
        b.put("pickup", Map.of("lat", lat, "lng", lng, "address", "12 Mill Street, Mandi, District"));
        b.put("senderName", "Sender Person");
        b.put("senderMobile", "9876500001");
        b.put("goodsType", "Grains");
        b.put("quantity", 50);
        b.put("quantityUnit", "BAGS");
        b.put("weightTonnes", 2.5);
        b.put("vehicleType", "OPEN_BODY");
        b.put("drop", Map.of("lat", lat + 0.5, "lng", lng + 0.5, "address", "Depot Road, City"));
        b.put("receiverName", "Receiver Person");
        b.put("receiverMobile", "9876500002");
        b.put("freightPaidBy", "SHIPPER");
        b.put("amountInr", 12000);
        String id = JsonPath.read(api.body(api.send("/api/v1/loads", b, s).andExpect(status().isOk())), "$.id");
        api.send("/api/v1/driver/suggestions/" + id + "/accept", Map.of(), d).andExpect(status().isOk());
        return new Trip(s, d, id, new double[] {lat, lng}, new double[] {lat + 0.5, lng + 0.5});
    }

    void doc(String ownerType, UUID owner, UUID user, String type) {
        jdbc.update("""
                insert into identity_document (id, owner_type, owner_id, user_id, type, file_ids, expires_on, status, created_at, updated_at, version)
                values (?, ?, ?, ?, ?, '', ?, 'APPROVED', now(), now(), 0)""", UUID.randomUUID(), ownerType, owner, user, type, LocalDate.now().plusYears(1));
    }

    String smsOtp(String mobile, String template) {
        return sms.sent().reversed().stream().filter(m -> m.mobile().equals(mobile) && m.templateKey().equals(template))
                .findFirst().orElseThrow().params().get("otp");
    }

    @Test
    void fullTripHappyPathWithRevisionAndOtps() throws Exception {
        Trip t = acceptedTrip();
        String base = "/api/v1/driver/trips/" + t.loadId();
        api.get("/api/v1/driver/current-trip", t.driver()).andExpect(status().isOk())
                .andExpect(jsonPath("$.senderMobile").value("9876500001"))
                .andExpect(jsonPath("$.pickup.address").value("12 Mill Street, Mandi, District"));

        // amount revision: request → pending blocks another → shipper confirms
        String detail = api.body(api.send(base + "/revisions", Map.of("amountInr", 13000, "reason", "Toll increase"), t.driver())
                .andExpect(jsonPath("$.status").value("AMOUNT_NEGOTIATION")));
        String rid = JsonPath.read(detail, "$.revisions[0].id");
        api.send(base + "/revisions", Map.of("amountInr", 14000, "reason", "again"), t.driver())
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("REVISION_PENDING"));
        api.send("/api/v1/loads/" + t.loadId() + "/revisions/" + rid + "/confirm", Map.of(), t.shipper())
                .andExpect(jsonPath("$.agreedAmountInr").value(13000)).andExpect(jsonPath("$.status").value("WAITING_FOR_PICKUP"));

        // reached pickup ~1.1 km away: first without reason → asks; then with reason
        double[] p = t.pickup();
        api.send(base + "/reached", Map.of("purpose", "PICKUP", "lat", p[0] + 0.01, "lng", p[1]), t.driver())
                .andExpect(jsonPath("$.outsideRadius").value(true)).andExpect(jsonPath("$.otpSentTo").doesNotExist());
        api.send(base + "/reached", Map.of("purpose", "PICKUP", "lat", p[0] + 0.01, "lng", p[1], "reason", "Gate closed, waited outside"), t.driver())
                .andExpect(jsonPath("$.outsideRadius").value(true)).andExpect(jsonPath("$.otpSentTo").value("******0001"));
        String code = JsonPath.read(api.body(api.get("/api/v1/loads/" + t.loadId() + "/otp", t.shipper())
                .andExpect(jsonPath("$.purpose").value("PICKUP"))), "$.code");
        assertThat(code).isEqualTo(smsOtp("9876500001", "TRIP_OTP_PICKUP"));
        api.get("/api/v1/loads/" + t.loadId() + "/otp", t.driver()).andExpect(status().isNotFound());
        String wrong = code.equals("000000") ? "111111" : "000000";
        api.send(base + "/otp/verify", Map.of("purpose", "PICKUP", "code", wrong, "lat", p[0], "lng", p[1]), t.driver())
                .andExpect(jsonPath("$.code").value("OTP_INVALID"));
        api.send(base + "/otp/verify", Map.of("purpose", "PICKUP", "code", code, "lat", p[0], "lng", p[1]), t.driver())
                .andExpect(jsonPath("$.status").value("TRAVELING"))
                .andExpect(jsonPath("$.locationExceptions", hasSize(1)));
        api.send(base + "/revisions", Map.of("amountInr", 15000, "reason", "late"), t.driver())
                .andExpect(jsonPath("$.code").value("INVALID_STATE"));

        // live location → tracking
        double[] d = t.drop();
        api.send(base + "/locations", List.of(Map.of("lat", p[0] + 0.2, "lng", p[1] + 0.2, "at", Instant.now().toString())), t.driver())
                .andExpect(jsonPath("$.accepted").value(1));
        api.get("/api/v1/loads/" + t.loadId() + "/tracking", t.shipper())
                .andExpect(jsonPath("$.driverLocation.lat").value(p[0] + 0.2))
                .andExpect(jsonPath("$.routeStatus").isString());

        // delivery
        api.send(base + "/reached", Map.of("purpose", "DELIVERY", "lat", d[0], "lng", d[1]), t.driver())
                .andExpect(jsonPath("$.outsideRadius").value(false));
        api.send(base + "/otp/verify", Map.of("purpose", "DELIVERY", "code", smsOtp("9876500002", "TRIP_OTP_DELIVERY"),
                "lat", d[0], "lng", d[1]), t.driver()).andExpect(jsonPath("$.status").value("DELIVERED"));
        api.get("/api/v1/loads/" + t.loadId(), t.shipper())
                .andExpect(jsonPath("$.timeline[*].status").value(org.hamcrest.Matchers.hasItems("LOCATION_REACHED", "PICKED_UP",
                        "TRAVELING", "ARRIVED_DESTINATION", "DELIVERED")))
                .andExpect(jsonPath("$.otpEvents[?(@.type=='VERIFIED')]", hasSize(2)));
        api.get("/api/v1/driver/current-trip", t.driver()).andExpect(status().isNoContent());
    }

    @Test
    void revisionLimitAndExpiryAndOtpLock() throws Exception {
        Trip t = acceptedTrip();
        String base = "/api/v1/driver/trips/" + t.loadId();
        for (int i = 1; i <= 4; i++) {
            String rid = JsonPath.read(api.body(api.send(base + "/revisions", Map.of("amountInr", 12000 + i * 100, "reason", "r" + i), t.driver())),
                    "$.revisions[" + (i - 1) + "].id");
            api.send("/api/v1/loads/" + t.loadId() + "/revisions/" + rid + "/reject", Map.of(), t.shipper())
                    .andExpect(jsonPath("$.agreedAmountInr").value(12000));
        }
        api.send(base + "/revisions", Map.of("amountInr", 12900, "reason", "r5"), t.driver()).andExpect(status().isOk());
        jdbc.update("update trips_revision set respond_by = now() - interval '1 minute' where load_id = ?::uuid and status = 'PENDING'", t.loadId());
        assertThat(trips.expireRevisions()).isEqualTo(1);
        api.get("/api/v1/loads/" + t.loadId(), t.shipper()).andExpect(jsonPath("$.status").value("WAITING_FOR_PICKUP"))
                .andExpect(jsonPath("$.revisionsUsed").value(5)).andExpect(jsonPath("$.agreedAmountInr").value(12000));
        api.send(base + "/revisions", Map.of("amountInr", 13000, "reason", "r6"), t.driver())
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("REVISION_LIMIT_REACHED"));

        double[] p = t.pickup();
        api.send(base + "/reached", Map.of("purpose", "PICKUP", "lat", p[0], "lng", p[1]), t.driver()).andExpect(status().isOk());
        String good = smsOtp("9876500001", "TRIP_OTP_PICKUP");
        String wrong = good.equals("000000") ? "111111" : "000000";
        for (int i = 0; i < 4; i++) {
            api.send(base + "/otp/verify", Map.of("purpose", "PICKUP", "code", wrong, "lat", p[0], "lng", p[1]), t.driver())
                    .andExpect(jsonPath("$.code").value("OTP_INVALID"));
        }
        api.send(base + "/otp/verify", Map.of("purpose", "PICKUP", "code", wrong, "lat", p[0], "lng", p[1]), t.driver())
                .andExpect(jsonPath("$.code").value("OTP_LOCKED"));
        api.send(base + "/otp/verify", Map.of("purpose", "PICKUP", "code", good, "lat", p[0], "lng", p[1]), t.driver())
                .andExpect(jsonPath("$.code").value("OTP_EXPIRED"));
        jdbc.update("update trips_otp set created_at = now() - interval '1 minute' where load_id = ?::uuid", t.loadId());
        api.send(base + "/otp/resend", Map.of("purpose", "PICKUP"), t.driver()).andExpect(status().isNoContent());
        api.send(base + "/otp/resend", Map.of("purpose", "PICKUP"), t.driver()).andExpect(jsonPath("$.code").value("RATE_LIMITED"));
        api.send(base + "/otp/help", Map.of("purpose", "PICKUP", "note", "Sender not answering"), t.driver())
                .andExpect(jsonPath("$.status").value("OPEN"));
        api.send(base + "/otp/verify", Map.of("purpose", "PICKUP", "code", smsOtp("9876500001", "TRIP_OTP_PICKUP"), "lat", p[0], "lng", p[1]),
                t.driver()).andExpect(jsonPath("$.status").value("TRAVELING"));
    }

    @Test
    void driverCancelsBeforePickupAndShipperIsTold() throws Exception {
        Trip t = acceptedTrip();
        api.send("/api/v1/driver/trips/" + t.loadId() + "/cancel", Map.of("reason", "TRUCK_BREAKDOWN"), t.driver())
                .andExpect(jsonPath("$.status").value("CANCELLED"));
        api.get("/api/v1/notifications?tab=TRIPS", t.shipper())
                .andExpect(jsonPath("$.items[?(@.type=='CANCELLED_BY_DRIVER')]", hasSize(1)));
        api.get("/api/v1/map/route-services?bbox=77.0,10.0,78.5,11.0&types=TOLL,PETROL", t.driver())
                .andExpect(jsonPath("$[?(@.type=='TOLL')]", hasSize(1)));
        api.get("/api/v1/map/restrictions?bbox=80.0,12.9,80.4,13.2", t.driver()).andExpect(jsonPath("$", hasSize(1)));
        api.get("/api/v1/map/restrictions?bbox=1,2,3", t.driver()).andExpect(status().isBadRequest());
    }
}
