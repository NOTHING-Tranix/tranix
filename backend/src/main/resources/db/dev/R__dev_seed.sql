-- Dev-only seed (profile dev). Sign in with these mobiles and OTP 123456.
-- 9000000001 Load Provider · 9000000002 Farmer Network · 9000000003 Driver · 9000000004 Organization
-- 9000000005 Receiver · 9000000006 Admin (use its token in Swagger for /api/v1/admin/**)
INSERT INTO identity_user (id, mobile, name, role, language, verification_status, profile_completion, trust_score,
                           consent_at, created_at, updated_at, version)
VALUES
('00000000-0000-4000-8000-000000000001', '9000000001', 'Dev Load Provider', 'LOAD_PROVIDER', 'en', 'VERIFIED', 100, 70, now(), now(), now(), 0),
('00000000-0000-4000-8000-000000000002', '9000000002', 'Dev Farmer Network', 'FARMER_NETWORK', 'ta', 'VERIFIED', 100, 70, now(), now(), now(), 0),
('00000000-0000-4000-8000-000000000003', '9000000003', 'Dev Driver', 'DRIVER', 'ta', 'VERIFIED', 100, 70, now(), now(), now(), 0),
('00000000-0000-4000-8000-000000000004', '9000000004', 'Dev Organization', 'ORGANIZATION', 'en', 'VERIFIED', 100, 70, now(), now(), now(), 0),
('00000000-0000-4000-8000-000000000005', '9000000005', 'Dev Receiver', 'RECEIVER', 'hi', 'VERIFIED', 100, 70, now(), now(), now(), 0),
('00000000-0000-4000-8000-000000000006', '9000000006', 'Dev Admin', 'ADMIN', 'en', 'VERIFIED', 100, 70, now(), now(), now(), 0)
ON CONFLICT (mobile) DO NOTHING;

-- B-501: dev driver 9000000003 owns truck TN57AB1234 (documents approved, valid 2 years) and is on duty.
INSERT INTO fleet_truck (id, owner_type, owner_id, number, vehicle_type, capacity_tonnes, active, created_at, updated_at, version)
VALUES ('00000000-0000-4000-8000-0000000000a1', 'DRIVER', '00000000-0000-4000-8000-000000000003', 'TN57AB1234', 'OPEN_BODY', 9, true, now(), now(), 0)
ON CONFLICT (number) DO NOTHING;
INSERT INTO identity_document (id, owner_type, owner_id, user_id, type, number_masked, file_ids, expires_on, status, reviewed_at, created_at, updated_at, version)
VALUES
('00000000-0000-4000-8000-0000000000d1', 'TRUCK', '00000000-0000-4000-8000-0000000000a1', '00000000-0000-4000-8000-000000000003', 'RC', 'XXXXXX1234', '', current_date + 730, 'APPROVED', now(), now(), now(), 0),
('00000000-0000-4000-8000-0000000000d2', 'TRUCK', '00000000-0000-4000-8000-0000000000a1', '00000000-0000-4000-8000-000000000003', 'INSURANCE', 'XXXXXX5678', '', current_date + 365, 'APPROVED', now(), now(), now(), 0),
('00000000-0000-4000-8000-0000000000d3', 'TRUCK', '00000000-0000-4000-8000-0000000000a1', '00000000-0000-4000-8000-000000000003', 'NATIONAL_PERMIT', 'XXXXXX9012', '', current_date + 365, 'APPROVED', now(), now(), now(), 0),
('00000000-0000-4000-8000-0000000000d4', 'USER', '00000000-0000-4000-8000-000000000003', '00000000-0000-4000-8000-000000000003', 'DRIVING_LICENCE', 'XXXXXXXXXXX2345', '', current_date + 1000, 'APPROVED', now(), now(), now(), 0)
ON CONFLICT (owner_type, owner_id, type) DO NOTHING;
-- near Oddanchatram so it gets suggestions for the demo load
INSERT INTO fleet_driver_state (driver_id, on_duty, last_lat, last_lng, last_location_at, updated_at)
VALUES ('00000000-0000-4000-8000-000000000003', true, 10.50, 77.76, now(), now())
ON CONFLICT (driver_id) DO NOTHING;
-- Organization 9000000004 owns truck TN38CD5678 (documents approved).
INSERT INTO fleet_truck (id, owner_type, owner_id, number, vehicle_type, capacity_tonnes, active, created_at, updated_at, version)
VALUES ('00000000-0000-4000-8000-0000000000a2', 'ORG', '00000000-0000-4000-8000-000000000004', 'TN38CD5678', 'CLOSED_BODY', 12, true, now(), now(), 0)
ON CONFLICT (number) DO NOTHING;
INSERT INTO identity_document (id, owner_type, owner_id, user_id, type, number_masked, file_ids, expires_on, status, reviewed_at, created_at, updated_at, version)
VALUES
('00000000-0000-4000-8000-0000000000d5', 'TRUCK', '00000000-0000-4000-8000-0000000000a2', '00000000-0000-4000-8000-000000000004', 'RC', 'XXXXXX5678', '', current_date + 730, 'APPROVED', now(), now(), now(), 0),
('00000000-0000-4000-8000-0000000000d6', 'TRUCK', '00000000-0000-4000-8000-0000000000a2', '00000000-0000-4000-8000-000000000004', 'INSURANCE', 'XXXXXX1111', '', current_date + 365, 'APPROVED', now(), now(), now(), 0),
('00000000-0000-4000-8000-0000000000d7', 'TRUCK', '00000000-0000-4000-8000-0000000000a2', '00000000-0000-4000-8000-000000000004', 'NATIONAL_PERMIT', 'XXXXXX2222', '', current_date + 365, 'APPROVED', now(), now(), now(), 0)
ON CONFLICT (owner_type, owner_id, type) DO NOTHING;
