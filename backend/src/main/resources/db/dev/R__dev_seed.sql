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
