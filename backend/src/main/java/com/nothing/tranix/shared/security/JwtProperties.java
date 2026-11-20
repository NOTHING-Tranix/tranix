package com.nothing.tranix.shared.security;

import java.nio.charset.StandardCharsets;
import java.time.Duration;

import org.springframework.boot.context.properties.ConfigurationProperties;

/** {@code tranix.jwt.*}: HS256 secret (≥ 32 bytes), access TTL 15 min, refresh TTL 30 days (D-04). */
@ConfigurationProperties(prefix = "tranix.jwt")
public record JwtProperties(String secret, Duration accessTtl, Duration refreshTtl) {

    public JwtProperties {
        if (secret == null || secret.getBytes(StandardCharsets.UTF_8).length < 32) {
            throw new IllegalStateException("tranix.jwt.secret (JWT_SECRET) must be set and at least 32 bytes");
        }
        accessTtl = accessTtl != null ? accessTtl : Duration.ofMinutes(15);
        refreshTtl = refreshTtl != null ? refreshTtl : Duration.ofDays(30);
    }
}
