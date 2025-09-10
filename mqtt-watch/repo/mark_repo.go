package repo

import (
	"IOT-Manage-System/mqtt-watch/model"
	"errors"

	"gorm.io/gorm"
)

type MarkRepo interface {
	GetPersistMQTTByDeviceID(deviceID string) (bool, error)
	GetDeviceIDsByPersistMQTT(persist bool) ([]string, error)
}

type markRepo struct {
	db *gorm.DB
}

// NewMarkRepo 返回 MarkRepository 接口实例
func NewMarkRepo(db *gorm.DB) MarkRepo {
	return &markRepo{db: db}
}

// GetPersistMQTTByDeviceID 根据 DeviceID 查询 PersistMQTT 的值
// 如果设备不存在，返回 false, nil
func (r *markRepo) GetPersistMQTTByDeviceID(deviceID string) (bool, error) {
	var persist bool

	result := r.db.Model(&model.Mark{}).
		Select("persist_mqtt").
		Where("device_id = ?", deviceID).
		First(&persist)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			// 设备不存在，返回 false 且无错误
			return false, nil
		}
		// 其他数据库错误（如连接失败），返回错误
		return false, result.Error
	}
	return persist, nil
}

// GetDeviceIDsByPersistMQTT 根据 PersistMQTT 的值查询所有对应的 DeviceID 列表
func (r *markRepo) GetDeviceIDsByPersistMQTT(persist bool) ([]string, error) {
	var deviceIDs []string

	// 只查询 device_id 字段
	result := r.db.Model(&model.Mark{}).
		Select("device_id").
		Where("persist_mqtt = ?", persist).
		Pluck("device_id", &deviceIDs)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, result.Error
	}

	return deviceIDs, nil
}
