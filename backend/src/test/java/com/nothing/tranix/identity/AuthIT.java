package com.nothing.tranix.identity;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;
import com.nothing.tranix.shared.integrations.fake.FakeSmsSender;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;

@IntegrationTest
@Import(TestApi.class)
class AuthIT {

    @Autowired
    TestApi api;

    @Autowired
    FakeSmsSender sms;

    @Autowired
    JdbcTemplate jdbc;

    @Test
    void signUpThenSignInRefreshAndSignOut() throws Exception {
        TestApi.Session s = api.signUp("DRIVER");
        api.get("/api/v1/me", s).andExpect(status().isOk())
                .andExpect(jsonPath("$.role").value("DRIVER"))
                .andExpect(jsonPath("$.verificationStatus").value("NOT_SUBMITTED"))
                .andExpect(jsonPath("$.trustScore").value(70.0))
                .andExpect(jsonPath("$.profileCompletion").value(10));

        // OTP is stored hashed, never in clear text
        String hash = jdbc.queryForObject("select code_hash from identity_otp where mobile = ? limit 1", String.class, s.mobile());
        assertThat(hash).hasSize(64).doesNotContain(api.lastOtp(s.mobile()));

        api.send("/api/v1/auth/otp/send", Map.of("mobile", s.mobile(), "purpose", "SIGN_IN"), null).andExpect(status().isNoContent());
        String body = api.body(api.send("/api/v1/auth/sign-in",
                Map.of("mobile", s.mobile(), "otp", api.lastOtp(s.mobile()), "deviceId", "phone-2"), null).andExpect(status().isOk()));
        String refresh1 = JsonPath.read(body, "$.refreshToken");
        assertThat((Integer) JsonPath.read(body, "$.expiresIn")).isEqualTo(900);

        String refreshed = api.body(api.send("/api/v1/auth/refresh", Map.of("refreshToken", refresh1), null).andExpect(status().isOk()));
        String refresh2 = JsonPath.read(refreshed, "$.refreshToken");
        assertThat(refresh2).isNotEqualTo(refresh1);

        // reuse of a rotated token revokes the family
        api.send("/api/v1/auth/refresh", Map.of("refreshToken", refresh1), null)
                .andExpect(status().isUnauthorized()).andExpect(jsonPath("$.code").value("UNAUTHENTICATED"));
        api.send("/api/v1/auth/refresh", Map.of("refreshToken", refresh2), null).andExpect(status().isUnauthorized());

        api.send("/api/v1/auth/sign-out", Map.of("refreshToken", s.refreshToken()), null).andExpect(status().isNoContent());
        api.send("/api/v1/auth/refresh", Map.of("refreshToken", s.refreshToken()), null).andExpect(status().isUnauthorized());
    }

