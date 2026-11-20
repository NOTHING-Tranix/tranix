-- B-006: defaults from docs/product-spec.md, docs/decisions.md and docs/open-questions.md (safe defaults).
-- Lists are comma-separated. Points may be fractional (DECIMAL).
INSERT INTO admin_setting (key, value, type, description) VALUES
-- Wallet and charges (§4, D-07; amounts are placeholders until Q-01)
('charges.posting_inr',             '50',               'INT',         'Posting charge deducted from the shipper at acceptance (Q-01 placeholder)'),
('charges.trip_inr',                '50',               'INT',         'Trip charge deducted from the driver/Organization at acceptance (Q-01 placeholder)'),
('wallet.topup_chips_inr',          '500,1000,2000',    'INT_LIST',    'Top-up amount chips shown in the app'),
-- OTP (§3, §9)
('otp.ttl_seconds',                 '300',              'INT',         'OTP validity (5 min)'),
('otp.resend_seconds',              '30',               'INT',         'Resend cooldown'),
('otp.max_attempts',                '5',                'INT',         'Wrong attempts before lock'),
('otp.lock_minutes',                '15',               'INT',         'Sign-in lock after too many wrong OTPs'),
('otp.geofence_meters',             '500',              'INT',         'Reached/OTP more than this from the pin creates a location exception'),
-- Amount revision (§7, D-05)
('revision.limit',                  '5',                'INT',         'Max amount requests per trip'),
('revision.response_minutes',       '15',               'INT',         'Shipper response window'),
-- Matching (§6, D-06; tuning Q-09)
('matching.initial_radius_km',      '25',               'INT',         'Search radius from pickup at posting'),
('matching.batch_size',             '5',                'INT',         'Drivers per suggestion batch'),
('matching.batch_interval_minutes', '10',               'INT',         'Minutes between batches'),
('matching.weight.distance',        '30',               'DECIMAL',     'Ranking weight %: distance to pickup'),
('matching.weight.time_fit',        '20',               'DECIMAL',     'Ranking weight %: time fit'),
('matching.weight.trust',           '20',               'DECIMAL',     'Ranking weight %: Trust Score'),
('matching.weight.capacity_fit',    '15',               'DECIMAL',     'Ranking weight %: capacity fit'),
('matching.weight.return_load',     '10',               'DECIMAL',     'Ranking weight %: return-load potential'),
('matching.weight.idle_time',       '5',                'DECIMAL',     'Ranking weight %: idle time'),
-- Wish list (§6A, D-19; tuning Q-12)
('wishlist.max_entries',            '20',               'INT',         'Max wish-list entries per shipper'),
('wishlist.first_minutes',          '15',               'INT',         'WISHLIST_FIRST window before opening to everyone'),
('wishlist.only_notify_minutes',    '30',               'INT',         'WISHLIST_ONLY: notify shipper after this with no acceptance'),
('wishlist.relaxed_radius_km',      '100',              'INT',         'Max distance from pickup for wish-list entries'),
-- Trust Score (§12, D-10)
('trust.start_score',               '70',               'INT',         'Starting Trust Score'),
('trust.points.driver.on_time',             '2',    'DECIMAL', 'Driver: trip completed on time'),
('trust.points.shipper.on_time',            '1',    'DECIMAL', 'LP/FN: trip completed on time'),
('trust.points.driver.late_delivery',       '-2',   'DECIMAL', 'Driver: late delivery (beyond ETA + grace)'),
('trust.points.driver.late_pickup',         '-1',   'DECIMAL', 'Driver: late pickup'),
('trust.points.cancel_own_fault',           '-5',   'DECIMAL', 'Cancelled after acceptance (own fault)'),
('trust.points.rating_5',                   '1',    'DECIMAL', 'Rating received: 5 stars'),
('trust.points.rating_4',                   '0.5',  'DECIMAL', 'Rating received: 4 stars'),
('trust.points.rating_2',                   '-1',   'DECIMAL', 'Rating received: 2 stars'),
('trust.points.rating_1',                   '-2',   'DECIMAL', 'Rating received: 1 star'),
('trust.points.verified_complaint',         '-5',   'DECIMAL', 'Verified complaint against user'),
('trust.points.shipper.payment_on_time',    '1',    'DECIMAL', 'LP/FN: payment confirmed on time'),
('trust.points.dispute_lost',               '-5',   'DECIMAL', 'Payment dispute decided against user'),
-- Route status (D-11)
('route.slow_threshold_pct',        '10',               'INT',         'SLOW when ETA is more than this % late'),
('route.fast_threshold_pct',        '10',               'INT',         'FAST when ETA is more than this % early'),
-- Documents and data (§3, Q-08 default)
('documents.expiry_reminder_days',  '30,7,1',           'INT_LIST',    'Reminder days before document expiry'),
('files.max_mb',                    '10',               'INT',         'Max upload size (PDF/JPG/PNG)'),
('location.retention_days',         '90',               'INT',         'Keep detailed trip location points (Q-08 default)'),
-- Support (screens S-10)
('support.reopen_days',             '7',                'INT',         'A closed ticket can be reopened within this many days'),
-- Client lists (§12 of the contract)
('lists.goods_types',               'Vegetables,Fruits,Grains,Pulses,Spices,Fertilizer,Building material,FMCG,Other', 'STRING_LIST', 'Goods type dropdown (Q-13 default)'),
('lists.supported_languages',       'en,ta,hi',         'STRING_LIST', 'App languages (D-12)');
