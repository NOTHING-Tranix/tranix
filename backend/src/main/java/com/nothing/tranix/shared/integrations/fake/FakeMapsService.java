package com.nothing.tranix.shared.integrations.fake;

import com.nothing.tranix.shared.geo.GeoPoint;
import com.nothing.tranix.shared.geo.Haversine;
import com.nothing.tranix.shared.integrations.MapsService;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/** Q-05 default: road distance = straight line × 1.3, driven at 40 km/h. */
@Component
@ConditionalOnProperty(name = "tranix.integrations.maps", havingValue = "fake", matchIfMissing = true)
public class FakeMapsService implements MapsService {

    static final double ROAD_FACTOR = 1.3;
    static final double SPEED_KMH = 40.0;

    @Override
    public RouteEstimate route(GeoPoint from, GeoPoint to) {
        double km = Haversine.distanceKm(from, to) * ROAD_FACTOR;
        double rounded = Math.round(km * 10) / 10.0;
        int minutes = (int) Math.ceil(km / SPEED_KMH * 60);
        return new RouteEstimate(rounded, minutes);
    }
}
