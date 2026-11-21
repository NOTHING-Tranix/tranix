-- M9 wish list (D-19): preferred trucks and Organizations per shipper.
CREATE TABLE matching_wishlist_entry (
    id           UUID PRIMARY KEY,
    shipper_id   UUID         NOT NULL,
    target_type  VARCHAR(12)  NOT NULL CHECK (target_type IN ('TRUCK','ORGANIZATION')),
    truck_id     UUID,
    org_id       UUID,
    note         VARCHAR(200),
    created_at   TIMESTAMPTZ  NOT NULL,
    CHECK ((target_type = 'TRUCK' AND truck_id IS NOT NULL) OR (target_type = 'ORGANIZATION' AND org_id IS NOT NULL))
);
CREATE UNIQUE INDEX matching_wishlist_truck_uq ON matching_wishlist_entry (shipper_id, truck_id) WHERE truck_id IS NOT NULL;
CREATE UNIQUE INDEX matching_wishlist_org_uq ON matching_wishlist_entry (shipper_id, org_id) WHERE org_id IS NOT NULL;
CREATE INDEX matching_wishlist_org_idx ON matching_wishlist_entry (org_id) WHERE org_id IS NOT NULL;

ALTER TABLE matching_load_state ADD COLUMN wishlist_notified BOOLEAN NOT NULL DEFAULT FALSE;

INSERT INTO admin_setting (key, value, type, description) VALUES
('wishlist.ranking_bonus', '10', 'DECIMAL', 'Score points (0-100 scale) added for wish-list drivers on EVERYONE loads (D-30)');
