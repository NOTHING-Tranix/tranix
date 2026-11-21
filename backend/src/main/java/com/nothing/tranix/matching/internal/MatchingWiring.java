package com.nothing.tranix.matching.internal;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.fleet.api.DriverHomeContributor;
import com.nothing.tranix.fleet.api.FleetApi;
import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.loads.api.LoadEvents;
import com.nothing.tranix.shared.files.FileService;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionalEventListener;

/** Starts/stops matching on load events (after commit). */
@Component
class MatchingListeners {

    private final MatchingService matching;

    MatchingListeners(MatchingService matching) {
        this.matching = matching;
    }

    @TransactionalEventListener(fallbackExecution = true)
    void on(LoadEvents.LoadPosted e) {
        matching.start(e.loadId());
    }

    @TransactionalEventListener(fallbackExecution = true)
    void on(LoadEvents.LoadUpdated e) {
        matching.restart(e.loadId());
    }

    @TransactionalEventListener(fallbackExecution = true)
    void on(LoadEvents.LoadCancelled e) {
        matching.stop(e.loadId(), "EXPIRED");
    }
}

/** B-603: batch timer on the server (hard rule 10). */
@Component
@ConditionalOnProperty(name = "tranix.jobs.enabled", havingValue = "true", matchIfMissing = true)
class MatchingJob {

    private final MatchingService matching;

    MatchingJob(MatchingService matching) {
        this.matching = matching;
    }

    @Scheduled(fixedDelayString = "${tranix.jobs.matching-delay:60000}", initialDelay = 30_000)
    void run() {
        matching.runDueBatches();
    }
}

/** suggestionsCount on driver home. */
@Component
class SuggestionsCountContributor implements DriverHomeContributor {

    private final MatchingService matching;

    SuggestionsCountContributor(MatchingService matching) {
        this.matching = matching;
    }

    @Override
    public void contribute(UUID driverId, Map<String, Object> home) {
        home.put("suggestionsCount", matching.shownCount(driverId));
    }
}

/** The {@code driver} block of LoadDetail — only after acceptance (hard rule 7). */
@Component
class DriverBlockContributor implements LoadEvents.DetailContributor {

    private final UserDirectory users;
    private final FleetApi fleet;
    private final FileService files;

    DriverBlockContributor(UserDirectory users, FleetApi fleet, FileService files) {
        this.users = users;
        this.fleet = fleet;
        this.files = files;
    }

    @Override
    public void contribute(LoadDirectory.LoadInfo load, LoadDirectory.Viewer viewer, Map<String, Object> detail) {
        if (load.driverId() == null || !detail.containsKey("driver")) {
            return;
        }
        users.find(load.driverId()).ifPresent(d -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", d.id());
            m.put("name", d.name());
            m.put("photoUrl", d.photoFileId() == null ? null : files.viewUrl(d.photoFileId()));
            m.put("mobile", d.mobile());
            m.put("trustScore", d.trustScore());
            fleet.truck(load.truckId()).ifPresent(t -> {
                m.put("truckNumber", t.number());
                m.put("vehicleType", t.vehicleType());
            });
            detail.put("driver", m);
        });
    }
}

/** B-654: wish-list windows run on the server every minute (hard rule 13). */
@Component
@ConditionalOnProperty(name = "tranix.jobs.enabled", havingValue = "true", matchIfMissing = true)
class WishlistJob {

    private final WishlistService wishlist;

    WishlistJob(WishlistService wishlist) {
        this.wishlist = wishlist;
    }

    @Scheduled(fixedDelayString = "${tranix.jobs.matching-delay:60000}", initialDelay = 45_000)
    void run() {
        wishlist.runWindows();
    }
}
