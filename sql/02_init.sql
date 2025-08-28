INSERT INTO mark_types (type_name)
VALUES ('默认')
ON CONFLICT (type_name) DO NOTHING;

