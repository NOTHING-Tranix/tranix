-- B-701…B-711 + B-408: trip execution.
CREATE TABLE trips_revision (
    id                   UUID PRIMARY KEY,
    load_id              UUID         NOT NULL,
    driver_id            UUID         NOT NULL,
    previous_amount_inr  BIGINT       NOT NULL,
    requested_amount_inr BIGINT       NOT NULL CHECK (requested_amount_inr > 0),
    reason               VARCHAR(300) NOT NULL,
    status               VARCHAR(10)  NOT NULL CHECK (status IN ('PENDING','CONFIRMED','REJECTED','EXPIRED')),
    created_at           TIMESTAMPTZ  NOT NULL,
    respond_by           TIMESTAMPTZ  NOT NULL,
    responded_at         TIMESTAMPTZ
);
CREATE INDEX trips_revision_load_idx ON trips_revision (load_id, created_at);
-- one pending request per trip (hard rule 5)
CREATE UNIQUE INDEX trips_revision_one_pending ON trips_revision (load_id) WHERE status = 'PENDING';

-- Pickup/delivery OTP: hash for checking, AES-GCM copy so the sender/receiver screen can show it (D-28).
CREATE TABLE trips_otp (
    id              UUID PRIMARY KEY,
    load_id         UUID        NOT NULL,
    purpose         VARCHAR(10) NOT NULL CHECK (purpose IN ('PICKUP','DELIVERY')),
    code_hash       VARCHAR(64) NOT NULL,
    code_enc        VARCHAR(200) NOT NULL,
    expires_at      TIMESTAMPTZ NOT NULL,
    attempts        INT         NOT NULL DEFAULT 0,
    consumed_at     TIMESTAMPTZ,
    invalidated_at  TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL
);
CREATE INDEX trips_otp_load_idx ON trips_otp (load_id, purpose, created_at DESC);

CREATE TABLE trips_otp_event (
    id          UUID PRIMARY KEY,
    load_id     UUID        NOT NULL,
    purpose     VARCHAR(10) NOT NULL,
    type        VARCHAR(10) NOT NULL CHECK (type IN ('SENT','ATTEMPT','VERIFIED','RESENT','OVERRIDE')),
    lat         DOUBLE PRECISION,
    lng         DOUBLE PRECISION,
    distance_m  INT,
    at          TIMESTAMPTZ NOT NULL
);
CREATE INDEX trips_otp_event_load_idx ON trips_otp_event (load_id, at);

CREATE TABLE trips_location_exception (
    id             UUID PRIMARY KEY,
    load_id        UUID         NOT NULL,
    purpose        VARCHAR(10)  NOT NULL,
    distance_m     INT          NOT NULL,
    driver_reason  VARCHAR(300) NOT NULL,
    review_status  VARCHAR(10)  NOT NULL DEFAULT 'PENDING' CHECK (review_status IN ('PENDING','OK','FLAGGED')),
    admin_note     VARCHAR(500),
    created_at     TIMESTAMPTZ  NOT NULL
);

CREATE TABLE trips_otp_help (
    id            UUID PRIMARY KEY,
    load_id       UUID         NOT NULL,
    purpose       VARCHAR(10)  NOT NULL,
    lat           DOUBLE PRECISION,
    lng           DOUBLE PRECISION,
    note          VARCHAR(500) NOT NULL,
    status        VARCHAR(10)  NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN','APPROVED','REJECTED')),
    admin_reason  VARCHAR(500),
    created_at    TIMESTAMPTZ  NOT NULL
);

CREATE TABLE trips_location_point (
    id        BIGSERIAL PRIMARY KEY,
    load_id   UUID        NOT NULL,
    lat       DOUBLE PRECISION NOT NULL,
    lng       DOUBLE PRECISION NOT NULL,
    speed     REAL,
    at        TIMESTAMPTZ NOT NULL
);
CREATE INDEX trips_location_point_load_idx ON trips_location_point (load_id, at DESC);
CREATE INDEX trips_location_point_at_idx ON trips_location_point (at);

CREATE TABLE trips_route (
    load_id         UUID PRIMARY KEY,
    current_eta     TIMESTAMPTZ,
    route_status    VARCHAR(10),
    late_notified   BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at      TIMESTAMPTZ NOT NULL
);

-- B-710 map layers (admin-entered; Q-05/Q-06 defaults: static sample data)
CREATE TABLE admin_map_point (
    id      UUID PRIMARY KEY,
    kind    VARCHAR(12)  NOT NULL CHECK (kind IN ('PETROL','WEIGHBRIDGE','PUNCTURE','TOLL')),
    name    VARCHAR(120) NOT NULL,
    lat     DOUBLE PRECISION NOT NULL,
    lng     DOUBLE PRECISION NOT NULL,
    active  BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE TABLE admin_map_restriction (
    id             UUID PRIMARY KEY,
    name           VARCHAR(120) NOT NULL,
    lat            DOUBLE PRECISION NOT NULL,
    lng            DOUBLE PRECISION NOT NULL,
    radius_km      NUMERIC(6,2) NOT NULL,
    no_entry_from  TIME,
    no_entry_to    TIME,
    vehicle_types  VARCHAR(200),
    note           VARCHAR(300),
    active         BOOLEAN NOT NULL DEFAULT TRUE
);
INSERT INTO admin_map_point (id, kind, name, lat, lng) VALUES
(gen_random_uuid(), 'PETROL', 'Indian Oil, Oddanchatram', 10.4870, 77.7500),
(gen_random_uuid(), 'WEIGHBRIDGE', 'Market weighbridge, Oddanchatram', 10.4905, 77.7440),
(gen_random_uuid(), 'PUNCTURE', 'Tyre works, Dindigul bypass', 10.3650, 77.9800),
(gen_random_uuid(), 'TOLL', 'Kodai Road toll plaza', 10.2100, 77.8900),
(gen_random_uuid(), 'TOLL', 'Paranur toll plaza', 12.7400, 79.9900),
(gen_random_uuid(), 'PETROL', 'HP, Koyambedu', 13.0700, 80.1950);
INSERT INTO admin_map_restriction (id, name, lat, lng, radius_km, no_entry_from, no_entry_to, vehicle_types, note) VALUES
(gen_random_uuid(), 'Chennai city heavy-vehicle no-entry', 13.0827, 80.2707, 12, '08:00', '22:00', 'OPEN_BODY,CLOSED_BODY,CONTAINER,TANKER,REFRIGERATED', 'Sample data (Q-06)');

INSERT INTO admin_setting (key, value, type, description) VALUES
('trips.late_grace_minutes', '30', 'INT', 'Late when current ETA is beyond the delivery estimate + this (D-28, assumed; Q-09)'),
('trips.max_location_batch', '100', 'INT', 'Most points per location upload');
