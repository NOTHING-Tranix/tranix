-- B-006: all tunable values (CLAUDE.md hard rule 11). Changed by Admin only, every change audited (Phase 12).
CREATE TABLE admin_setting (
    key         VARCHAR(100) PRIMARY KEY,
    value       TEXT         NOT NULL,
    type        VARCHAR(20)  NOT NULL
        CHECK (type IN ('INT', 'DECIMAL', 'BOOLEAN', 'STRING', 'INT_LIST', 'STRING_LIST')),
    description TEXT,
    updated_by  UUID,
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);
