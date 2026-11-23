package com.nothing.tranix.shared.integrations.real;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

import com.nothing.tranix.shared.geo.GeoPoint;
import com.nothing.tranix.shared.integrations.Geocoder;
import com.nothing.tranix.shared.integrations.MapsService;
import com.nothing.tranix.shared.integrations.fake.FakeMapsService;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import tools.jackson.databind.JsonNode;

/**
 * Free routing (dev/testing): OSRM driving routes — default the public demo server, which allows light use only;
 * point {@code tranix.osrm.base-url} at your own OSRM for production traffic. 24 h cache on ~100 m rounded points,
 * straight-line fallback on any error. Enabled with {@code tranix.integrations.maps=osrm}.
 */
@Component
@ConditionalOnProperty(name = "tranix.integrations.maps", havingValue = "osrm")
class OsrmMapsService implements MapsService {

    private static final Logger log = LoggerFactory.getLogger(OsrmMapsService.class);

    private record Cached(RouteEstimate estimate, Instant at) {
    }

    private final RestClient http;
    private final Clock clock;
    private final FakeMapsService fallback = new FakeMapsService();
    private final Map<String, Cached> cache = new ConcurrentHashMap<>();

    OsrmMapsService(RestClient.Builder builder, Clock clock, @Value("${tranix.osrm.base-url:https://router.project-osrm.org}") String baseUrl) {
        this.http = builder.baseUrl(baseUrl).defaultHeader("User-Agent", "Tranix/1.0 (dev)").build();
        this.clock = clock;
    }

    @Override
    public RouteEstimate route(GeoPoint from, GeoPoint to) {
        String key = String.format(Locale.ROOT, "%.3f,%.3f;%.3f,%.3f", from.lng(), from.lat(), to.lng(), to.lat());
        Instant now = Instant.now(clock);
        Cached hit = cache.get(key);
        if (hit != null && hit.at().plus(Duration.ofHours(24)).isAfter(now)) {
            return hit.estimate();
        }
        try {
            JsonNode res = http.get().uri("/route/v1/driving/{c}?overview=false", key).retrieve().body(JsonNode.class);
            JsonNode route = res == null ? null : res.path("routes").path(0);
            if (route == null || !route.has("distance")) {
                return fallback.route(from, to);
            }
            RouteEstimate e = new RouteEstimate(Math.round(route.path("distance").asDouble() / 100.0) / 10.0,
                    (int) Math.ceil(route.path("duration").asDouble() / 60.0));
            cache.put(key, new Cached(e, now));
            return e;
        } catch (RuntimeException e) {
            log.warn("[osrm] route failed ({}), using the straight-line estimate", e.getClass().getSimpleName());
            return fallback.route(from, to);
        }
    }

    @Override
    public String area(GeoPoint point, String address) {
        return fallback.area(point, address);
    }
}

/**
 * Free geocoding (dev/testing): OpenStreetMap Nominatim, limited to India. Its usage policy allows at most 1 request
 * per second with an identifying User-Agent, so calls are spaced and cached. Enabled with
 * {@code tranix.integrations.geocoding=nominatim}.
 */
@Component
@ConditionalOnProperty(name = "tranix.integrations.geocoding", havingValue = "nominatim")
class NominatimGeocoder implements Geocoder {

    private static final Logger log = LoggerFactory.getLogger(NominatimGeocoder.class);

    private final RestClient http;
    private final Map<String, List<Hit>> searchCache = new ConcurrentHashMap<>();
    private final Map<String, String> reverseCache = new ConcurrentHashMap<>();
    private long lastCall;

    NominatimGeocoder(RestClient.Builder builder, @Value("${tranix.nominatim.base-url:https://nominatim.openstreetmap.org}") String baseUrl) {
        this.http = builder.baseUrl(baseUrl).defaultHeader("User-Agent", "Tranix/1.0 (dev testing)").build();
    }

    @Override
    public List<Hit> search(String query) {
        String q = query.trim().toLowerCase(Locale.ROOT);
        if (q.length() < 3) {
            return List.of();
        }
        return searchCache.computeIfAbsent(q, k -> {
            try {
                pace();
                JsonNode res = http.get().uri(u -> u.path("/search").queryParam("q", k).queryParam("format", "jsonv2")
                        .queryParam("countrycodes", "in").queryParam("limit", 8).build()).retrieve().body(JsonNode.class);
                List<Hit> out = new ArrayList<>();
                if (res != null) {
                    for (JsonNode n : res) {
                        out.add(new Hit(n.path("display_name").asString(""), n.path("lat").asDouble(), n.path("lon").asDouble()));
                    }
                }
                return out;
            } catch (RuntimeException e) {
                log.warn("[nominatim] search failed: {}", e.getClass().getSimpleName());
                return List.of();
            }
        });
    }

    @Override
    public Optional<String> reverse(GeoPoint p) {
        String key = String.format(Locale.ROOT, "%.4f,%.4f", p.lat(), p.lng());
        String cached = reverseCache.get(key);
        if (cached != null) {
            return Optional.of(cached);
        }
        try {
            pace();
            JsonNode res = http.get().uri(u -> u.path("/reverse").queryParam("lat", p.lat()).queryParam("lon", p.lng())
                    .queryParam("format", "jsonv2").queryParam("zoom", 18).build()).retrieve().body(JsonNode.class);
            String name = res == null ? "" : res.path("display_name").asString("");
            if (name.isEmpty()) {
                return Optional.empty();
            }
            reverseCache.put(key, name);
            return Optional.of(name);
        } catch (RuntimeException e) {
            log.warn("[nominatim] reverse failed: {}", e.getClass().getSimpleName());
            return Optional.empty();
        }
    }

    /** Nominatim policy: max 1 request/second. */
    private synchronized void pace() {
        long wait = lastCall + 1100 - System.currentTimeMillis();
        if (wait > 0) {
            try {
                Thread.sleep(wait);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
        lastCall = System.currentTimeMillis();
    }
}
