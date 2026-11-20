package com.nothing.tranix.identity.api;

import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.shared.types.Role;

/**
 * Lets other modules add their fields to {@code GET /me} without identity depending on them
 * (wallet → walletBalanceInr, trust → pendingRatingsCount, engagement → unreadNotifications).
 */
public interface MeContributor {

    Map<String, Object> contribute(UUID userId, Role role);
}
