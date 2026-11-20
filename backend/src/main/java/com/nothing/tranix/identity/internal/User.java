package com.nothing.tranix.identity.internal;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;

import com.nothing.tranix.shared.domain.BaseEntity;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.types.Language;
import com.nothing.tranix.shared.types.Role;
import com.nothing.tranix.shared.types.VerificationStatus;

@Entity
@Table(name = "identity_user")
class User extends BaseEntity {

    @Column(name = "mobile", nullable = false, unique = true, length = 10)
    private String mobile;

    @Column(name = "name", nullable = false, length = 60)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false, updatable = false)
    private Role role;

    @Enumerated(EnumType.STRING)
    @Column(name = "language", nullable = false)
    private Language language;

    @Column(name = "email")
    private String email;

    @Column(name = "photo_file_id")
    private UUID photoFileId;

    @Enumerated(EnumType.STRING)
    @Column(name = "verification_status", nullable = false)
    private VerificationStatus verificationStatus = VerificationStatus.NOT_SUBMITTED;

    @Column(name = "profile_completion", nullable = false)
    private int profileCompletion;

    @Column(name = "trust_score", nullable = false)
    private BigDecimal trustScore;

    @Column(name = "consent_at")
    private Instant consentAt;

    @Column(name = "suspended_at")
    private Instant suspendedAt;

    protected User() {
    }

    User(String mobile, String name, Role role, Language language, BigDecimal trustScore, Instant consentAt) {
        this.mobile = mobile;
        this.name = name;
        this.role = role;
        this.language = language;
        this.trustScore = trustScore;
        this.consentAt = consentAt;
    }

    /** Allowed verification transitions (B-202, B-203, B-206). */
    void changeVerification(VerificationStatus next) {
        boolean ok = switch (next) {
            case UNDER_REVIEW -> verificationStatus != VerificationStatus.UNDER_REVIEW;
            case VERIFIED, NOT_VERIFIED -> verificationStatus == VerificationStatus.UNDER_REVIEW
                    || verificationStatus == VerificationStatus.VERIFIED;
            case NOT_SUBMITTED -> false;
        };
        if (!ok) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Verification can not move to " + next);
        }
        verificationStatus = next;
    }

    void updateProfile(String name, String email, Language language) {
        this.name = name;
        this.email = email;
        this.language = language;
    }

    String getMobile() { return mobile; }
    void setMobile(String mobile) { this.mobile = mobile; }
    String getName() { return name; }
    Role getRole() { return role; }
    Language getLanguage() { return language; }
    String getEmail() { return email; }
    UUID getPhotoFileId() { return photoFileId; }
    void setPhotoFileId(UUID id) { this.photoFileId = id; }
    VerificationStatus getVerificationStatus() { return verificationStatus; }
    int getProfileCompletion() { return profileCompletion; }
    void setProfileCompletion(int p) { this.profileCompletion = p; }
    BigDecimal getTrustScore() { return trustScore; }
    void setTrustScore(BigDecimal s) { this.trustScore = s; }
    Instant getSuspendedAt() { return suspendedAt; }
    void setSuspendedAt(Instant at) { this.suspendedAt = at; }
    boolean isSuspended() { return suspendedAt != null; }
}
