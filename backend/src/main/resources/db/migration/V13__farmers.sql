-- M10 Farmer Network farmers (§15). Aadhaar: last 4 digits only (hard rule 8).
CREATE TABLE farmers_farmer (
    id             UUID PRIMARY KEY,
    network_id     UUID         NOT NULL,
    name           VARCHAR(60)  NOT NULL,
    mobile         VARCHAR(10)  NOT NULL,
    aadhaar_last4  VARCHAR(4)   CHECK (aadhaar_last4 ~ '^[0-9]{4}$'),
    land_acres     NUMERIC(8,2) CHECK (land_acres >= 0),
    village        VARCHAR(100) NOT NULL,
    consent_at     TIMESTAMPTZ  NOT NULL,
    active         BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMPTZ  NOT NULL,
    updated_at     TIMESTAMPTZ  NOT NULL
);
CREATE UNIQUE INDEX farmers_farmer_mobile_uq ON farmers_farmer (network_id, mobile) WHERE active;
CREATE INDEX farmers_farmer_network_idx ON farmers_farmer (network_id, active, name);
