package com.nothing.tranix.shared.web;

import java.io.IOException;
import java.time.Clock;
import java.time.Instant;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.slf4j.MDC;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * B-1402: every request gets an id ({@code X-Request-Id}, echoed back and put in the log MDC as {@code requestId}).
 * Logs never contain bodies, tokens, OTPs or full mobiles (hard rule 14).
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
class RequestIdFilter extends OncePerRequestFilter {

    static final String HEADER = "X-Request-Id";

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        String incoming = request.getHeader(HEADER);
        String id = incoming != null && incoming.matches("[A-Za-z0-9-]{8,64}") ? incoming : UUID.randomUUID().toString();
        MDC.put("requestId", id);
        response.setHeader(HEADER, id);
        try {
            chain.doFilter(request, response);
        } finally {
            MDC.remove("requestId");
        }
    }
}

/**
 * B-1401: fixed-window limits per client IP for the unauthenticated surfaces — sign-up/sign-in/OTP and the public
 * tracking link (the OTP service also has its own per-mobile cooldown). In-memory per instance; use a shared store
 * when running more than one instance. Answers {@code 429 RATE_LIMITED} as a contract Problem.
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE + 10)
class RateLimitFilter extends OncePerRequestFilter {

    private record Window(long start, int count) {
    }

    private final Map<String, Window> windows = new ConcurrentHashMap<>();
    private final Clock clock;
    private final int authPerMinute;
    private final int publicPerMinute;

    RateLimitFilter(Clock clock, @Value("${tranix.rate-limit.auth-per-minute:20}") int authPerMinute,
                    @Value("${tranix.rate-limit.public-per-minute:120}") int publicPerMinute) {
        this.clock = clock;
        this.authPerMinute = authPerMinute;
        this.publicPerMinute = publicPerMinute;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String p = request.getRequestURI();
        return !(p.startsWith("/api/v1/auth/") || p.startsWith("/api/v1/public/") || p.startsWith("/p/track/"));
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        boolean auth = request.getRequestURI().startsWith("/api/v1/auth/");
        String key = (auth ? "a:" : "p:") + clientIp(request);
        long minute = Instant.now(clock).getEpochSecond() / 60;
        Window w = windows.compute(key, (k, old) -> old == null || old.start() != minute ? new Window(minute, 1) : new Window(minute, old.count() + 1));
        if (w.count() > (auth ? authPerMinute : publicPerMinute)) {
            response.setStatus(429);
            response.setHeader("Retry-After", "60");
            response.setContentType("application/problem+json");
            response.getWriter().write("{\"type\":\"about:blank\",\"title\":\"Too many requests\",\"status\":429,\"code\":\"RATE_LIMITED\","
                    + "\"detail\":\"Too many requests. Try again in a minute.\",\"fields\":[]}");
            return;
        }
        if (windows.size() > 50_000) {
            windows.entrySet().removeIf(e -> e.getValue().start() < minute);
        }
        chain.doFilter(request, response);
    }

    private static String clientIp(HttpServletRequest request) {
        String fwd = request.getHeader("X-Forwarded-For"); // set by the load balancer in production
        return fwd != null && !fwd.isBlank() ? fwd.split(",")[0].trim() : request.getRemoteAddr();
    }
}
