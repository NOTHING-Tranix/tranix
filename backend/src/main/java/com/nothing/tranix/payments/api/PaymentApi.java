package com.nothing.tranix.payments.api;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import com.nothing.tranix.shared.types.PaymentMode;

/** Payments for other modules (receiver link page, M12). */
public interface PaymentApi {

    /** The LoadDetail.payment block, if a record exists. */
    Optional<Map<String, Object>> payment(UUID loadId);

    /** Receiver (no account) marks paid from the tracking link when the receiver pays. */
    Map<String, Object> markPaidFromLink(UUID loadId, long amountInr, PaymentMode mode, String reference);
}
