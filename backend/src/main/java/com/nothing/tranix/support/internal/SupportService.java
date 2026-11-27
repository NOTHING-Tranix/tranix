package com.nothing.tranix.support.internal;

import java.sql.Timestamp;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import com.nothing.tranix.shared.config.AsyncConfig;
import com.nothing.tranix.engagement.api.Notifier;
import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.payments.api.PaymentEvents;
import com.nothing.tranix.receiver.api.ReceiverEvents;
import com.nothing.tranix.shared.audit.AuditLog;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.files.FileService;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.shared.types.NotificationTab;
import com.nothing.tranix.shared.types.TicketType;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.scheduling.annotation.Async;
import org.springframework.transaction.event.TransactionalEventListener;

/** B-1104, B-1105, B-1005: tickets with a conversation, unread flags, reopen window, admin reply/ignore, automatic tickets. */
@Service
public class SupportService {

    static final Set<TicketType> TRIP_REQUIRED = Set.of(TicketType.COMPLAINT, TicketType.PAYMENT_DISPUTE);

    private final JdbcTemplate jdbc;
    private final LoadDirectory loads;
    private final FileService files;
    private final Notifier notifier;
    private final Settings settings;
    private final AuditLog audit;
    private final Clock clock;

    SupportService(JdbcTemplate jdbc, LoadDirectory loads, FileService files, Notifier notifier, Settings settings, AuditLog audit, Clock clock) {
        this.jdbc = jdbc;
        this.loads = loads;
        this.files = files;
        this.notifier = notifier;
        this.settings = settings;
        this.audit = audit;
        this.clock = clock;
    }

    // ------------------------------------------------------------------ user side

    @Transactional
    public Map<String, Object> create(UUID userId, TicketType type, String otherText, UUID loadId, String description, List<UUID> fileIds) {
        if (type == null) {
            throw ApiException.invalidField("type", "Choose a type");
        }
        if (type == TicketType.OTHERS && (otherText == null || otherText.isBlank())) {
            throw ApiException.invalidField("otherText", "Tell us what this is about");
        }
        if (TRIP_REQUIRED.contains(type) && loadId == null) {
            throw ApiException.invalidField("loadId", "Choose the trip");
        }
        if (loadId != null && !involved(userId, loadId)) {
            throw ApiException.invalidField("loadId", "Unknown trip");
        }
        if (description == null || description.isBlank() || description.length() > 1000) {
            throw ApiException.invalidField("description", "Describe the problem (up to 1000 characters)");
        }
        List<UUID> photos = fileIds == null ? List.of() : fileIds;
        if (photos.size() > 3) {
            throw ApiException.invalidField("fileIds", "Up to 3 photos");
        }
        files.requireOwned(userId, photos);
        UUID id = insert(userId, type, otherText, loadId, description.trim(), photos, "USER");
        return detail(userId, id);
    }

    private UUID insert(UUID userId, TicketType type, String otherText, UUID loadId, String description, List<UUID> fileIds, String source) {
        UUID id = UUID.randomUUID();
        Long seq = jdbc.queryForObject("select nextval('support_ticket_seq')", Long.class);
        Timestamp now = Timestamp.from(Instant.now(clock));
        jdbc.update("""
                insert into support_ticket (id, code, user_id, type, other_text, load_id, description, file_ids, source, status, created_at, updated_at)
                values (?, ?, ?, ?, ?, ?, ?, ?, ?, 'OPEN', ?, ?)""", id, String.format("TKT-%06d", seq), userId, type.name(),
                otherText == null || otherText.isBlank() ? null : otherText.trim(), loadId, description, join(fileIds), source, now, now);
        return id;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> list(UUID userId) {
        return jdbc.queryForList("select * from support_ticket where user_id = ? order by updated_at desc limit 200", userId).stream()
                .map(r -> summary(r, true)).toList();
    }

    @Transactional
    public Map<String, Object> detail(UUID userId, UUID ticketId) {
        Map<String, Object> t = own(userId, ticketId);
        jdbc.update("update support_ticket set unread_for_user = false where id = ?", ticketId);
        Map<String, Object> m = full(t, true);
        m.put("unread", false);
        return m;
    }

    @Transactional
    public Map<String, Object> message(UUID userId, UUID ticketId, String body, List<UUID> fileIds) {
        Map<String, Object> t = own(userId, ticketId);
        if (!"OPEN".equals(t.get("status"))) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Reopen the ticket to write again");
        }
        List<UUID> photos = fileIds == null ? List.of() : fileIds;
        if (photos.size() > 3) {
            throw ApiException.invalidField("fileIds", "Up to 3 photos");
        }
        files.requireOwned(userId, photos);
        addMessage(ticketId, "USER", userId, body, photos);
        jdbc.update("update support_ticket set unread_for_admin = true, updated_at = ? where id = ?", Timestamp.from(Instant.now(clock)), ticketId);
        return detail(userId, ticketId);
    }

