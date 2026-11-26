package com.nothing.tranix.shared;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Map;

import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.system.CapturedOutput;
import org.springframework.boot.test.system.OutputCaptureExtension;
import org.springframework.context.annotation.Import;
import org.springframework.core.env.Environment;

/** B-1602: a refused request is logged with its code and field names only — never the mobile or OTP that was sent. */
@IntegrationTest
@Import(TestApi.class)
@ExtendWith(OutputCaptureExtension.class)
class LogPrivacyIT {

    @Autowired
    TestApi api;

    @Autowired
    Environment env;

    @Test
    void rejectedMobilesAndOtpsAreNotLogged(CapturedOutput output) throws Exception {
        assertThat(env.getProperty("spring.mvc.log-resolved-exception", Boolean.class)).isFalse();

        api.send("/api/v1/auth/otp/send", Map.of("mobile", "1234598765", "purpose", "SIGN_UP"), null)
                .andExpect(status().isBadRequest());
        api.send("/api/v1/auth/sign-in", Map.of("mobile", "9876501234", "otp", "98765"), null)
                .andExpect(status().isBadRequest());

        assertThat(output).contains("Refused 400 VALIDATION_FAILED").contains("fields=[mobile]");
        assertThat(output).doesNotContain("1234598765").doesNotContain("9876501234").doesNotContain("98765\"");
    }
}
