package model

import (
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
	"gorm.io/gorm"
)

// MarkType 标记类型表：同一类型下可拥有多条 Mark 记录。
type MarkType struct {
	ID                   int      `gorm:"primaryKey;autoIncrement;column:id"`        // ID：主键，自增
	TypeName             string   `gorm:"unique;size:255;not null;column:type_name"` // TypeName：类型名称，全局唯一
	DefaultSafeDistanceM *float64 `gorm:"column:default_safe_distance_m;default:-1"` // DefaultSafeDistanceM：该类型下默认安全距离（米），-1 表示未设置

	// 一对多关联：删除类型时被关联的 Mark 受外键 RESTRICT 保护。
	Marks []Mark `gorm:"foreignKey:MarkTypeID;references:ID"`
}

// TableName 返回 GORM 使用的表名。
func (MarkType) TableName() string { return "mark_types" }

// MarkTag 标记标签表：标签与 Mark 之间为多对多关系，通过 mark_tag_relation 表维护。
type MarkTag struct {
	ID      int    `gorm:"primaryKey;autoIncrement;column:id"`       // ID：主键，自增
	TagName string `gorm:"unique;size:255;not null;column:tag_name"` // TagName：标签名称，全局唯一

	// 多对多关联：标签被删除时，GORM 会自动级联删除关联关系（constraint:OnDelete:CASCADE）。
	Marks []Mark `gorm:"many2many:mark_tag_relation;foreignKey:ID;joinForeignKey:TagID;references:ID;joinReferences:MarkID"`
}

func (MarkTag) TableName() string { return "mark_tags" }

// Mark 标记主表：一条 Mark 必须归属某一种 MarkType，可拥有零到多个 MarkTag。
type Mark struct {
	ID            uuid.UUID      `gorm:"primaryKey;type:uuid;default:gen_random_uuid();column:id"` // ID：主键，UUID v4，数据库默认生成
	DeviceID      string         `gorm:"unique;size:255;not null;column:device_id"`                // DeviceID：设备标识，全局唯一
	MarkName      string         `gorm:"size:255;not null;column:mark_name"`                       // MarkName：标记名称
	MqttTopic     pq.StringArray `gorm:"type:text[];not null;default:'{}';column:mqtt_topic"`      // MqttTopic：该标记监听的 MQTT 主题数组，空数组表示未订阅
	PersistMQTT   bool           `gorm:"not null;default:false;column:persist_mqtt"`               // PersistMQTT：是否持久化 MQTT 消息
	SafeDistanceM *float64       `gorm:"column:safe_distance_m"`                                   // SafeDistanceM：自定义安全距离（米），nil 表示使用所属类型的默认值
	MarkTypeID    int            `gorm:"not null;column:mark_type_id"`                             // MarkTypeID：外键，关联 mark_types.id
	CreatedAt     time.Time      `gorm:"not null;default:now();column:created_at"`                 // CreatedAt：记录创建时间
	UpdatedAt     time.Time      `gorm:"not null;default:now();column:updated_at"`                 // UpdatedAt：记录最后更新时间
	LastOnlineAt  *time.Time     `gorm:"column:last_online_at"`                                    // LastOnlineAt：设备最后一次上线时间，nil 表示从未上线

	// 外键实体：查询时自动填充。
	MarkType MarkType `gorm:"foreignKey:MarkTypeID;references:ID;constraint:OnDelete:RESTRICT"`

	// 多对多关联：Mark 被删除时，GORM 会自动级联删除 mark_tag_relation 中的关联行。
	Tags []MarkTag `gorm:"many2many:mark_tag_relation;foreignKey:ID;joinForeignKey:MarkID;references:ID;joinReferences:TagID;constraint:OnDelete:CASCADE"`
}

func (Mark) TableName() string { return "marks" }

// MarkPairSafeDistance 用于存储两条 Mark 之间的安全距离约束。
// 业务上 (mark1, mark2) 与 (mark2, mark1) 视为同一记录，因此通过 BeforeCreate 保证字典序。
type MarkPairSafeDistance struct {
	Mark1ID   uuid.UUID `gorm:"primaryKey"` // Mark1ID：参与比较的第一条 Mark ID（字典序较小）
	Mark2ID   uuid.UUID `gorm:"primaryKey"` // Mark2ID：参与比较的第二条 Mark ID（字典序较大）
	DistanceM float64   // DistanceM：两条 Mark 之间的安全距离（米）
}

func (MarkPairSafeDistance) TableName() string { return "mark_pair_safe_distance" }

// BeforeCreate GORM 钩子：在插入前将 UUID 对调整为字典序，避免重复主键。
func (m *MarkPairSafeDistance) BeforeCreate(tx *gorm.DB) error {
	if m.Mark1ID.String() > m.Mark2ID.String() {
		m.Mark1ID, m.Mark2ID = m.Mark2ID, m.Mark1ID
	}
	return nil
}
