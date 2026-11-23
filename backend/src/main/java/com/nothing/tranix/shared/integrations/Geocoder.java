package com.nothing.tranix.shared.integrations;

import java.util.List;
import java.util.Optional;

import com.nothing.tranix.shared.geo.GeoPoint;

/** Address search and pin → address for the location picker (`GET /map/geocode`, `GET /map/reverse`). */
public interface Geocoder {

    /** Up to 8 places in India matching the text. */
    List<Hit> search(String query);

    /** A readable address for a point, if the provider knows one. */
    Optional<String> reverse(GeoPoint point);

    record Hit(String name, double lat, double lng) {
    }
}
