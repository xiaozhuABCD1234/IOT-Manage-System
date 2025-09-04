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
    mark1_id    UUID NOT NULL,
    mark2_id    UUID NOT NULL,
    distance_m  DOUBLE PRECISION NOT NULL,
    PRIMARY KEY (mark1_id, mark2_id),
    -- 保证 (mark1, mark2) 与 (mark2, mark1) 不会同时存在
    CHECK (mark1_id < mark2_id),
    -- 外键约束
    FOREIGN KEY (mark1_id) REFERENCES marks(id) ON DELETE CASCADE,
    FOREIGN KEY (mark2_id) REFERENCES marks(id) ON DELETE CASCADE
);

CREATE TYPE user_type_enum AS ENUM ('user', 'admin','root');

CREATE TABLE IF NOT EXISTS users
(
    id         UUID           NOT NULL DEFAULT gen_random_uuid(),
    username   VARCHAR(255)   NOT NULL UNIQUE,
    pwd_hash   VARCHAR(255)   NOT NULL,
    user_type  user_type_enum NOT NULL DEFAULT 'user',
    created_at TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- 添加索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_marks_type_id ON marks (mark_type_id);
CREATE INDEX IF NOT EXISTS idx_marks_device_id ON marks (device_id);
CREATE INDEX IF NOT EXISTS idx_marks_created_at ON marks (created_at);
CREATE INDEX IF NOT EXISTS idx_marks_last_online ON marks (last_online_at);
CREATE INDEX IF NOT EXISTS idx_mark_tag_relation_tag_id ON mark_tag_relation (tag_id);
CREATE INDEX IF NOT EXISTS idx_users_username ON users (username);
-- 单独索引（如果查询频繁）
CREATE INDEX IF NOT EXISTS idx_marks_persist_mqtt ON marks (persist_mqtt);

-- 或者更高效的复合索引（覆盖索引）
CREATE INDEX IF NOT EXISTS idx_marks_persist_device ON marks (persist_mqtt, device_id);