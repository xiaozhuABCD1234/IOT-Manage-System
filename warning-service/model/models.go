package model

import (
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
)

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
}

func (Mark) TableName() string {
	return "marks"
}

type MarkPairSafeDistance struct {
	Mark1ID   uuid.UUID `gorm:"primaryKey"` // Mark1ID：参与比较的第一条 Mark ID（字典序较小）
	Mark2ID   uuid.UUID `gorm:"primaryKey"` // Mark2ID：参与比较的第二条 Mark ID（字典序较大）
	DistanceM float64   // DistanceM：两条 Mark 之间的安全距离（米）
}

func (MarkPairSafeDistance) TableName() string {
	return "mark_pair_safe_distance"
}
