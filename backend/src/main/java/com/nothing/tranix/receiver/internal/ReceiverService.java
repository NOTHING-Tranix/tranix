package com.nothing.tranix.receiver.internal;

import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Arrays;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import com.nothing.tranix.fleet.api.FleetApi;
import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.loads.api.LoadEvents;
import com.nothing.tranix.payments.api.PaymentApi;
import com.nothing.tranix.receiver.api.ReceiverEvents;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.files.FileService;
import com.nothing.tranix.shared.integrations.SmsSender;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.shared.types.FreightPayer;
import com.nothing.tranix.shared.types.Language;
import com.nothing.tranix.shared.types.LoadStatus;
import com.nothing.tranix.shared.types.PaymentMode;
import com.nothing.tranix.shared.types.Role;
import com.nothing.tranix.trips.api.TripTracking;
import com.nothing.tranix.trust.api.TrustApi;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionalEventListener;
import org.springframework.web.multipart.MultipartFile;

/**
 * B-1001…B-1006: tracking links (RECEIVER always, SENDER for farmer loads) created at acceptance and sent by SMS,
 * expiring N days after the trip ends; the public JSON for the link page (never the delivery OTP); receipt,
 * rating and mark-paid from the link; registered receiver endpoints.
 */
@Service
public class ReceiverService {

    public enum Audience { RECEIVER, SENDER }

    public record Link(String token, UUID loadId, Audience audience, String mobile, Instant expiresAt, Instant ratedAt) {
    }

    static final Set<LoadStatus> ENDED = Set.of(LoadStatus.DELIVERED, LoadStatus.CANCELLED);
    private static final SecureRandom RANDOM = new SecureRandom();

    private final JdbcTemplate jdbc;
    private final LoadDirectory loads;
    private final UserDirectory users;
    private final FleetApi fleet;
    private final TripTracking tracking;
    private final PaymentApi payments;
    private final TrustApi trust;
    private final FileService files;
    private final SmsSender sms;
    private final Settings settings;
    private final ApplicationEventPublisher events;
    private final Clock clock;
    private final String baseUrl;

    ReceiverService(JdbcTemplate jdbc, LoadDirectory loads, UserDirectory users, FleetApi fleet, TripTracking tracking,
                    PaymentApi payments, TrustApi trust, FileService files, SmsSender sms, Settings settings,
                    ApplicationEventPublisher events, Clock clock, @Value("${tranix.public-base-url:http://localhost:8080}") String baseUrl) {
        this.jdbc = jdbc;
        this.loads = loads;
        this.users = users;
        this.fleet = fleet;
        this.tracking = tracking;
        this.payments = payments;
        this.trust = trust;
        this.files = files;
        this.sms = sms;
        this.settings = settings;
        this.events = events;
        this.clock = clock;
        this.baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
    }

    // ------------------------------------------------------------------ links (B-1001)

    @TransactionalEventListener(fallbackExecution = true)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void on(LoadEvents.StatusChanged e) {
        if (e.from() == LoadStatus.NOT_ACCEPTED && e.to() == LoadStatus.WAITING_FOR_PICKUP) {
            createLinks(e.loadId());
        } else if (ENDED.contains(e.to())) {
            jdbc.update("update receiver_tracking_token set expires_at = ? where load_id = ? and expires_at is null",
                    Timestamp.from(now().plus(Duration.ofDays(settings.getInt("tracking.link_days_after_end")))), e.loadId());
        }
    }

    void createLinks(UUID loadId) {
        LoadDirectory.LoadInfo l = loads.get(loadId);
        String shipper = users.find(l.shipperId()).map(UserDirectory.UserView::name).orElse("");
        Language lang = users.find(l.shipperId()).map(UserDirectory.UserView::language).orElse(Language.en);
        String truck = l.truckId() == null ? "" : fleet.truck(l.truckId()).map(FleetApi.TruckView::number).orElse("");
        String receiverToken = insertToken(loadId, Audience.RECEIVER, l.receiverMobile());
        sms.send(l.receiverMobile(), "RECEIVER_TRACKING",
                Map.of("code", l.code(), "shipper", shipper, "truck", truck, "link", linkUrl(receiverToken)), lang);
        if (l.postedForFarmerId() != null) { // B-903: the farmer is the sender
            String senderToken = insertToken(loadId, Audience.SENDER, l.senderMobile());
            sms.send(l.senderMobile(), "SENDER_TRACKING",
                    Map.of("code", l.code(), "network", shipper, "truck", truck, "link", linkUrl(senderToken)), lang);
        }
    }

    private String insertToken(UUID loadId, Audience audience, String mobile) {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        jdbc.update("insert into receiver_tracking_token (token, load_id, audience, mobile, created_at) values (?, ?, ?, ?, ?) on conflict do nothing",
                token, loadId, audience.name(), mobile, Timestamp.from(now()));
        return jdbc.queryForObject("select token from receiver_tracking_token where load_id = ? and audience = ?", String.class,
                loadId, audience.name());
    }

    public String linkUrl(String token) {
        return baseUrl + "/p/track/" + token;
    }

