package com.nothing.tranix.matching.internal;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import com.nothing.tranix.engagement.api.Notifier;
import com.nothing.tranix.fleet.api.FleetApi;
import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.loads.api.PostingHooks;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.settings.SettingKeys;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.shared.types.LoadAudience;
import com.nothing.tranix.shared.types.NotificationTab;
import com.nothing.tranix.shared.types.Role;
import com.nothing.tranix.shared.types.VerificationStatus;

import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * B-651…B-655: wish list of preferred trucks and Organizations (D-19). Also the matching hooks: audience
 * restriction (WISHLIST_FIRST window / WISHLIST_ONLY), ranking bonus, relaxed radius — eligibility is never bypassed.
 */
@Service
@Order(0)
public class WishlistService implements PostingHooks.AudienceValidator, MatchingService.RankingBonus {

    enum Target { TRUCK, ORGANIZATION }

    record Entry(UUID id, UUID shipperId, Target targetType, UUID truckId, UUID orgId, String note, Instant createdAt) {
    }

    private final JdbcTemplate jdbc;
    private final LoadDirectory loads;
    private final FleetApi fleet;
    private final UserDirectory users;
    private final Settings settings;
    private final Notifier notifier;
    private final Clock clock;

    WishlistService(JdbcTemplate jdbc, LoadDirectory loads, FleetApi fleet, UserDirectory users, Settings settings,
                    Notifier notifier, Clock clock) {
        this.jdbc = jdbc;
        this.loads = loads;
        this.fleet = fleet;
        this.users = users;
        this.settings = settings;
        this.notifier = notifier;
        this.clock = clock;
    }

    // ------------------------------------------------------------------ CRUD (B-651)

    List<Entry> entries(UUID shipperId) {
        return jdbc.query("select * from matching_wishlist_entry where shipper_id = ? order by created_at desc",
                (rs, i) -> new Entry(rs.getObject("id", UUID.class), rs.getObject("shipper_id", UUID.class),
                        Target.valueOf(rs.getString("target_type")), rs.getObject("truck_id", UUID.class),
                        rs.getObject("org_id", UUID.class), rs.getString("note"), rs.getTimestamp("created_at").toInstant()),
                shipperId);
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> list(UUID shipperId) {
        requireShipper(shipperId);
        List<LoadDirectory.PastTrip> trips = loads.pastTripsOfShipper(shipperId);
        return entries(shipperId).stream().map(e -> view(e, trips)).toList();
    }

    @Transactional
    public Map<String, Object> add(UUID shipperId, String targetType, UUID truckId, UUID orgId, String note) {
        requireShipper(shipperId);
        Target type = parse(targetType);
        List<LoadDirectory.PastTrip> trips = loads.pastTripsOfShipper(shipperId);
        if (type == Target.TRUCK) {
            if (truckId == null) {
                throw ApiException.invalidField("truckId", "Choose a truck");
            }
            if (trips.stream().noneMatch(t -> truckId.equals(t.truckId()))) {
                throw new ApiException(ErrorCode.FORBIDDEN, "Only trucks from your own trips can be added");
            }
        } else {
            if (orgId == null) {
                throw ApiException.invalidField("orgId", "Choose an Organization");
            }
            UserDirectory.UserView org = users.find(orgId).filter(u -> u.role() == Role.ORGANIZATION)
                    .orElseThrow(() -> ApiException.notFound("Organization"));
            if (org.verificationStatus() != VerificationStatus.VERIFIED || org.suspended()) {
                throw new ApiException(ErrorCode.FORBIDDEN, "Only verified Organizations can be added");
            }
        }
        List<Entry> existing = entries(shipperId);
        Optional<Entry> same = existing.stream().filter(e -> e.targetType() == type
                && (type == Target.TRUCK ? truckId.equals(e.truckId()) : orgId.equals(e.orgId()))).findFirst();
        if (same.isPresent()) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Already in your wish list");
        }
        if (existing.size() >= settings.getInt(SettingKeys.WISHLIST_MAX_ENTRIES)) {
            throw new ApiException(ErrorCode.WISHLIST_FULL);
        }
        UUID id = UUID.randomUUID();
        Instant now = Instant.now(clock);
        jdbc.update("insert into matching_wishlist_entry (id, shipper_id, target_type, truck_id, org_id, note, created_at) values (?, ?, ?, ?, ?, ?, ?)",
                id, shipperId, type.name(), type == Target.TRUCK ? truckId : null, type == Target.ORGANIZATION ? orgId : null,
                blankToNull(note), Timestamp.from(now));
        return view(new Entry(id, shipperId, type, type == Target.TRUCK ? truckId : null, type == Target.ORGANIZATION ? orgId : null,
                blankToNull(note), now), trips);
    }

