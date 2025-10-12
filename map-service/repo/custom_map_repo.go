package repo

import (
	"IOT-Manage-System/map-service/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type CustomMapRepo struct {
	db *gorm.DB
}

// NewCustomMapRepo 构造函数
func NewCustomMapRepo(db *gorm.DB) *CustomMapRepo {
	return &CustomMapRepo{db: db}
}

// --------------------------------------------------
// Create
// --------------------------------------------------

// Create 插入一条记录，成功返回 nil
func (r *CustomMapRepo) Create(customMap *model.CustomMap) error {
	return r.db.Create(customMap).Error
}

// --------------------------------------------------
// Read
// --------------------------------------------------

// GetByID 根据主键查询
func (r *CustomMapRepo) GetByID(id uuid.UUID) (*model.CustomMap, error) {
	var cm model.CustomMap
	err := r.db.First(&cm, "id = ?", id).Error
	return &cm, err
}

// GetByName 根据地图名称精确查询
func (r *CustomMapRepo) GetByName(name string) (*model.CustomMap, error) {
	var cm model.CustomMap
	err := r.db.First(&cm, "map_name = ?", name).Error
	return &cm, err
}

// ListAll 获取全部记录（简单场景）
func (r *CustomMapRepo) ListAll() ([]model.CustomMap, error) {
	var list []model.CustomMap
	err := r.db.Order("created_at DESC").Find(&list).Error
	return list, err
}

// GetLatest 获取最新创建的一条记录
func (r *CustomMapRepo) GetLatest() (*model.CustomMap, error) {
	var cm model.CustomMap
	err := r.db.Order("created_at DESC").First(&cm).Error
	return &cm, err
}

// --------------------------------------------------
// Update
// --------------------------------------------------

// UpdateByID 全字段更新（零值也写库）
func (r *CustomMapRepo) UpdateByID(id uuid.UUID, customMap *model.CustomMap) error {
	return r.db.Model(&model.CustomMap{}).Where("id = ?", id).Updates(customMap).Error
}

// --------------------------------------------------
// Delete
// --------------------------------------------------

// DeleteByID 硬删除
func (r *CustomMapRepo) DeleteByID(id uuid.UUID) error {
	return r.db.Delete(&model.CustomMap{}, "id = ?", id).Error
}
