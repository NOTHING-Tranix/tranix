package com.nothing.tranix.admin;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasItem;
import static org.hamcrest.Matchers.lessThanOrEqualTo;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;
import com.nothing.tranix.TripFixtures;
import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.shared.settings.Settings;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;

/** B-1201…B-1212 admin back office. */
@IntegrationTest
@Import({TestApi.class, TripFixtures.class})
class AdminIT {

    @Autowired
    TestApi api;

    @Autowired
    TripFixtures trips;

    @Autowired
    JdbcTemplate jdbc;

    @Autowired
    UserDirectory users;

    @Autowired
    Settings settings;

    long audits(String action) {
        Long n = jdbc.queryForObject("select count(*) from admin_audit where action = ?", Long.class, action);
        return n == null ? 0 : n;
    }

    @Test
    void dashboardLoadsCancelAfterPickupAndOtpOverride() throws Exception {
        TestApi.Session admin = api.admin();
        TripFixtures.Trip t = trips.accepted("LOAD_PROVIDER", "SHIPPER", null);
        api.get("/api/v1/admin/dashboard", admin).andExpect(jsonPath("$.activeLoads").isNumber())
                .andExpect(jsonPath("$.routeStatus.NORMAL").exists()).andExpect(jsonPath("$.reminders.paymentDisputes").isNumber());
        api.get("/api/v1/admin/dashboard", t.shipper()).andExpect(status().isForbidden());
        String code = JsonPath.read(api.body(api.get("/api/v1/loads/" + t.loadId(), t.shipper())), "$.code");
        api.get("/api/v1/admin/loads?q=" + code, admin).andExpect(jsonPath("$.items[0].id").value(t.loadId()));
        api.get("/api/v1/admin/loads", admin).andExpect(jsonPath("$.size").value(10)).andExpect(jsonPath("$.items.length()", lessThanOrEqualTo(10)));
        api.get("/api/v1/admin/loads/" + t.loadId(), admin).andExpect(jsonPath("$.tracking").exists());

        // pickup by OTP override (driver reached, sender can't receive the code)
        String base = "/api/v1/driver/trips/" + t.loadId();
        api.send(base + "/reached", Map.of("purpose", "PICKUP", "lat", t.pickup()[0], "lng", t.pickup()[1]), t.driver()).andExpect(status().isOk());
        api.send("/api/v1/admin/loads/" + t.loadId() + "/otp-override", Map.of("purpose", "DELIVERY", "reason", "x"), admin)
                .andExpect(status().isConflict());
        api.send("/api/v1/admin/loads/" + t.loadId() + "/otp-override", Map.of("purpose", "PICKUP"), admin).andExpect(status().isBadRequest());
        api.send("/api/v1/admin/loads/" + t.loadId() + "/otp-override", Map.of("purpose", "PICKUP", "reason", "Sender phone off; verified by call"), admin)
                .andExpect(jsonPath("$.status").value("TRAVELING"));
        assertThat(audits("OTP_OVERRIDE")).isPositive();

        // after pickup only admin can cancel
        api.send("/api/v1/admin/loads/" + t.loadId() + "/cancel", Map.of("reason", "Truck breakdown, goods moved by another truck"), admin)
                .andExpect(jsonPath("$.status").value("CANCELLED"));
        api.send("/api/v1/admin/loads/" + t.loadId() + "/cancel", Map.of("reason", "again"), admin).andExpect(status().isConflict());
        assertThat(audits("LOAD_CANCEL")).isPositive();
    }

