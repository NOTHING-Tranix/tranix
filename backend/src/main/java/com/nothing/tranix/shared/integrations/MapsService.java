package com.nothing.tranix.shared.integrations;

import com.nothing.tranix.shared.geo.GeoPoint;

/** Road distance and drive time (real provider: Q-05). */
public interface MapsService {

    RouteEstimate route(GeoPoint from, GeoPoint to);

    /** Area/district label shown before acceptance (never the exact address). */
    String area(GeoPoint point, String address);

    record RouteEstimate(double distanceKm, int driveMinutes) {
    }
}
