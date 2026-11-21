-- M13: support tickets (B-1104/B-1105) and broadcasts (B-1103).
CREATE TABLE support_ticket (
    id                UUID PRIMARY KEY,
    code              VARCHAR(12)  NOT NULL UNIQUE,
    user_id           UUID         NOT NULL,
    type              VARCHAR(20)  NOT NULL,
    other_text        VARCHAR(60),
    load_id           UUID,
    description       VARCHAR(1000) NOT NULL,
    file_ids          TEXT         NOT NULL DEFAULT '',
    source            VARCHAR(30)  NOT NULL DEFAULT 'USER',
    status            VARCHAR(10)  NOT NULL CHECK (status IN ('OPEN','CLOSED')),
    close_reason      VARCHAR(300),
    closed_at         TIMESTAMPTZ,
    unread_for_user   BOOLEAN      NOT NULL DEFAULT FALSE,
    unread_for_admin  BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ  NOT NULL,
    updated_at        TIMESTAMPTZ  NOT NULL
);
CREATE INDEX support_ticket_user_idx ON support_ticket (user_id, updated_at DESC);
CREATE INDEX support_ticket_status_idx ON support_ticket (status, updated_at DESC);
CREATE SEQUENCE support_ticket_seq START 1;

CREATE TABLE support_message (
    id          UUID PRIMARY KEY,
    ticket_id   UUID          NOT NULL REFERENCES support_ticket (id),
    author      VARCHAR(10)   NOT NULL CHECK (author IN ('USER','ADMIN','SYSTEM')),
    author_id   UUID,
    body        VARCHAR(1000) NOT NULL,
    file_ids    TEXT          NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ   NOT NULL
);
CREATE INDEX support_message_ticket_idx ON support_message (ticket_id, created_at);

CREATE TABLE engagement_broadcast (
    id              UUID PRIMARY KEY,
    title           VARCHAR(80)   NOT NULL,
    body            VARCHAR(500)  NOT NULL,
    audience        VARCHAR(10)   NOT NULL CHECK (audience IN ('ALL','ROLE','DISTRICT','USER')),
    role            VARCHAR(20),
    district        VARCHAR(100),
    user_id         UUID,
    send_at         TIMESTAMPTZ   NOT NULL,
    sent_at         TIMESTAMPTZ,
    recipients      INT,
    created_by      UUID          NOT NULL,
    created_at      TIMESTAMPTZ   NOT NULL
);
CREATE INDEX engagement_broadcast_due_idx ON engagement_broadcast (send_at) WHERE sent_at IS NULL;
