-- B-401…B-407: loads, timeline, cancellations.
CREATE SEQUENCE loads_code_seq START 1;

CREATE TABLE loads_load (
    id                     UUID PRIMARY KEY,
    code                   VARCHAR(16)   NOT NULL UNIQUE,
    shipper_id             UUID          NOT NULL,
    posted_for_farmer_id   UUID,
    status                 VARCHAR(24)   NOT NULL,
    pickup_lat             DOUBLE PRECISION NOT NULL,
    pickup_lng             DOUBLE PRECISION NOT NULL,
    pickup_address         VARCHAR(300)  NOT NULL,
    pickup_landmark        VARCHAR(120),
    pickup_area            VARCHAR(120)  NOT NULL,
    drop_lat               DOUBLE PRECISION NOT NULL,
    drop_lng               DOUBLE PRECISION NOT NULL,
    drop_address           VARCHAR(300)  NOT NULL,
    drop_landmark          VARCHAR(120),
    drop_area              VARCHAR(120)  NOT NULL,
    pickup_window_start    TIMESTAMPTZ   NOT NULL,
    pickup_window_end      TIMESTAMPTZ   NOT NULL,
    sender_name            VARCHAR(60)   NOT NULL,
    sender_mobile          VARCHAR(10)   NOT NULL,
    receiver_name          VARCHAR(60)   NOT NULL,
    receiver_mobile        VARCHAR(10)   NOT NULL,
    receiver_user_id       UUID,
    goods_type             VARCHAR(60)   NOT NULL,
    description            VARCHAR(300),
    quantity               NUMERIC(12,2) NOT NULL CHECK (quantity > 0),
    quantity_unit          VARCHAR(10)   NOT NULL,
    weight_tonnes          NUMERIC(8,2)  NOT NULL CHECK (weight_tonnes > 0),
    vehicle_type           VARCHAR(20)   NOT NULL,
    freight_paid_by        VARCHAR(10)   NOT NULL,
    posted_amount_inr      BIGINT        NOT NULL CHECK (posted_amount_inr > 0),
    agreed_amount_inr      BIGINT        NOT NULL CHECK (agreed_amount_inr > 0),
    driver_id              UUID,
    truck_id               UUID,
    org_id                 UUID,
    distance_km            NUMERIC(8,1)  NOT NULL,
    drive_minutes          INT           NOT NULL,
    delivery_eta           TIMESTAMPTZ   NOT NULL,
    audience               VARCHAR(16)   NOT NULL DEFAULT 'EVERYONE',
    wishlist_entry_ids     TEXT,
    wishlist_until         TIMESTAMPTZ,
    opened_to_everyone_at  TIMESTAMPTZ,
    accepted_at            TIMESTAMPTZ,
    picked_up_at           TIMESTAMPTZ,
    delivered_at           TIMESTAMPTZ,
    cancelled_at           TIMESTAMPTZ,
    closed_at              TIMESTAMPTZ,
    created_at             TIMESTAMPTZ   NOT NULL,
    updated_at             TIMESTAMPTZ   NOT NULL,
    version                BIGINT        NOT NULL
);
CREATE INDEX loads_load_shipper_idx ON loads_load (shipper_id, created_at DESC);
CREATE INDEX loads_load_status_idx ON loads_load (status);
CREATE INDEX loads_load_driver_idx ON loads_load (driver_id) WHERE driver_id IS NOT NULL;
CREATE INDEX loads_load_receiver_idx ON loads_load (receiver_user_id) WHERE receiver_user_id IS NOT NULL;

CREATE TABLE loads_timeline (
    id        UUID PRIMARY KEY,
    load_id   UUID        NOT NULL REFERENCES loads_load (id),
    status    VARCHAR(24) NOT NULL,
    at        TIMESTAMPTZ NOT NULL,
    actor_id  UUID
);
CREATE INDEX loads_timeline_load_idx ON loads_timeline (load_id, at);

CREATE TABLE loads_cancellation (
    id              UUID PRIMARY KEY,
    load_id         UUID         NOT NULL REFERENCES loads_load (id),
    by_user_id      UUID         NOT NULL,
    by_role         VARCHAR(20)  NOT NULL,
    stage           VARCHAR(24)  NOT NULL,
    reason          VARCHAR(40)  NOT NULL,
    note            VARCHAR(500),
    charges_kept    BOOLEAN      NOT NULL,
    penalty_points  NUMERIC(5,2) NOT NULL DEFAULT 0,
    admin_decision  VARCHAR(20),
    admin_reason    VARCHAR(500),
    decided_by      UUID,
    decided_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ  NOT NULL
);

INSERT INTO admin_setting (key, value, type, description) VALUES
('loads.loading_buffer_minutes', '60', 'INT', 'Added to drive time for the delivery estimate (D-26, assumed)'),
('loads.max_weight_tonnes', '60', 'INT', 'Largest load weight accepted (D-26, assumed)'),
('lists.cancel_reasons_shipper', 'PLANS_CHANGED,GOODS_NOT_READY,FOUND_OTHER_TRUCK,DRIVER_NOT_REACHABLE,DRIVER_DID_NOT_COME,DRIVER_ASKED_MORE,OTHER', 'STRING_LIST', 'Shipper cancel reasons'),
('lists.cancel_reasons_driver', 'TRUCK_BREAKDOWN,EMERGENCY,SHIPPER_CHANGED_DETAILS,AMOUNT_NOT_AGREED,TOO_FAR,OTHER', 'STRING_LIST', 'Driver cancel reasons'),
('lists.counterparty_fault_reasons', 'DRIVER_NOT_REACHABLE,DRIVER_DID_NOT_COME,DRIVER_ASKED_MORE,SHIPPER_CHANGED_DETAILS,EMERGENCY', 'STRING_LIST', 'Reasons that waive the −5 (other party at fault or emergency, §11)');
