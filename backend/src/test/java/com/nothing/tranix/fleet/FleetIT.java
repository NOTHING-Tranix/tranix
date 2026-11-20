package com.nothing.tranix.fleet;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;
import com.nothing.tranix.fleet.api.FleetApi;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;

/** B-501…B-509. */
@IntegrationTest
@Import(TestApi.class)
class FleetIT {

    @Autowired
    TestApi api;

    @Autowired
    JdbcTemplate jdbc;

    @Autowired
    FleetApi fleet;

    static String plate() {
        return "TN" + (10 + (int) (Math.random() * 89)) + "AB" + (1000 + (int) (Math.random() * 8999));
    }

    /** Adds RC/insurance/permit through the API and approves them in the DB. */
    void documentsApproved(String truckDocsPath, TestApi.Session as) throws Exception {
        for (String type : List.of("RC", "INSURANCE", "NATIONAL_PERMIT")) {
            api.send(truckDocsPath, Map.of("type", type, "fileIds", List.of(api.uploadPng(as)), "number", "NUM" + type,
                    "expiresOn", LocalDate.now().plusYears(1).toString()), as).andExpect(status().isOk());
        }
        jdbc.update("update identity_document set status = 'APPROVED' where user_id = ? and owner_type = 'TRUCK'", as.userId());
    }

    @Test
    void ownerDriverHasOneTruckAndDutyAndHome() throws Exception {
        TestApi.Session d = api.verified("DRIVER");
        String plate = plate();
        api.send("/api/v1/driver/truck", Map.of("number", plate.substring(0, 4) + " " + plate.substring(4), "vehicleType",
                "OPEN_BODY", "capacityTonnes", 9), d).andExpect(status().isOk())
                .andExpect(jsonPath("$.number").value(plate)).andExpect(jsonPath("$.status").value("DOCUMENTS_PENDING"));
        api.send("/api/v1/driver/truck", Map.of("number", plate(), "vehicleType", "OPEN_BODY", "capacityTonnes", 9), d)
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("INVALID_STATE"));
        api.send("/api/v1/driver/truck", Map.of("number", "BAD", "vehicleType", "OPEN_BODY", "capacityTonnes", 9), api.verified("DRIVER"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("number"));
        api.send("/api/v1/driver/truck/documents", Map.of("type", "RC", "fileIds", List.of(api.uploadPng(d))), d)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("number"));
        documentsApproved("/api/v1/driver/truck/documents", d);
        api.get("/api/v1/driver/truck", d).andExpect(jsonPath("$.status").value("AVAILABLE")).andExpect(jsonPath("$.ownedByMe").value(true));

