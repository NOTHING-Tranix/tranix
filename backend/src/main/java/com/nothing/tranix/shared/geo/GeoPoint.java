package com.nothing.tranix.shared.geo;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

/** A WGS-84 coordinate, serialised as {@code {"lat": 10.95, "lng": 78.08}}. */
public record GeoPoint(
        @NotNull @DecimalMin("-90.0") @DecimalMax("90.0") Double lat,
        @NotNull @DecimalMin("-180.0") @DecimalMax("180.0") Double lng) {

    /** Range is checked by Bean Validation on request bodies ({@code @Valid}); this factory checks it for code. */
    public static GeoPoint of(double lat, double lng) {
        if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
            throw new IllegalArgumentException("Coordinate out of range");
        }
        return new GeoPoint(lat, lng);
    }
}
