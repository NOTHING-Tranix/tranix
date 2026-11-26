package com.nothing.tranix.shared;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import com.jayway.jsonpath.JsonPath;
import com.nothing.tranix.IntegrationTest;
import com.nothing.tranix.TestApi;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.TestPropertySource;

/**
 * B-1611: 20 simultaneous write requests on a 10-connection pool. Before the fix the after-commit listeners took a
 * second connection while the request still held its first, so about half of these failed after a 30 s pool timeout.
 */
@IntegrationTest
@Import(TestApi.class)
@TestPropertySource(properties = {"tranix.async.after-commit=true", "spring.datasource.hikari.maximum-pool-size=10",
        "spring.datasource.hikari.connection-timeout=5000"})
class BurstIT {

    @Autowired
    TestApi api;

    @Test
    void twentySimultaneousCreditsAllSucceedAndAddUp() throws Exception {
        TestApi.Session admin = api.admin();
        TestApi.Session user = api.verified("LOAD_PROVIDER");
        int n = 20;
        CountDownLatch start = new CountDownLatch(1);
        ExecutorService pool = Executors.newFixedThreadPool(n);
        List<Future<Integer>> results = new ArrayList<>();
        for (int i = 0; i < n; i++) {
            int k = i;
            Callable<Integer> credit = () -> {
                start.await();
                return api.send("/api/v1/admin/wallet/" + user.userId() + "/credit",
                        Map.of("amountInr", 10, "reason", "burst " + k), admin).andReturn().getResponse().getStatus();
            };
            results.add(pool.submit(credit));
        }
        long t0 = System.currentTimeMillis();
        start.countDown();
        List<Integer> codes = new ArrayList<>();
        for (Future<Integer> f : results) {
            codes.add(f.get());
        }
        pool.shutdown();
        long ms = System.currentTimeMillis() - t0;

        assertThat(codes).as("all 20 credits succeed").containsOnly(200);
        assertThat(ms).as("no pool stall (the old failure waited for the connection timeout)").isLessThan(5000);
        Number balance = JsonPath.read(api.body(api.get("/api/v1/wallet", user)), "$.balanceInr");
        assertThat(balance.longValue()).isEqualTo(200);

        // the notifications are written in the background: all 20 arrive shortly after
        long deadline = System.currentTimeMillis() + 10_000;
        int notes = 0;
        while (System.currentTimeMillis() < deadline) {
            notes = ((List<?>) JsonPath.read(api.body(api.get("/api/v1/notifications?tab=WALLET&size=50", user)), "$.items")).size();
            if (notes >= n) {
                break;
            }
            Thread.sleep(200);
        }
        assertThat(notes).as("one wallet notification per credit").isGreaterThanOrEqualTo(n);
    }
}
