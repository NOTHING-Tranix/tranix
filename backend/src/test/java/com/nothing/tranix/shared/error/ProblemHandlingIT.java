package com.nothing.tranix.shared.error;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.shared.geo.GeoPoint;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Problem JSON shape from docs/api-contract.md §1 for validation and ApiException errors. */
@IntegrationTest
@Import(ProblemHandlingIT.Endpoints.class)
class ProblemHandlingIT {

    @Autowired
    MockMvc mvc;

    @Test
    void invalidBodyGivesFieldErrors() throws Exception {
        mvc.perform(post("/api/v1/test/echo").with(jwt())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"mobile\":\"12345\",\"name\":\"\",\"at\":{\"lat\":95,\"lng\":78}}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.type").value("about:blank"))
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
                .andExpect(jsonPath("$.fields.length()").value(3))
                .andExpect(jsonPath("$.fields[?(@.field=='mobile')]").exists())
                .andExpect(jsonPath("$.fields[?(@.field=='at.lat')]").exists());
    }

    @Test
    void malformedJsonIsValidationFailed() throws Exception {
        mvc.perform(post("/api/v1/test/echo").with(jwt()).contentType(MediaType.APPLICATION_JSON).content("{"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"));
    }

    @Test
    void apiExceptionKeepsCodeStatusAndDetail() throws Exception {
        mvc.perform(post("/api/v1/test/balance").with(jwt()))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("INSUFFICIENT_BALANCE"))
                .andExpect(jsonPath("$.title").value("Insufficient wallet balance"))
                .andExpect(jsonPath("$.detail").value("Posting needs ₹50"))
                .andExpect(jsonPath("$.fields").isEmpty());
    }

    @TestConfiguration
    static class Endpoints {
        /** Nested in a test class, so Boot's TestTypeExcludeFilter keeps it out of other contexts' scanning. */
        @RestController
        @RequestMapping("/api/v1/test")
        static class TestController {
            @PostMapping("/echo")
            Body echo(@Valid @RequestBody Body body) {
                return body;
            }

            @PostMapping("/balance")
            void balance() {
                throw new ApiException(ErrorCode.INSUFFICIENT_BALANCE, "Posting needs ₹50");
            }
        }
    }

    record Body(@NotBlank @Pattern(regexp = "[6-9]\\d{9}") String mobile, @NotBlank String name,
                @Valid GeoPoint at) {
    }
}
