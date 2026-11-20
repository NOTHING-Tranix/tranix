package com.nothing.tranix.identity.api;

import java.util.UUID;

import com.nothing.tranix.shared.types.Role;
import com.nothing.tranix.shared.types.VerificationStatus;

/** Application events published by identity. */
public final class UserEvents {

    private UserEvents() {
    }

    public record UserRegistered(UUID userId, Role role) {
    }

    /** B-207: verification result (VERIFIED / NOT_VERIFIED) or document rejected. */
    public record VerificationChanged(UUID userId, VerificationStatus status, String reason) {
    }

    public record DocumentRejected(UUID userId, UUID documentId, String type, String reason) {
    }

    public record DocumentExpiring(UUID userId, UUID documentId, String type, int daysLeft) {
    }

    public record DocumentExpired(UUID userId, UUID documentId, String type, String ownerType, UUID ownerId) {
    }
}
