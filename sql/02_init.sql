-- 插入默认标记类型
INSERT INTO mark_types (type_name, default_safe_distance_m)
VALUES ('默认', -1),
       ('吊车', 20)
ON CONFLICT (type_name) DO NOTHING;