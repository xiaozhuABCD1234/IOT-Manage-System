// repository/mark_repo.go
package repo

import (
	"errors"
	"time"

	"IOT-Manage-System/mark-service/model"

	"gorm.io/gorm"
)

func (r *markRepo) CreateMark(mark *model.Mark) error {
	return r.db.Create(mark).Error
}

// Create 创建一条 Mark 记录，并自动处理标签关联
func (r *markRepo) CreateMarkAutoTag(mark *model.Mark, tagNames []string) error {
	if len(tagNames) > 0 {
		tags, err := r.getOrCreateTags(tagNames)
		if err != nil {
			return err
		}
		mark.Tags = tags
	}
	return r.db.Create(mark).Error
}

// GetByID 根据 ID 查询，可预加载关联
func (r *markRepo) GetMarkByID(id string, preload bool) (*model.Mark, error) {
	q := r.db
	if preload {
		q = q.Preload("MarkType").Preload("Tags")
	}
	var mark model.Mark
	err := q.First(&mark, "id = ?", id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &mark, err
}

// GetByDeviceID 根据 DeviceID 查询
func (r *markRepo) GetMarkByDeviceID(deviceID string, preload bool) (*model.Mark, error) {
	q := r.db
	if preload {
		q = q.Preload("MarkType").Preload("Tags")
	}
	var mark model.Mark
	err := q.Where("device_id = ?", deviceID).First(&mark).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &mark, err
}

// ListMark 列表查询，支持预加载和分页
func (r *markRepo) ListMark(offset, limit int, preload bool) ([]model.Mark, error) {
	q := r.db
	if preload {
		q = q.Preload("MarkType").Preload("Tags")
	}
	// 添加分页
	q = q.Offset(offset).Limit(limit)
	var marks []model.Mark
	err := q.Find(&marks).Error
	return marks, err
}

// ListMarkWithCount 列表查询，支持预加载、分页，并返回总记录数
// 这个方法对于前端分页控件（显示总页数）非常有用
func (r *markRepo) ListMarkWithCount(offset, limit int, preload bool) ([]model.Mark, int64, error) {
	q := r.db
	if preload {
		q = q.Preload("MarkType").Preload("Tags")
	}

	var marks []model.Mark
	var total int64

	// 先获取总记录数（不带分页）
	if err := q.Model(&model.Mark{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 再获取分页数据
	q = q.Offset(offset).Limit(limit).Order("created_at DESC")
	err := q.Find(&marks).Error
	return marks, total, err
}

// Update 更新 Mark 本身及其标签
func (r *markRepo) UpdateMark(mark *model.Mark, tagNames []string) error {
	// 1. 先写业务字段
	if err := r.db.Model(&model.Mark{}).
		Where("id = ?", mark.ID).
		Updates(map[string]interface{}{
			"mark_name":       mark.MarkName,
			"device_id":       mark.DeviceID,
			"mqtt_topic":      mark.MqttTopic,
			"persist_mqtt":    mark.PersistMQTT,
			"safe_distance_m": mark.SafeDistanceM,
			"mark_type_id":    mark.MarkTypeID,
		}).Error; err != nil {
		return err
	}

	// 2. 再管标签
	if tagNames != nil {
		tags, err := r.getOrCreateTags(tagNames)
		if err != nil {
			return err
		}
		// 重新加载一次指针，避免旧快照
		var fresh model.Mark
		if err := r.db.First(&fresh, mark.ID).Error; err != nil {
			return err
		}
		return r.db.Model(&fresh).Association("Tags").Replace(tags)
	}
	return nil
}

// Delete 软删除
func (r *markRepo) DeleteMark(id string) error {
	return r.db.Delete(&model.Mark{}, "id = ?", id).Error
}

// UpdateLastOnline 更新最后在线时间
func (r *markRepo) UpdateMarkLastOnline(deviceID string, t time.Time) error {
	return r.db.Model(&model.Mark{}).
		Where("device_id = ?", deviceID).
		Update("last_online_at", t).Error
}

// ---------- 内部辅助 ----------
// getOrCreateTags 内部复用，批量获取或创建标签
func (r *markRepo) getOrCreateTags(names []string) ([]model.MarkTag, error) {
	var tags []model.MarkTag
	for _, name := range names {
		if name == "" {
			continue // 过滤空值
		}
		var tag model.MarkTag
		// 显式赋值，更清晰
		err := r.db.Where("tag_name = ?", name).Assign(model.MarkTag{TagName: name}).FirstOrCreate(&tag).Error
		if err != nil {
			return nil, err
		}
		tags = append(tags, tag)
	}
	return tags, nil
}

// GetMarksByTagID 支持分页查询带有特定标签ID的标记，返回数据和总数
func (r *markRepo) GetMarksByTagID(tagID int, preload bool, offset, limit int) ([]model.Mark, int64, error) {
	// 验证标签是否存在
	var tag model.MarkTag
	if err := r.db.First(&tag, tagID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, 0, nil
		}
		return nil, 0, err
	}

	// 构建基础查询
	query := r.db.Model(&model.Mark{}).
		Joins("JOIN mark_tag_relation ON marks.id = mark_tag_relation.mark_id").
		Where("mark_tag_relation.tag_id = ?", tagID)

	// 预加载关联数据
	if preload {
		query = query.Preload("MarkType").Preload("Tags")
	}

	// 获取总数
	var total int64
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 获取分页数据
	var marks []model.Mark
	if err := query.Offset(offset).Limit(limit).Find(&marks).Error; err != nil {
		return nil, 0, err
	}

	return marks, total, nil
}

// GetMarksByTagName 根据标签名称分页查询关联的标记列表
func (r *markRepo) GetMarksByTagName(tagName string, preload bool, offset, limit int) ([]model.Mark, int64, error) {
	// 1. 先根据名称拿到标签
	var tag model.MarkTag
	if err := r.db.Where("tag_name = ?", tagName).First(&tag).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, 0, nil // 标签不存在，也返回 0 条数据
		}
		return nil, 0, err
	}

	// 2. 复用已有的按 ID 查询逻辑
	return r.GetMarksByTagID(int(tag.ID), preload, offset, limit)
}

