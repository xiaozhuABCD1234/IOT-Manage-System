// repository/marktype_repo.go
package repo

import (
	// "errors"
	// "fmt"
	// "strings"
	"IOT-Manage-System/mark-service/model"
)

func (r *markRepo) CreateMarkType(mt *model.MarkType) error {
	return r.db.Create(mt).Error
}

func (r *markRepo) GetMarkTypeByID(id int) (*model.MarkType, error) {
	var mt model.MarkType
	err := r.db.First(&mt, id).Error
	if err != nil {
		return nil, err
	}
	return &mt, nil
}

func (r *markRepo) GetMarkTypeByName(name string) (*model.MarkType, error) {
	var mt model.MarkType
	err := r.db.Where("type_name = ?", name).First(&mt).Error
	if err != nil {
		return nil, err
	}
	return &mt, nil
}

// ListMarkTypes 列表查询，支持分页
func (r *markRepo) ListMarkTypes(offset, limit int) ([]model.MarkType, error) {
	var types []model.MarkType
	err := r.db.Offset(offset).Limit(limit).Find(&types).Error
	return types, err
}

// ListMarkTypesWithCount 列表查询，支持分页，并返回总记录数
func (r *markRepo) ListMarkTypesWithCount(offset, limit int) ([]model.MarkType, int64, error) {
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

func (r *markRepo) UpdateMarkType(mt *model.MarkType) error {
	return r.db.Save(mt).Error
}

func (r *markRepo) DeleteMarkType(id int) error {
	return r.db.Delete(&model.MarkType{}, id).Error
}

func (r *markRepo) GetMarkIDsByTypeID(typeID int) ([]string, error) {
	var markIDs []string

	// 直接通过marks表中的外键字段查询
	err := r.db.Model(&model.Mark{}).
		Where("mark_type_id = ?", typeID).
		Pluck("id", &markIDs).Error

	if err != nil {
		return nil, err
	}
	return markIDs, nil
}

// GetAllTypeIDsAndNames 获取所有类型的 ID -> TypeName 映射
func (r *markRepo) GetAllTypeIDsAndNames() (map[int]string, error) {
	rows := make([]struct {
		ID   int
		Name string
	}, 0)

	// 只查两列
	if err := r.db.Model(&model.MarkType{}).
		Select("id", "type_name as name").
		Scan(&rows).Error; err != nil {
		return nil, err
	}

	// 转 map
	out := make(map[int]string, len(rows))
	for _, v := range rows {
		out[v.ID] = v.Name
	}
	return out, nil
}
