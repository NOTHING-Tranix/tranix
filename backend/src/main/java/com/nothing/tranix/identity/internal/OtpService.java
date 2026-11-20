package com.nothing.tranix.identity.internal;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.integrations.SmsSender;
import com.nothing.tranix.shared.settings.SettingKeys;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.shared.types.Language;
import com.nothing.tranix.shared.types.OtpPurpose;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * B-102: account OTPs — 6 digits, HMAC-hashed at rest, TTL/attempts/cooldown/lock from settings, resend invalidates
 * the old code. In the dev profile the code is always {@code tranix.dev.otp} (123456). Codes are never logged.
 */
@Service
class OtpService {

    private static final SecureRandom RANDOM = new SecureRandom();

    private final OtpRepository otps;
    private final SmsSender sms;
    private final Settings settings;
    private final Clock clock;
    private final byte[] pepper;
    private final String devOtp;

    OtpService(OtpRepository otps, SmsSender sms, Settings settings, Clock clock,
               @Value("${tranix.jwt.secret}") String pepper, @Value("${tranix.dev.otp:}") String devOtp) {
        this.otps = otps;
        this.sms = sms;
        this.settings = settings;
        this.clock = clock;
        this.pepper = pepper.getBytes(StandardCharsets.UTF_8);
        this.devOtp = devOtp == null || devOtp.isBlank() ? null : devOtp;
    }

    @Transactional
    void send(String mobile, OtpPurpose purpose, UUID userId, Language language) {
        Instant now = Instant.now(clock);
        requireNotLocked(mobile, purpose, now);
        List<Otp> previous = otps.findByMobileAndPurposeOrderByCreatedAtDesc(mobile, purpose);
        if (!previous.isEmpty() && previous.get(0).getCreatedAt()
                .plusSeconds(settings.getInt(SettingKeys.OTP_RESEND_SECONDS)).isAfter(now)) {
            throw new ApiException(ErrorCode.RATE_LIMITED, "Wait before asking for a new OTP");
        }
        if (otps.countByMobileAndCreatedAtAfter(mobile, now.minus(Duration.ofHours(1)))
                >= settings.getInt("otp.max_sends_per_hour")) {
            throw new ApiException(ErrorCode.RATE_LIMITED, "Too many OTPs requested");
        }
        previous.forEach(o -> o.invalidate(now));
        String code = devOtp != null ? devOtp : String.format("%06d", RANDOM.nextInt(1_000_000));
        otps.save(new Otp(mobile, purpose, userId, hash(mobile, code), now,
                now.plusSeconds(settings.getInt(SettingKeys.OTP_TTL_SECONDS))));
        sms.send(mobile, "OTP_" + purpose.name(), Map.of("otp", code), language);
    }

    /** Checks and consumes the latest code. Wrong attempts are kept even though an exception is thrown. */
    @Transactional(noRollbackFor = ApiException.class)
    Otp verify(String mobile, OtpPurpose purpose, String code) {
        Instant now = Instant.now(clock);
        requireNotLocked(mobile, purpose, now);
        Otp otp = otps.findByMobileAndPurposeOrderByCreatedAtDesc(mobile, purpose).stream()
                .filter(Otp::usable).findFirst()
                .orElseThrow(() -> new ApiException(ErrorCode.OTP_INVALID, "Ask for a new OTP"));
        if (!now.isBefore(otp.getExpiresAt())) {
            otp.invalidate(now);
            throw new ApiException(ErrorCode.OTP_EXPIRED);
        }
        if (code == null || !MessageDigest.isEqual(hash(mobile, code).getBytes(StandardCharsets.UTF_8),
                otp.getCodeHash().getBytes(StandardCharsets.UTF_8))) {
            otp.failedAttempt();
            if (otp.getAttempts() >= settings.getInt(SettingKeys.OTP_MAX_ATTEMPTS)) {
                otp.lockUntil(now, now.plus(Duration.ofMinutes(settings.getInt(SettingKeys.OTP_LOCK_MINUTES))));
                throw new ApiException(ErrorCode.OTP_LOCKED);
            }
            throw new ApiException(ErrorCode.OTP_INVALID);
        }
        otp.consume(now);
        return otp;
    }

    private void requireNotLocked(String mobile, OtpPurpose purpose, Instant now) {
        Instant locked = otps.lockedUntil(mobile, purpose);
        if (locked != null && locked.isAfter(now)) {
            throw new ApiException(ErrorCode.OTP_LOCKED);
        }
    }

    private String hash(String mobile, String code) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(pepper, "HmacSHA256"));
            return HexFormat.of().formatHex(mac.doFinal((mobile + ":" + code).getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }
}
