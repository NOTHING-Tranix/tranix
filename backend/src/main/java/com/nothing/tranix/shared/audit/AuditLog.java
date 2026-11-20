package com.nothing.tranix.shared.audit;

import java.sql.Timestamp;
import java.time.Clock;
import java.time.Instant;
import java.util.UUID;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

/** Append-only audit log ({@code admin_audit}). Never write personal data such as full mobiles or OTPs. */
@Service
public class AuditLog {

    private final JdbcTemplate jdbc;
    private final Clock clock;

    public AuditLog(JdbcTemplate jdbc, Clock clock) {
        this.jdbc = jdbc;
        this.clock = clock;
    }

    public void record(UUID actorId, String action, String entity, Object entityId, String before, String after,
                       String reason) {
        jdbc.update("""
                insert into admin_audit (id, actor_id, action, entity, entity_id, before, after, reason, at)
                values (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                UUID.randomUUID(), actorId, action, entity, entityId == null ? null : entityId.toString(),
                before, after, reason, Timestamp.from(Instant.now(clock)));
    }
}
