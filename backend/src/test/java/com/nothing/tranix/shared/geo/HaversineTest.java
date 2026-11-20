package com.nothing.tranix.shared.geo;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.Assertions.within;

import org.junit.jupiter.api.Test;

class HaversineTest {

    static final GeoPoint CHENNAI = GeoPoint.of(13.0827, 80.2707);
    static final GeoPoint MADURAI = GeoPoint.of(9.9252, 78.1198);

    @Test
    void samePointIsZero() {
        assertThat(Haversine.distanceMeters(CHENNAI, CHENNAI)).isZero();
    }

    @Test
    void chennaiToMaduraiIsAbout420Km() {
        assertThat(Haversine.distanceKm(CHENNAI, MADURAI)).isCloseTo(421.0, within(3.0));
    }

    @Test
    void isSymmetric() {
        assertThat(Haversine.distanceMeters(CHENNAI, MADURAI))
                .isCloseTo(Haversine.distanceMeters(MADURAI, CHENNAI), within(1e-6));
    }

    @Test
    void shortDistanceAroundGeofence() {
        // 0.0045° of latitude ≈ 500 m
        GeoPoint near = GeoPoint.of(CHENNAI.lat() + 0.0045, CHENNAI.lng());
        assertThat(Haversine.distanceMeters(CHENNAI, near)).isCloseTo(500.4, within(1.0));
    }

    @Test
    void boundingBoxContainsPointsInsideRadius() {
        Haversine.BoundingBox box = Haversine.boundingBox(CHENNAI, 25);
        assertThat(box.contains(GeoPoint.of(13.25, 80.27))).isTrue();   // ~18.6 km north
        assertThat(box.contains(GeoPoint.of(13.40, 80.27))).isFalse();  // ~35 km north
    }

    @Test
    void rejectsOutOfRangeCoordinates() {
        assertThatThrownBy(() -> GeoPoint.of(91, 0)).isInstanceOf(IllegalArgumentException.class);
        assertThatThrownBy(() -> GeoPoint.of(0, 181)).isInstanceOf(IllegalArgumentException.class);
    }
}