    /** Reopen within {@code support.reopen_days} of closing. */
    @Transactional
    public Map<String, Object> reopen(UUID userId, UUID ticketId) {
        Map<String, Object> t = own(userId, ticketId);
        Timestamp closedAt = (Timestamp) t.get("closed_at");
        if (!"CLOSED".equals(t.get("status")) || closedAt == null
                || closedAt.toInstant().plus(Duration.ofDays(settings.getInt("support.reopen_days"))).isBefore(Instant.now(clock))) {
            throw new ApiException(ErrorCode.INVALID_STATE, "This ticket can no longer be reopened — please raise a new one");
        }
        // B-1613: only the request that actually changes CLOSED → OPEN wins; a simultaneous second reopen is refused
        int changed = jdbc.update("update support_ticket set status = 'OPEN', closed_at = null, close_reason = null, unread_for_admin = true, updated_at = ? where id = ? and status = 'CLOSED'",
                Timestamp.from(Instant.now(clock)), ticketId);
        if (changed == 0) {
            throw new ApiException(ErrorCode.INVALID_STATE, "This ticket is already open");
        }
        return detail(userId, ticketId);
    }

    // ------------------------------------------------------------------ admin side

    @Transactional(readOnly = true)
    public List<Map<String, Object>> adminList(String status) {
        String where = status == null ? "" : " where status = ?";
        Object[] args = status == null ? new Object[0] : new Object[] {status};
        return jdbc.queryForList("select * from support_ticket" + where + " order by unread_for_admin desc, updated_at desc limit 200", args)
                .stream().map(r -> summary(r, false)).toList();
    }

    @Transactional
    public Map<String, Object> adminDetail(UUID ticketId) {
        Map<String, Object> t = find(ticketId);
        jdbc.update("update support_ticket set unread_for_admin = false where id = ?", ticketId);
        Map<String, Object> m = full(t, false);
        m.put("userId", t.get("user_id"));
        m.put("source", t.get("source"));
        return m;
    }

    @Transactional
    public Map<String, Object> reply(UUID adminId, UUID ticketId, String body, boolean close) {
        Map<String, Object> t = find(ticketId);
        if (!"OPEN".equals(t.get("status"))) {
            throw new ApiException(ErrorCode.INVALID_STATE, "The ticket is closed");
        }
        addMessage(ticketId, "ADMIN", adminId, body, List.of());
        Timestamp now = Timestamp.from(Instant.now(clock));
        jdbc.update("update support_ticket set unread_for_user = true, unread_for_admin = false, updated_at = ?"
                + (close ? ", status = 'CLOSED', closed_at = ?, close_reason = 'Resolved' where id = ?" : " where id = ?"),
                close ? new Object[] {now, now, ticketId} : new Object[] {now, ticketId});
        audit.record(adminId, close ? "TICKET_REPLY_CLOSE" : "TICKET_REPLY", "TICKET", ticketId, null, null, null);
        notifier.notify((UUID) t.get("user_id"), NotificationTab.TRANIX, "SUPPORT_REPLY",
                Map.of("ticket", (String) t.get("code"), "body", body.length() > 120 ? body.substring(0, 117) + "…" : body), "/support/" + ticketId);
        return adminDetail(ticketId);
    }

    /** Ignore with a reason (D-10 style: reason required) — closes the ticket. */
    @Transactional
    public Map<String, Object> ignore(UUID adminId, UUID ticketId, String reason) {
        Map<String, Object> t = find(ticketId);
        if (!"OPEN".equals(t.get("status"))) {
            throw new ApiException(ErrorCode.INVALID_STATE, "The ticket is closed");
        }
        Timestamp now = Timestamp.from(Instant.now(clock));
        jdbc.update("update support_ticket set status = 'CLOSED', closed_at = ?, close_reason = ?, unread_for_user = true, unread_for_admin = false, updated_at = ? where id = ?",
                now, reason.trim(), now, ticketId);
        audit.record(adminId, "TICKET_IGNORE", "TICKET", ticketId, "OPEN", "CLOSED", reason.trim());
        notifier.notify((UUID) t.get("user_id"), NotificationTab.TRANIX, "TICKET_CLOSED",
                Map.of("ticket", (String) t.get("code"), "reason", reason.trim()), "/support/" + ticketId);
        return adminDetail(ticketId);
    }

    // ------------------------------------------------------------------ automatic tickets

    @Async(AsyncConfig.AFTER_COMMIT)
    @TransactionalEventListener(fallbackExecution = true)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void on(PaymentEvents.PaymentDisputed e) {
        String code = loads.find(e.loadId()).map(LoadDirectory.LoadInfo::code).orElse("");
        UUID id = insert(e.driverId(), TicketType.PAYMENT_DISPUTE, null, e.loadId(), "Payment dispute on " + code + ": " + e.reason(), List.of(),
                "PAYMENT_DISPUTE");
        opened(e.driverId(), id, code);
    }