    @Test
    void usersSuspendFleetCancellationExceptionAndAudit() throws Exception {
        TestApi.Session admin = api.admin();
        TestApi.Session user = api.verified("LOAD_PROVIDER");
        api.get("/api/v1/admin/users?q=" + user.mobile(), admin).andExpect(jsonPath("$.items[0].id").value(user.userId().toString()));
        api.send("/api/v1/admin/users/" + user.userId() + "/suspend", Map.of(), admin).andExpect(status().isBadRequest());
        api.send("/api/v1/admin/users/" + user.userId() + "/suspend", Map.of("reason", "Fraud report"), admin).andExpect(status().isNoContent());
        assertThat(users.get(user.userId()).suspended()).isTrue();
        api.send("/api/v1/auth/refresh", Map.of("refreshToken", user.refreshToken()), null).andExpect(status().is4xxClientError());
        api.send("/api/v1/admin/users/" + user.userId() + "/reactivate", Map.of("reason", "Cleared"), admin).andExpect(status().isNoContent());
        assertThat(users.get(user.userId()).suspended()).isFalse();

        TripFixtures.Trip t = trips.accepted("LOAD_PROVIDER", "SHIPPER", null);
        api.get("/api/v1/admin/fleet?q=" + JsonPath.read(api.body(api.get("/api/v1/driver/truck", t.driver())), "$.number"), admin)
                .andExpect(jsonPath("$.items[0].onDuty").value(true));

        // driver cancels after acceptance → penalty; admin reverses it
        BigDecimal before = users.get(t.driver().userId()).trustScore();
        api.send("/api/v1/driver/trips/" + t.loadId() + "/cancel", Map.of("reason", "TRUCK_BREAKDOWN"), t.driver()).andExpect(status().isOk());
        BigDecimal after = users.get(t.driver().userId()).trustScore();
        String cid = jdbc.queryForObject("select cast(id as text) from loads_cancellation where load_id = ?", String.class, UUID.fromString(t.loadId()));
        api.get("/api/v1/admin/cancellations", admin).andExpect(jsonPath("$[*].id", hasItem(cid)));
        api.send("/api/v1/admin/cancellations/" + cid + "/decide", Map.of("decision", "REVERSE", "reason", "Verified breakdown"), admin)
                .andExpect(jsonPath("$.adminDecision").value("REVERSE"));
        if (after.compareTo(before) < 0) {
            assertThat(users.get(t.driver().userId()).trustScore()).isEqualByComparingTo(before);
        }

        // location exception review
        UUID ex = UUID.randomUUID();
        jdbc.update("insert into trips_location_exception (id, load_id, purpose, distance_m, driver_reason, created_at) values (?, ?, 'PICKUP', 900, 'Gate closed', now())",
                ex, UUID.fromString(t.loadId()));
        api.get("/api/v1/admin/location-exceptions", admin).andExpect(jsonPath("$[*].id", hasItem(ex.toString())));
        api.send("/api/v1/admin/location-exceptions/" + ex + "/review", Map.of("decision", "OK", "note", "Known gate"), admin)
                .andExpect(jsonPath("$.reviewStatus").value("OK"));
        api.send("/api/v1/admin/location-exceptions/" + ex + "/review", Map.of("decision", "OK"), admin).andExpect(status().isNotFound());

        api.get("/api/v1/admin/audit?action=USER_SUSPEND", admin).andExpect(jsonPath("$.items[0].reason").value("Fraud report"));
        assertThat(audits("CANCELLATION_DECIDE")).isPositive();
    }

    @Test
    void settingsValidationRestrictionsAndIdleTimeout() throws Exception {
        TestApi.Session admin = api.admin();
        api.put("/api/v1/admin/settings/matching.batch_size", Map.of("value", "abc", "reason", "test"), admin).andExpect(status().isBadRequest());
        api.put("/api/v1/admin/settings/matching.weight.distance", Map.of("value", "45", "reason", "test"), admin)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].message").value(org.hamcrest.Matchers.containsString("100%")));
        String old = jdbc.queryForObject("select value from admin_setting where key = 'support.reopen_days'", String.class);
        try {
            api.put("/api/v1/admin/settings/support.reopen_days", Map.of("value", "10", "reason", "Policy"), admin).andExpect(jsonPath("$.value").value("10"));
            assertThat(settings.getInt("support.reopen_days")).isEqualTo(10);
        } finally {
            jdbc.update("update admin_setting set value = ? where key = 'support.reopen_days'", old);
            settings.reload();
        }

        String rid = JsonPath.read(api.body(api.send("/api/v1/admin/map-restrictions", Map.of("name", "Town market no entry", "lat", 10.36, "lng", 77.98,
                "radiusKm", 2, "noEntryFrom", "08:00:00", "noEntryTo", "21:00:00", "vehicleTypes", List.of("OPEN_BODY")), admin)
                .andExpect(jsonPath("$.active").value(true))), "$.id");
        api.put("/api/v1/admin/map-restrictions/" + rid, Map.of("name", "Town market", "lat", 10.36, "lng", 77.98, "radiusKm", 3), admin)
                .andExpect(jsonPath("$.name").value("Town market"));
        api.delete("/api/v1/admin/map-restrictions/" + rid, admin).andExpect(status().isNoContent());
        api.get("/api/v1/admin/map-restrictions", admin).andExpect(jsonPath("$[?(@.id == '" + rid + "')].active").value(false));

        // B-1201: an admin refresh after more than 30 idle minutes ends the session
        jdbc.update("update identity_refresh_token set created_at = now() - interval '31 minutes' where user_id = ?", admin.userId());
        api.send("/api/v1/auth/refresh", Map.of("refreshToken", admin.refreshToken()), null)
                .andExpect(status().isUnauthorized()).andExpect(jsonPath("$.code").value("TOKEN_EXPIRED"));
    }
}