    @Transactional
    public Map<String, Object> updateNote(UUID shipperId, UUID entryId, String note) {
        if (jdbc.update("update matching_wishlist_entry set note = ? where id = ? and shipper_id = ?", blankToNull(note), entryId, shipperId) == 0) {
            throw ApiException.notFound("Wish-list entry");
        }
        Entry e = entries(shipperId).stream().filter(x -> x.id().equals(entryId)).findFirst().orElseThrow();
        return view(e, loads.pastTripsOfShipper(shipperId));
    }

    /** The truck owner / Organization is never told (D-19). */
    @Transactional
    public void remove(UUID shipperId, UUID entryId) {
        if (jdbc.update("delete from matching_wishlist_entry where id = ? and shipper_id = ?", entryId, shipperId) == 0) {
            throw ApiException.notFound("Wish-list entry");
        }
    }

    // ------------------------------------------------------------------ search + candidates (B-652)

    @Transactional(readOnly = true)
    public List<Map<String, Object>> orgSearch(UUID shipperId, String q) {
        requireShipper(shipperId);
        if (q == null || q.trim().length() < 2) {
            return List.of();
        }
        return users.searchOrganizations(q, 20).stream().map(o -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("orgId", o.orgId());
            m.put("orgName", o.orgName());
            m.put("orgCode", o.orgCode());
            m.put("district", o.district());
            m.put("trustScore", o.trustScore());
            m.put("trucksCount", fleet.activeTruckCount(o.orgId()));
            return m;
        }).toList();
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> candidates(UUID shipperId) {
        requireShipper(shipperId);
        List<Entry> existing = entries(shipperId);
        Set<UUID> listedTrucks = new HashSet<>();
        Set<UUID> listedOrgs = new HashSet<>();
        existing.forEach(e -> {
            if (e.truckId() != null) {
                listedTrucks.add(e.truckId());
            }
            if (e.orgId() != null) {
                listedOrgs.add(e.orgId());
            }
        });
        List<LoadDirectory.PastTrip> trips = loads.pastTripsOfShipper(shipperId);
        Map<UUID, Map<String, Object>> trucks = new LinkedHashMap<>();
        Map<UUID, Map<String, Object>> orgs = new LinkedHashMap<>();
        for (LoadDirectory.PastTrip t : trips) {
            if (!listedTrucks.contains(t.truckId()) && !trucks.containsKey(t.truckId())) {
                fleet.truck(t.truckId()).ifPresent(truck -> {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("targetType", Target.TRUCK);
                    m.put("truckId", truck.id());
                    m.put("truckNumber", truck.number());
                    m.put("vehicleType", truck.vehicleType());
                    m.put("driverName", users.find(t.driverId()).map(UserDirectory.UserView::name).orElse(null));
                    m.put("orgId", t.orgId());
                    m.put("orgName", t.orgId() == null ? null : orgName(t.orgId()));
                    m.put("tripsTogether", trips.stream().filter(x -> truck.id().equals(x.truckId())).count());
                    m.put("lastTripAt", t.at());
                    trucks.put(truck.id(), m);
                });
            }
            if (t.orgId() != null && !listedOrgs.contains(t.orgId()) && !orgs.containsKey(t.orgId())) {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("targetType", Target.ORGANIZATION);
                m.put("orgId", t.orgId());
                m.put("orgName", orgName(t.orgId()));
                m.put("tripsTogether", trips.stream().filter(x -> t.orgId().equals(x.orgId())).count());
                m.put("lastTripAt", t.at());
                orgs.put(t.orgId(), m);
            }
        }
        List<Map<String, Object>> out = new ArrayList<>(trucks.values());
        out.addAll(orgs.values());
        return out;
    }

