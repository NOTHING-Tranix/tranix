package com.nothing.tranix.identity.internal;

import java.util.List;
import java.util.UUID;

import com.nothing.tranix.shared.security.AccountStatus;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/** B-1603: a suspended user's access tokens stop working immediately — one primary-key lookup per request. */
@Component
class SuspendedAccountCheck implements AccountStatus {

    private final JdbcTemplate jdbc;

    SuspendedAccountCheck(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Override
    public boolean isBlocked(UUID userId) {
        List<Boolean> rows = jdbc.queryForList("select suspended_at is not null from identity_user where id = ?", Boolean.class, userId);
        return !rows.isEmpty() && Boolean.TRUE.equals(rows.getFirst());
    }
}
