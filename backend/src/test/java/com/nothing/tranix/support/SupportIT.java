package com.nothing.tranix.support;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;
import com.nothing.tranix.TripFixtures;
import com.nothing.tranix.engagement.internal.BroadcastService;
import com.nothing.tranix.shared.integrations.fake.FakeSmsSender;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MockMvc;

/** B-1103…B-1105, B-1005 and dispute tickets. */
@IntegrationTest
@Import({TestApi.class, TripFixtures.class})
class SupportIT {

    @Autowired
    TestApi api;

    @Autowired
    TripFixtures trips;

    @Autowired
    JdbcTemplate jdbc;

    @Autowired
    MockMvc mvc;

    @Autowired
    FakeSmsSender sms;

    @Autowired
    BroadcastService broadcasts;

    int notifications(UUID user, String type) {
        Integer n = jdbc.queryForObject("select count(*) from engagement_notification where user_id = ? and type = ?", Integer.class, user, type);
        return n == null ? 0 : n;
    }

    @Test
    void ticketConversationReopenAndIgnore() throws Exception {
        TestApi.Session user = api.verified("LOAD_PROVIDER");
        TestApi.Session admin = api.admin();
        api.send("/api/v1/tickets", Map.of("type", "OTHERS", "description", "Need help"), user)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("otherText"));
        api.send("/api/v1/tickets", Map.of("type", "COMPLAINT", "description", "Driver was rude"), user)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("loadId"));
        String id = JsonPath.read(api.body(api.send("/api/v1/tickets", Map.of("type", "WALLET", "description", "Top-up not credited"), user)
                .andExpect(jsonPath("$.status").value("OPEN")).andExpect(jsonPath("$.code").value(org.hamcrest.Matchers.startsWith("TKT-")))), "$.id");

        api.get("/api/v1/admin/tickets?status=OPEN", admin).andExpect(jsonPath("$[?(@.id == '" + id + "')].unread").value(true));
        api.get("/api/v1/admin/tickets", user).andExpect(status().isForbidden());
        api.send("/api/v1/admin/tickets/" + id + "/reply", Map.of("body", "We are checking"), admin).andExpect(jsonPath("$.messages", hasSize(1)));
        assertThat(notifications(user.userId(), "SUPPORT_REPLY")).isEqualTo(1);
        api.get("/api/v1/tickets", user).andExpect(jsonPath("$[0].unread").value(true));
        api.get("/api/v1/tickets/" + id, user).andExpect(jsonPath("$.messages[0].author").value("ADMIN"));
        api.get("/api/v1/tickets", user).andExpect(jsonPath("$[0].unread").value(false));
        api.send("/api/v1/tickets/" + id + "/messages", Map.of("body", "Thanks"), user).andExpect(jsonPath("$.messages", hasSize(2)));
        api.get("/api/v1/tickets/" + id, api.verified("DRIVER")).andExpect(status().isNotFound());

        api.send("/api/v1/admin/tickets/" + id + "/ignore", Map.of(), admin).andExpect(status().isBadRequest());
        api.send("/api/v1/admin/tickets/" + id + "/ignore", Map.of("reason", "Duplicate"), admin).andExpect(jsonPath("$.status").value("CLOSED"));
        api.send("/api/v1/tickets/" + id + "/messages", Map.of("body", "Hello?"), user).andExpect(status().isConflict());
        api.get("/api/v1/tickets/" + id, user).andExpect(jsonPath("$.canReopen").value(true)).andExpect(jsonPath("$.closeReason").value("Duplicate"));
        api.send("/api/v1/tickets/" + id + "/reopen", Map.of(), user).andExpect(jsonPath("$.status").value("OPEN"));

        // reopen only within the window
        api.send("/api/v1/admin/tickets/" + id + "/reply", Map.of("body", "Done", "close", true), admin).andExpect(jsonPath("$.status").value("CLOSED"));
        jdbc.update("update support_ticket set closed_at = now() - interval '8 days' where id = ?", UUID.fromString(id));
        api.send("/api/v1/tickets/" + id + "/reopen", Map.of(), user).andExpect(status().isConflict());
    }

    @Test
    void disputeAndShortageOpenTicketsAutomatically() throws Exception {
        TripFixtures.Trip t = trips.accepted("LOAD_PROVIDER", "SHIPPER", null);
        trips.deliver(t);
        // payment dispute → PAYMENT_DISPUTE ticket for the driver
        api.send("/api/v1/loads/" + t.loadId() + "/payment/mark-paid", Map.of("amountInr", 9000, "mode", "CASH"), t.shipper()).andExpect(status().isOk());
        api.send("/api/v1/driver/trips/" + t.loadId() + "/payment/dispute", Map.of("reason", "Got only 9000"), t.driver()).andExpect(status().isOk());
        api.get("/api/v1/tickets", t.driver()).andExpect(jsonPath("$[0].type").value("PAYMENT_DISPUTE"))
                .andExpect(jsonPath("$[0].loadId").value(t.loadId()));

        // shortage/damage from the link → COMPLAINT for the shipper (receiver has no account)
        String link = sms.sent().reversed().stream().filter(m -> m.mobile().equals(t.receiverMobile()) && m.templateKey().equals("RECEIVER_TRACKING"))
                .findFirst().orElseThrow().params().get("link");
        String pub = "/api/v1/public/track/" + link.substring(link.lastIndexOf('/') + 1);
        String fileId = JsonPath.read(mvc.perform(multipart(pub + "/files").file(new MockMultipartFile("file", "r.png", "image/png",
                new byte[] {(byte) 0x89, 'P', 'N', 'G', 0x0D, 0x0A, 0x1A, 0x0A, 0, 0, 0, 0}))).andReturn().getResponse().getContentAsString(), "$.id");
        api.send(pub + "/receipt", Map.of("fileIds", List.of(fileId), "condition", "SHORTAGE_DAMAGE", "remarks", "Wet boxes"), null)
                .andExpect(status().isOk());
        api.get("/api/v1/tickets", t.shipper()).andExpect(jsonPath("$[0].type").value("COMPLAINT"))
                .andExpect(jsonPath("$[0].description").value(org.hamcrest.Matchers.containsString("Wet boxes")));
        assertThat(notifications(t.shipper().userId(), "TICKET_OPENED")).isEqualTo(1);
    }

    @Test
    void broadcastsNowAndScheduled() throws Exception {
        TestApi.Session admin = api.admin();
        TestApi.Session driver = api.verified("DRIVER");
        TestApi.Session shipper = api.verified("LOAD_PROVIDER");
        api.send("/api/v1/admin/broadcasts", Map.of("title", "Diesel", "body", "Rates updated", "audience", "ROLE"), admin)
                .andExpect(status().isBadRequest());
        api.send("/api/v1/admin/broadcasts", Map.of("title", "Diesel", "body", "Rates updated", "audience", "ROLE", "role", "DRIVER"), admin)
                .andExpect(jsonPath("$.sentAt").exists());
        assertThat(notifications(driver.userId(), "BROADCAST")).isEqualTo(1);
        assertThat(notifications(shipper.userId(), "BROADCAST")).isZero();
        api.get("/api/v1/notifications?tab=TRANIX", driver).andExpect(jsonPath("$.items[0].title").value("Diesel"));

        String later = Instant.now().plus(1, ChronoUnit.HOURS).toString();
        String id = JsonPath.read(api.body(api.send("/api/v1/admin/broadcasts", Map.of("title", "Hello", "body", "Just you", "audience", "USER",
                "userId", shipper.userId(), "sendAt", later), admin).andExpect(jsonPath("$.sentAt").doesNotExist())), "$.id");
        broadcasts.sendDue();
        assertThat(notifications(shipper.userId(), "BROADCAST")).isZero();
        jdbc.update("update engagement_broadcast set send_at = now() - interval '1 minute' where id = ?", UUID.fromString(id));
        broadcasts.sendDue();
        assertThat(notifications(shipper.userId(), "BROADCAST")).isEqualTo(1);
    }
}
