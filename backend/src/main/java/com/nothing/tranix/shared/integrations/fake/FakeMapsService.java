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

    /** Fake: the last two comma-separated parts of the address (e.g. "Oddanchatram, Dindigul"). */
    @Override
    public String area(GeoPoint point, String address) {
        String[] parts = address == null ? new String[0] : address.split(",");
        java.util.List<String> clean = java.util.Arrays.stream(parts).map(String::trim).filter(s -> !s.isEmpty() && !s.matches("[0-9]{6}")).toList();
        if (clean.isEmpty()) {
            return String.format("%.2f, %.2f", point.lat(), point.lng());
        }
        return String.join(", ", clean.subList(Math.max(0, clean.size() - 2), clean.size()));
    }
}
