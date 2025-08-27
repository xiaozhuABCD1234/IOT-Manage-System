package model

import (
	"time"
	// "github.com/google/uuid"
)

// ==========================
// mark_types
// ==========================
type MarkType struct {
	ID       int    `gorm:"primaryKey;autoIncrement;column:id"`
	TypeName string `gorm:"unique;size:255;not null;column:type_name"`

	// 一对多：一个类型下有多条 Mark
	Marks []Mark `gorm:"foreignKey:MarkTypeID;references:ID"`
}

func (MarkType) TableName() string { return "mark_types" }

// ==========================
// mark_tags
// ==========================
type MarkTag struct {
	ID      int    `gorm:"primaryKey;autoIncrement;column:id"`
	TagName string `gorm:"unique;size:255;not null;column:tag_name"`

	// 多对多：一个标签可以对应多条 Mark；通过 mark_tag_relation 表
	Marks []Mark `gorm:"many2many:mark_tag_relation;foreignKey:ID;joinForeignKey:TagID;references:ID;joinReferences:MarkID"`
}

func (MarkTag) TableName() string { return "mark_tags" }

// ==========================
// marks
// ==========================
type Mark struct {
	ID            string     `gorm:"primaryKey;type:uuid;default:gen_random_uuid();column:id"`
	DeviceID      string     `gorm:"unique;size:255;not null;column:device_id"`
	MarkName      string     `gorm:"size:255;not null;column:mark_name"`
	MqttTopic     string     `gorm:"type:text;not null;default:'';column:mqtt_topic"`
	PersistMQTT   bool       `gorm:"not null;default:false;column:persist_mqtt"`
	SafeDistanceM *float64   `gorm:"column:safe_distance_m"` // 允许 NULL
	MarkTypeID    int        `gorm:"not null;column:mark_type_id"`
	CreatedAt     time.Time  `gorm:"not null;default:now();column:created_at"`
	UpdatedAt     time.Time  `gorm:"not null;default:now();column:updated_at"`
	LastOnlineAt  *time.Time `gorm:"column:last_online_at"` // 允许 NULL

	// 外键关联
	MarkType MarkType `gorm:"foreignKey:MarkTypeID;references:ID;constraint:OnDelete:RESTRICT"`

	// 多对多：通过 mark_tag_relation 表
	Tags []MarkTag `gorm:"many2many:mark_tag_relation;foreignKey:ID;joinForeignKey:MarkID;references:ID;joinReferences:TagID;constraint:OnDelete:CASCADE"`
}

func (Mark) TableName() string { return "marks" }