    /** B-1005: shortage/damage on a receipt opens a complaint for the receiver (or the shipper when the receiver has no account). */
    @Async(AsyncConfig.AFTER_COMMIT)
    @TransactionalEventListener(fallbackExecution = true)
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void on(ReceiverEvents.ReceiptRecorded e) {
        if (!"SHORTAGE_DAMAGE".equals(e.condition())) {
            return;
        }
        Optional<LoadDirectory.LoadInfo> l = loads.find(e.loadId());
        if (l.isEmpty()) {
            return;
        }
        UUID owner = e.byUserId() != null ? e.byUserId() : l.get().shipperId();
        String from = e.byUserId() != null ? "the receiver (app)" : "the receiver (tracking link)";
        UUID id = insert(owner, TicketType.COMPLAINT, null, e.loadId(),
                "Shortage or damage reported by " + from + " on " + l.get().code() + ": " + e.remarks(), List.of(), "RECEIPT");
        opened(owner, id, l.get().code());
    }

    private void opened(UUID userId, UUID ticketId, String loadCode) {
        String code = jdbc.queryForObject("select code from support_ticket where id = ?", String.class, ticketId);
        notifier.notify(userId, NotificationTab.TRANIX, "TICKET_OPENED", Map.of("ticket", code, "code", loadCode), "/support/" + ticketId);
    }

    // ------------------------------------------------------------------ helpers

    private boolean involved(UUID userId, UUID loadId) {
        return loads.find(loadId).filter(l -> userId.equals(l.shipperId()) || userId.equals(l.driverId()) || userId.equals(l.receiverUserId())
                || userId.equals(l.orgId())).isPresent();
    }

    private Map<String, Object> own(UUID userId, UUID ticketId) {
        Map<String, Object> t = find(ticketId);
        if (!userId.equals(t.get("user_id"))) {
            throw ApiException.notFound("Ticket");
        }
        return t;
    }

    private Map<String, Object> find(UUID ticketId) {
        return jdbc.queryForList("select * from support_ticket where id = ?", ticketId).stream().findFirst()
                .orElseThrow(() -> ApiException.notFound("Ticket"));
    }

    private void addMessage(UUID ticketId, String author, UUID authorId, String body, List<UUID> fileIds) {
        if (body == null || body.isBlank() || body.length() > 1000) {
            throw ApiException.invalidField("body", "Write a message (up to 1000 characters)");
        }
        jdbc.update("insert into support_message (id, ticket_id, author, author_id, body, file_ids, created_at) values (?, ?, ?, ?, ?, ?, ?)",
                UUID.randomUUID(), ticketId, author, authorId, body.trim(), join(fileIds), Timestamp.from(Instant.now(clock)));
    }

    private Map<String, Object> summary(Map<String, Object> r, boolean forUser) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", r.get("id"));
        m.put("code", r.get("code"));
        m.put("type", r.get("type"));
        m.put("otherText", r.get("other_text"));
        m.put("status", r.get("status"));
        m.put("loadId", r.get("load_id"));
        m.put("loadCode", r.get("load_id") == null ? null : loads.find((UUID) r.get("load_id")).map(LoadDirectory.LoadInfo::code).orElse(null));
        m.put("description", r.get("description"));
        m.put("unread", Boolean.TRUE.equals(r.get(forUser ? "unread_for_user" : "unread_for_admin")));
        m.put("closeReason", r.get("close_reason"));
        m.put("createdAt", ((Timestamp) r.get("created_at")).toInstant());
        m.put("updatedAt", ((Timestamp) r.get("updated_at")).toInstant());
        m.put("closedAt", r.get("closed_at") == null ? null : ((Timestamp) r.get("closed_at")).toInstant());
        return m;
    }

    private Map<String, Object> full(Map<String, Object> t, boolean forUser) {
        Map<String, Object> m = summary(t, forUser);
        m.put("fileIds", split((String) t.get("file_ids")));
        Timestamp closedAt = (Timestamp) t.get("closed_at");
        m.put("canReopen", "CLOSED".equals(t.get("status")) && closedAt != null
                && !closedAt.toInstant().plus(Duration.ofDays(settings.getInt("support.reopen_days"))).isBefore(Instant.now(clock)));
        m.put("messages", jdbc.queryForList("select * from support_message where ticket_id = ? order by created_at", t.get("id")).stream().map(r -> {
            Map<String, Object> x = new LinkedHashMap<>();
            x.put("id", r.get("id"));
            x.put("author", r.get("author"));
            x.put("body", r.get("body"));
            x.put("fileIds", split((String) r.get("file_ids")));
            x.put("at", ((Timestamp) r.get("created_at")).toInstant());
            return x;
        }).toList());
        return m;
    }

    private static String join(List<UUID> ids) {
        return String.join(",", ids.stream().map(UUID::toString).toList());
    }

    private static List<String> split(String s) {
        return s == null || s.isBlank() ? List.of() : Arrays.asList(s.split(","));
    }
}
