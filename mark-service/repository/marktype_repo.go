// repository/marktype_repo.go
package repository

import (
	// "errors"
	// "fmt"
	// "strings"
	"IOT-Manage-System/mark-service/model"
)

func (r *MarkRepo) CreateMarkType(mt *model.MarkType) error {
	return r.db.Create(mt).Error
}

func (r *MarkRepo) GetMarkTypeByID(id int) (*model.MarkType, error) {
	var mt model.MarkType
	err := r.db.First(&mt, id).Error
	if err != nil {
		return nil, err
	}
	return &mt, nil
}

func (r *MarkRepo) GetMarkTypeByName(name string) (*model.MarkType, error) {
	var mt model.MarkType
	err := r.db.Where("type_name = ?", name).First(&mt).Error
	if err != nil {
		return nil, err
	}
	return &mt, nil
}

// ListMarkTypes 列表查询，支持分页
func (r *MarkRepo) ListMarkTypes(offset, limit int) ([]model.MarkType, error) {
	var types []model.MarkType
	err := r.db.Offset(offset).Limit(limit).Find(&types).Error
	return types, err
}

// ListMarkTypesWithCount 列表查询，支持分页，并返回总记录数
func (r *MarkRepo) ListMarkTypesWithCount(offset, limit int) ([]model.MarkType, int64, error) {
	var types []model.MarkType
	var total int64

	// 获取总记录数
	if err := r.db.Model(&model.MarkType{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 获取分页数据
	err := r.db.Offset(offset).Limit(limit).Find(&types).Error
	return types, total, err
}

func (r *MarkRepo) UpdateMarkType(mt *model.MarkType) error {
	return r.db.Save(mt).Error
}

func (r *MarkRepo) DeleteMarkType(id int) error {
	return r.db.Delete(&model.MarkType{}, id).Error
}