        api.put("/api/v1/driver/duty", Map.of("onDuty", true), d).andExpect(jsonPath("$.onDuty").value(true));
        api.get("/api/v1/driver/home", d).andExpect(status().isOk())
                .andExpect(jsonPath("$.onDuty").value(true))
                .andExpect(jsonPath("$.truck.number").value(plate))
                .andExpect(jsonPath("$.walletBalanceInr").value(0))
                .andExpect(jsonPath("$.orgName").doesNotExist())
                .andExpect(jsonPath("$.trustScore").value(70.0));
        FleetApi.DriverContext ctx = fleet.driver(d.userId(), LocalDate.now()).orElseThrow();
        assertThat(ctx.truckDocumentsValid()).isTrue();
        assertThat(ctx.payerUserId()).isEqualTo(d.userId());
        assertThat(fleet.onDutyDrivers(LocalDate.now())).extracting(FleetApi.DriverContext::driverId).contains(d.userId());
    }

    @Test
    void orgInvitesAllocatesAndConflicts() throws Exception {
        TestApi.Session org = api.verified("ORGANIZATION");
        api.put("/api/v1/me/role-profile", Map.of("orgName", "Sri Transports", "contactPerson", "Arun"), org).andExpect(status().isOk());
        TestApi.Session d1 = api.verified("DRIVER");
        TestApi.Session d2 = api.verified("DRIVER");

        String inv = JsonPath.read(api.body(api.send("/api/v1/org/drivers", Map.of("name", "Ravi", "mobile", d1.mobile()), org)
                .andExpect(status().isOk()).andExpect(jsonPath("$.status").value("PENDING"))), "$.id");
        api.send("/api/v1/org/drivers", Map.of("name", "Ravi", "mobile", d1.mobile()), org).andExpect(status().isConflict());
        api.get("/api/v1/driver/invitations", d1).andExpect(jsonPath("$[0].orgName").value("Sri Transports"));
        api.send("/api/v1/driver/invitations/" + inv + "/accept", Map.of(), d1).andExpect(jsonPath("$.status").value("ACCEPTED"));
        api.send("/api/v1/driver/invitations/" + inv + "/accept", Map.of(), d1).andExpect(status().isConflict());

        String inv2 = JsonPath.read(api.body(api.send("/api/v1/org/drivers", Map.of("name", "Kumar", "mobile", d2.mobile()), org)), "$.id");
        api.send("/api/v1/driver/invitations/" + inv2 + "/accept", Map.of(), d2).andExpect(status().isOk());

        String t1 = JsonPath.read(api.body(api.send("/api/v1/org/trucks", Map.of("number", plate(), "vehicleType", "CLOSED_BODY",
                "capacityTonnes", 12), org).andExpect(status().isOk())), "$.id");
        String t2 = JsonPath.read(api.body(api.send("/api/v1/org/trucks", Map.of("number", plate(), "vehicleType", "TANKER",
                "capacityTonnes", 20), org)), "$.id");
        api.send("/api/v1/org/allocations", Map.of("driverId", d1.userId(), "truckId", t1), org)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("truckId"));
        documentsApproved("/api/v1/org/trucks/" + t1 + "/documents", org);
        documentsApproved("/api/v1/org/trucks/" + t2 + "/documents", org);

        String alloc = JsonPath.read(api.body(api.send("/api/v1/org/allocations", Map.of("driverId", d1.userId(), "truckId", t1), org)
                .andExpect(status().isOk()).andExpect(jsonPath("$.status").value("ACTIVE"))), "$.id");
        api.send("/api/v1/org/allocations", Map.of("driverId", d2.userId(), "truckId", t1), org)
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ALLOCATION_CONFLICT"));
        api.send("/api/v1/org/allocations", Map.of("driverId", d1.userId(), "truckId", t2), org)
                .andExpect(jsonPath("$.code").value("ALLOCATION_CONFLICT"));
        api.send("/api/v1/org/allocations", Map.of("driverId", d2.userId(), "truckId", t2), org).andExpect(status().isOk());

        // driver sees the Org truck read-only; Org pays the trip charge
        api.get("/api/v1/driver/home", d1).andExpect(jsonPath("$.orgName").value("Sri Transports"))
                .andExpect(jsonPath("$.truck.ownedByMe").value(false)).andExpect(jsonPath("$.walletBalanceInr").doesNotExist());
        assertThat(fleet.driver(d1.userId(), LocalDate.now()).orElseThrow().payerUserId()).isEqualTo(org.userId());
        assertThat(fleet.driversForTruck(UUID.fromString(t1))).containsExactly(d1.userId());
        api.send("/api/v1/driver/truck", Map.of("number", plate(), "vehicleType", "OPEN_BODY", "capacityTonnes", 9), d1)
                .andExpect(status().isConflict());

        // no change during an active trip
        UUID load = UUID.randomUUID();
        jdbc.update("""
                insert into loads_load (id, code, shipper_id, status, pickup_lat, pickup_lng, pickup_address, pickup_area, drop_lat, drop_lng,
                drop_address, drop_area, pickup_window_start, pickup_window_end, sender_name, sender_mobile, receiver_name, receiver_mobile,
                goods_type, quantity, quantity_unit, weight_tonnes, vehicle_type, freight_paid_by, posted_amount_inr, agreed_amount_inr,
                driver_id, truck_id, org_id, distance_km, drive_minutes, delivery_eta, created_at, updated_at, version)
                values (?, ?, ?, 'TRAVELING', 1, 1, 'a', 'a', 2, 2, 'b', 'b', now(), now(), 'S', '9876543210', 'R', '9123456780',
                'Fruits', 1, 'BAGS', 1, 'CLOSED_BODY', 'SHIPPER', 1000, 1000, ?, ?, ?, 10, 30, now(), now(), now(), 0)""",
                load, "TST-" + load.toString().substring(0, 8), UUID.randomUUID(), d1.userId(), UUID.fromString(t1), org.userId());
        api.put("/api/v1/org/allocations/" + alloc, Map.of("status", "PAUSED"), org)
                .andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("ALLOCATION_CONFLICT"));
        api.get("/api/v1/org/trucks", org).andExpect(jsonPath("$[?(@.id=='" + t1 + "')].status").value("ON_TRIP"));
        api.get("/api/v1/org/trucks/" + t1 + "/location", org).andExpect(status().isOk());
        api.get("/api/v1/org/dashboard", org).andExpect(jsonPath("$.trucks.total").value(2))
                .andExpect(jsonPath("$.drivers.onTrip").value(1)).andExpect(jsonPath("$.activeTrips").value(1));
        api.get("/api/v1/org/trips?by=DRIVER&id=" + d1.userId(), org).andExpect(jsonPath("$.length()").value(1));
        api.get("/api/v1/org/trips/export", org).andExpect(status().isOk())
                .andExpect(content().string(startsWith("code,status")));
        api.get("/api/v1/org/drivers", org).andExpect(jsonPath("$.length()").value(2));
        api.get("/api/v1/org/drivers/" + d1.userId() + "/performance", org).andExpect(jsonPath("$.trips").value(0));
        jdbc.update("update loads_load set status = 'DELIVERED' where id = ?", load);
        api.send("/api/v1/org/trucks/" + t2 + "/deactivate", Map.of(), org).andExpect(jsonPath("$.status").value("INACTIVE"));
        api.delete("/api/v1/org/allocations/" + alloc, org).andExpect(status().isNoContent());
    }

    @Test
    void invitingUnregisteredNumberSendsSmsAndRoleChecks() throws Exception {
        TestApi.Session org = api.verified("ORGANIZATION");
        String mobile = TestApi.newMobile();
        api.send("/api/v1/org/drivers", Map.of("name", "New Driver", "mobile", mobile), org).andExpect(status().isOk());
        TestApi.Session lp = api.signUp("LOAD_PROVIDER");
        api.send("/api/v1/org/drivers", Map.of("name", "X Y", "mobile", lp.mobile()), org)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("mobile"));
        api.get("/api/v1/org/dashboard", lp).andExpect(status().isForbidden());
        api.get("/api/v1/driver/home", lp).andExpect(status().isForbidden());
    }
}