    // ------------------------------------------------------------------ posting (B-653)

    @Override
    public PostingHooks.Audience resolve(UUID shipperId, LoadAudience audience, List<UUID> requestedEntryIds, Instant postedAt) {
        List<Entry> chosen = entries(shipperId);
        if (requestedEntryIds != null && !requestedEntryIds.isEmpty()) {
            Set<UUID> wanted = new HashSet<>(requestedEntryIds);
            chosen = chosen.stream().filter(e -> wanted.contains(e.id())).toList();
        }
        if (chosen.isEmpty() || driversOf(chosen).isEmpty()) {
            throw new ApiException(ErrorCode.WISHLIST_EMPTY);
        }
        Instant until = audience == LoadAudience.WISHLIST_FIRST
                ? postedAt.plus(Duration.ofMinutes(settings.getInt(SettingKeys.WISHLIST_FIRST_MINUTES))) : null;
        return new PostingHooks.Audience(chosen.stream().map(Entry::id).toList(), until);
    }

    // ------------------------------------------------------------------ matching hooks (B-654)

    @Override
    public Set<UUID> preferredDrivers(LoadDirectory.LoadInfo load) {
        List<Entry> all = entries(load.shipperId());
        if (load.audience() == LoadAudience.EVERYONE || load.wishlistEntryIds().isEmpty()) {
            return driversOf(all);
        }
        Set<UUID> ids = new HashSet<>(load.wishlistEntryIds());
        return driversOf(all.stream().filter(e -> ids.contains(e.id())).toList());
    }

    @Override
    public Set<UUID> restrictTo(LoadDirectory.LoadInfo load, Instant now) {
        boolean restricted = load.audience() == LoadAudience.WISHLIST_ONLY
                || (load.audience() == LoadAudience.WISHLIST_FIRST && load.wishlistUntil() != null && now.isBefore(load.wishlistUntil()));
        return restricted ? preferredDrivers(load) : null;
    }

    @Override
    public double bonus() {
        return settings.getDecimal("wishlist.ranking_bonus").doubleValue() / 100;
    }

    @Override
    public int relaxedRadiusKm() {
        return settings.getInt(SettingKeys.WISHLIST_RELAXED_RADIUS_KM);
    }

    Set<UUID> driversOf(List<Entry> entries) {
        Set<UUID> out = new HashSet<>();
        for (Entry e : entries) {
            out.addAll(e.targetType() == Target.TRUCK ? fleet.driversForTruck(e.truckId()) : fleet.driversOfOrg(e.orgId()));
        }
        return out;
    }

