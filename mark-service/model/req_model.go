package model

import (
// "time"
)

// ==========================
// MarkType
// ==========================
type MarkTypeRequest struct {
	TypeName             string  `json:"type_name" validate:"required,max=255"`
	DefaultSafeDistanceM float64 `json:"default_safe_distance_m"`
}

// ==========================
// MarkTag
// ==========================
type MarkTagRequest struct {
	TagName string `json:"tag_name" validate:"required,max=255"`
}

// ==========================
// Mark
// ==========================

// 创建/更新时共用字段
type MarkRequest struct {
	DeviceID      string   `json:"device_id" validate:"required,max=255"`
	MarkName      string   `json:"mark_name" validate:"required,max=255"`
	MqttTopic     []string `json:"mqtt_topic" validate:"max=65535"`
	PersistMQTT   *bool    `json:"persist_mqtt,omitempty"`    // 可选(默认false)
	SafeDistanceM *float64 `json:"safe_distance_m,omitempty"` // 可选
	MarkTypeID    *int     `json:"mark_type_id,omitempty"`    // 可选(默认nil)
	Tags          []string `json:"tags,omitempty"`            // 可选(默认nil)
}

type MarkUpdateRequest struct {
	DeviceID      *string  `json:"device_id,omitempty" validate:"omitempty,max=255"`
	MarkName      *string  `json:"mark_name,omitempty" validate:"omitempty,max=255"`
	MqttTopic     []string `json:"mqtt_topic,omitempty" validate:"omitempty,max=65535"`
	PersistMQTT   *bool    `json:"persist_mqtt,omitempty"`
	SafeDistanceM *float64 `json:"safe_distance_m,omitempty"`
	MarkTypeID    *int     `json:"mark_type_id,omitempty"`
	Tags          []string `json:"tags,omitempty"` // 传 nil 表示不改；传 []string{} 表示清空
}

// TypedID 单个 ID 参数
type TypedID struct {
	Kind   string `json:"kind" validate:"required,oneof=mark tag type"` // 必填 + 枚举
	MarkID string `json:"mark_id,omitempty" validate:"omitempty,max=36,len=36"`
	TagID  int    `json:"tag_id,omitempty" validate:"omitempty,min=1"`
	TypeID int    `json:"type_id,omitempty" validate:"omitempty,min=1"`
}

// DistanceQuery 请求体
type DistanceQuery struct {
	First    TypedID `json:"first"  validate:"required"`
	Second   TypedID `json:"second" validate:"required"`
	Distance float64 `json:"distance" validate:"required,min=0"`
}

type DistanceSimpleQuery struct {
	Mark1ID  string  `json:"mark1_id" validate:"required,uuid"`
	Mark2ID  string  `json:"mark2_id" validate:"required,uuid"`
	Distance float64 `json:"distance" validate:"required,min=0"`
}
