-- M15: Google Routes monthly call budget (B-1304); over budget the straight-line estimate is used.
INSERT INTO admin_setting (key, value, type, description) VALUES
('maps.monthly_route_calls', '20000', 'INT', 'Max Google Routes calls per month before falling back to the straight-line estimate');
