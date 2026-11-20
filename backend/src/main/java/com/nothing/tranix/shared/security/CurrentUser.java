package com.nothing.tranix.shared.security;

import java.util.Optional;
import java.util.UUID;

import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.types.Role;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;

/** Reads the signed-in user (JWT {@code sub} + {@code role}) from the security context. */
public final class CurrentUser {

    private CurrentUser() {
    }

    public static Optional<UUID> idIfPresent() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof Jwt jwt && jwt.getSubject() != null) {
            try {
                return Optional.of(UUID.fromString(jwt.getSubject()));
            } catch (IllegalArgumentException e) {
                return Optional.empty();
            }
        }
        return Optional.empty();
    }

    public static UUID id() {
        return idIfPresent().orElseThrow(() -> new ApiException(ErrorCode.UNAUTHENTICATED));
    }

    public static Optional<Role> role() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof Jwt jwt) {
            String role = jwt.getClaimAsString(SecurityConfig.ROLE_CLAIM);
            if (role != null) {
                try {
                    return Optional.of(Role.valueOf(role));
                } catch (IllegalArgumentException e) {
                    return Optional.empty();
                }
            }
        }
        return Optional.empty();
    }
}
