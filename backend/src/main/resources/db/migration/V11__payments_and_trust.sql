-- B-801…B-808: freight payment records, Trust Score ledger, ratings.
CREATE TABLE payments_record (
    load_id          UUID PRIMARY KEY,
    payer            VARCHAR(10)  NOT NULL CHECK (payer IN ('SHIPPER','RECEIVER')),
    payee_driver_id  UUID         NOT NULL,
    amount_inr       BIGINT,
    mode             VARCHAR(10)  CHECK (mode IN ('CASH','UPI','BANK')),
    reference        VARCHAR(60),
    status           VARCHAR(10)  NOT NULL CHECK (status IN ('PENDING','PAID','CONFIRMED','DISPUTED')),
    marked_by        UUID,
    paid_at          TIMESTAMPTZ,
    confirmed_at     TIMESTAMPTZ,
    dispute_reason   VARCHAR(500),
    resolution       VARCHAR(20),
    resolved_by      UUID,
    resolved_at      TIMESTAMPTZ,
    created_at       TIMESTAMPTZ  NOT NULL,
    updated_at       TIMESTAMPTZ  NOT NULL
);
CREATE INDEX payments_record_driver_idx ON payments_record (payee_driver_id, status);

CREATE TABLE trust_event (
    id          UUID PRIMARY KEY,
    user_id     UUID          NOT NULL,
    load_id     UUID,
    event       VARCHAR(40)   NOT NULL,
    points      NUMERIC(6,2)  NOT NULL,
    reason      VARCHAR(300)  NOT NULL,
    score_after NUMERIC(5,2)  NOT NULL,
    created_by  UUID,
    created_at  TIMESTAMPTZ   NOT NULL
);
CREATE INDEX trust_event_user_idx ON trust_event (user_id, created_at DESC);
-- one automatic event of a kind per user and trip (idempotent listeners)
CREATE UNIQUE INDEX trust_event_once ON trust_event (user_id, load_id, event) WHERE load_id IS NOT NULL AND event <> 'ADMIN_ADJUSTMENT';

CREATE TABLE trust_rating (
    id          UUID PRIMARY KEY,
    load_id     UUID          NOT NULL,
    rater_id    UUID          NOT NULL,
    ratee_id    UUID          NOT NULL,
    stars       INT           NOT NULL CHECK (stars BETWEEN 1 AND 5),
    tags        VARCHAR(300),
    comment     VARCHAR(500),
    created_at  TIMESTAMPTZ   NOT NULL,
    UNIQUE (load_id, rater_id, ratee_id)
);

CREATE TABLE trust_pending_rating (
    id             UUID PRIMARY KEY,
    load_id        UUID         NOT NULL,
    rater_id       UUID         NOT NULL,
    ratee_id       UUID         NOT NULL,
    ratee_role     VARCHAR(20)  NOT NULL,
    later_used     BOOLEAN      NOT NULL DEFAULT FALSE,
    reminder_sent  BOOLEAN      NOT NULL DEFAULT FALSE,
    done           BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at     TIMESTAMPTZ  NOT NULL,
    UNIQUE (load_id, rater_id, ratee_id)
);
CREATE INDEX trust_pending_rater_idx ON trust_pending_rating (rater_id) WHERE NOT done;

INSERT INTO admin_setting (key, value, type, description) VALUES
('payments.on_time_days', '7', 'INT', 'Payment confirmed within this many days of delivery counts as "on time" (D-29, assumed)'),
('lists.rating_tags', 'On time,Polite,Careful with goods,Good communication,Late,Rude,Damaged goods,Asked for more money', 'STRING_LIST', 'Quick tags on the rating pop-up');