    @Test
    void signUpRules() throws Exception {
        TestApi.Session existing = api.signUp("LOAD_PROVIDER");
        api.send("/api/v1/auth/sign-up", Map.of("mobile", existing.mobile(), "otp", "123456", "name", "Dup",
                "role", "DRIVER", "consent", true), null).andExpect(status().isConflict()).andExpect(jsonPath("$.code").value("MOBILE_IN_USE"));

        String m = TestApi.newMobile();
        api.send("/api/v1/auth/otp/send", Map.of("mobile", m, "purpose", "SIGN_UP"), null);
        api.send("/api/v1/auth/sign-up", Map.of("mobile", m, "otp", api.lastOtp(m), "name", "X", "role", "ADMIN", "consent", true), null)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("VALIDATION_FAILED"));
        api.send("/api/v1/auth/sign-up", Map.of("mobile", m, "otp", "000000", "name", "Xy", "role", "DRIVER", "consent", false), null)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("consent"));
        api.send("/api/v1/auth/otp/send", Map.of("mobile", "12345", "purpose", "SIGN_UP"), null)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("mobile"));
    }

    @Test
    void signInDoesNotRevealUnknownNumbers() throws Exception {
        String m = TestApi.newMobile();
        int before = sms.sent().size();
        api.send("/api/v1/auth/otp/send", Map.of("mobile", m, "purpose", "SIGN_IN"), null).andExpect(status().isNoContent());
        assertThat(sms.sent()).hasSize(before);
        api.send("/api/v1/auth/sign-in", Map.of("mobile", m, "otp", "123456"), null)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("OTP_INVALID"));
    }

    @Test
    void wrongOtpFiveTimesLocksAndResendHasCooldown() throws Exception {
        TestApi.Session s = api.signUp("RECEIVER");
        api.send("/api/v1/auth/otp/send", Map.of("mobile", s.mobile(), "purpose", "SIGN_IN"), null).andExpect(status().isNoContent());
        api.send("/api/v1/auth/otp/send", Map.of("mobile", s.mobile(), "purpose", "SIGN_IN"), null)
                .andExpect(status().isTooManyRequests()).andExpect(jsonPath("$.code").value("RATE_LIMITED"));
        String good = api.lastOtp(s.mobile());
        String wrong = good.equals("000000") ? "111111" : "000000";
        for (int i = 0; i < 4; i++) {
            api.send("/api/v1/auth/sign-in", Map.of("mobile", s.mobile(), "otp", wrong), null)
                    .andExpect(jsonPath("$.code").value("OTP_INVALID"));
        }
        api.send("/api/v1/auth/sign-in", Map.of("mobile", s.mobile(), "otp", wrong), null)
                .andExpect(status().isTooManyRequests()).andExpect(jsonPath("$.code").value("OTP_LOCKED"));
        api.send("/api/v1/auth/sign-in", Map.of("mobile", s.mobile(), "otp", good), null)
                .andExpect(jsonPath("$.code").value("OTP_LOCKED"));
    }

    @Test
    void profileRoleProfileCompletionAndDevices() throws Exception {
        TestApi.Session s = api.signUp("FARMER_NETWORK");
        api.put("/api/v1/me", Map.of("name", "Kaveri FPO", "language", "ta", "address",
                Map.of("line", "12 Main Rd", "village", "Melur", "district", "Madurai", "state", "Tamil Nadu", "pin", "625106")), s)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.language").value("ta"))
                .andExpect(jsonPath("$.profileCompletion").value(25));

        Map<String, Object> fn = new HashMap<>(Map.of("networkName", "Kaveri FPO", "registrationNumber", "FPO-123",
                "idType", "PAN", "idNumber", "abcde1234z", "contactPerson", "Selvi", "state", "Tamil Nadu", "district", "Madurai"));
        api.put("/api/v1/me/role-profile", fn, s).andExpect(status().isOk()).andExpect(jsonPath("$.idNumber").value("ABCDE1234Z"));
        fn.put("idType", "GSTIN");
        api.put("/api/v1/me/role-profile", fn, s).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fields[0].field").value("idNumber"));

        api.get("/api/v1/me/verification", s).andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("NOT_SUBMITTED"))
                .andExpect(jsonPath("$.items.length()").value(6))
                .andExpect(jsonPath("$.estimatedReviewHours").value(24));
        api.get("/api/v1/me", s).andExpect(jsonPath("$.profileCompletion").value(45));
        api.send("/api/v1/me/verification/submit", Map.of(), s).andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("INVALID_STATE"));

        api.send("/api/v1/me/devices", Map.of("fcmToken", "fcm-" + s.mobile(), "platform", "ANDROID"), s).andExpect(status().isNoContent());
        assertThat(jdbc.queryForObject("select count(*) from identity_device where user_id = ?", Integer.class, s.userId())).isEqualTo(1);
    }

    @Test
    void driverLicenceAndOrgFormats() throws Exception {
        TestApi.Session d = api.signUp("DRIVER");
        api.put("/api/v1/me/role-profile", Map.of("licenceNumber", "TN57 2019 0012345", "licenceValidUntil", "2030-01-01",
                "vehicleClasses", List.of("HGMV")), d).andExpect(status().isOk());
        api.put("/api/v1/me/role-profile", Map.of("licenceNumber", "BAD", "licenceValidUntil", "2020-01-01",
                "vehicleClasses", List.of()), d).andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fields.length()").value(3));
        TestApi.Session o = api.signUp("ORGANIZATION");
        api.put("/api/v1/me/role-profile", Map.of("orgName", "Sri Transports", "contactPerson", "Arun", "gstin", "33ABCDE1234F1Z5"), o)
                .andExpect(status().isOk());
    }

    @Test
    void mobileChangeWithOtpIsAudited() throws Exception {
        TestApi.Session s = api.signUp("LOAD_PROVIDER");
        String newMobile = TestApi.newMobile();
        api.send("/api/v1/me/mobile/change", Map.of("mobile", newMobile), s).andExpect(status().isNoContent());
        api.send("/api/v1/me/mobile/verify", Map.of("mobile", newMobile, "otp", api.lastOtp(newMobile)), s)
                .andExpect(status().isOk()).andExpect(jsonPath("$.mobile").value(newMobile));
        assertThat(jdbc.queryForObject("select count(*) from admin_audit where action = 'MOBILE_CHANGED' and entity_id = ?",
                Integer.class, s.userId().toString())).isEqualTo(1);
        String after = jdbc.queryForObject("select after from admin_audit where entity_id = ?", String.class, s.userId().toString());
        assertThat(after).doesNotContain(newMobile.substring(0, 6));
    }
}
