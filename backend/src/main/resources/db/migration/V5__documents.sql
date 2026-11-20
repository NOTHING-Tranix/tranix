-- B-201…B-206: documents and Aadhaar results (last 4 + result only, D-03).
CREATE TABLE identity_document (
    id               UUID PRIMARY KEY,
    owner_type       VARCHAR(10)  NOT NULL CHECK (owner_type IN ('USER','TRUCK','FARMER')),
    owner_id         UUID         NOT NULL,
    user_id          UUID         NOT NULL REFERENCES identity_user (id),
    type             VARCHAR(30)  NOT NULL,
    number_masked    VARCHAR(40),
    file_ids         TEXT         NOT NULL,
    expires_on       DATE,
    status           VARCHAR(10)  NOT NULL CHECK (status IN ('PENDING','APPROVED','REJECTED')),
    reject_reason    TEXT,
    reviewed_by      UUID,
    reviewed_at      TIMESTAMPTZ,
    reminders_sent   VARCHAR(40)  NOT NULL DEFAULT '',
    expired_notified BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at       TIMESTAMPTZ  NOT NULL,
    updated_at       TIMESTAMPTZ  NOT NULL,
    version          BIGINT       NOT NULL,
    UNIQUE (owner_type, owner_id, type)
);
CREATE INDEX identity_document_user_idx ON identity_document (user_id);
CREATE INDEX identity_document_expiry_idx ON identity_document (expires_on) WHERE expires_on IS NOT NULL;

CREATE TABLE identity_aadhaar_check (
    id              UUID PRIMARY KEY,
    subject_type    VARCHAR(10) NOT NULL CHECK (subject_type IN ('USER','FARMER')),
    subject_id      UUID        NOT NULL,
    method          VARCHAR(20) NOT NULL,
    last4           VARCHAR(4)  NOT NULL,
    name_on_record  VARCHAR(120),
    verified        BOOLEAN     NOT NULL,
    verified_at     TIMESTAMPTZ NOT NULL
);
