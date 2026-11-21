package com.nothing.tranix.farmers.internal;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.loads.api.PostingHooks;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.types.Role;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** B-901, B-902: a Farmer Network's farmers; a farmer is the locked sender of loads posted for them. */
@Service
public class FarmerService implements PostingHooks.FarmerValidator {

    public record FarmerInput(String name, String mobile, String aadhaarLast4, BigDecimal landAcres, String village, Boolean consent) {
    }

    private static final String DUPLICATE = "A farmer with this mobile number is already in your list";

    private final JdbcTemplate jdbc;
    private final UserDirectory users;
    private final Clock clock;

    FarmerService(JdbcTemplate jdbc, UserDirectory users, Clock clock) {
        this.jdbc = jdbc;
        this.users = users;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> list(UUID networkId, String q, boolean includeInactive, int page, int size) {
        requireNetwork(networkId);
        StringBuilder where = new StringBuilder(" from farmers_farmer where network_id = ?");
        List<Object> args = new ArrayList<>(List.of(networkId));
        if (!includeInactive) {
            where.append(" and active");
        }
        if (q != null && !q.isBlank()) {
            where.append(" and (lower(name) like ? or mobile like ? or lower(village) like ?)");
            String like = "%" + q.trim().toLowerCase(Locale.ROOT).replace("%", "") + "%";
            args.addAll(List.of(like, like, like));
        }
        Long total = jdbc.queryForObject("select count(*)" + where, Long.class, args.toArray());
        List<Object> pageArgs = new ArrayList<>(args);
        pageArgs.addAll(List.of(size, page * size));
        List<Map<String, Object>> items = jdbc.queryForList("select *" + where + " order by active desc, name limit ? offset ?",
                pageArgs.toArray()).stream().map(FarmerService::view).toList();
        return Map.of("items", items, "page", page, "size", size, "total", total == null ? 0 : total);
    }

    @Transactional
    public Map<String, Object> create(UUID networkId, FarmerInput in) {
        requireNetwork(networkId);
        validate(in);
        if (!Boolean.TRUE.equals(in.consent())) {
            throw ApiException.invalidField("consent", "The farmer's consent is required");
        }
        UUID id = UUID.randomUUID();
        Timestamp now = Timestamp.from(Instant.now(clock));
        try {
            jdbc.update("""
                    insert into farmers_farmer (id, network_id, name, mobile, aadhaar_last4, land_acres, village, consent_at, active, created_at, updated_at)
                    values (?, ?, ?, ?, ?, ?, ?, ?, true, ?, ?)""",
                    id, networkId, in.name().trim(), in.mobile(), blank(in.aadhaarLast4()), in.landAcres(), in.village().trim(), now, now, now);
        } catch (DuplicateKeyException e) {
            throw ApiException.invalidField("mobile", DUPLICATE);
        }
        return get(networkId, id);
    }

    @Transactional
    public Map<String, Object> update(UUID networkId, UUID farmerId, FarmerInput in) {
        requireNetwork(networkId);
        validate(in);
        int n;
        try {
            n = jdbc.update("""
                    update farmers_farmer set name = ?, mobile = ?, aadhaar_last4 = ?, land_acres = ?, village = ?, updated_at = ?
                    where id = ? and network_id = ? and active""",
                    in.name().trim(), in.mobile(), blank(in.aadhaarLast4()), in.landAcres(), in.village().trim(),
                    Timestamp.from(Instant.now(clock)), farmerId, networkId);
        } catch (DuplicateKeyException e) {
            throw ApiException.invalidField("mobile", DUPLICATE);
        }
        if (n == 0) {
            throw ApiException.notFound("Farmer");
        }
        return get(networkId, farmerId);
    }

    @Transactional
    public Map<String, Object> deactivate(UUID networkId, UUID farmerId) {
        requireNetwork(networkId);
        if (jdbc.update("update farmers_farmer set active = false, updated_at = ? where id = ? and network_id = ? and active",
                Timestamp.from(Instant.now(clock)), farmerId, networkId) == 0) {
            throw ApiException.notFound("Farmer");
        }
        return get(networkId, farmerId);
    }

    @Override
    @Transactional(readOnly = true)
    public PostingHooks.FarmerSender sender(UUID networkId, UUID farmerId) {
        return jdbc.queryForList("select name, mobile from farmers_farmer where id = ? and network_id = ? and active", farmerId, networkId)
                .stream().findFirst()
                .map(r -> new PostingHooks.FarmerSender((String) r.get("name"), (String) r.get("mobile")))
                .orElseThrow(() -> ApiException.invalidField("postedForFarmerId", "Choose an active farmer from your list"));
    }

    private Map<String, Object> get(UUID networkId, UUID id) {
        return jdbc.queryForList("select * from farmers_farmer where id = ? and network_id = ?", id, networkId).stream()
                .findFirst().map(FarmerService::view).orElseThrow(() -> ApiException.notFound("Farmer"));
    }

    static Map<String, Object> view(Map<String, Object> r) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", r.get("id"));
        m.put("name", r.get("name"));
        m.put("mobile", r.get("mobile"));
        m.put("aadhaarLast4", r.get("aadhaar_last4"));
        m.put("landAcres", r.get("land_acres"));
        m.put("village", r.get("village"));
        m.put("active", r.get("active"));
        m.put("createdAt", ((Timestamp) r.get("created_at")).toInstant());
        return m;
    }

    private static void validate(FarmerInput in) {
        if (in.name() == null || in.name().isBlank() || in.name().trim().length() > 60) {
            throw ApiException.invalidField("name", "Enter the farmer's name");
        }
        if (in.mobile() == null || !in.mobile().matches("[6-9][0-9]{9}")) {
            throw ApiException.invalidField("mobile", "Enter a 10-digit mobile number");
        }
        if (in.aadhaarLast4() != null && !in.aadhaarLast4().isBlank() && !in.aadhaarLast4().matches("[0-9]{4}")) {
            throw ApiException.invalidField("aadhaarLast4", "Only the last 4 digits of Aadhaar");
        }
        if (in.landAcres() != null && in.landAcres().signum() < 0) {
            throw ApiException.invalidField("landAcres", "Enter a valid land holding");
        }
        if (in.village() == null || in.village().isBlank() || in.village().trim().length() > 100) {
            throw ApiException.invalidField("village", "Enter the village");
        }
    }

    private void requireNetwork(UUID userId) {
        if (users.get(userId).role() != Role.FARMER_NETWORK) {
            throw new ApiException(ErrorCode.FORBIDDEN, "Only Farmer Networks have farmers");
        }
    }

    private static String blank(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }
}
