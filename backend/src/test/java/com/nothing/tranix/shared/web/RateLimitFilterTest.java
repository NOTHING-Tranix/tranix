package com.nothing.tranix.shared.web;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;

import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

/** B-1401: per-IP fixed window on auth and public link paths only. */
class RateLimitFilterTest {

    final RateLimitFilter filter = new RateLimitFilter(Clock.fixed(Instant.parse("2026-11-21T10:00:00Z"), ZoneOffset.UTC), 3, 5,
            "127.0.0.1, 10.0.0.5");

    int status(String path, String ip) throws Exception {
        return status(path, ip, null);
    }

    int status(String path, String ip, String forwardedFor) throws Exception {
        MockHttpServletRequest req = new MockHttpServletRequest("POST", path);
        req.setRequestURI(path);
        req.setRemoteAddr(ip);
        if (forwardedFor != null) {
            req.addHeader("X-Forwarded-For", forwardedFor);
        }
        MockHttpServletResponse res = new MockHttpServletResponse();
        filter.doFilter(req, res, new MockFilterChain());
        return res.getStatus();
    }

    @Test
    void clientCannotDodgeTheLimitWithItsOwnForwardedForHeader() throws Exception {
        // direct caller (not our proxy) sends a new fake X-Forwarded-For every time → still counted as one IP
        for (int i = 0; i < 3; i++) {
            assertThat(status("/api/v1/auth/otp/send", "6.6.6.6", "9.9.9." + i)).isEqualTo(200);
        }
        assertThat(status("/api/v1/auth/otp/send", "6.6.6.6", "9.9.9.99")).isEqualTo(429);

        // through our proxy, only the last hop (added by the proxy) counts; forged first entries are ignored
        for (int i = 0; i < 3; i++) {
            assertThat(status("/api/v1/auth/otp/send", "10.0.0.5", "1.2.3." + i + ", 7.7.7.7")).isEqualTo(200);
        }
        assertThat(status("/api/v1/auth/otp/send", "10.0.0.5", "5.5.5.5, 7.7.7.7")).isEqualTo(429);
        // a different real client behind the same proxy has its own limit
        assertThat(status("/api/v1/auth/otp/send", "10.0.0.5", "8.8.8.8")).isEqualTo(200);
    }

    @Test
    void limitsAuthPerIpAndLeavesOtherPathsAlone() throws Exception {
        for (int i = 0; i < 3; i++) {
            assertThat(status("/api/v1/auth/otp/send", "1.1.1.1")).isEqualTo(200);
        }
        assertThat(status("/api/v1/auth/otp/send", "1.1.1.1")).isEqualTo(429);
        assertThat(status("/api/v1/auth/otp/send", "2.2.2.2")).isEqualTo(200);
        for (int i = 0; i < 10; i++) {
            assertThat(status("/api/v1/loads", "1.1.1.1")).isEqualTo(200);
        }
        for (int i = 0; i < 5; i++) {
            assertThat(status("/api/v1/public/track/x", "3.3.3.3")).isEqualTo(200);
        }
        assertThat(status("/api/v1/public/track/x", "3.3.3.3")).isEqualTo(429);
    }
}
