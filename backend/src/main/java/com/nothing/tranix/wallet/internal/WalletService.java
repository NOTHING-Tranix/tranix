package com.nothing.tranix.wallet.internal;

import java.sql.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.identity.api.MeContributor;
import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.shared.audit.AuditLog;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.error.ErrorCode;
import com.nothing.tranix.shared.settings.SettingKeys;
import com.nothing.tranix.shared.settings.Settings;
import com.nothing.tranix.shared.types.Role;
import com.nothing.tranix.shared.types.TxnType;
import com.nothing.tranix.wallet.api.OrganizationPays;
import com.nothing.tranix.wallet.api.WalletApi;
import com.nothing.tranix.wallet.api.WalletEvents;

import org.springframework.context.ApplicationEventPublisher;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * Append-only ledger (hard rule 3): every change is a {@code wallet_entry}; the cached balance on
 * {@code wallet_account} is updated in the same transaction under a row lock ({@code SELECT … FOR UPDATE}).
 */
@Service
public class WalletService implements WalletApi, MeContributor {

    static final ZoneId IST = ZoneId.of("Asia/Kolkata");

    private final JdbcTemplate jdbc;
    private final Settings settings;
    private final UserDirectory users;
    private final AuditLog audit;
    private final ApplicationEventPublisher events;
    private final Clock clock;
    private final ObjectProvider<OrganizationPays> organizationPays;

    WalletService(JdbcTemplate jdbc, Settings settings, UserDirectory users, AuditLog audit,
                  ApplicationEventPublisher events, Clock clock, ObjectProvider<OrganizationPays> organizationPays) {
        this.jdbc = jdbc;
        this.settings = settings;
        this.users = users;
        this.audit = audit;
        this.events = events;
        this.clock = clock;
        this.organizationPays = organizationPays;
    }

    /** B-1608: an Organization's driver has no own wallet; the Organization's wallet pays their trip charges. */
    boolean paidByOrganization(UUID userId, Role role) {
        if (role != Role.DRIVER) {
            return false;
        }
        OrganizationPays org = organizationPays.getIfAvailable();
        return org != null && org.forDriver(userId);
    }

    static boolean hasWallet(Role role) {
        return role == Role.LOAD_PROVIDER || role == Role.FARMER_NETWORK || role == Role.DRIVER || role == Role.ORGANIZATION;
    }

    /** The charge this owner's role needs (used for low-balance). */
    ChargeType neededCharge(Role role) {
        return role == Role.DRIVER || role == Role.ORGANIZATION ? ChargeType.TRIP_CHARGE : ChargeType.POSTING_CHARGE;
    }

    // ----------------------------------------------------------------- accounts

    /** Creates the account on first use (works inside read-only callers too). */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public UUID ensureAccount(UUID ownerUserId) {
        Instant now = Instant.now(clock);
        jdbc.update("""
                insert into wallet_account (id, owner_type, owner_id, cached_balance_inr, created_at, updated_at, version)
                values (?, 'USER', ?, 0, ?, ?, 0) on conflict (owner_type, owner_id) do nothing""",
                UUID.randomUUID(), ownerUserId, Timestamp.from(now), Timestamp.from(now));
        return jdbc.queryForObject("select id from wallet_account where owner_type = 'USER' and owner_id = ?", UUID.class, ownerUserId);
    }

    @Override
    @Transactional(readOnly = true)
    public long balance(UUID ownerUserId) {
        List<Long> b = jdbc.queryForList(
                "select cached_balance_inr from wallet_account where owner_type = 'USER' and owner_id = ?", Long.class, ownerUserId);
        return b.isEmpty() ? 0 : b.getFirst();
    }

    @Override
    public long chargeAmount(ChargeType type) {
        return settings.getInt(type == ChargeType.POSTING_CHARGE ? SettingKeys.POSTING_CHARGE_INR : SettingKeys.TRIP_CHARGE_INR);
    }

    @Override
    public boolean hasBalance(UUID ownerUserId, ChargeType type) {
        return balance(ownerUserId) >= chargeAmount(type);
    }

    // ----------------------------------------------------------------- ledger

    record Posted(String txnId, long balance, boolean duplicate) {
    }

