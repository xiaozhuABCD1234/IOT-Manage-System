// repository/mark_repo.go
package repository

import (
	"errors"
	"time"

	"IOT-Manage-System/mark-service/model"

	"gorm.io/gorm"
)

func (r *MarkRepo) CreateMark(mark *model.Mark) error {
	return r.db.Create(mark).Error
}

// Create 创建一条 Mark 记录，并自动处理标签关联
func (r *MarkRepo) CreateMarkAutoTag(mark *model.Mark, tagNames []string) error {
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
func (r *MarkRepo) GetMarkByID(id string, preload bool) (*model.Mark, error) {
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
func (r *MarkRepo) GetMarkByDeviceID(deviceID string, preload bool) (*model.Mark, error) {
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
func (r *MarkRepo) ListMark(offset, limit int, preload bool) ([]model.Mark, error) {
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
func (r *MarkRepo) ListMarkWithCount(offset, limit int, preload bool) ([]model.Mark, int64, error) {
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
	q = q.Offset(offset).Limit(limit)
	err := q.Find(&marks).Error
	return marks, total, err
}

// Update 更新 Mark 本身及其标签
func (r *MarkRepo) UpdateMark(mark *model.Mark, tagNames []string) error {
	// 1. 更新基础字段
	if err := r.db.Save(mark).Error; err != nil {
		return err
	}
	// 2. 更新标签
	if tagNames != nil {
		tags, err := r.getOrCreateTags(tagNames)
		if err != nil {
			return err
		}
		if err := r.db.Model(mark).Association("Tags").Replace(tags); err != nil {
			return err
		}
	}
	return nil
}

// Delete 软删除
func (r *MarkRepo) DeleteMark(id string) error {
	return r.db.Delete(&model.Mark{}, "id = ?", id).Error
}

// UpdateLastOnline 更新最后在线时间
func (r *MarkRepo) UpdateMarkLastOnline(deviceID string, t time.Time) error {
	return r.db.Model(&model.Mark{}).
		Where("device_id = ?", deviceID).
		Update("last_online_at", t).Error
}

// ---------- 内部辅助 ----------
// getOrCreateTags 内部复用，批量获取或创建标签
func (r *MarkRepo) getOrCreateTags(names []string) ([]model.MarkTag, error) {
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
func (r *MarkRepo) GetMarksByTagID(tagID int, preload bool, offset, limit int) ([]model.Mark, int64, error) {
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
func (r *MarkRepo) GetMarksByTagName(tagName string, preload bool, offset, limit int) ([]model.Mark, int64, error) {
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
func (r *MarkRepo) GetMarksByTypeID(typeID int, preload bool, offset, limit int) ([]model.Mark, int64, error) {
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
func (r *MarkRepo) GetMarksByTypeName(typeName string, preload bool, offset, limit int) ([]model.Mark, int64, error) {
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
