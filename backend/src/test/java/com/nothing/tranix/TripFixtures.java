package com.nothing.tranix;

import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Instant;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.shared.integrations.fake.FakeSmsSender;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/** Builds accepted and delivered trips through the real API (each in its own area so tests don't interfere). */
@Component
public class TripFixtures {

    private static final AtomicInteger AREA = new AtomicInteger();

    private final TestApi api;
    private final JdbcTemplate jdbc;
    private final FakeSmsSender sms;

    public TripFixtures(TestApi api, JdbcTemplate jdbc, org.springframework.beans.factory.ObjectProvider<FakeSmsSender> sms) {
        this.api = api;
        this.jdbc = jdbc;
        this.sms = sms.getIfAvailable();
    }

    public record Trip(TestApi.Session shipper, TestApi.Session driver, String loadId, double[] pickup, double[] drop,
                       String senderMobile, String receiverMobile) {
    }

    /** Verified owner-driver with a valid truck/licence, on duty at (lat, lng), wallet ₹100. */
    public TestApi.Session driverAt(double lat, double lng) throws Exception {
        TestApi.Session d = api.verified("DRIVER");
        UUID truck = UUID.randomUUID();
        jdbc.update("""
                insert into fleet_truck (id, owner_type, owner_id, number, vehicle_type, capacity_tonnes, active, created_at, updated_at, version)
                values (?, 'DRIVER', ?, ?, 'OPEN_BODY', 10, true, now(), now(), 0)""", truck, d.userId(),
                "MH" + (10 + AREA.get() % 89) + "FX" + (1000 + (int) (Math.random() * 8999)));
        for (String t : List.of("RC", "INSURANCE", "NATIONAL_PERMIT")) {
            doc("TRUCK", truck, d.userId(), t);
        }
        doc("USER", d.userId(), d.userId(), "DRIVING_LICENCE");
        jdbc.update("insert into fleet_driver_state (driver_id, on_duty, last_lat, last_lng, last_location_at, updated_at) values (?, true, ?, ?, now(), now())",
                d.userId(), lat, lng);
        api.fund(d, 100);
        return d;
    }

    private void doc(String ownerType, UUID owner, UUID user, String type) {
        jdbc.update("""
                insert into identity_document (id, owner_type, owner_id, user_id, type, file_ids, expires_on, status, created_at, updated_at, version)
                values (?, ?, ?, ?, ?, '', ?, 'APPROVED', now(), now(), 0)""", UUID.randomUUID(), ownerType, owner, user, type, LocalDate.now().plusYears(1));
    }

    public Trip accepted(String shipperRole, String freightPaidBy, String receiverMobile) throws Exception {
        int n = AREA.incrementAndGet();
        double lat = 15.0 + (n % 40) * 0.9;
        double lng = 85.0 + (n / 40) * 0.9;
        TestApi.Session d = driverAt(lat + 0.01, lng);
        TestApi.Session s = api.verified(shipperRole);
        api.fund(s, 100);
        String sender = String.valueOf(9_700_000_000L + n * 10L);
        String receiver = receiverMobile != null ? receiverMobile : String.valueOf(9_700_000_001L + n * 10L);
        Instant start = Instant.now().plus(2, ChronoUnit.HOURS);
        Map<String, Object> b = new HashMap<>();
        b.put("pickupWindowStart", start.toString());
        b.put("pickupWindowEnd", start.plus(3, ChronoUnit.HOURS).toString());
        b.put("pickup", Map.of("lat", lat, "lng", lng, "address", "Yard 1, Market, District"));
        b.put("senderName", "Sender");
        b.put("senderMobile", sender);
        b.put("goodsType", "Fruits");
        b.put("quantity", 40);
        b.put("quantityUnit", "BOXES");
        b.put("weightTonnes", 2);
        b.put("vehicleType", "OPEN_BODY");
        b.put("drop", Map.of("lat", lat + 0.3, "lng", lng + 0.3, "address", "Depot, City"));
        b.put("receiverName", "Receiver");
        b.put("receiverMobile", receiver);
        b.put("freightPaidBy", freightPaidBy);
        b.put("amountInr", 10000);
        String id = JsonPath.read(api.body(api.send("/api/v1/loads", b, s).andExpect(status().isOk())), "$.id");
        api.send("/api/v1/driver/suggestions/" + id + "/accept", Map.of(), d).andExpect(status().isOk());
        return new Trip(s, d, id, new double[] {lat, lng}, new double[] {lat + 0.3, lng + 0.3}, sender, receiver);
    }

    public String smsOtp(String mobile, String template) {
        return sms.sent().reversed().stream().filter(m -> m.mobile().equals(mobile) && m.templateKey().equals(template))
                .findFirst().orElseThrow().params().get("otp");
    }

    /** Runs pickup and delivery with OTPs at the pins. */
    public void deliver(Trip t) throws Exception {
        String base = "/api/v1/driver/trips/" + t.loadId();
        api.send(base + "/reached", Map.of("purpose", "PICKUP", "lat", t.pickup()[0], "lng", t.pickup()[1]), t.driver()).andExpect(status().isOk());
        api.send(base + "/otp/verify", Map.of("purpose", "PICKUP", "code", smsOtp(t.senderMobile(), "TRIP_OTP_PICKUP"),
                "lat", t.pickup()[0], "lng", t.pickup()[1]), t.driver()).andExpect(jsonPath("$.status").value("TRAVELING"));
        api.send(base + "/reached", Map.of("purpose", "DELIVERY", "lat", t.drop()[0], "lng", t.drop()[1]), t.driver()).andExpect(status().isOk());
        api.send(base + "/otp/verify", Map.of("purpose", "DELIVERY", "code", smsOtp(t.receiverMobile(), "TRIP_OTP_DELIVERY"),
                "lat", t.drop()[0], "lng", t.drop()[1]), t.driver()).andExpect(jsonPath("$.status").value("DELIVERED"));
    }
}
