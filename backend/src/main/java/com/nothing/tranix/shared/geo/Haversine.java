package com.nothing.tranix.shared.geo;

/** Great-circle distance (D-18: Haversine, no PostGIS). */
public final class Haversine {

    /** Mean Earth radius in metres. */
    public static final double EARTH_RADIUS_M = 6_371_008.8;

    private Haversine() {
    }

    public static double distanceMeters(GeoPoint a, GeoPoint b) {
        double lat1 = Math.toRadians(a.lat());
        double lat2 = Math.toRadians(b.lat());
        double dLat = lat2 - lat1;
        double dLng = Math.toRadians(b.lng() - a.lng());
        double h = Math.pow(Math.sin(dLat / 2), 2)
                + Math.cos(lat1) * Math.cos(lat2) * Math.pow(Math.sin(dLng / 2), 2);
        return 2 * EARTH_RADIUS_M * Math.asin(Math.min(1.0, Math.sqrt(h)));
    }

    public static double distanceKm(GeoPoint a, GeoPoint b) {
        return distanceMeters(a, b) / 1000.0;
    }

    /**
     * Bounding box around {@code center} that contains every point within {@code radiusKm}; use as a cheap SQL
     * pre-filter before the exact Haversine check.
     */
    public static BoundingBox boundingBox(GeoPoint center, double radiusKm) {
        double latDelta = Math.toDegrees(radiusKm * 1000 / EARTH_RADIUS_M);
        double cosLat = Math.cos(Math.toRadians(center.lat()));
        double lngDelta = cosLat < 1e-9 ? 180 : Math.min(180, latDelta / cosLat);
        return new BoundingBox(
                Math.max(-90, center.lat() - latDelta), Math.min(90, center.lat() + latDelta),
                Math.max(-180, center.lng() - lngDelta), Math.min(180, center.lng() + lngDelta));
    }

    public record BoundingBox(double minLat, double maxLat, double minLng, double maxLng) {
        public boolean contains(GeoPoint p) {
            return p.lat() >= minLat && p.lat() <= maxLat && p.lng() >= minLng && p.lng() <= maxLng;
        }
    }
}
