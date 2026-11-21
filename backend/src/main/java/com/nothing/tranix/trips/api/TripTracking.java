package com.nothing.tranix.trips.api;

import java.util.Map;
import java.util.UUID;

/** Live tracking for other modules (public link page, M12): {driverLocation{lat,lng,at}, etaAt, routeStatus}. */
public interface TripTracking {

    Map<String, Object> trackingOf(UUID loadId);
}
