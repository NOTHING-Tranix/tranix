package com.nothing.tranix.identity.internal;

import java.time.Instant;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import com.nothing.tranix.shared.types.OtpPurpose;
import com.nothing.tranix.shared.types.Role;

/** Small identity entities kept together. */
final class IdentityEntities {
    private IdentityEntities() {
    }
}

@Entity
@Table(name = "identity_address")
class Address {

    @Id
    @Column(name = "user_id")
    private UUID userId;
    private String line;
    private String village;
    private String district;
    private String state;
    private String pin;

    protected Address() {
    }

    Address(UUID userId) {
        this.userId = userId;
    }

    void update(String line, String village, String district, String state, String pin) {
        this.line = line;
        this.village = village;
        this.district = district;
        this.state = state;
        this.pin = pin;
    }

    String line() { return line; }
    String village() { return village; }
    String district() { return district; }
    String state() { return state; }
    String pin() { return pin; }
}

@Entity
@Table(name = "identity_role_profile")
class RoleProfile {

    @Id
    @Column(name = "user_id")
    private UUID userId;

    @Enumerated(EnumType.STRING)
    private Role role;

    /** JSON of the role's record (validated in RoleProfiles). */
    private String data;

    @Column(name = "updated_at")
    private Instant updatedAt;

    protected RoleProfile() {
    }

    RoleProfile(UUID userId, Role role) {
        this.userId = userId;
        this.role = role;
    }

    void update(String data, Instant at) {
        this.data = data;
        this.updatedAt = at;
    }

    String data() { return data; }
}

@Entity
@Table(name = "identity_otp")
class Otp {

    @Id
    private UUID id = UUID.randomUUID();
    private String mobile;

    @Enumerated(EnumType.STRING)
    private OtpPurpose purpose;

    @Column(name = "user_id")
    private UUID userId;

    @Column(name = "code_hash")
    private String codeHash;

    @Column(name = "expires_at")
    private Instant expiresAt;
    private int attempts;

    @Column(name = "consumed_at")
    private Instant consumedAt;

    @Column(name = "invalidated_at")
    private Instant invalidatedAt;

    @Column(name = "locked_until")
    private Instant lockedUntil;

    @Column(name = "created_at")
    private Instant createdAt;

    protected Otp() {
    }

    Otp(String mobile, OtpPurpose purpose, UUID userId, String codeHash, Instant now, Instant expiresAt) {
        this.mobile = mobile;
        this.purpose = purpose;
        this.userId = userId;
        this.codeHash = codeHash;
        this.createdAt = now;
        this.expiresAt = expiresAt;
    }

    boolean usable() {
        return consumedAt == null && invalidatedAt == null;
    }

    String getCodeHash() { return codeHash; }
    Instant getExpiresAt() { return expiresAt; }
    Instant getCreatedAt() { return createdAt; }
    UUID getUserId() { return userId; }
    int getAttempts() { return attempts; }
    void failedAttempt() { attempts++; }
    void consume(Instant now) { consumedAt = now; }
    void invalidate(Instant now) { if (invalidatedAt == null) invalidatedAt = now; }
    void lockUntil(Instant now, Instant until) { lockedUntil = until; invalidate(now); }
}

@Entity
@Table(name = "identity_refresh_token")
class RefreshToken {

    @Id
    private UUID id = UUID.randomUUID();

    @Column(name = "user_id")
    private UUID userId;

    @Column(name = "family_id")
    private UUID familyId;

    @Column(name = "token_hash")
    private String tokenHash;

    @Column(name = "device_id")
    private String deviceId;

    @Column(name = "expires_at")
    private Instant expiresAt;

    @Column(name = "revoked_at")
    private Instant revokedAt;

    @Column(name = "created_at")
    private Instant createdAt;

    protected RefreshToken() {
    }

    RefreshToken(UUID userId, UUID familyId, String tokenHash, String deviceId, Instant now, Instant expiresAt) {
        this.userId = userId;
        this.familyId = familyId;
        this.tokenHash = tokenHash;
        this.deviceId = deviceId;
        this.createdAt = now;
        this.expiresAt = expiresAt;
    }

    UUID getUserId() { return userId; }
    UUID getFamilyId() { return familyId; }
    String getDeviceId() { return deviceId; }
    Instant getExpiresAt() { return expiresAt; }
    boolean isRevoked() { return revokedAt != null; }
    void revoke(Instant now) { if (revokedAt == null) revokedAt = now; }
}

@Entity
@Table(name = "identity_device")
class Device {

    @Id
    private UUID id = UUID.randomUUID();

    @Column(name = "user_id")
    private UUID userId;

    @Column(name = "fcm_token")
    private String fcmToken;
    private String platform;

    @Column(name = "updated_at")
    private Instant updatedAt;

    protected Device() {
    }

    Device(String fcmToken) {
        this.fcmToken = fcmToken;
    }

    void assign(UUID userId, String platform, Instant now) {
        this.userId = userId;
        this.platform = platform;
        this.updatedAt = now;
    }

    String getFcmToken() { return fcmToken; }
}
