// repository/marktag_repo.go
package repo

import (
	"errors"
	// "fmt"
	// "strings"
	"IOT-Manage-System/mark-service/model"

	"gorm.io/gorm"
)

func (r *markRepo) CreateMarkTag(mt *model.MarkTag) error {
	return r.db.Create(mt).Error
}

func (r *markRepo) GetMarkTagByID(id int) (*model.MarkTag, error) {
	var tag model.MarkTag
	err := r.db.First(&tag, id).Error
	if err != nil {
		return nil, err
	}
	return &tag, nil
}

func (r *markRepo) GetMarkTagByName(name string) (*model.MarkTag, error) {
	var tag model.MarkTag
	err := r.db.Where("tag_name = ?", name).First(&tag).Error
	if err != nil {
		return nil, err
	}
	return &tag, nil
}

func (r *markRepo) ListMarkTags(offset, limit int) ([]model.MarkTag, error) {
	var tags []model.MarkTag
	err := r.db.Offset(offset).Limit(limit).Find(&tags).Error
	return tags, err
}

func (r *markRepo) UpdateMarkTag(tag *model.MarkTag) error {
	return r.db.Save(tag).Error
}

func (r *markRepo) DeleteMarkTag(id int) error {
	return r.db.Delete(&model.MarkTag{}, id).Error
}

// FindTagsByNames 批量查询标签：根据名字列表查找存在的标签，并返回未找到的名字
// 返回：存在的标签列表、未找到的标签名、错误
func (r *markRepo) FindTagsByNames(names []string) ([]model.MarkTag, []string, error) {
	if len(names) == 0 {
		return nil, nil, nil
	}

	var existingTags []model.MarkTag

	// 查询数据库中匹配的名字
	err := r.db.Where("tag_name IN ?", names).Find(&existingTags).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			// 没有找到任何记录，所有名字都不存在
			return nil, names, nil
		}
		return nil, nil, err
	}

	// 提取查到的 tag_name
	foundNamesMap := make(map[string]bool)
	for _, tag := range existingTags {
		foundNamesMap[tag.TagName] = true
	}

	// 找出未找到的 names
	var notFound []string
	for _, name := range names {
		if !foundNamesMap[name] {
			notFound = append(notFound, name)
		}
	}

	return existingTags, notFound, nil
}

func (r *markRepo) GetOrCreateTags(names []string) ([]model.MarkTag, error) {
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

// ListMarkTagsWithCount 列表查询，支持分页，并返回总记录数
func (r *markRepo) ListMarkTagsWithCount(offset, limit int) ([]model.MarkTag, int64, error) {
	var tags []model.MarkTag
	var total int64

	// 获取总记录数
	if err := r.db.Model(&model.MarkTag{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 获取分页数据
	err := r.db.Offset(offset).Limit(limit).Find(&tags).Error
	return tags, total, err
}

func (r *markRepo) GetMarkIDsByTagID(tagID int) ([]string, error) {
	var markIDs []string

	err := r.db.Table("mark_tag_relation").
		Where("tag_id = ?", tagID).
		Pluck("mark_id", &markIDs).Error

	if err != nil {
		return nil, err
	}
	return markIDs, nil
}