    /** Valid link or 404 / 410 (expired: no load data at all). */
    public Link link(String token) {
        Link link = jdbc.query("select * from receiver_tracking_token where token = ?", (rs, i) -> new Link(rs.getString("token"),
                        rs.getObject("load_id", UUID.class), Audience.valueOf(rs.getString("audience")), rs.getString("mobile"),
                        rs.getTimestamp("expires_at") == null ? null : rs.getTimestamp("expires_at").toInstant(),
                        rs.getTimestamp("rated_at") == null ? null : rs.getTimestamp("rated_at").toInstant()), token)
                .stream().findFirst().orElseThrow(() -> ApiException.notFound("Link"));
        if (link.expiresAt() != null && !now().isBefore(link.expiresAt())) {
            throw new ApiException(ErrorCode.LINK_EXPIRED);
        }
        return link;
    }

    // ------------------------------------------------------------------ public JSON (B-1002, B-1006)

    @Transactional(readOnly = true)
    public Map<String, Object> publicView(String token) {
        Link link = link(token);
        LoadDirectory.LoadInfo l = loads.get(link.loadId());
        Map<String, Object> detail = loads.detail(l.id(), LoadDirectory.Viewer.RECEIVER);
        boolean receiver = link.audience() == Audience.RECEIVER;
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("code", l.code());
        m.put("status", l.status());
        m.put("audience", link.audience());
        m.put("senderName", l.senderName());
        m.put("receiverName", l.receiverName());
        m.put("goodsType", l.goodsType());
        m.put("description", l.description());
        m.put("quantity", l.quantity());
        m.put("quantityUnit", l.quantityUnit());
        m.put("pickupArea", l.pickupArea());
        m.put("dropArea", l.dropArea());
        m.put("timeline", detail.get("timeline"));
        Object driver = detail.get("driver");
        if (driver instanceof Map<?, ?> d) {
            Map<String, Object> dv = new LinkedHashMap<>();
            dv.put("name", d.get("name"));
            dv.put("truckNumber", d.get("truckNumber"));
            dv.put("mobile", d.get("mobile"));
            m.put("driver", dv);
        } else {
            m.put("driver", null);
        }
        m.put("tracking", ENDED.contains(l.status()) ? null : tracking.trackingOf(l.id()));
        // B-1006: the delivery OTP is only announced, never shown here
        m.put("deliveryOtpNotice", receiver && l.status() == LoadStatus.ARRIVED_DESTINATION);
        Optional<Map<String, Object>> receipt = receipt(l.id());
        m.put("receipt", receipt.orElse(null));
        m.put("freightPaidBy", l.freightPaidBy());
        Optional<Map<String, Object>> payment = receiver && l.freightPaidBy() == FreightPayer.RECEIVER ? payments.payment(l.id()) : Optional.empty();
        m.put("payment", payment.orElse(null));
        boolean delivered = l.status() == LoadStatus.DELIVERED;
        m.put("canSubmitReceipt", receiver && delivered && receipt.isEmpty());
        m.put("canRate", receiver && delivered && link.ratedAt() == null && l.driverId() != null);
        m.put("canMarkPaid", payment.map(p -> "PENDING".equals(String.valueOf(p.get("status"))) || "DISPUTED".equals(String.valueOf(p.get("status"))))
                .orElse(false));
        m.put("expiresAt", link.expiresAt());
        return m;
    }

    @Transactional
    public Map<String, Object> uploadFromLink(String token, MultipartFile file) {
        Link link = requireReceiverDelivered(token);
        LoadDirectory.LoadInfo l = loads.get(link.loadId());
        return Map.of("id", files.upload(fileOwner(l), file).getId());
    }

    @Transactional
    public Map<String, Object> receiptFromLink(String token, List<UUID> fileIds, String condition, String remarks) {
        Link link = requireReceiverDelivered(token);
        LoadDirectory.LoadInfo l = loads.get(link.loadId());
        files.requireOwned(fileOwner(l), fileIds);
        return saveReceipt(l, null, link.mobile(), "LINK", fileIds, condition, remarks);
    }

