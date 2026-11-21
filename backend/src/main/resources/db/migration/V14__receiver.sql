-- M12 receiver: public tracking links (B-1001) and delivery receipts (B-1003).
CREATE TABLE receiver_tracking_token (
    token        VARCHAR(64)  PRIMARY KEY,
    load_id      UUID         NOT NULL,
    audience     VARCHAR(10)  NOT NULL CHECK (audience IN ('RECEIVER','SENDER')),
    mobile       VARCHAR(10)  NOT NULL,
    created_at   TIMESTAMPTZ  NOT NULL,
    expires_at   TIMESTAMPTZ,
    rated_at     TIMESTAMPTZ,
    UNIQUE (load_id, audience)
);

CREATE TABLE receiver_receipt (
    load_id      UUID PRIMARY KEY,
    by_user_id   UUID,
    via          VARCHAR(10)  NOT NULL CHECK (via IN ('APP','LINK')),
    file_ids     TEXT         NOT NULL,
    condition    VARCHAR(20)  NOT NULL CHECK (condition IN ('FULL','SHORTAGE_DAMAGE')),
    remarks      VARCHAR(500),
    created_at   TIMESTAMPTZ  NOT NULL
);

INSERT INTO admin_setting (key, value, type, description) VALUES
('tracking.link_days_after_end', '7', 'INT', 'Public tracking link expires this many days after delivery or cancellation');