// GetMarksByTypeID 支持分页查询带有特定类型ID的标记，返回数据和总数
func (r *markRepo) GetMarksByTypeID(typeID int, preload bool, offset, limit int) ([]model.Mark, int64, error) {
	// 验证类型是否存在
	var markType model.MarkType
	if err := r.db.First(&markType, typeID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, 0, nil
		}
		return nil, 0, err
	}

	// 构建基础查询
	query := r.db.Model(&model.Mark{}).Where("mark_type_id = ?", typeID)

	// 预加载关联数据
	if preload {
		query = query.Preload("MarkType").Preload("Tags")
	}

	// 获取总数
	var total int64
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 获取分页数据
	var marks []model.Mark
	if err := query.Offset(offset).Limit(limit).Find(&marks).Error; err != nil {
		return nil, 0, err
	}

	return marks, total, nil
}

// GetMarksByTypeName 根据类型名称分页查询关联的标记列表
func (r *markRepo) GetMarksByTypeName(typeName string, preload bool, offset, limit int) ([]model.Mark, int64, error) {
	// 1. 先根据名称拿到类型
	var markType model.MarkType
	if err := r.db.Where("type_name = ?", typeName).First(&markType).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, 0, nil // 类型不存在，也返回 0 条数据
		}
		return nil, 0, err
	}

	// 2. 复用已有的按 ID 查询逻辑
	return r.GetMarksByTypeID(int(markType.ID), preload, offset, limit)
}

// GetMarksByPersistMQTT 根据 PersistMQTT 字段查询 Mark 列表，支持分页和预加载
func (r *markRepo) GetMarksByPersistMQTT(persist bool, preload bool, offset, limit int) ([]model.Mark, int64, error) {
	var marks []model.Mark
	var total int64

	db := r.db

	// 如果需要预加载关联数据
	if preload {
		db = db.Preload("MarkType").Preload("Tags")
	}

	// 查询总数
	if err := db.Model(&model.Mark{}).Where("persist_mqtt = ?", persist).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 查询分页数据
	result := db.Where("persist_mqtt = ?", persist).
		Offset(offset).
		Limit(limit).
		Order("created_at DESC"). // 可选：按创建时间排序
		Find(&marks)

	if result.Error != nil {
		return nil, 0, result.Error
	}

	return marks, total, nil
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

func (r *markRepo) GetAllMarkDeviceIDsAndNames() (map[string]string, error) {
	rows := make([]struct {
		DeviceID string
		Name     string
	}, 0)

	// 只查两列
	if err := r.db.Model(&model.Mark{}).
		Select("device_id", "mark_name as name").
		Scan(&rows).Error; err != nil {
		return nil, err
	}

	// 转 map
	out := make(map[string]string, len(rows))
	for _, v := range rows {
		out[v.DeviceID] = v.Name
	}
	return out, nil
}
