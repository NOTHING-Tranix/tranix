package com.nothing.tranix.engagement.internal;

import java.util.Map;

import com.nothing.tranix.shared.config.AsyncConfig;
import com.nothing.tranix.identity.api.UserEvents;
import com.nothing.tranix.shared.types.NotificationTab;
import com.nothing.tranix.shared.types.VerificationStatus;
import com.nothing.tranix.wallet.api.WalletEvents;

import org.springframework.stereotype.Component;
import org.springframework.scheduling.annotation.Async;
import org.springframework.transaction.event.TransactionalEventListener;

/** Turns account and wallet events into notifications (B-207, B-304, B-307, B-1107). Runs after commit. */
@Component
class NotificationListeners {

    static final String ROUTE_WALLET = "/wallet";
    static final String ROUTE_VERIFICATION = "/verification";

    private final NotificationService notifications;

    NotificationListeners(NotificationService notifications) {
        this.notifications = notifications;
    }

    @Async(AsyncConfig.AFTER_COMMIT)
    @TransactionalEventListener(fallbackExecution = true)
    void on(WalletEvents.Credited e) {
        String type = switch (e.type()) {
            case "TOPUP" -> "TOPUP_SUCCESS";
            case "REFUND" -> "REFUND";
            default -> "ADMIN_CREDIT";
        };
        notifications.notify(e.ownerUserId(), NotificationTab.WALLET, type,
                Map.of("amount", String.valueOf(e.amountInr()), "balance", String.valueOf(e.balanceInr())), ROUTE_WALLET);
    }

    @Async(AsyncConfig.AFTER_COMMIT)
    @TransactionalEventListener(fallbackExecution = true)
    void on(WalletEvents.Debited e) {
        notifications.notify(e.ownerUserId(), NotificationTab.WALLET, "CHARGE_DEDUCTED",
                Map.of("amount", String.valueOf(e.amountInr()), "balance", String.valueOf(e.balanceInr()),
                        "charge", e.type().equals("POSTING_CHARGE") ? "posting charge" : "trip charge",
                        "load", e.loadId() == null ? "" : e.loadId().toString().substring(0, 8)), ROUTE_WALLET);
    }

    @Async(AsyncConfig.AFTER_COMMIT)
    @TransactionalEventListener(fallbackExecution = true)
    void on(WalletEvents.LowBalance e) {
        notifications.notify(e.ownerUserId(), NotificationTab.WALLET, "LOW_BALANCE",
                Map.of("balance", String.valueOf(e.balanceInr()), "needed", String.valueOf(e.neededInr())), ROUTE_WALLET);
    }

    @Async(AsyncConfig.AFTER_COMMIT)
    @TransactionalEventListener(fallbackExecution = true)
    void on(UserEvents.VerificationChanged e) {
        notifications.notify(e.userId(), NotificationTab.ACCOUNT,
                e.status() == VerificationStatus.VERIFIED ? "VERIFICATION_VERIFIED" : "VERIFICATION_NOT_VERIFIED",
                Map.of("reason", e.reason() == null ? "" : e.reason()), ROUTE_VERIFICATION);
    }

    @Async(AsyncConfig.AFTER_COMMIT)
    @TransactionalEventListener(fallbackExecution = true)
    void on(UserEvents.DocumentRejected e) {
        notifications.notify(e.userId(), NotificationTab.ACCOUNT, "DOCUMENT_REJECTED",
                Map.of("document", e.type(), "reason", e.reason() == null ? "" : e.reason()), ROUTE_VERIFICATION);
    }

    @Async(AsyncConfig.AFTER_COMMIT)
    @TransactionalEventListener(fallbackExecution = true)
    void on(UserEvents.DocumentExpiring e) {
        notifications.notify(e.userId(), NotificationTab.ACCOUNT, "DOCUMENT_EXPIRING",
                Map.of("document", e.type(), "days", String.valueOf(e.daysLeft())), ROUTE_VERIFICATION);
    }

    @Async(AsyncConfig.AFTER_COMMIT)
    @TransactionalEventListener(fallbackExecution = true)
    void on(UserEvents.DocumentExpired e) {
        notifications.notify(e.userId(), NotificationTab.ACCOUNT, "DOCUMENT_EXPIRED",
                Map.of("document", e.type()), ROUTE_VERIFICATION);
    }
}