    /** Posts one entry under a row lock. A repeated {@code idemKey} returns the first entry and changes nothing. */
    Posted post(UUID ownerUserId, TxnType type, boolean credit, long amount, UUID loadId, UUID orderId, String note,
                String idemKey, UUID createdBy) {
        if (amount <= 0) {
            throw ApiException.invalidField("amountInr", "Amount must be positive");
        }
        UUID account = ensureAccount(ownerUserId);
        long balance = jdbc.queryForObject("select cached_balance_inr from wallet_account where id = ? for update", Long.class, account);
        if (idemKey != null) {
            List<String> existing = jdbc.queryForList("select txn_id from wallet_entry where idem_key = ?", String.class, idemKey);
            if (!existing.isEmpty()) {
                return new Posted(existing.getFirst(), balance, true);
            }
        }
        long next = credit ? balance + amount : balance - amount;
        if (next < 0) {
            throw new ApiException(ErrorCode.INSUFFICIENT_BALANCE, "Wallet balance is ₹" + balance + ", needs ₹" + amount);
        }
        String txnId = "TXN-" + String.format("%06d", jdbc.queryForObject("select nextval('wallet_txn_seq')", Long.class));
        Instant now = Instant.now(clock);
        jdbc.update("""
                insert into wallet_entry (txn_id, account_id, type, direction, amount_inr, load_id, order_id, note, idem_key, created_by, created_at)
                values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                txnId, account, type.name(), credit ? "CREDIT" : "DEBIT", amount, loadId, orderId, note, idemKey, createdBy,
                Timestamp.from(now));
        jdbc.update("update wallet_account set cached_balance_inr = ?, updated_at = ?, version = version + 1 where id = ?",
                next, Timestamp.from(now), account);
        if (credit) {
            events.publishEvent(new WalletEvents.Credited(ownerUserId, type.name(), amount, next, txnId));
        } else {
            events.publishEvent(new WalletEvents.Debited(ownerUserId, type.name(), amount, next, loadId, txnId));
            users.find(ownerUserId).ifPresent(u -> {
                long needed = chargeAmount(neededCharge(u.role()));
                if (next < needed && balance >= needed) {
                    events.publishEvent(new WalletEvents.LowBalance(ownerUserId, next, needed));
                }
            });
        }
        return new Posted(txnId, next, false);
    }

    @Override
    @Transactional
    public String charge(UUID ownerUserId, ChargeType type, UUID loadId) {
        TxnType t = type == ChargeType.POSTING_CHARGE ? TxnType.POSTING_CHARGE : TxnType.TRIP_CHARGE;
        return post(ownerUserId, t, false, chargeAmount(type), loadId, null, null, "CHARGE:" + t + ":" + loadId, null).txnId();
    }

    @Override
    @Transactional
    public String refund(UUID ownerUserId, long amountInr, UUID loadId, String note, UUID adminId) {
        String key = loadId == null ? null : "REFUND:" + ownerUserId + ":" + loadId;
        Posted p = post(ownerUserId, TxnType.REFUND, true, amountInr, loadId, null, note, key, adminId);
        if (!p.duplicate()) {
            audit.record(adminId, "WALLET_REFUND", "WALLET", ownerUserId, null, amountInr + " INR", note);
        }
        return p.txnId();
    }

    /** B-306. */
    @Transactional
    public String adminCredit(UUID ownerUserId, long amountInr, String reason, UUID adminId) {
        requireReason(reason);
        requireWalletOwner(ownerUserId);
        String txn = post(ownerUserId, TxnType.ADMIN_CREDIT, true, amountInr, null, null, reason, null, adminId).txnId();
        audit.record(adminId, "WALLET_ADMIN_CREDIT", "WALLET", ownerUserId, null, amountInr + " INR " + txn, reason);
        return txn;
    }

    @Transactional
    public String adminRefund(UUID ownerUserId, long amountInr, UUID loadId, String reason, UUID adminId) {
        requireReason(reason);
        requireWalletOwner(ownerUserId);
        return refund(ownerUserId, amountInr, loadId, reason, adminId);
    }

    /** Called by the verified top-up webhook. Idempotent per order. */
    @Transactional
    String topup(UUID ownerUserId, long amountInr, UUID orderId) {
        return post(ownerUserId, TxnType.TOPUP, true, amountInr, null, orderId, null, "TOPUP:" + orderId, null).txnId();
    }

    private static void requireReason(String reason) {
        if (reason == null || reason.isBlank()) {
            throw ApiException.invalidField("reason", "Give a reason");
        }
    }

    UserDirectory.UserView requireWalletOwner(UUID userId) {
        UserDirectory.UserView u = users.get(userId);
        if (!hasWallet(u.role())) {
            throw new ApiException(ErrorCode.FORBIDDEN, "This account has no wallet");
        }
        if (paidByOrganization(userId, u.role())) {
            throw new ApiException(ErrorCode.FORBIDDEN, "Your Organization's wallet pays your trip charges");
        }
        return u;
    }

    // ----------------------------------------------------------------- reads (B-302)

    @Transactional(readOnly = true)
    public Map<String, Object> wallet(UUID userId) {
        UserDirectory.UserView u = requireWalletOwner(userId);
        long balance = balance(userId);
        Map<String, Object> m = new HashMap<>();
        m.put("balanceInr", balance);
        m.put("postingChargeInr", chargeAmount(ChargeType.POSTING_CHARGE));
        m.put("tripChargeInr", chargeAmount(ChargeType.TRIP_CHARGE));
        m.put("lowBalance", balance < chargeAmount(neededCharge(u.role())));
        return m;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> transactions(UUID userId, TxnType type, YearMonth month, int page, int size) {
        requireWalletOwner(userId);
        StringBuilder where = new StringBuilder(" from wallet_entry e join wallet_account a on a.id = e.account_id"
                + " where a.owner_type = 'USER' and a.owner_id = ?");
        List<Object> args = new ArrayList<>(List.of(userId));
        if (type != null) {
            where.append(" and e.type = ?");
            args.add(type.name());
        }
        if (month != null) {
            where.append(" and e.created_at >= ? and e.created_at < ?");
            args.add(Timestamp.from(month.atDay(1).atStartOfDay(IST).toInstant()));
            args.add(Timestamp.from(month.plusMonths(1).atDay(1).atStartOfDay(IST).toInstant()));
        }
        long total = jdbc.queryForObject("select count(*)" + where, Long.class, args.toArray());
        List<Object> pageArgs = new ArrayList<>(args);
        pageArgs.add(size);
        pageArgs.add((long) page * size);
        List<Map<String, Object>> items = jdbc.query(
                "select e.txn_id, e.created_at, e.amount_inr, e.direction, e.type, e.load_id, e.note" + where
                        + " order by e.created_at desc, e.txn_id desc limit ? offset ?",
                (rs, i) -> {
                    Map<String, Object> m = new HashMap<>();
                    m.put("txnId", rs.getString("txn_id"));
                    m.put("at", rs.getTimestamp("created_at").toInstant());
                    m.put("amountInr", rs.getLong("amount_inr"));
                    m.put("direction", rs.getString("direction"));
                    m.put("type", rs.getString("type"));
                    m.put("loadId", rs.getObject("load_id"));
                    m.put("note", rs.getString("note"));
                    return m;
                }, pageArgs.toArray());
        return Map.of("items", items, "page", page, "size", size, "total", total);
    }

    @Transactional(readOnly = true)
    public byte[] statementPdf(UUID userId, YearMonth month) {
        UserDirectory.UserView u = requireWalletOwner(userId);
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> items = (List<Map<String, Object>>) transactions(userId, null, month, 0, 1000).get("items");
        List<String> lines = new ArrayList<>();
        lines.add("Tranix wallet statement - " + month);
        lines.add(u.name() + "   Generated " + LocalDate.now(clock.withZone(IST)));
        lines.add("Closing balance today: INR " + balance(userId));
        lines.add("");
        lines.add(String.format("%-12s %-17s %-15s %-7s %10s", "Txn", "Time (IST)", "Type", "Dir", "Amount"));
        for (Map<String, Object> m : items.reversed()) {
            lines.add(String.format("%-12s %-17s %-15s %-7s %10s", m.get("txnId"),
                    ((Instant) m.get("at")).atZone(IST).toLocalDateTime().toString().replace('T', ' ').substring(0, 16),
                    m.get("type"), m.get("direction"), "INR " + m.get("amountInr")));
        }
        if (items.isEmpty()) {
            lines.add("No transactions in this month.");
        }
        return SimplePdf.render(lines);
    }

    // ----------------------------------------------------------------- Me

    @Override
    public Map<String, Object> contribute(UUID userId, Role role) {
        Map<String, Object> m = new HashMap<>();
        m.put("walletBalanceInr", hasWallet(role) && !paidByOrganization(userId, role) ? balance(userId) : null);
        return m;
    }

    /** For other wallet classes: rethrows unique-key races as idempotent no-ops. */
    static boolean isDuplicate(RuntimeException e) {
        return e instanceof DuplicateKeyException;
    }
}
