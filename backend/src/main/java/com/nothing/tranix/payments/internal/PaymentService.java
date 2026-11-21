package com.nothing.tranix.payments.internal;

import java.sql.Timestamp;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.YearMonth;
import java.time.ZoneId;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.engagement.api.Notifier;
import com.nothing.tranix.loads.api.LoadDirectory;
import com.nothing.tranix.loads.api.LoadEvents;
import com.nothing.tranix.payments.api.PaymentEvents;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.shared.types.FreightPayer;
import com.nothing.tranix.shared.types.LoadStatus;
import com.nothing.tranix.shared.types.NotificationTab;
import com.nothing.tranix.shared.types.PaymentMode;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.event.TransactionalEventListener;

/** B-801, B-802, B-807: freight payment records (paid outside Tranix) and driver earnings history. */
@Service
public class PaymentService {

    static final ZoneId IST = ZoneId.of("Asia/Kolkata");

    private final JdbcTemplate jdbc;
    private final LoadDirectory loads;
    private final Notifier notifier;
    private final Settings settings;
    private final ApplicationEventPublisher events;
    private final Clock clock;

    PaymentService(JdbcTemplate jdbc, LoadDirectory loads, Notifier notifier, Settings settings, ApplicationEventPublisher events,
                   Clock clock) {
        this.jdbc = jdbc;
        this.loads = loads;
        this.notifier = notifier;
        this.settings = settings;
        this.events = events;
        this.clock = clock;
    }

    private Timestamp now() {
        return Timestamp.from(Instant.now(clock));
    }

    /** Created when the load is accepted (payer chosen at posting, D-09). */
    @Transactional(propagation = org.springframework.transaction.annotation.Propagation.REQUIRES_NEW)
    public void create(UUID loadId) {
        LoadDirectory.LoadInfo l = loads.get(loadId);
        jdbc.update("""
                insert into payments_record (load_id, payer, payee_driver_id, status, created_at, updated_at)
                values (?, ?, ?, 'PENDING', ?, ?) on conflict do nothing""",
                loadId, l.freightPaidBy().name(), l.driverId(), now(), now());
    }

    Map<String, Object> record(UUID loadId) {
        return jdbc.queryForList("select * from payments_record where load_id = ?", loadId).stream().findFirst().orElse(null);
    }

    /** Payer marks paid: shipper when SHIPPER pays, registered receiver when RECEIVER pays (public page in M12). */
    @Transactional
    public Map<String, Object> markPaid(UUID userId, UUID loadId, long amountInr, PaymentMode mode, String reference) {
        LoadDirectory.LoadInfo l = loads.find(loadId).orElseThrow(() -> ApiException.notFound("Load"));
        boolean payer = l.freightPaidBy() == FreightPayer.SHIPPER ? userId.equals(l.shipperId()) : userId.equals(l.receiverUserId());
        if (!payer) {
            throw new ApiException(ErrorCode.FORBIDDEN, "Only the payer marks this payment");
        }
        return markPaidBy(userId, l, amountInr, mode, reference);
    }

