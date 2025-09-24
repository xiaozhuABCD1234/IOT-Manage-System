package model

// MarkTypeCreateRequest 用于创建或更新标记类型
type MarkTypeCreateRequest struct {
	TypeName             string   `json:"type_name" validate:"required,max=255"`
	DefaultSafeDistanceM *float64 `json:"default_danger_zone_m"`
}

type MarkTypeUpdateRequest struct {
	TypeName             *string  `json:"type_name" validate:"omitempty,max=255"`
	DefaultSafeDistanceM *float64 `json:"default_danger_zone_m"`
}

// MarkTagRequest 用于创建或更新标记标签
type MarkTagRequest struct {
	TagName string `json:"tag_name" validate:"required,max=255"`
}

// MarkRequest 用于创建或全量更新 Mark 的共用请求体
type MarkRequest struct {
	DeviceID      string   `json:"device_id" validate:"required,max=255"`
	MarkName      string   `json:"mark_name" validate:"required,max=255"`
	MqttTopic     []string `json:"mqtt_topic" validate:"max=65535"`
	PersistMQTT   *bool    `json:"persist_mqtt,omitempty"`
	SafeDistanceM *float64 `json:"danger_zone_m,omitempty"`
	MarkTypeID    *int     `json:"mark_type_id,omitempty"`
	Tags          []string `json:"tags,omitempty"`
}

// MarkUpdateRequest 用于增量更新 Mark 的请求体
type MarkUpdateRequest struct {
	DeviceID      *string  `json:"device_id,omitempty" validate:"omitempty,max=255"`
	MarkName      *string  `json:"mark_name,omitempty" validate:"omitempty,max=255"`
	MqttTopic     []string `json:"mqtt_topic,omitempty" validate:"omitempty,max=65535"`
	PersistMQTT   *bool    `json:"persist_mqtt,omitempty"`
	SafeDistanceM *float64 `json:"danger_zone_m,omitempty"`
	MarkTypeID    *int     `json:"mark_type_id,omitempty"`
	Tags          []string `json:"tags,omitempty"`
}

// TypedID 按类型区分的主键参数
type TypedID struct {
	Kind   string `json:"kind" validate:"required,oneof=mark tag type"`
	MarkID string `json:"mark_id,omitempty" validate:"omitempty,max=36,len=36"`
	TagID  int    `json:"tag_id,omitempty" validate:"omitempty,min=1"`
	TypeID int    `json:"type_id,omitempty" validate:"omitempty,min=1"`
}

// SetDistanceTypedReq 按 TypedID 设置两点距离的请求体
type SetDistanceTypedReq struct {
	First    TypedID `json:"first" validate:"required"`
	Second   TypedID `json:"second" validate:"required"`
	Distance float64 `json:"distance" validate:"required,min=0"`
}

// SetDistanceMarkReq 按 Mark UUID 设置两点距离的请求体
type SetDistanceMarkReq struct {
	Mark1ID  string  `json:"mark1_id" validate:"required,uuid"`
	Mark2ID  string  `json:"mark2_id" validate:"required,uuid"`
	Distance float64 `json:"distance" validate:"required,min=0"`
}
