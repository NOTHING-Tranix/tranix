package com.nothing.tranix.wallet;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.net.URI;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;
import com.nothing.tranix.shared.error.ApiException;
import com.nothing.tranix.shared.integrations.fake.FakePaymentGateway;
import com.nothing.tranix.wallet.api.WalletApi;
import com.nothing.tranix.wallet.internal.WalletService;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;

/** B-301…B-308, B-1101. */
@IntegrationTest
@Import(TestApi.class)
class WalletIT {

    @Autowired
    TestApi api;

    @Autowired
    MockMvc mvc;

    @Autowired
    FakePaymentGateway gateway;

    @Autowired
    WalletService wallet;

    @Autowired
    JdbcTemplate jdbc;

    /** Top-up through link → page → signed webhook. Returns the gateway order id. */
    String topup(TestApi.Session s, long amount) throws Exception {
        String link = api.body(api.send("/api/v1/wallet/topup-link", Map.of("amountInr", amount), s).andExpect(status().isOk()));
        URI url = URI.create(JsonPath.read(link, "$.url"));
        mvc.perform(get(url.getPath() + "?" + url.getQuery())).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("₹" + String.format("%,d", amount))));
        String gid = jdbc.queryForObject("select gateway_order_id from wallet_topup_order o join wallet_account a on a.id = o.account_id"
                + " where a.owner_id = ? order by o.created_at desc limit 1", String.class, s.userId());
        String body = "evt_" + UUID.randomUUID() + "|" + gid + "|PAID|" + amount;
        mvc.perform(post("/api/v1/webhooks/payments").contentType(MediaType.TEXT_PLAIN).content(body)
                        .header("X-Signature", gateway.sign(body)))
                .andExpect(status().isOk()).andExpect(jsonPath("$.result").value("CREDITED"));
        // same event again → no second credit
        mvc.perform(post("/api/v1/webhooks/payments").contentType(MediaType.TEXT_PLAIN).content(body)
                .header("X-Signature", gateway.sign(body))).andExpect(jsonPath("$.result").value("DUPLICATE"));
        // a different event for the same order → still no second credit
        String again = "evt_" + UUID.randomUUID() + "|" + gid + "|PAID|" + amount;
        mvc.perform(post("/api/v1/webhooks/payments").contentType(MediaType.TEXT_PLAIN).content(again)
                .header("X-Signature", gateway.sign(again))).andExpect(jsonPath("$.result").value("DUPLICATE"));
        return gid;
    }

    @Test
    void topupFlowCreditsOnceAfterVerifiedWebhook() throws Exception {
        TestApi.Session s = api.signUp("LOAD_PROVIDER");
        api.get("/api/v1/wallet", s).andExpect(jsonPath("$.balanceInr").value(0)).andExpect(jsonPath("$.lowBalance").value(true));
        String gid = topup(s, 1000);
        api.get("/api/v1/wallet", s).andExpect(jsonPath("$.balanceInr").value(1000))
                .andExpect(jsonPath("$.postingChargeInr").value(50)).andExpect(jsonPath("$.lowBalance").value(false));
        api.get("/api/v1/me", s).andExpect(jsonPath("$.walletBalanceInr").value(1000));

        String forged = "evt_x|" + gid + "|PAID|5000";
        mvc.perform(post("/api/v1/webhooks/payments").contentType(MediaType.TEXT_PLAIN).content(forged)
                .header("X-Signature", "nope")).andExpect(status().isBadRequest());

        api.get("/api/v1/wallet/transactions?type=TOPUP&month=" + YearMonth.now(), s)
                .andExpect(jsonPath("$.total").value(1)).andExpect(jsonPath("$.items[0].direction").value("CREDIT"))
                .andExpect(jsonPath("$.items[0].txnId").value(org.hamcrest.Matchers.startsWith("TXN-")));
        byte[] pdf = api.get("/api/v1/wallet/statement?month=" + YearMonth.now(), s).andExpect(status().isOk())
                .andReturn().getResponse().getContentAsByteArray();
        assertThat(new String(pdf, 0, 5)).isEqualTo("%PDF-");

        api.get("/api/v1/notifications/summary", s).andExpect(jsonPath("$.unreadByTab.WALLET").value(1));
        String list = api.body(api.get("/api/v1/notifications?tab=WALLET", s).andExpect(jsonPath("$.items[0].type").value("TOPUP_SUCCESS")));
        String id = JsonPath.read(list, "$.items[0].id");
        api.send("/api/v1/notifications/" + id + "/read", Map.of(), s).andExpect(status().isNoContent());
        api.get("/api/v1/me", s).andExpect(jsonPath("$.unreadNotifications").value(0));
    }

    @Test
    void topupLimitsAndReceiverHasNoWallet() throws Exception {
        TestApi.Session s = api.signUp("DRIVER");
        api.send("/api/v1/wallet/topup-link", Map.of("amountInr", 10), s)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("amountInr"));
        TestApi.Session r = api.signUp("RECEIVER");
        api.get("/api/v1/wallet", r).andExpect(status().isForbidden());
        api.get("/api/v1/me", r).andExpect(jsonPath("$.walletBalanceInr").doesNotExist());
        mvc.perform(get("/p/wallet/topup?t=not-a-token")).andExpect(status().isOk())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("not valid")));
    }

    @Test
    void chargesAreIdempotentLedgerIsAppendOnlyAndLowBalanceNotifies() throws Exception {
        TestApi.Session s = api.signUp("LOAD_PROVIDER");
        topup(s, 100);
        UUID load = UUID.randomUUID();
        String t1 = wallet.charge(s.userId(), WalletApi.ChargeType.POSTING_CHARGE, load);
        String t2 = wallet.charge(s.userId(), WalletApi.ChargeType.POSTING_CHARGE, load);
        assertThat(t1).isEqualTo(t2);
        assertThat(wallet.balance(s.userId())).isEqualTo(50);
        wallet.charge(s.userId(), WalletApi.ChargeType.POSTING_CHARGE, UUID.randomUUID());
        assertThatThrownBy(() -> wallet.charge(s.userId(), WalletApi.ChargeType.POSTING_CHARGE, UUID.randomUUID()))
                .isInstanceOf(ApiException.class).hasMessageContaining("needs");
        api.get("/api/v1/notifications?tab=WALLET", s).andExpect(jsonPath("$.items[?(@.type=='LOW_BALANCE')]").isNotEmpty());
        assertThatThrownBy(() -> jdbc.update("update wallet_entry set amount_inr = 1 where txn_id = ?", t1))
                .hasMessageContaining("append-only");
        Long sum = jdbc.queryForObject("""
                select sum(case when direction = 'CREDIT' then amount_inr else -amount_inr end) from wallet_entry e
                join wallet_account a on a.id = e.account_id where a.owner_id = ?""", Long.class, s.userId());
        assertThat(sum).isEqualTo(wallet.balance(s.userId()));
    }

    @Test
    void twoChargesAtOnceCannotOverdraw() throws Exception {
        TestApi.Session s = api.signUp("DRIVER");
        topup(s, 100);
        wallet.charge(s.userId(), WalletApi.ChargeType.TRIP_CHARGE, UUID.randomUUID()); // 50 left = one more charge
        ExecutorService pool = Executors.newFixedThreadPool(4);
        CountDownLatch start = new CountDownLatch(1);
        List<Future<Boolean>> results = new ArrayList<>();
        for (int i = 0; i < 4; i++) {
            Callable<Boolean> c = () -> {
                start.await();
                try {
                    wallet.charge(s.userId(), WalletApi.ChargeType.TRIP_CHARGE, UUID.randomUUID());
                    return true;
                } catch (ApiException e) {
                    return false;
                }
            };
            results.add(pool.submit(c));
        }
        start.countDown();
        int ok = 0;
        for (Future<Boolean> f : results) {
            ok += f.get() ? 1 : 0;
        }
        pool.shutdown();
        assertThat(ok).isEqualTo(1);
        assertThat(wallet.balance(s.userId())).isZero();
    }

    @Test
    void adminCreditAndRefundAreAudited() throws Exception {
        TestApi.Session s = api.signUp("ORGANIZATION");
        TestApi.Session admin = api.admin();
        api.send("/api/v1/admin/wallet/" + s.userId() + "/credit", Map.of("amountInr", 200), admin)
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.fields[0].field").value("reason"));
        api.send("/api/v1/admin/wallet/" + s.userId() + "/credit", Map.of("amountInr", 200, "reason", "Launch offer"), admin)
                .andExpect(status().isOk());
        UUID load = UUID.randomUUID();
        api.send("/api/v1/admin/wallet/" + s.userId() + "/refund", Map.of("amountInr", 50, "reason", "Cancelled", "loadId", load), admin)
                .andExpect(status().isOk());
        api.send("/api/v1/admin/wallet/" + s.userId() + "/refund", Map.of("amountInr", 50, "reason", "Cancelled", "loadId", load), admin)
                .andExpect(status().isOk());
        assertThat(wallet.balance(s.userId())).isEqualTo(250);
        assertThat(jdbc.queryForObject("select count(*) from admin_audit where entity = 'WALLET' and entity_id = ?",
                Integer.class, s.userId().toString())).isEqualTo(2);
        api.send("/api/v1/admin/wallet/" + s.userId() + "/credit", Map.of("amountInr", 1, "reason", "x"), s)
                .andExpect(status().isForbidden());
    }
}
