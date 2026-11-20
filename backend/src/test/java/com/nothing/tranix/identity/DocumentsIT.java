package com.nothing.tranix.identity;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;
import com.nothing.tranix.identity.api.UserEvents;
import com.nothing.tranix.identity.internal.DocumentService;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.event.ApplicationEvents;
import org.springframework.test.context.event.RecordApplicationEvents;

/** B-201…B-208. */
@IntegrationTest
@Import(TestApi.class)
@RecordApplicationEvents
class DocumentsIT {

    @Autowired
    TestApi api;

    @Autowired
    JdbcTemplate jdbc;

    @Autowired
    DocumentService documents;

    @Autowired
    ApplicationEvents events;

    /** Loads a complete Load Provider profile; returns the PAN document id. */
    String completeLoadProvider(TestApi.Session s) throws Exception {
        api.put("/api/v1/me", Map.of("name", "Murugan Traders", "language", "en", "address",
                Map.of("line", "1 Market St", "village", "Oddanchatram", "district", "Dindigul", "state", "Tamil Nadu",
                        "pin", "624619")), s).andExpect(status().isOk());
        api.put("/api/v1/me/role-profile", Map.of("accountType", "INDIVIDUAL"), s).andExpect(status().isOk());
        api.send("/api/v1/me/documents", Map.of("type", "PHOTO", "fileIds", List.of(api.uploadPng(s))), s)
                .andExpect(status().isOk());
        String pan = api.body(api.send("/api/v1/me/documents",
                Map.of("type", "PAN", "fileIds", List.of(api.uploadPng(s)), "number", "abcde1234f"), s)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.numberMasked").value("XXXXXX234F"))
                .andExpect(jsonPath("$.status").value("PENDING"))
                .andExpect(jsonPath("$.viewUrl").isString()));
        return JsonPath.read(pan, "$.id");
    }

    @Test
    void completeSubmitApproveVerified() throws Exception {
        TestApi.Session s = api.signUp("LOAD_PROVIDER");
        completeLoadProvider(s);
        api.get("/api/v1/me", s).andExpect(jsonPath("$.profileCompletion").value(100))
                .andExpect(jsonPath("$.photoUrl").isString());
        api.send("/api/v1/me/verification/submit", Map.of(), s).andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UNDER_REVIEW"));

        TestApi.Session admin = api.admin();
        api.get("/api/v1/admin/verifications?tab=IDENTITY", s).andExpect(status().isForbidden());
        String queue = api.body(api.get("/api/v1/admin/verifications?tab=IDENTITY", admin).andExpect(status().isOk()));
        List<String> docIds = JsonPath.read(queue, "$[?(@.userId=='" + s.userId() + "')].documents[*].id");
        assertThat(docIds).hasSize(2);
        for (String id : docIds) {
            api.send("/api/v1/admin/documents/" + id + "/approve", Map.of(), admin).andExpect(status().isOk());
        }
        api.get("/api/v1/me", s).andExpect(jsonPath("$.verificationStatus").value("VERIFIED"));
        assertThat(events.stream(UserEvents.VerificationChanged.class)
                .filter(e -> e.userId().equals(s.userId()))).hasSize(1);
        assertThat(jdbc.queryForObject("select count(*) from admin_audit where action = 'VERIFICATION_VERIFIED' and entity_id = ?",
                Integer.class, s.userId().toString())).isEqualTo(1);
    }

    @Test
    void rejectThenReuploadGoesBackToReview() throws Exception {
        TestApi.Session s = api.signUp("LOAD_PROVIDER");
        String pan = completeLoadProvider(s);
        api.send("/api/v1/me/verification/submit", Map.of(), s).andExpect(status().isOk());
        TestApi.Session admin = api.admin();
        api.send("/api/v1/admin/documents/" + pan + "/reject", Map.of(), admin)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("reason"));
        api.send("/api/v1/admin/documents/" + pan + "/reject", Map.of("reason", "Photo is blurred"), admin).andExpect(status().isOk());
        String queue = api.body(api.get("/api/v1/admin/verifications?tab=IDENTITY", admin));
        List<String> rest = JsonPath.read(queue, "$[?(@.userId=='" + s.userId() + "')].documents[?(@.status=='PENDING')].id");
        rest.forEach(id -> {
            try {
                api.send("/api/v1/admin/documents/" + id + "/approve", Map.of(), admin);
            } catch (Exception e) {
                throw new IllegalStateException(e);
            }
        });
        api.get("/api/v1/me/verification", s).andExpect(jsonPath("$.status").value("NOT_VERIFIED"))
                .andExpect(jsonPath("$.documents[?(@.type=='PAN')].rejectReason").value("Photo is blurred"));
        assertThat(events.stream(UserEvents.DocumentRejected.class).filter(e -> e.userId().equals(s.userId()))).hasSize(1);

        api.put("/api/v1/me/documents/" + pan, Map.of("fileIds", List.of(api.uploadPng(s)), "number", "ABCDE1234F"), s)
                .andExpect(status().isOk()).andExpect(jsonPath("$.status").value("PENDING"));
        api.get("/api/v1/me", s).andExpect(jsonPath("$.verificationStatus").value("UNDER_REVIEW"));
    }

    @Test
    void documentRules() throws Exception {
        TestApi.Session d = api.signUp("DRIVER");
        String file = api.uploadPng(d);
        api.send("/api/v1/me/documents", Map.of("type", "PAN", "fileIds", List.of(file), "number", "BAD"), d)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("number"));
        api.send("/api/v1/me/documents", Map.of("type", "DRIVING_LICENCE", "fileIds", List.of(file), "number", "TN5720190012345"), d)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("expiresOn"));
        api.send("/api/v1/me/documents", Map.of("type", "DRIVING_LICENCE", "fileIds", List.of(file), "number", "TN5720190012345",
                "expiresOn", "2020-01-01"), d).andExpect(status().isBadRequest());
        api.send("/api/v1/me/documents", Map.of("type", "ORG_REGISTRATION_CERT", "fileIds", List.of(file)), d)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("type"));
        TestApi.Session other = api.signUp("DRIVER");
        api.send("/api/v1/me/documents", Map.of("type", "PHOTO", "fileIds", List.of(file)), other)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("fileIds"));
        api.send("/api/v1/me/aadhaar/offline", Map.of("qrPayload", "x"), d)
                .andExpect(status().isForbidden());
        api.get("/api/v1/settings/public", null).andExpect(jsonPath("$.aadhaarEnabled").value(false));
    }

    @Test
    void expiryJobSendsOneReminderPerThresholdAndExpiredOnce() throws Exception {
        TestApi.Session d = api.signUp("DRIVER");
        String body = api.body(api.send("/api/v1/me/documents", Map.of("type", "DRIVING_LICENCE",
                "fileIds", List.of(api.uploadPng(d)), "number", "TN5720190012345",
                "expiresOn", LocalDate.now().plusDays(60).toString()), d).andExpect(status().isOk()));
        String id = JsonPath.read(body, "$.id");
        jdbc.update("update identity_document set expires_on = ? where id = ?::uuid", LocalDate.now().plusDays(5), id);
        documents.expiryJob();
        documents.expiryJob();
        assertThat(events.stream(UserEvents.DocumentExpiring.class).filter(e -> e.documentId().toString().equals(id))).hasSize(1);
        jdbc.update("update identity_document set expires_on = ? where id = ?::uuid", LocalDate.now().minusDays(1), id);
        documents.expiryJob();
        documents.expiryJob();
        assertThat(events.stream(UserEvents.DocumentExpired.class).filter(e -> e.documentId().toString().equals(id))).hasSize(1);
    }
}
