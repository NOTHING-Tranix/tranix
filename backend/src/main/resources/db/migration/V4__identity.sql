-- B-101…B-112: identity module.
CREATE TABLE identity_user (
    id                   UUID PRIMARY KEY,
    mobile               VARCHAR(10)  NOT NULL UNIQUE,
    name                 VARCHAR(60)  NOT NULL,
    role                 VARCHAR(20)  NOT NULL CHECK (role IN ('LOAD_PROVIDER','FARMER_NETWORK','DRIVER','ORGANIZATION','RECEIVER','ADMIN')),
    language             VARCHAR(2)   NOT NULL DEFAULT 'en' CHECK (language IN ('en','ta','hi')),
    email                VARCHAR(120),
    photo_file_id        UUID,
    verification_status  VARCHAR(20)  NOT NULL DEFAULT 'NOT_SUBMITTED'
        CHECK (verification_status IN ('NOT_SUBMITTED','UNDER_REVIEW','VERIFIED','NOT_VERIFIED')),
    profile_completion   INT          NOT NULL DEFAULT 0 CHECK (profile_completion BETWEEN 0 AND 100),
    trust_score          NUMERIC(5,2) NOT NULL DEFAULT 70 CHECK (trust_score BETWEEN 0 AND 100),
    consent_at           TIMESTAMPTZ,
    suspended_at         TIMESTAMPTZ,
    created_at           TIMESTAMPTZ  NOT NULL,
    updated_at           TIMESTAMPTZ  NOT NULL,
    version              BIGINT       NOT NULL
);
CREATE INDEX identity_user_role_idx ON identity_user (role, verification_status);

CREATE TABLE identity_address (
    user_id   UUID PRIMARY KEY REFERENCES identity_user (id),
    line      VARCHAR(200) NOT NULL,
    village   VARCHAR(100) NOT NULL,
    district  VARCHAR(100) NOT NULL,
    state     VARCHAR(100) NOT NULL,
    pin       VARCHAR(6)   NOT NULL
);

-- Role-specific fields as JSON text (validated per role in code).
CREATE TABLE identity_role_profile (
    user_id     UUID PRIMARY KEY REFERENCES identity_user (id),
    role        VARCHAR(20) NOT NULL,
    data        TEXT        NOT NULL,
    updated_at  TIMESTAMPTZ NOT NULL
);

CREATE TABLE identity_otp (
    id           UUID PRIMARY KEY,
    mobile       VARCHAR(10) NOT NULL,
    purpose      VARCHAR(20) NOT NULL,
    user_id      UUID,
    code_hash    VARCHAR(64) NOT NULL,
    expires_at   TIMESTAMPTZ NOT NULL,
    attempts     INT         NOT NULL DEFAULT 0,
    consumed_at  TIMESTAMPTZ,
    invalidated_at TIMESTAMPTZ,
    locked_until TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL
);
CREATE INDEX identity_otp_mobile_idx ON identity_otp (mobile, purpose, created_at DESC);

CREATE TABLE identity_refresh_token (
    id           UUID PRIMARY KEY,
    user_id      UUID        NOT NULL REFERENCES identity_user (id),
    family_id    UUID        NOT NULL,
    token_hash   VARCHAR(64) NOT NULL UNIQUE,
    device_id    VARCHAR(64),
    expires_at   TIMESTAMPTZ NOT NULL,
    revoked_at   TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL
);
CREATE INDEX identity_refresh_family_idx ON identity_refresh_token (family_id);

CREATE TABLE identity_device (
    id          UUID PRIMARY KEY,
    user_id     UUID         NOT NULL REFERENCES identity_user (id),
    fcm_token   VARCHAR(400) NOT NULL UNIQUE,
    platform    VARCHAR(10)  NOT NULL,
    updated_at  TIMESTAMPTZ  NOT NULL
);
CREATE INDEX identity_device_user_idx ON identity_device (user_id);

-- Audit log for admin and sensitive actions (CLAUDE.md hard rule 12).
CREATE TABLE admin_audit (
    id         UUID PRIMARY KEY,
    actor_id   UUID,
    action     VARCHAR(60)  NOT NULL,
    entity     VARCHAR(40)  NOT NULL,
    entity_id  VARCHAR(64),
    before     TEXT,
    after      TEXT,
    reason     TEXT,
    at         TIMESTAMPTZ  NOT NULL
);
CREATE INDEX admin_audit_entity_idx ON admin_audit (entity, entity_id);

INSERT INTO admin_setting (key, value, type, description) VALUES
('otp.max_sends_per_hour',          '5',  'INT', 'OTP sends per mobile per hour (D-23, assumed)'),
('verification.estimated_review_hours', '24', 'INT', 'Shown on the verification screen (D-23, assumed)');
