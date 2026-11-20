package com.nothing.tranix.wallet.api;

import java.util.UUID;

/** Events published by the wallet module (consumed by engagement for notifications). */
public final class WalletEvents {

    private WalletEvents() {
    }

    public record Credited(UUID ownerUserId, String type, long amountInr, long balanceInr, String txnId) {
    }

    public record Debited(UUID ownerUserId, String type, long amountInr, long balanceInr, UUID loadId, String txnId) {
    }

    /** B-307: balance fell below the charge this owner needs. */
    public record LowBalance(UUID ownerUserId, long balanceInr, long neededInr) {
    }
}
