package com.nothing.tranix.payments.api;

import java.util.UUID;

/** Events published by payments (trust and engagement listen). */
public final class PaymentEvents {

    private PaymentEvents() {
    }

    /** {@code payerUserId} is null when an unregistered receiver paid. */
    public record PaymentConfirmed(UUID loadId, UUID payerUserId, boolean onTime) {
    }

    public record PaymentDisputed(UUID loadId, UUID driverId, UUID payerUserId, String reason) {
    }

    /** Admin decision on a dispute; {@code againstUserId} loses points when not null. */
    public record DisputeDecided(UUID loadId, UUID againstUserId, String decision) {
    }
}
