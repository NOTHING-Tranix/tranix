-- B-301…B-307: wallet (append-only ledger) and B-1101: notification inbox.
CREATE TABLE wallet_account (
    id                 UUID PRIMARY KEY,
    owner_type         VARCHAR(10) NOT NULL CHECK (owner_type IN ('USER','ORG')),
    owner_id           UUID        NOT NULL,
    cached_balance_inr BIGINT      NOT NULL DEFAULT 0 CHECK (cached_balance_inr >= 0),
    created_at         TIMESTAMPTZ NOT NULL,
    updated_at         TIMESTAMPTZ NOT NULL,
    version            BIGINT      NOT NULL,
    UNIQUE (owner_type, owner_id)
);

CREATE SEQUENCE wallet_txn_seq START 1;

CREATE TABLE wallet_entry (
    txn_id      VARCHAR(20)  PRIMARY KEY,
    account_id  UUID         NOT NULL REFERENCES wallet_account (id),
    type        VARCHAR(20)  NOT NULL CHECK (type IN ('TOPUP','POSTING_CHARGE','TRIP_CHARGE','REFUND','ADMIN_CREDIT')),
    direction   VARCHAR(6)   NOT NULL CHECK (direction IN ('CREDIT','DEBIT')),
    amount_inr  BIGINT       NOT NULL CHECK (amount_inr > 0),
    load_id     UUID,
    order_id    UUID,
    note        VARCHAR(200),
    idem_key    VARCHAR(120) UNIQUE,
    created_by  UUID,
    created_at  TIMESTAMPTZ  NOT NULL
);
CREATE INDEX wallet_entry_account_idx ON wallet_entry (account_id, created_at DESC);

-- Hard rule 3: entries are never edited or deleted.
CREATE FUNCTION wallet_entry_append_only() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'wallet_entry is append-only';
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER wallet_entry_no_update BEFORE UPDATE OR DELETE ON wallet_entry
    FOR EACH ROW EXECUTE FUNCTION wallet_entry_append_only();

CREATE TABLE wallet_topup_order (
    id                UUID PRIMARY KEY,
    account_id        UUID        NOT NULL REFERENCES wallet_account (id),
    amount_inr        BIGINT      NOT NULL CHECK (amount_inr > 0),
    gateway_order_id  VARCHAR(80) UNIQUE,
    status            VARCHAR(10) NOT NULL CHECK (status IN ('CREATED','PAID','FAILED')),
    link_token_hash   VARCHAR(64) NOT NULL UNIQUE,
    link_expires_at   TIMESTAMPTZ NOT NULL,
    created_at        TIMESTAMPTZ NOT NULL,
    paid_at           TIMESTAMPTZ
);

CREATE TABLE wallet_webhook_event (
    event_id     VARCHAR(80) PRIMARY KEY,
    received_at  TIMESTAMPTZ NOT NULL
);

CREATE TABLE engagement_notification (
    id          UUID PRIMARY KEY,
    user_id     UUID         NOT NULL,
    tab         VARCHAR(10)  NOT NULL CHECK (tab IN ('TRIPS','WALLET','TRANIX','ACCOUNT')),
    type        VARCHAR(40)  NOT NULL,
    title       VARCHAR(120) NOT NULL,
    body        VARCHAR(500) NOT NULL,
    route       VARCHAR(200),
    read_at     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ  NOT NULL
);
CREATE INDEX engagement_notification_user_idx ON engagement_notification (user_id, tab, created_at DESC);

INSERT INTO admin_setting (key, value, type, description) VALUES
('wallet.topup_min_inr',      '100',   'INT', 'Smallest top-up (D-25, assumed)'),
('wallet.topup_max_inr',      '50000', 'INT', 'Largest single top-up (D-25, assumed)'),
('wallet.topup_link_minutes', '15',    'INT', 'Top-up link validity');
