CREATE TABLE IF NOT EXISTS marks
(
    id            UUID         NOT NULL DEFAULT gen_random_uuid(),
    device_id     VARCHAR(255) NOT NULL UNIQUE,
    mark_name     VARCHAR(255) NOT NULL UNIQUE,
    topic         TEXT         NOT NULL DEFAULT '',
    -- 是否保存device_id发送的mqtt数据
    record_mqtt   BOOLEAN      NOT NULL DEFAULT false,
    safe_distance DOUBLE PRECISION,
    type_id       INTEGER      NOT NULL,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    -- 最近上线时间
    last_online_at TIMESTAMPTZ,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS mark_types
(
    id        SERIAL NOT NULL,
    type_name VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS mark_tags
(
    id       SERIAL NOT NULL,
    tag_name VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS mark_tag_relation
(
    mark_id UUID NOT NULL,
    tag_id  INT  NOT NULL,
    PRIMARY KEY (mark_id, tag_id),
    FOREIGN KEY (mark_id) REFERENCES marks (id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES mark_tags (id) ON DELETE CASCADE
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

CREATE TABLE IF NOT EXISTS mqtt_data
(
    id    UUID        NOT NULL DEFAULT gen_random_uuid(),
    doc   JSONB       NOT NULL,
    topic TEXT        NOT NULL DEFAULT '',
    time  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

