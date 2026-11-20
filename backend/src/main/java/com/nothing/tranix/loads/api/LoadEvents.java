package com.nothing.tranix.loads.api;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.shared.types.LoadStatus;
import com.nothing.tranix.shared.types.Role;

/** Events published by loads, and the hook other modules use to add fields to {@code LoadDetail}. */
public final class LoadEvents {

    private LoadEvents() {
    }

    public record LoadPosted(UUID loadId, UUID shipperId) {
    }

    public record LoadUpdated(UUID loadId) {
    }

    public record StatusChanged(UUID loadId, LoadStatus from, LoadStatus to, UUID actorId) {
    }

    /** {@code penaltyPoints} is negative when the canceller loses Trust Score (§11). */
    public record LoadCancelled(UUID loadId, UUID byUserId, Role byRole, LoadStatus stage, String reason,
                                boolean chargesKept, BigDecimal penaltyPoints, UUID shipperId, UUID driverId) {
    }

    /** Implemented by trips, payments, matching… to add their parts of {@code LoadDetail}. */
    public interface DetailContributor {
        void contribute(LoadDirectory.LoadInfo load, LoadDirectory.Viewer viewer, Map<String, Object> detail);
    }
}
