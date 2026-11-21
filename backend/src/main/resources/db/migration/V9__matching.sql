-- B-601…B-607: suggestion batches and driver responses.
CREATE TABLE matching_load_state (
    load_id          UUID PRIMARY KEY,
    radius_km        INT         NOT NULL,
    batches          INT         NOT NULL DEFAULT 0,
    next_batch_at    TIMESTAMPTZ NOT NULL,
    no_driver_notified BOOLEAN   NOT NULL DEFAULT FALSE,
    done             BOOLEAN     NOT NULL DEFAULT FALSE
);
CREATE INDEX matching_load_state_due_idx ON matching_load_state (next_batch_at) WHERE NOT done;

CREATE TABLE matching_suggestion (
    id              UUID PRIMARY KEY,
    load_id         UUID         NOT NULL,
    driver_id       UUID         NOT NULL,
    truck_id        UUID         NOT NULL,
    batch_no        INT          NOT NULL,
    rank            INT          NOT NULL,
    score           NUMERIC(6,3) NOT NULL,
    preferred       BOOLEAN      NOT NULL DEFAULT FALSE,
    status          VARCHAR(10)  NOT NULL CHECK (status IN ('SHOWN','ACCEPTED','REJECTED','TAKEN','EXPIRED')),
    reject_reason   VARCHAR(20),
    shown_at        TIMESTAMPTZ  NOT NULL,
    responded_at    TIMESTAMPTZ,
    UNIQUE (load_id, driver_id)
);
CREATE INDEX matching_suggestion_driver_idx ON matching_suggestion (driver_id, status);

INSERT INTO admin_setting (key, value, type, description) VALUES
('matching.radius_step_km', '25',  'INT', 'Radius added when a batch finds nobody (D-27, assumed; Q-09)'),
('matching.max_radius_km',  '100', 'INT', 'Widest search radius before notifying the shipper (D-27, assumed; Q-09)');
