package com.nothing.tranix.trust.api;

import java.math.BigDecimal;
import java.util.UUID;

/** Trust Score writes for other modules (admin adjustments, verified complaints). Every change is a ledger event. */
public interface TrustApi {

    /** Adds one event; returns the new clamped score. {@code event} is a stable code, e.g. VERIFIED_COMPLAINT. */
    BigDecimal record(UUID userId, UUID loadId, String event, BigDecimal points, String reason, UUID createdBy);

    /** Admin adjustment (reason required, D-10). */
    BigDecimal adjust(UUID userId, BigDecimal points, String reason, UUID adminId);

    /** M12: a receiver without an account rates the driver from the tracking link (one rating per load). */
    void rateFromLink(UUID loadId, UUID raterId, UUID rateeId, int stars, java.util.List<String> tags, String comment);
}