    @Transactional
    public void rateFromLink(String token, int stars, List<String> tags, String comment) {
        Link link = requireReceiverDelivered(token);
        LoadDirectory.LoadInfo l = loads.get(link.loadId());
        if (link.ratedAt() != null || l.driverId() == null) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Already rated");
        }
        UUID rater = l.receiverUserId() != null ? l.receiverUserId()
                : UUID.nameUUIDFromBytes(("receiver:" + link.mobile()).getBytes(StandardCharsets.UTF_8));
        trust.rateFromLink(l.id(), rater, l.driverId(), stars, tags, comment);
        jdbc.update("update receiver_tracking_token set rated_at = ? where token = ?", Timestamp.from(now()), token);
    }

    @Transactional
    public Map<String, Object> markPaidFromLink(String token, long amountInr, PaymentMode mode, String reference) {
        Link link = link(token);
        if (link.audience() != Audience.RECEIVER) {
            throw new ApiException(ErrorCode.FORBIDDEN, "Only the receiver can mark this payment");
        }
        return payments.markPaidFromLink(link.loadId(), amountInr, mode, reference);
    }

    private Link requireReceiverDelivered(String token) {
        Link link = link(token);
        if (link.audience() != Audience.RECEIVER) {
            throw new ApiException(ErrorCode.FORBIDDEN, "Only the receiver can do this");
        }
        if (loads.get(link.loadId()).status() != LoadStatus.DELIVERED) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Available after delivery");
        }
        return link;
    }

    /** Link uploads belong to the registered receiver if any, else to the shipper (who may see the receipt). */
    private static UUID fileOwner(LoadDirectory.LoadInfo l) {
        return l.receiverUserId() != null ? l.receiverUserId() : l.shipperId();
    }

    // ------------------------------------------------------------------ receipts (B-1003, B-1005)

    Optional<Map<String, Object>> receipt(UUID loadId) {
        return jdbc.queryForList("select * from receiver_receipt where load_id = ?", loadId).stream().findFirst().map(r -> {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("condition", r.get("condition"));
            m.put("remarks", r.get("remarks"));
            m.put("fileIds", Arrays.stream(((String) r.get("file_ids")).split(",")).filter(s -> !s.isBlank()).toList());
            m.put("at", ((Timestamp) r.get("created_at")).toInstant());
            return m;
        });
    }

    private Map<String, Object> saveReceipt(LoadDirectory.LoadInfo l, UUID userId, String mobile, String via, List<UUID> fileIds,
                                            String condition, String remarks) {
        if (fileIds == null || fileIds.isEmpty() || fileIds.size() > 5) {
            throw ApiException.invalidField("fileIds", "Add 1 to 5 receipt photos");
        }
        if (!"FULL".equals(condition) && !"SHORTAGE_DAMAGE".equals(condition)) {
            throw ApiException.invalidField("condition", "FULL or SHORTAGE_DAMAGE");
        }
        String note = remarks == null || remarks.isBlank() ? null : remarks.trim();
        if ("SHORTAGE_DAMAGE".equals(condition) && note == null) {
            throw ApiException.invalidField("remarks", "Describe the shortage or damage");
        }
        if (note != null && note.length() > 500) {
            throw ApiException.invalidField("remarks", "At most 500 characters");
        }
        int n = jdbc.update("""
                insert into receiver_receipt (load_id, by_user_id, via, file_ids, condition, remarks, created_at) values (?, ?, ?, ?, ?, ?, ?)
                on conflict do nothing""", l.id(), userId, via, String.join(",", fileIds.stream().map(UUID::toString).toList()),
                condition, note, Timestamp.from(now()));
        if (n == 0) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Receipt already submitted");
        }
        events.publishEvent(new ReceiverEvents.ReceiptRecorded(l.id(), condition, note, userId, mobile));
        return receipt(l.id()).orElseThrow();
    }

    // ------------------------------------------------------------------ registered receiver app (B-1004)

    @Transactional(readOnly = true)
    public List<Map<String, Object>> appLoads(UUID userId, boolean ongoing) {
        requireReceiver(userId);
        return loads.forReceiver(userId, ongoing);
    }

    @Transactional(readOnly = true)
    public Map<String, Object> appDetail(UUID userId, UUID loadId) {
        LoadDirectory.LoadInfo l = ownLoad(userId, loadId);
        Map<String, Object> m = new LinkedHashMap<>(loads.detail(loadId, LoadDirectory.Viewer.RECEIVER));
        Optional<Map<String, Object>> receipt = receipt(loadId);
        m.put("receipt", receipt.orElse(null));
        m.put("canSubmitReceipt", l.status() == LoadStatus.DELIVERED && receipt.isEmpty());
        if (l.freightPaidBy() == FreightPayer.RECEIVER) {
            payments.payment(loadId).ifPresent(p -> m.put("payment", p));
        } else {
            m.remove("payment"); // the shipper pays: not the receiver's business
        }
        return m;
    }

    @Transactional
    public Map<String, Object> appReceipt(UUID userId, UUID loadId, List<UUID> fileIds, String condition, String remarks) {
        LoadDirectory.LoadInfo l = ownLoad(userId, loadId);
        if (l.status() != LoadStatus.DELIVERED) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Available after delivery");
        }
        files.requireOwned(userId, fileIds == null ? List.of() : fileIds);
        return saveReceipt(l, userId, null, "APP", fileIds, condition, remarks);
    }

    private LoadDirectory.LoadInfo ownLoad(UUID userId, UUID loadId) {
        requireReceiver(userId);
        return loads.find(loadId).filter(l -> userId.equals(l.receiverUserId()) && l.status() != LoadStatus.NOT_ACCEPTED)
                .orElseThrow(() -> ApiException.notFound("Load"));
    }

    private void requireReceiver(UUID userId) {
        if (users.get(userId).role() != Role.RECEIVER) {
            throw new ApiException(ErrorCode.FORBIDDEN, "Receivers only");
        }
    }

    private Instant now() {
        return Instant.now(clock);
    }
}
