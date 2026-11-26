package com.nothing.tranix.trust.internal;

import com.nothing.tranix.shared.config.AsyncConfig;
import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.loads.api.LoadEvents;
import com.nothing.tranix.payments.api.PaymentEvents;
import com.nothing.tranix.shared.types.LoadStatus;
import com.nothing.tranix.shared.types.Role;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.scheduling.annotation.Async;
import org.springframework.transaction.event.TransactionalEventListener;

/** Trust events from trips, cancellations and payments (§12 points table). Runs after commit. */
@Component
class TrustListeners {

    private final TrustService trust;
    private final LoadDirectory loads;

    TrustListeners(TrustService trust, LoadDirectory loads) {
        this.trust = trust;
        this.loads = loads;
    }

    @Async(AsyncConfig.AFTER_COMMIT)
    @TransactionalEventListener(fallbackExecution = true)
    void on(LoadEvents.StatusChanged e) {
        if (e.to() == LoadStatus.DELIVERED) {
            trust.onDelivered(e.loadId());
        } else if (e.to() == LoadStatus.PICKED_UP) {
            trust.onPickedUp(e.loadId());
        }
    }

    @Async(AsyncConfig.AFTER_COMMIT)
    @TransactionalEventListener(fallbackExecution = true)
    void on(LoadEvents.LoadCancelled e) {
        if (e.penaltyPoints() != null && e.penaltyPoints().signum() < 0) {
            String code = loads.find(e.loadId()).map(LoadDirectory.LoadInfo::code).orElse("");
            trust.record(e.byUserId(), e.loadId(), "CANCELLED_OWN_FAULT", e.penaltyPoints(),
                    "Cancelled after acceptance: " + code + " (" + e.reason() + ")", null);
            if (e.byRole() == Role.DRIVER) {
                // Organization drivers' cancellations also count for the Org (D-29)
                loads.find(e.loadId()).map(LoadDirectory.LoadInfo::orgId).ifPresent(org -> trust.record(org, e.loadId(),
                        "DRIVER_CANCELLED", e.penaltyPoints(), "Driver cancelled after acceptance: " + code, null));
            }
        }
    }

    @Async(AsyncConfig.AFTER_COMMIT)
    @TransactionalEventListener(fallbackExecution = true)
    void on(PaymentEvents.PaymentConfirmed e) {
        if (e.onTime() && e.payerUserId() != null) {
            trust.record(e.payerUserId(), e.loadId(), "PAYMENT_ON_TIME", trust.points("shipper.payment_on_time"),
                    "Payment confirmed on time", null);
        }
    }

    @Async(AsyncConfig.AFTER_COMMIT)
    @TransactionalEventListener(fallbackExecution = true)
    void on(PaymentEvents.DisputeDecided e) {
        if (e.againstUserId() != null) {
            trust.record(e.againstUserId(), e.loadId(), "DISPUTE_LOST", trust.points("dispute_lost"),
                    "Payment dispute decided against you", null);
        }
    }
}

@Component
@ConditionalOnProperty(name = "tranix.jobs.enabled", havingValue = "true", matchIfMissing = true)
class TrustJobs {

    private final TrustService trust;

    TrustJobs(TrustService trust) {
        this.trust = trust;
    }

    @Scheduled(fixedDelay = 3_600_000, initialDelay = 60_000)
    void ratingReminders() {
        trust.remindPendingRatings();
    }
}
