package com.nothing.tranix.identity;

import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Map;

import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;
import com.nothing.tranix.identity.api.RequiresVerified;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Import;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

/** B-107 / B-208: business actions need VERIFIED. */
@IntegrationTest
@Import({TestApi.class, VerifiedGuardIT.Endpoints.class})
class VerifiedGuardIT {

    @Autowired
    TestApi api;

    @Test
    void unverifiedIsBlockedVerifiedPasses() throws Exception {
        TestApi.Session unverified = api.signUp("LOAD_PROVIDER");
        api.send("/api/v1/test/business", Map.of(), unverified)
                .andExpect(status().isForbidden()).andExpect(jsonPath("$.code").value("NOT_VERIFIED"));
        TestApi.Session verified = api.verified("LOAD_PROVIDER");
        api.send("/api/v1/test/business", Map.of(), verified).andExpect(status().isOk());
    }

    @TestConfiguration
    static class Endpoints {
        @RestController
        static class Business {
            @RequiresVerified
            @PostMapping("/api/v1/test/business")
            Map<String, String> act() {
                return Map.of("ok", "yes");
            }
        }
    }
}
