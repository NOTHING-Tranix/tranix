package com.nothing.tranix.wallet.api;

import java.util.UUID;

/**
 * B-305: charges for other modules. The wallet owner is the user who pays (shipper, owner-driver or the
 * Organization user for its drivers). All amounts come from settings.
 */
public interface WalletApi {

    enum ChargeType { POSTING_CHARGE, TRIP_CHARGE }

    long balance(UUID ownerUserId);

    long chargeAmount(ChargeType type);

    boolean hasBalance(UUID ownerUserId, ChargeType type);

    /**
     * Debits the charge for this load; idempotent per (load, type). Must run inside the caller's transaction
     * (row lock on the account). Throws {@code INSUFFICIENT_BALANCE} when the balance is too low.
     */
    String charge(UUID ownerUserId, ChargeType type, UUID loadId);

    /** Credits a refund (admin decision); idempotent per (load, type) when {@code loadId} is given. */
    String refund(UUID ownerUserId, long amountInr, UUID loadId, String note, UUID adminId);
}
