package com.nothing.tranix.receiver.api;

import java.util.UUID;

/** Events published by the receiver module. */
public final class ReceiverEvents {

    private ReceiverEvents() {
    }

    /** A delivery receipt was recorded; {@code SHORTAGE_DAMAGE} opens a support ticket (B-1005). */
    public record ReceiptRecorded(UUID loadId, String condition, String remarks, UUID byUserId, String byMobile) {
    }
}
