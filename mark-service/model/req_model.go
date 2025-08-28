package model

import (
// "time"
)

// ==========================
// MarkType
// ==========================
type MarkTypeRequest struct {
	TypeName string `json:"type_name" binding:"required,max=255"`
}

// ==========================
// MarkTag
// ==========================
type MarkTagRequest struct {
	TagName string `json:"tag_name" binding:"required,max=255"`
}

// ==========================
// Mark
// ==========================

// 创建/更新时共用字段
type MarkRequest struct {
	DeviceID      string   `json:"device_id" binding:"required,max=255"`
	MarkName      string   `json:"mark_name" binding:"required,max=255"`
	MqttTopic     string   `json:"mqtt_topic" binding:"max=65535"`
	PersistMQTT   *bool    `json:"persist_mqtt,omitempty"`    // 可选(默认false)
	SafeDistanceM *float64 `json:"safe_distance_m,omitempty"` // 可选
	MarkTypeID    *int     `json:"mark_type_id,omitempty"`    // 可选(默认nil)
	Tags          []string `json:"tags,omitempty"`            // 可选(默认nil)
}

type MarkUpdateRequest struct {
	DeviceID      *string  `json:"device_id,omitempty" binding:"omitempty,max=255"`
	MarkName      *string  `json:"mark_name,omitempty" binding:"omitempty,max=255"`
	MqttTopic     *string  `json:"mqtt_topic,omitempty" binding:"omitempty,max=65535"`
	PersistMQTT   *bool    `json:"persist_mqtt,omitempty"`
	SafeDistanceM *float64 `json:"safe_distance_m,omitempty"`
	MarkTypeID    *int     `json:"mark_type_id,omitempty"`
	Tags          []string `json:"tags,omitempty"` // 传 nil 表示不改；传 []string{} 表示清空
}
