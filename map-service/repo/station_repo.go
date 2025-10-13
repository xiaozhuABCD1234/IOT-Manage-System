package repo

import (
	"IOT-Manage-System/map-service/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type StationRepo struct {
	db *gorm.DB
}

// NewStationRepo 构造函数
func NewStationRepo(db *gorm.DB) *StationRepo {
	return &StationRepo{db: db}
}

// --------------------------------------------------
// Create
// --------------------------------------------------

// Create 插入一条记录，成功返回 nil
func (r *StationRepo) Create(station *model.Station) error {
	return r.db.Create(station).Error
}

// CreateInBatches 批量插入，指定批次大小
func (r *StationRepo) CreateInBatches(stations []model.Station, batchSize int) error {
	return r.db.CreateInBatches(stations, batchSize).Error
}

// --------------------------------------------------
// Read
// --------------------------------------------------

// GetByID 根据主键查询
func (r *StationRepo) GetByID(id uuid.UUID) (*model.Station, error) {
	var s model.Station
	err := r.db.First(&s, "id = ?", id).Error
	return &s, err
}

// GetByName 根据基站名称精确查询
func (r *StationRepo) GetByName(name string) (*model.Station, error) {
	var s model.Station
	err := r.db.First(&s, "station_name = ?", name).Error
	return &s, err
}

// ListAll 获取全部记录（简单场景）
func (r *StationRepo) ListAll() ([]model.Station, error) {
	var list []model.Station
	err := r.db.Find(&list).Error
	return list, err
}

// --------------------------------------------------
// Update
// --------------------------------------------------

// UpdateByID 全字段更新（零值也写库）
func (r *StationRepo) UpdateByID(id uuid.UUID, station *model.Station) error {
	return r.db.Model(&model.Station{}).Where("id = ?", id).Updates(station).Error
}

// UpdateByIDWithMap 使用map更新，支持零值更新
func (r *StationRepo) UpdateByIDWithMap(id uuid.UUID, updates map[string]interface{}) error {
	return r.db.Model(&model.Station{}).Where("id = ?", id).Updates(updates).Error
}

// UpdateName 只更新名称
func (r *StationRepo) UpdateName(id uuid.UUID, newName string) error {
	return r.db.Model(&model.Station{}).Where("id = ?", id).Update("station_name", newName).Error
}

// --------------------------------------------------
// Delete
// --------------------------------------------------

// DeleteByID 硬删除
func (r *StationRepo) DeleteByID(id uuid.UUID) error {
	return r.db.Delete(&model.Station{}, "id = ?", id).Error
}

// DeleteInBatches 批量硬删除
func (r *StationRepo) DeleteInBatches(ids []uuid.UUID) error {
	return r.db.Delete(&model.Station{}, "id IN ?", ids).Error
}
