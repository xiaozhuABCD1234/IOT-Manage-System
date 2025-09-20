package model

import (
	"time"
)

// ==========================
// MarkType
// ==========================
type MarkTypeResponse struct {
	ID                 int      `json:"id"`
	TypeName           string   `json:"type_name"`
	DefaultDangerZoneM *float64 `json:"default_danger_zone_m,omitempty"`
}

// ==========================
// MarkTag
// ==========================
type MarkTagResponse struct {
	ID      int    `json:"id"`
	TagName string `json:"tag_name"`
}

// 返回给前端用的完整结构
type MarkResponse struct {
	ID           string            `json:"id"`
	DeviceID     string            `json:"device_id"`
	MarkName     string            `json:"mark_name"`
	MqttTopic    []string          `json:"mqtt_topic"`
	PersistMQTT  bool              `json:"persist_mqtt"`
	DangerZoneM  *float64          `json:"danger_zone_m"`
	MarkType     *MarkTypeResponse `json:"mark_type"` // 嵌套类型
	Tags         []MarkTagResponse `json:"tags"`      // 嵌套标签
	CreatedAt    time.Time         `json:"created_at"`
	UpdatedAt    time.Time         `json:"updated_at"`
	LastOnlineAt *time.Time        `json:"last_online_at"`
}
