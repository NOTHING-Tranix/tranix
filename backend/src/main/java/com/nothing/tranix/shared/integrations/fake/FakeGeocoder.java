package com.nothing.tranix.shared.integrations.fake;

import java.util.List;
import java.util.Locale;
import java.util.Optional;

import com.nothing.tranix.shared.geo.GeoPoint;
import com.nothing.tranix.shared.integrations.Geocoder;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/** Offline geocoder for tests: a few known market towns; reverse gives the coordinates as text. */
@Component
@ConditionalOnProperty(name = "tranix.integrations.geocoding", havingValue = "fake", matchIfMissing = true)
public class FakeGeocoder implements Geocoder {

    private static final List<Hit> PLACES = List.of(
            new Hit("Oddanchatram Vegetable Market, Dindigul, Tamil Nadu", 10.4870, 77.7500),
            new Hit("Koyambedu Market, Chennai, Tamil Nadu", 13.0694, 80.1948),
            new Hit("Gandhi Market, Tiruchirappalli, Tamil Nadu", 10.8050, 78.6936));

    @Override
    public List<Hit> search(String query) {
        String q = query.toLowerCase(Locale.ROOT);
        return PLACES.stream().filter(h -> h.name().toLowerCase(Locale.ROOT).contains(q)).toList();
    }

    @Override
    public Optional<String> reverse(GeoPoint point) {
        return Optional.of(String.format(Locale.ROOT, "Near %.4f, %.4f", point.lat(), point.lng()));
    }
}
