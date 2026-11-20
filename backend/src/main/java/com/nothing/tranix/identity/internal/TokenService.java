package com.nothing.tranix.identity.internal;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Clock;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;
import java.util.UUID;

import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.security.JwtProperties;
import com.nothing.tranix.shared.security.SecurityConfig;

import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * B-105/B-106: access JWT (15 min) + opaque refresh token (30 days, stored as SHA-256). Refresh rotates; using an
 * already-rotated token revokes the whole family (reuse detection).
 */
@Service
class TokenService {

    private static final SecureRandom RANDOM = new SecureRandom();

    private final JwtEncoder encoder;
    private final JwtProperties props;
    private final RefreshTokenRepository refreshTokens;
    private final Clock clock;

    TokenService(JwtEncoder encoder, JwtProperties props, RefreshTokenRepository refreshTokens, Clock clock) {
        this.encoder = encoder;
        this.props = props;
        this.refreshTokens = refreshTokens;
        this.clock = clock;
    }

    record Issued(String accessToken, String refreshToken, long expiresIn) {
    }

    @Transactional
    Issued issue(User user, String deviceId) {
        return issue(user, deviceId, UUID.randomUUID());
    }

    /** Validates and rotates; returns the user id with new tokens issued by {@code onValid}. */
    @Transactional(noRollbackFor = ApiException.class)
    RefreshToken rotate(String rawRefreshToken) {
        Instant now = Instant.now(clock);
        RefreshToken token = refreshTokens.findByTokenHash(sha256(rawRefreshToken))
                .orElseThrow(() -> new ApiException(ErrorCode.UNAUTHENTICATED, "Sign in again"));
        if (token.isRevoked()) {
            refreshTokens.revokeFamily(token.getFamilyId(), now);
            throw new ApiException(ErrorCode.UNAUTHENTICATED, "Sign in again");
        }
        if (!now.isBefore(token.getExpiresAt())) {
            throw new ApiException(ErrorCode.UNAUTHENTICATED, "Sign in again");
        }
        token.revoke(now);
        return token;
    }

    @Transactional
    Issued issueInFamily(User user, RefreshToken previous) {
        return issue(user, previous.getDeviceId(), previous.getFamilyId());
    }

    @Transactional
    void revoke(String rawRefreshToken) {
        refreshTokens.findByTokenHash(sha256(rawRefreshToken))
                .ifPresent(t -> refreshTokens.revokeFamily(t.getFamilyId(), Instant.now(clock)));
    }

    private Issued issue(User user, String deviceId, UUID familyId) {
        Instant now = Instant.now(clock);
        JwtClaimsSet claims = JwtClaimsSet.builder()
                .subject(user.getId().toString())
                .issuedAt(now)
                .expiresAt(now.plus(props.accessTtl()))
                .claim(SecurityConfig.ROLE_CLAIM, user.getRole().name())
                .build();
        String access = encoder.encode(JwtEncoderParameters.from(JwsHeader.with(MacAlgorithm.HS256).build(), claims))
                .getTokenValue();
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String refresh = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        refreshTokens.save(new RefreshToken(user.getId(), familyId, sha256(refresh), deviceId, now,
                now.plus(props.refreshTtl())));
        return new Issued(access, refresh, props.accessTtl().toSeconds());
    }

    static String sha256(String value) {
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                    .digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }
}
