package com.nothing.tranix.loads.api;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import com.nothing.tranix.shared.types.LoadAudience;

/** Checks owned by other modules, called while posting (loads does not depend on them). */
public final class PostingHooks {

    private PostingHooks() {
    }

    /** Implemented by matching (wish list, M9). Returns the entry ids to use and the window end. */
    public interface AudienceValidator {
        Audience resolve(UUID shipperId, LoadAudience audience, List<UUID> requestedEntryIds, Instant postedAt);
    }

    public record Audience(List<UUID> entryIds, Instant wishlistUntil) {
    }

    /** Implemented by farmers (M10): the farmer must belong to this Farmer Network and be active. */
    public interface FarmerValidator {
        FarmerSender sender(UUID networkId, UUID farmerId);
    }

    public record FarmerSender(String name, String mobile) {
    }
}
