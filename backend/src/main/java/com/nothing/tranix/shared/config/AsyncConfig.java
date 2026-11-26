package com.nothing.tranix.shared.config;

import java.util.Map;
import java.util.concurrent.ThreadPoolExecutor;

import org.slf4j.MDC;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.SyncTaskExecutor;
import org.springframework.core.task.TaskExecutor;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

/**
 * B-1611: after-commit event listeners (notifications, matching, trust, tickets…) run on this small pool instead of
 * the request thread. On the request thread they ran while the request still held its database connection and opened
 * a second one, so ~10 simultaneous write requests used up the whole pool and stalled for 30 s (connection timeout).
 * Here each listener uses one connection after the request has released its own.
 * <p>Tests keep them synchronous ({@code tranix.async.after-commit=false}) so assertions can follow right away.
 */
@Configuration(proxyBeanMethods = false)
@EnableAsync
public class AsyncConfig {

    /** Qualifier for {@code @Async(AsyncConfig.AFTER_COMMIT)} on {@code @TransactionalEventListener} methods. */
    public static final String AFTER_COMMIT = "afterCommitExecutor";

    @Bean(name = AFTER_COMMIT)
    TaskExecutor afterCommitExecutor(@Value("${tranix.async.after-commit:true}") boolean async,
                                     @Value("${tranix.async.threads:8}") int threads) {
        if (!async) {
            return new SyncTaskExecutor();
        }
        ThreadPoolTaskExecutor ex = new ThreadPoolTaskExecutor();
        ex.setCorePoolSize(Math.max(1, threads / 2));
        ex.setMaxPoolSize(threads);
        ex.setQueueCapacity(5000);
        ex.setThreadNamePrefix("after-commit-");
        // a full queue degrades to the old behaviour (run on the request thread) instead of dropping events
        ex.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        ex.setWaitForTasksToCompleteOnShutdown(true);
        ex.setAwaitTerminationSeconds(30);
        ex.setTaskDecorator(task -> {
            Map<String, String> mdc = MDC.getCopyOfContextMap();   // keep the request id in the log
            return () -> {
                if (mdc != null) {
                    MDC.setContextMap(mdc);
                }
                try {
                    task.run();
                } finally {
                    MDC.clear();
                }
            };
        });
        ex.initialize();
        return ex;
    }
}
