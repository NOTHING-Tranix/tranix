-- M14 admin: idle timeout for admin sessions (B-1201).
INSERT INTO admin_setting (key, value, type, description) VALUES
('admin.idle_minutes', '30', 'INT', 'Admin sessions end after this many idle minutes');
