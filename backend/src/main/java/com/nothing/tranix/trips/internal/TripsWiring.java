package com.nothing.tranix.trips.internal;

import java.util.List;
import java.util.Map;

import com.nothing.tranix.shared.config.AsyncConfig;
import com.nothing.tranix.engagement.api.Notifier;
import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.loads.api.LoadEvents;
import com.nothing.tranix.shared.types.NotificationTab;
import com.nothing.tranix.shared.types.Role;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.scheduling.annotation.Async;
import org.springframework.transaction.event.TransactionalEventListener;

/** Adds revisions, OTP events and location exceptions to LoadDetail (all viewers that see the detail). */
@Component
class TripDetailContributor implements LoadEvents.DetailContributor {

    private final TripService trips;

    TripDetailContributor(TripService trips) {
        this.trips = trips;
    }

    @Override
    public void contribute(LoadDirectory.LoadInfo load, LoadDirectory.Viewer viewer, Map<String, Object> detail) {
        if (!detail.containsKey("revisions")) {
            return; // summary, not detail
        }
        List<Map<String, Object>> revisions = trips.revisions(load.id());
        detail.put("revisions", revisions);
        detail.put("revisionsUsed", revisions.size());
        detail.put("otpEvents", trips.otpEvents(load.id()));
        detail.put("locationExceptions", trips.locationExceptions(load.id()));
    }
}

/** Server timers (hard rule 10): revision expiry every minute, location purge nightly. */
@Component
@ConditionalOnProperty(name = "tranix.jobs.enabled", havingValue = "true", matchIfMissing = true)
class TripJobs {

    private final TripService trips;

    TripJobs(TripService trips) {
        this.trips = trips;
    }

    @Scheduled(fixedDelay = 60_000, initialDelay = 20_000)
    void expireRevisions() {
        trips.expireRevisions();
    }

    @Scheduled(cron = "0 15 2 * * *", zone = "Asia/Kolkata")
    void purge() {
        trips.purgeOldLocations();
    }
}

/** Tells the other party when a trip is cancelled after acceptance. */
@Component
class TripCancelListener {

    private final Notifier notifier;
    private final LoadDirectory loads;

    TripCancelListener(Notifier notifier, LoadDirectory loads) {
        this.notifier = notifier;
        this.loads = loads;
    }

    @Async(AsyncConfig.AFTER_COMMIT)
    @TransactionalEventListener(fallbackExecution = true)
    void on(LoadEvents.LoadCancelled e) {
        if (e.driverId() == null) {
            return;
        }
        String code = loads.find(e.loadId()).map(LoadDirectory.LoadInfo::code).orElse("");
        if (e.byRole() == Role.DRIVER) {
            notifier.notify(e.shipperId(), NotificationTab.TRIPS, "CANCELLED_BY_DRIVER", Map.of("code", code), "/loads/" + e.loadId());
        } else {
            notifier.notify(e.driverId(), NotificationTab.TRIPS, "CANCELLED_BY_SHIPPER", Map.of("code", code), "/driver");
        }
    }
}

