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
    /**
     * B-1607: the area a driver sees before accepting (hard rule 7: area/district only). Built from the address the
     * shipper typed, so it must never contain street-level text: parts with digits (door numbers, PIN) are dropped, and
     * the first part (usually the street or building) is never used. From what is left: the last two parts (e.g.
     * town, district); with nothing left only a rough position (~10 km).
     */
    public String area(GeoPoint point, String address) {
        String[] parts = address == null ? new String[0] : address.split(",");
        java.util.List<String> all = java.util.Arrays.stream(parts).map(String::trim).filter(s -> !s.isEmpty()).toList();
        java.util.List<String> named = all.stream().skip(1).filter(s -> !s.matches(".*[0-9].*")).toList();
        if (!named.isEmpty()) {
            return String.join(", ", named.subList(Math.max(0, named.size() - 2), named.size()));
        }
        return String.format(java.util.Locale.ROOT, "Near %.1f, %.1f", point.lat(), point.lng());
    }
}
