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

    /** B-1618: a duplicate-key race must not log the database detail "Key (mobile)=(…) already exists". */
    @Test
    void duplicateSignUpRaceDoesNotLogTheMobile(CapturedOutput output) throws Exception {
        String mobile = TestApi.newMobile();
        api.send("/api/v1/auth/otp/send", Map.of("mobile", mobile, "purpose", "SIGN_UP"), null).andExpect(status().isNoContent());
        String otp = api.lastOtp(mobile);
        java.util.concurrent.CountDownLatch start = new java.util.concurrent.CountDownLatch(1);
        java.util.concurrent.ExecutorService pool = java.util.concurrent.Executors.newFixedThreadPool(4);
        java.util.List<java.util.concurrent.Future<Integer>> fs = new java.util.ArrayList<>();
        for (int i = 0; i < 4; i++) {
            int k = i;
            fs.add(pool.submit(() -> {
                start.await();
                return api.send("/api/v1/auth/sign-up", Map.of("mobile", mobile, "otp", otp, "name", "Race " + k,
                        "role", "RECEIVER", "consent", true), null).andReturn().getResponse().getStatus();
            }));
        }
        start.countDown();
        for (java.util.concurrent.Future<Integer> f : fs) {
            assertThat(f.get()).isIn(200, 409, 400);
        }
        pool.shutdown();
        assertThat(output).doesNotContain(mobile);
    }
}
