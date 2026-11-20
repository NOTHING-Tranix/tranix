package com.nothing.tranix.wallet.internal;

import java.security.SecureRandom;
import java.sql.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import com.nothing.tranix.identity.api.UserDirectory;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.integrations.PaymentGateway;
import com.nothing.tranix.shared.settings.Settings;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * B-303/B-304: web-only top-up (D-13). The app gets a signed, short-lived link to the server page; the balance changes
 * only after a signature-verified, idempotent gateway webhook (hard rule 4).
 */
@Service
public class TopupService {

    private static final Logger log = LoggerFactory.getLogger(TopupService.class);
    private static final SecureRandom RANDOM = new SecureRandom();

    private final JdbcTemplate jdbc;
    private final WalletService wallet;
    private final PaymentGateway gateway;
    private final Settings settings;
    private final UserDirectory users;
    private final Clock clock;
    private final String publicBaseUrl;

    TopupService(JdbcTemplate jdbc, WalletService wallet, PaymentGateway gateway, Settings settings, UserDirectory users,
                 Clock clock, @Value("${tranix.public-base-url:http://localhost:8080}") String publicBaseUrl) {
        this.jdbc = jdbc;
        this.wallet = wallet;
        this.gateway = gateway;
        this.settings = settings;
        this.users = users;
        this.clock = clock;
        this.publicBaseUrl = publicBaseUrl.replaceAll("/$", "");
    }

    public record Link(String url, Instant expiresAt) {
    }

    @Transactional
    public Link createLink(UUID userId, long amountInr) {
        wallet.requireWalletOwner(userId);
        long min = settings.getInt("wallet.topup_min_inr");
        long max = settings.getInt("wallet.topup_max_inr");
        if (amountInr < min || amountInr > max) {
            throw ApiException.invalidField("amountInr", "Top up between ₹" + min + " and ₹" + max);
        }
        UUID account = wallet.ensureAccount(userId);
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        Instant now = Instant.now(clock);
        Instant expires = now.plusSeconds(60L * settings.getInt("wallet.topup_link_minutes"));
        jdbc.update("""
                insert into wallet_topup_order (id, account_id, amount_inr, status, link_token_hash, link_expires_at, created_at)
                values (?, ?, ?, 'CREATED', ?, ?, ?)""",
                UUID.randomUUID(), account, amountInr, sha256(token), Timestamp.from(expires), Timestamp.from(now));
        return new Link(publicBaseUrl + "/p/wallet/topup?t=" + token, expires);
    }

    /** What the top-up page shows. */
    public record PageModel(String state, long amountInr, String name, String language, String checkoutUrl) {
    }

    @Transactional
    public PageModel page(String token) {
        List<Map<String, Object>> rows = token == null ? List.of() : jdbc.queryForList("""
                select o.id, o.amount_inr, o.status, o.link_expires_at, o.gateway_order_id, a.owner_id
                from wallet_topup_order o join wallet_account a on a.id = o.account_id where o.link_token_hash = ?""",
                sha256(token));
        if (rows.isEmpty()) {
            return new PageModel("INVALID", 0, null, "en", null);
        }
        Map<String, Object> o = rows.getFirst();
        UserDirectory.UserView u = users.get((UUID) o.get("owner_id"));
        long amount = ((Number) o.get("amount_inr")).longValue();
        String lang = u.language().name();
        if ("PAID".equals(o.get("status"))) {
            return new PageModel("PAID", amount, u.name(), lang, null);
        }
        if (((Timestamp) o.get("link_expires_at")).toInstant().isBefore(Instant.now(clock))) {
            return new PageModel("EXPIRED", amount, u.name(), lang, null);
        }
        String gid = (String) o.get("gateway_order_id");
        String checkout;
        if (gid == null) {
            PaymentGateway.GatewayOrder g = gateway.createOrder(o.get("id").toString(), amount);
            jdbc.update("update wallet_topup_order set gateway_order_id = ? where id = ?", g.gatewayOrderId(), o.get("id"));
            checkout = g.checkoutUrl();
        } else {
            checkout = publicBaseUrl + "/dev/payments/" + gid;
        }
        return new PageModel("READY", amount, u.name(), lang, checkout);
    }

    public enum WebhookResult { CREDITED, DUPLICATE, IGNORED, BAD_SIGNATURE }

    /** B-304: verify → idempotent by event id → credit exactly the order amount once. */
    @Transactional
    public WebhookResult handleWebhook(String rawBody, String signature) {
        PaymentGateway.WebhookEvent e = gateway.verifyWebhook(rawBody, signature);
        if (e == null) {
            log.warn("Payment webhook with a bad signature rejected");
            return WebhookResult.BAD_SIGNATURE;
        }
        int inserted = jdbc.update("insert into wallet_webhook_event (event_id, received_at) values (?, ?) on conflict do nothing",
                e.eventId(), Timestamp.from(Instant.now(clock)));
        if (inserted == 0) {
            return WebhookResult.DUPLICATE;
        }
        List<Map<String, Object>> rows = jdbc.queryForList("""
                select o.id, o.amount_inr, o.status, a.owner_id from wallet_topup_order o
                join wallet_account a on a.id = o.account_id where o.gateway_order_id = ? for update of o""", e.gatewayOrderId());
        if (rows.isEmpty()) {
            log.warn("Payment webhook for an unknown order ignored");
            return WebhookResult.IGNORED;
        }
        Map<String, Object> o = rows.getFirst();
        UUID orderId = (UUID) o.get("id");
        long amount = ((Number) o.get("amount_inr")).longValue();
        if (!"CREATED".equals(o.get("status"))) {
            return WebhookResult.DUPLICATE;
        }
        if (!e.paid()) {
            jdbc.update("update wallet_topup_order set status = 'FAILED' where id = ?", orderId);
            return WebhookResult.IGNORED;
        }
        if (e.amountInr() != amount) {
            log.warn("Payment webhook amount mismatch for order {}", orderId);
            return WebhookResult.IGNORED;
        }
        wallet.topup((UUID) o.get("owner_id"), amount, orderId);
        jdbc.update("update wallet_topup_order set status = 'PAID', paid_at = ? where id = ?", Timestamp.from(Instant.now(clock)), orderId);
        return WebhookResult.CREDITED;
    }

    @Transactional(readOnly = true)
    public Long amountForGatewayOrder(String gatewayOrderId) {
        List<Long> a = jdbc.queryForList("select amount_inr from wallet_topup_order where gateway_order_id = ?", Long.class, gatewayOrderId);
        return a.isEmpty() ? null : a.getFirst();
    }

    static String sha256(String v) {
        try {
            return java.util.HexFormat.of().formatHex(java.security.MessageDigest.getInstance("SHA-256")
                    .digest(v.getBytes(java.nio.charset.StandardCharsets.UTF_8)));
        } catch (Exception ex) {
            throw new IllegalStateException(ex);
        }
    }
}
