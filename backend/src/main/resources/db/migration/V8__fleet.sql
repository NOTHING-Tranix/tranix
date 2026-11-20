-- B-501…B-508: trucks, Organization drivers, invitations, allocations, driver duty/location.
CREATE TABLE fleet_truck (
    id               UUID PRIMARY KEY,
    owner_type       VARCHAR(10)  NOT NULL CHECK (owner_type IN ('DRIVER','ORG')),
    owner_id         UUID         NOT NULL,
    number           VARCHAR(16)  NOT NULL UNIQUE,
    vehicle_type     VARCHAR(20)  NOT NULL,
    capacity_tonnes  NUMERIC(6,2) NOT NULL CHECK (capacity_tonnes > 0),
    active           BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ  NOT NULL,
    updated_at       TIMESTAMPTZ  NOT NULL,
    version          BIGINT       NOT NULL
);
-- One truck only for an owner-driver (§16).
CREATE UNIQUE INDEX fleet_truck_one_per_driver ON fleet_truck (owner_id) WHERE owner_type = 'DRIVER' AND active;
CREATE INDEX fleet_truck_owner_idx ON fleet_truck (owner_type, owner_id);

CREATE TABLE fleet_invitation (
    id              UUID PRIMARY KEY,
    org_id          UUID        NOT NULL,
    driver_mobile   VARCHAR(10) NOT NULL,
    driver_name     VARCHAR(60) NOT NULL,
    driver_user_id  UUID,
    status          VARCHAR(10) NOT NULL CHECK (status IN ('PENDING','ACCEPTED','REJECTED','CANCELLED')),
    created_at      TIMESTAMPTZ NOT NULL,
    responded_at    TIMESTAMPTZ
);
CREATE UNIQUE INDEX fleet_invitation_one_pending ON fleet_invitation (org_id, driver_mobile) WHERE status = 'PENDING';
CREATE INDEX fleet_invitation_mobile_idx ON fleet_invitation (driver_mobile, status);

CREATE TABLE fleet_org_driver (
    id          UUID PRIMARY KEY,
    org_id      UUID        NOT NULL,
    driver_id   UUID        NOT NULL,
    joined_at   TIMESTAMPTZ NOT NULL,
    removed_at  TIMESTAMPTZ
);
-- A driver belongs to at most one Organization at a time.
CREATE UNIQUE INDEX fleet_org_driver_one_org ON fleet_org_driver (driver_id) WHERE removed_at IS NULL;

CREATE TABLE fleet_allocation (
    id          UUID PRIMARY KEY,
    org_id      UUID        NOT NULL,
    driver_id   UUID        NOT NULL,
    truck_id    UUID        NOT NULL REFERENCES fleet_truck (id),
    status      VARCHAR(10) NOT NULL CHECK (status IN ('ACTIVE','PAUSED','REMOVED')),
    created_at  TIMESTAMPTZ NOT NULL,
    updated_at  TIMESTAMPTZ NOT NULL
);
-- One driver ↔ one truck (§17): a driver or truck has at most one live (ACTIVE or PAUSED) allocation.
CREATE UNIQUE INDEX fleet_allocation_driver_live ON fleet_allocation (driver_id) WHERE status <> 'REMOVED';
CREATE UNIQUE INDEX fleet_allocation_truck_live ON fleet_allocation (truck_id) WHERE status <> 'REMOVED';

CREATE TABLE fleet_driver_state (
    driver_id           UUID PRIMARY KEY,
    on_duty             BOOLEAN NOT NULL DEFAULT FALSE,
    last_lat            DOUBLE PRECISION,
    last_lng            DOUBLE PRECISION,
    last_location_at    TIMESTAMPTZ,
    last_trip_ended_at  TIMESTAMPTZ,
    updated_at          TIMESTAMPTZ NOT NULL
);