    /** Also used by the receiver's public tracking page (no account). */
    @Transactional
    public Map<String, Object> markPaidBy(UUID userId, LoadDirectory.LoadInfo l, long amountInr, PaymentMode mode, String reference) {
        Map<String, Object> r = record(l.id());
        if (r == null || l.status() == LoadStatus.CANCELLED) {
            throw new ApiException(ErrorCode.INVALID_STATE, "No payment for this load");
        }
        if (!"PENDING".equals(r.get("status")) && !"DISPUTED".equals(r.get("status"))) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Already marked paid");
        }
        if (amountInr <= 0 || mode == null) {
            throw ApiException.invalidField("amountInr", "Enter the amount and mode");
        }
        jdbc.update("""
                update payments_record set status = 'PAID', amount_inr = ?, mode = ?, reference = ?, marked_by = ?, paid_at = ?,
                dispute_reason = null, updated_at = ? where load_id = ?""",
                amountInr, mode.name(), reference, userId, now(), now(), l.id());
        notifier.notify(l.driverId(), NotificationTab.TRIPS, "PAYMENT_MARKED",
                Map.of("code", l.code(), "amount", String.valueOf(amountInr), "mode", mode.name()), "/driver/history");
        return view(l.id());
    }

    @Transactional
    public Map<String, Object> confirm(UUID driverId, UUID loadId, long amountInr) {
        LoadDirectory.LoadInfo l = driverLoad(driverId, loadId);
        Map<String, Object> r = record(loadId);
        if (r == null || !"PAID".equals(r.get("status"))) {
            throw new ApiException(ErrorCode.INVALID_STATE, "The payer has not marked this paid yet");
        }
        jdbc.update("update payments_record set status = 'CONFIRMED', confirmed_at = ?, updated_at = ? where load_id = ?", now(), now(), loadId);
        if (l.status() == LoadStatus.DELIVERED) {
            loads.close(loadId); // trip closed when payment is confirmed (§8)
        }
        Instant deliveredAt = l.deliveredAt() == null ? Instant.now(clock) : l.deliveredAt();
        boolean onTime = !Instant.now(clock).isAfter(deliveredAt.plus(Duration.ofDays(settings.getInt("payments.on_time_days"))));
        UUID payerUser = l.freightPaidBy() == FreightPayer.SHIPPER ? l.shipperId() : l.receiverUserId();
        events.publishEvent(new PaymentEvents.PaymentConfirmed(loadId, payerUser, onTime));
        if (payerUser != null) {
            notifier.notify(payerUser, NotificationTab.TRIPS, "PAYMENT_CONFIRMED", Map.of("code", l.code()), "/loads/" + loadId);
        }
        return view(loadId);
    }

    @Transactional
    public Map<String, Object> dispute(UUID driverId, UUID loadId, String reason) {
        LoadDirectory.LoadInfo l = driverLoad(driverId, loadId);
        Map<String, Object> r = record(loadId);
        if (r == null || !List.of("PENDING", "PAID").contains(r.get("status")) || l.status() != LoadStatus.DELIVERED) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Dispute only after delivery while payment is open");
        }
        jdbc.update("update payments_record set status = 'DISPUTED', dispute_reason = ?, updated_at = ? where load_id = ?", reason.trim(), now(), loadId);
        UUID payerUser = l.freightPaidBy() == FreightPayer.SHIPPER ? l.shipperId() : l.receiverUserId();
        events.publishEvent(new PaymentEvents.PaymentDisputed(loadId, driverId, payerUser, reason.trim()));
        if (payerUser != null) {
            notifier.notify(payerUser, NotificationTab.TRIPS, "PAYMENT_DISPUTED", Map.of("code", l.code()), "/loads/" + loadId);
        }
        return view(loadId);
    }

    /** Admin decision (B-120x): RELEASE (paid as marked) or AGAINST_PAYER / AGAINST_DRIVER. Closes the trip. */
    @Transactional
    public Map<String, Object> decideDispute(UUID adminId, UUID loadId, String decision) {
        LoadDirectory.LoadInfo l = loads.get(loadId);
        Map<String, Object> r = record(loadId);
        if (r == null || !"DISPUTED".equals(r.get("status"))) {
            throw new ApiException(ErrorCode.INVALID_STATE, "Not disputed");
        }
        UUID payerUser = l.freightPaidBy() == FreightPayer.SHIPPER ? l.shipperId() : l.receiverUserId();
        UUID against = switch (decision) {
            case "AGAINST_PAYER" -> payerUser;
            case "AGAINST_DRIVER" -> l.driverId();
            case "NO_FAULT" -> null;
            default -> throw ApiException.invalidField("decision", "AGAINST_PAYER, AGAINST_DRIVER or NO_FAULT");
        };
        jdbc.update("""
                update payments_record set status = 'CONFIRMED', resolution = ?, resolved_by = ?, resolved_at = ?, confirmed_at = ?,
                updated_at = ? where load_id = ?""", decision, adminId, now(), now(), now(), loadId);
        loads.close(loadId);
        events.publishEvent(new PaymentEvents.DisputeDecided(loadId, against, decision));
        return view(loadId);
    }

    Map<String, Object> view(UUID loadId) {
        Map<String, Object> r = record(loadId);
        if (r == null) {
            return null;
        }
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("status", r.get("status"));
        m.put("amountInr", r.get("amount_inr"));
        m.put("mode", r.get("mode"));
        m.put("reference", r.get("reference"));
        m.put("paidAt", r.get("paid_at") == null ? null : ((Timestamp) r.get("paid_at")).toInstant());
        m.put("confirmedAt", r.get("confirmed_at") == null ? null : ((Timestamp) r.get("confirmed_at")).toInstant());
        m.put("disputeReason", r.get("dispute_reason"));
        return m;
    }

    private LoadDirectory.LoadInfo driverLoad(UUID driverId, UUID loadId) {
        return loads.find(loadId).filter(x -> driverId.equals(x.driverId())).orElseThrow(() -> ApiException.notFound("Trip"));
    }

    // ------------------------------------------------------------------ driver history (B-807)

    @Transactional(readOnly = true)
    public Map<String, Object> driverHistory(UUID driverId, YearMonth month) {
        YearMonth m = month == null ? YearMonth.now(clock.withZone(IST)) : month;
        Instant from = m.atDay(1).atStartOfDay(IST).toInstant();
        Instant to = m.plusMonths(1).atDay(1).atStartOfDay(IST).toInstant();
        List<Map<String, Object>> items = loads.historyForDriver(driverId, from, to, 500);
        long trips = 0;
        long agreed = 0;
        long confirmed = 0;
        for (Map<String, Object> item : items) {
            if (!"DELIVERED".equals(String.valueOf(item.get("status")))) {
                continue;
            }
            trips++;
            long amount = ((Number) item.get("agreedAmountInr")).longValue();
            agreed += amount;
            if ("CONFIRMED".equals(String.valueOf(item.get("paymentStatus")))) {
                confirmed += amount;
            }
        }
        return Map.of("summary", Map.of("trips", trips, "agreedTotalInr", agreed, "confirmedInr", confirmed, "pendingInr", agreed - confirmed),
                "items", items);
    }
}

/** Creates the record at acceptance; adds payment to LoadDetail/summary. */
@Component
class PaymentWiring implements LoadEvents.DetailContributor {

    private final PaymentService payments;

    PaymentWiring(PaymentService payments) {
        this.payments = payments;
    }

    @TransactionalEventListener(fallbackExecution = true)
    void on(LoadEvents.StatusChanged e) {
        if (e.from() == LoadStatus.NOT_ACCEPTED && e.to() == LoadStatus.WAITING_FOR_PICKUP) {
            payments.create(e.loadId());
        }
    }

    @Override
    public void contribute(LoadDirectory.LoadInfo load, LoadDirectory.Viewer viewer, Map<String, Object> detail) {
        Map<String, Object> v = payments.view(load.id());
        if (v == null) {
            return;
        }
        detail.put("paymentStatus", v.get("status"));
        if (detail.containsKey("payment")) {
            detail.put("payment", v);
        }
    }
}
