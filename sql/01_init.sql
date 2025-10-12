CREATE TABLE IF NOT EXISTS mark_types
(
    id                      SERIAL           NOT NULL,
    type_name               VARCHAR(255)     NOT NULL UNIQUE,
    default_safe_distance_m DOUBLE PRECISION NOT NULL DEFAULT -1,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS mark_tags
(
    id       SERIAL       NOT NULL,
    tag_name VARCHAR(255) NOT NULL UNIQUE,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS marks
(
    id              UUID             NOT NULL DEFAULT gen_random_uuid(),
    device_id       VARCHAR(255)     NOT NULL UNIQUE,
    mark_name       VARCHAR(255)     NOT NULL,
    mqtt_topic      TEXT[]           NOT NULL DEFAULT '{}',
    persist_mqtt    BOOLEAN          NOT NULL DEFAULT false,
    safe_distance_m DOUBLE PRECISION NOT NULL DEFAULT -1,
    mark_type_id    INTEGER          NOT NULL DEFAULT 1,
    created_at      TIMESTAMPTZ      NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ      NOT NULL DEFAULT now(),
    last_online_at  TIMESTAMPTZ,
    PRIMARY KEY (id),
    -- 添加外键约束
    CONSTRAINT fk_mark_type FOREIGN KEY (mark_type_id) REFERENCES mark_types (id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS mark_tag_relation
(
    mark_id UUID NOT NULL,
    tag_id  INT  NOT NULL,
    PRIMARY KEY (mark_id, tag_id),
    FOREIGN KEY (mark_id) REFERENCES marks (id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES mark_tags (id) ON DELETE CASCADE
);

-- 2. 创建 mark_pair_safe_distance 表
CREATE TABLE IF NOT EXISTS mark_pair_safe_distance
(
    mark1_id   UUID             NOT NULL,
    mark2_id   UUID             NOT NULL,
    distance_m DOUBLE PRECISION NOT NULL,
    PRIMARY KEY (mark1_id, mark2_id),
    -- 保证 (mark1, mark2) 与 (mark2, mark1) 不会同时存在
    CHECK (mark1_id < mark2_id),
    -- 外键约束
    FOREIGN KEY (mark1_id) REFERENCES marks (id) ON DELETE CASCADE,
    FOREIGN KEY (mark2_id) REFERENCES marks (id) ON DELETE CASCADE
);

CREATE TYPE user_type_enum AS ENUM ('user', 'admin', 'root');

CREATE TABLE IF NOT EXISTS users
(
    id         UUID           NOT NULL DEFAULT gen_random_uuid(),
    username   VARCHAR(255)   NOT NULL UNIQUE,
    pwd_hash   VARCHAR(255)   NOT NULL,
    user_type  user_type_enum NOT NULL DEFAULT 'user',
    created_at TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ    NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS base_stations
(
    id           UUID             NOT NULL DEFAULT gen_random_uuid(),
    station_name VARCHAR(255)     NOT NULL,
    location_x   DOUBLE PRECISION NOT NULL,
    location_y   DOUBLE PRECISION NOT NULL,
    created_at   TIMESTAMPTZ      NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ      NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);

-- 添加索引以提高查询性能

-- marks 表索引
CREATE INDEX IF NOT EXISTS idx_marks_type_id ON marks (mark_type_id);
CREATE INDEX IF NOT EXISTS idx_marks_created_at_desc ON marks (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_marks_last_online_desc ON marks (last_online_at DESC) WHERE last_online_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_marks_persist_mqtt ON marks (persist_mqtt) WHERE persist_mqtt = true;
-- 复合索引：用于同时筛选类型和时间的查询
CREATE INDEX IF NOT EXISTS idx_marks_type_created ON marks (mark_type_id, created_at DESC);

-- mark_tag_relation 表索引
CREATE INDEX IF NOT EXISTS idx_mark_tag_relation_tag_id ON mark_tag_relation (tag_id);

-- base_stations 表索引
CREATE INDEX IF NOT EXISTS idx_base_stations_name ON base_stations (station_name);
CREATE INDEX IF NOT EXISTS idx_base_stations_created_at_desc ON base_stations (created_at DESC);
-- 空间查询索引（如果需要按位置范围查询）
CREATE INDEX IF NOT EXISTS idx_base_stations_location ON base_stations (location_x, location_y);

-- 创建自制地图表
CREATE TABLE IF NOT EXISTS custom_maps
(
    id          UUID             NOT NULL DEFAULT gen_random_uuid(),
    map_name    VARCHAR(255)     NOT NULL,
    image_path  VARCHAR(500),
    x_min       DOUBLE PRECISION NOT NULL,
    x_max       DOUBLE PRECISION NOT NULL,
    y_min       DOUBLE PRECISION NOT NULL,
    y_max       DOUBLE PRECISION NOT NULL,
    center_x    DOUBLE PRECISION NOT NULL,
    center_y    DOUBLE PRECISION NOT NULL,
    description TEXT,
    created_at  TIMESTAMPTZ      NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ      NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);

-- custom_maps 表索引
CREATE INDEX IF NOT EXISTS idx_custom_maps_map_name ON custom_maps (map_name);
CREATE INDEX IF NOT EXISTS idx_custom_maps_created_at_desc ON custom_maps (created_at DESC);

-- 添加注释
COMMENT ON TABLE custom_maps IS '自制地图底图表';
COMMENT ON COLUMN custom_maps.id IS '主键ID';
COMMENT ON COLUMN custom_maps.map_name IS '地图名称';
COMMENT ON COLUMN custom_maps.image_path IS '图片存储路径';
COMMENT ON COLUMN custom_maps.x_min IS 'X坐标系最小值';
COMMENT ON COLUMN custom_maps.x_max IS 'X坐标系最大值';
COMMENT ON COLUMN custom_maps.y_min IS 'Y坐标系最小值';
COMMENT ON COLUMN custom_maps.y_max IS 'Y坐标系最大值';
COMMENT ON COLUMN custom_maps.center_x IS '地图中心点X坐标';
COMMENT ON COLUMN custom_maps.center_y IS '地图中心点Y坐标';
COMMENT ON COLUMN custom_maps.description IS '地图描述（可选）';
COMMENT ON COLUMN custom_maps.created_at IS '创建时间';
COMMENT ON COLUMN custom_maps.updated_at IS '更新时间';

-- 启用 PostGIS 扩展（如果还没有）
CREATE EXTENSION IF NOT EXISTS postgis;

-- 创建多边形围栏表
CREATE TABLE polygon_fences
(
    id          UUID PRIMARY KEY              DEFAULT gen_random_uuid(),
    fence_name  VARCHAR(255)         NOT NULL UNIQUE,
    geometry    GEOMETRY(POLYGON, 0) NOT NULL, -- 只存储多边形
    description TEXT,
    is_active   BOOLEAN                       DEFAULT true,
    created_at  TIMESTAMP            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP            NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 创建空间索引，提高查询性能
CREATE INDEX idx_polygon_fences_geometry ON polygon_fences USING GIST (geometry);

-- 创建索引加速名称查询
CREATE INDEX idx_polygon_fences_name ON polygon_fences (fence_name);
CREATE INDEX idx_polygon_fences_active ON polygon_fences (is_active);