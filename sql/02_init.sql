INSERT INTO mark_types (type_name)
VALUES ('默认')
ON CONFLICT (type_name) DO NOTHING;

ALTER TABLE mark_types
    ADD COLUMN IF NOT EXISTS default_safe_distance_m DOUBLE PRECISION NOT NULL DEFAULT -1;