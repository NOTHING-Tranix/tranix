package com.nothing.tranix.shared.integrations.real;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.YearMonth;
import java.time.ZoneOffset;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

import com.nothing.tranix.shared.geo.GeoPoint;
import com.nothing.tranix.shared.integrations.MapsService;
import com.nothing.tranix.shared.integrations.fake.FakeMapsService;
import com.nothing.tranix.shared.settings.Settings;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import tools.jackson.databind.JsonNode;

/**
 * B-1304 (Q-05): Google Routes API (truck-friendly driving route, traffic-unaware to keep the cost low) with a
 * 24 h cache on ~100 m rounded points and a monthly call budget (setting {@code maps.monthly_route_calls}); over
 * budget or on errors it falls back to the straight-line estimate. Area labels stay address-based (no geocoding
 * spend). Enabled with {@code tranix.integrations.maps=google}.
 */
@Component
@ConditionalOnProperty(name = "tranix.integrations.maps", havingValue = "google")
public class GoogleMapsService implements MapsService {

    private static final Logger log = LoggerFactory.getLogger(GoogleMapsService.class);
    static final Duration CACHE_TTL = Duration.ofHours(24);

    private record Cached(RouteEstimate estimate, Instant at) {
    }

    private final RestClient http;
    private final Settings settings;
    private final Clock clock;
    private final FakeMapsService fallback = new FakeMapsService();
    private final Map<String, Cached> cache = new ConcurrentHashMap<>();
    private final AtomicInteger callsThisMonth = new AtomicInteger();
    private volatile YearMonth month;

    public GoogleMapsService(RestClient.Builder builder, Settings settings, Clock clock,
                             @Value("${tranix.google.routes-url:https://routes.googleapis.com}") String baseUrl,
                             @Value("${tranix.google.maps-api-key}") String apiKey) {
        this.http = builder.baseUrl(baseUrl).defaultHeader("X-Goog-Api-Key", apiKey)
                .defaultHeader("X-Goog-FieldMask", "routes.distanceMeters,routes.duration").build();
        this.settings = settings;
        this.clock = clock;
        this.month = YearMonth.now(clock.withZone(ZoneOffset.UTC));
    }

    @Override
    public RouteEstimate route(GeoPoint from, GeoPoint to) {
        String key = String.format("%.3f,%.3f>%.3f,%.3f", from.lat(), from.lng(), to.lat(), to.lng());
        Instant now = Instant.now(clock);
        Cached hit = cache.get(key);
        if (hit != null && hit.at().plus(CACHE_TTL).isAfter(now)) {
            return hit.estimate();
        }
        if (!withinBudget()) {
            return fallback.route(from, to);
        }
        try {
            JsonNode res = http.post().uri("/directions/v2:computeRoutes").contentType(MediaType.APPLICATION_JSON)
                    .body(Map.of("origin", waypoint(from), "destination", waypoint(to), "travelMode", "DRIVE",
                            "routingPreference", "TRAFFIC_UNAWARE", "units", "METRIC"))
                    .retrieve().body(JsonNode.class);
            JsonNode route = res == null ? null : res.path("routes").path(0);
            if (route == null || route.isMissingNode() || !route.has("distanceMeters")) {
                return fallback.route(from, to);
            }
            double km = Math.round(route.path("distanceMeters").asDouble() / 100.0) / 10.0;
            long seconds = Long.parseLong(route.path("duration").asString("0s").replace("s", ""));
            RouteEstimate estimate = new RouteEstimate(km, (int) Math.ceil(seconds / 60.0));
            cache.put(key, new Cached(estimate, now));
            return estimate;
        } catch (RuntimeException e) {
            log.warn("[maps] route failed ({}), using the straight-line estimate", e.getClass().getSimpleName());
            return fallback.route(from, to);
        }
    }

    @Override
    public String area(GeoPoint point, String address) {
        return fallback.area(point, address);
    }

    private boolean withinBudget() {
        YearMonth now = YearMonth.now(clock.withZone(ZoneOffset.UTC));
        if (!now.equals(month)) {
            month = now;
            callsThisMonth.set(0);
        }
        return callsThisMonth.incrementAndGet() <= settings.getInt("maps.monthly_route_calls");
    }

    private static Map<String, Object> waypoint(GeoPoint p) {
        return Map.of("location", Map.of("latLng", Map.of("latitude", p.lat(), "longitude", p.lng())));
    }
}
