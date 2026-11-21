package com.nothing.tranix.trips.internal;

import java.util.List;
import java.util.Map;

import com.nothing.tranix.shared.geo.GeoPoint;
import com.nothing.tranix.shared.geo.Haversine;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** B-710: route services and entry restrictions inside a bounding box (admin-entered data). */
@Service
public class MapLayerService {

    private final JdbcTemplate jdbc;

    MapLayerService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    record Box(double minLat, double minLng, double maxLat, double maxLng) {
        static Box parse(String bbox) {
            String[] p = bbox == null ? new String[0] : bbox.split(",");
            if (p.length != 4) {
                throw com.nothing.tranix.shared.error.ApiException.invalidField("bbox", "Use minLng,minLat,maxLng,maxLat");
            }
            try {
                double minLng = Double.parseDouble(p[0]);
                double minLat = Double.parseDouble(p[1]);
                double maxLng = Double.parseDouble(p[2]);
                double maxLat = Double.parseDouble(p[3]);
                if (maxLat - minLat > 5 || maxLng - minLng > 5) {
                    throw com.nothing.tranix.shared.error.ApiException.invalidField("bbox", "Area too large");
                }
                return new Box(minLat, minLng, maxLat, maxLng);
            } catch (NumberFormatException e) {
                throw com.nothing.tranix.shared.error.ApiException.invalidField("bbox", "Use minLng,minLat,maxLng,maxLat");
            }
        }
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> services(String bbox, List<String> types) {
        Box b = Box.parse(bbox);
        List<String> kinds = types == null || types.isEmpty() ? List.of("PETROL", "WEIGHBRIDGE", "PUNCTURE", "TOLL") : types;
        return jdbc.queryForList("select id, kind as type, name, lat, lng from admin_map_point where active and lat between ? and ? and lng between ? and ?",
                b.minLat(), b.maxLat(), b.minLng(), b.maxLng()).stream()
                .filter(m -> kinds.contains(String.valueOf(m.get("type")))).toList();
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> restrictions(String bbox) {
        Box b = Box.parse(bbox);
        GeoPoint centre = GeoPoint.of((b.minLat() + b.maxLat()) / 2, (b.minLng() + b.maxLng()) / 2);
        double halfDiagonalKm = Haversine.distanceKm(centre, GeoPoint.of(b.maxLat(), b.maxLng()));
        return jdbc.queryForList("""
                select id, name, lat, lng, radius_km as "radiusKm", no_entry_from as "noEntryFrom", no_entry_to as "noEntryTo",
                vehicle_types as "vehicleTypes", note from admin_map_restriction where active""").stream()
                .filter(r -> Haversine.distanceKm(centre, GeoPoint.of(((Number) r.get("lat")).doubleValue(), ((Number) r.get("lng")).doubleValue()))
                        <= halfDiagonalKm + ((Number) r.get("radiusKm")).doubleValue())
                .map(r -> {
                    Map<String, Object> m = new java.util.LinkedHashMap<>(r);
                    m.put("noEntryFrom", r.get("noEntryFrom") == null ? null : r.get("noEntryFrom").toString());
                    m.put("noEntryTo", r.get("noEntryTo") == null ? null : r.get("noEntryTo").toString());
                    return m;
                }).toList();
    }
}
