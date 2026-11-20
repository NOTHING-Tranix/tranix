package com.nothing.tranix.shared.integrations;

import com.nothing.tranix.shared.geo.GeoPoint;

/** Road distance and drive time (real provider: Q-05). */
public interface MapsService {

    RouteEstimate route(GeoPoint from, GeoPoint to);

    record RouteEstimate(double distanceKm, int driveMinutes) {
    }
}