    /** Server job (hard rule 13): WISHLIST_FIRST window end → everyone; WISHLIST_ONLY → notify the shipper once. */
    public void runWindows() {
        Instant now = Instant.now(clock);
        int notifyMinutes = settings.getInt(SettingKeys.WISHLIST_ONLY_NOTIFY_MINUTES);
        for (LoadDirectory.LoadInfo l : loads.openWishlistLoads()) {
            if (l.audience() == LoadAudience.WISHLIST_FIRST && (l.wishlistUntil() == null || !now.isBefore(l.wishlistUntil()))) {
                loads.openToEveryone(l.id());
                notifier.notify(l.shipperId(), NotificationTab.TRIPS, "WISHLIST_OPENED", Map.of("code", l.code()), "/loads/" + l.id());
            } else if (l.audience() == LoadAudience.WISHLIST_ONLY && !now.isBefore(l.createdAt().plus(Duration.ofMinutes(notifyMinutes)))) {
                int n = jdbc.update("update matching_load_state set wishlist_notified = true where load_id = ? and not wishlist_notified", l.id());
                if (n > 0) {
                    notifier.notify(l.shipperId(), NotificationTab.TRIPS, "WISHLIST_NO_RESPONSE", Map.of("code", l.code()), "/loads/" + l.id());
                }
            }
        }
    }

    // ------------------------------------------------------------------ helpers

    private Map<String, Object> view(Entry e, List<LoadDirectory.PastTrip> trips) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", e.id());
        m.put("targetType", e.targetType());
        BigDecimal trust = null;
        UUID orgId = e.orgId();
        Set<UUID> drivers;
        long together;
        if (e.targetType() == Target.TRUCK) {
            Optional<FleetApi.TruckView> t = fleet.truck(e.truckId());
            m.put("truckNumber", t.map(FleetApi.TruckView::number).orElse(null));
            m.put("vehicleType", t.map(FleetApi.TruckView::vehicleType).orElse(null));
            m.put("capacityTonnes", t.map(FleetApi.TruckView::capacityTonnes).orElse(null));
            orgId = t.map(FleetApi.TruckView::orgId).orElse(null);
            drivers = new HashSet<>(fleet.driversForTruck(e.truckId()));
            UUID driverId = t.map(FleetApi.TruckView::ownerDriverId).filter(Objects::nonNull)
                    .orElse(drivers.stream().findFirst().orElse(null));
            Optional<UserDirectory.UserView> driver = driverId == null ? Optional.empty() : users.find(driverId);
            m.put("driverName", driver.map(UserDirectory.UserView::name).orElse(null));
            trust = orgId != null ? users.find(orgId).map(UserDirectory.UserView::trustScore).orElse(null)
                    : driver.map(UserDirectory.UserView::trustScore).orElse(null);
            together = trips.stream().filter(x -> e.truckId().equals(x.truckId())).count();
        } else {
            drivers = new HashSet<>(fleet.driversOfOrg(e.orgId()));
            trust = users.find(e.orgId()).map(UserDirectory.UserView::trustScore).orElse(null);
            together = trips.stream().filter(x -> e.orgId().equals(x.orgId())).count();
        }
        m.put("orgId", orgId);
        m.put("orgName", orgId == null ? null : orgName(orgId));
        m.put("trustScore", trust == null ? BigDecimal.valueOf(70) : trust);
        m.put("tripsTogether", together);
        m.put("note", e.note());
        LocalDate today = LocalDate.now(clock.withZone(MatchingService.IST));
        m.put("available", drivers.stream().anyMatch(d -> fleet.driver(d, today)
                .filter(c -> c.onDuty() && c.truckId() != null).isPresent() && loads.activeForDriver(d).isEmpty()));
        return m;
    }

    private String orgName(UUID orgId) {
        Object name = users.roleProfile(orgId).get("orgName");
        return name == null ? users.find(orgId).map(UserDirectory.UserView::name).orElse(null) : name.toString();
    }

    private void requireShipper(UUID userId) {
        Role r = users.get(userId).role();
        if (r != Role.LOAD_PROVIDER && r != Role.FARMER_NETWORK) {
            throw new ApiException(ErrorCode.FORBIDDEN, "Only Load Providers and Farmer Networks keep a wish list");
        }
    }

    private static Target parse(String v) {
        try {
            return Target.valueOf(v);
        } catch (RuntimeException e) {
            throw ApiException.invalidField("targetType", "TRUCK or ORGANIZATION");
        }
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }
}
