package repo

import (
	"IOT-Manage-System/map-service/model"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type PolygonFenceRepo struct {
	db *gorm.DB
}

func NewPolygonFenceRepo(db *gorm.DB) *PolygonFenceRepo {
	return &PolygonFenceRepo{db: db}
}

// --------------------------------------------------
// Create
// --------------------------------------------------

// Create 创建多边形围栏
func (r *PolygonFenceRepo) Create(fence *model.PolygonFence) error {
	// 使用原生 SQL，利用 ST_GeomFromText 函数
	return r.db.Exec(`
		INSERT INTO polygon_fences (is_indoor, fence_name, geometry, description, is_active)
		VALUES (?, ?, ST_GeomFromText(?), ?, ?)
	`, fence.IsIndoor, fence.FenceName, fence.Geometry, fence.Description, fence.IsActive).Error
}

// --------------------------------------------------
// Read
// --------------------------------------------------

// GetByID 根据ID获取围栏
func (r *PolygonFenceRepo) GetByID(id uuid.UUID) (*model.PolygonFence, error) {
	var fence model.PolygonFence
	// 使用 ST_AsText 将几何数据转换为 WKT 格式
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry, 
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE id = ?
	`, id).Scan(&fence).Error
	if err != nil {
		return nil, err
	}
	return &fence, nil
}

// GetByName 根据名称获取围栏
func (r *PolygonFenceRepo) GetByName(name string) (*model.PolygonFence, error) {
	var fence model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry, 
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE fence_name = ?
	`, name).Scan(&fence).Error
	if err != nil {
		return nil, err
	}
	return &fence, nil
}

// ListAll 获取所有围栏
func (r *PolygonFenceRepo) ListAll() ([]model.PolygonFence, error) {
	var fences []model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry, 
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		ORDER BY created_at DESC
	`).Scan(&fences).Error
	return fences, err
}

// ListActive 获取所有激活的围栏
func (r *PolygonFenceRepo) ListActive() ([]model.PolygonFence, error) {
	var fences []model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry, 
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE is_active = true
		ORDER BY created_at DESC
	`).Scan(&fences).Error
	return fences, err
}

// --------------------------------------------------
// Update
// --------------------------------------------------

// UpdateByID 更新围栏
func (r *PolygonFenceRepo) UpdateByID(id uuid.UUID, fence *model.PolygonFence) error {
	return r.db.Exec(`
		UPDATE polygon_fences
		SET is_indoor = ?,
		    fence_name = ?, 
		    geometry = ST_GeomFromText(?), 
		    description = ?, 
		    is_active = ?,
		    updated_at = CURRENT_TIMESTAMP
		WHERE id = ?
	`, fence.IsIndoor, fence.FenceName, fence.Geometry, fence.Description, fence.IsActive, id).Error
}

// --------------------------------------------------
// Delete
// --------------------------------------------------

// DeleteByID 删除围栏
func (r *PolygonFenceRepo) DeleteByID(id uuid.UUID) error {
	return r.db.Exec("DELETE FROM polygon_fences WHERE id = ?", id).Error
}

// --------------------------------------------------
// 空间查询
// --------------------------------------------------

// IsPointInFence 检查点是否在指定围栏内
func (r *PolygonFenceRepo) IsPointInFence(fenceID uuid.UUID, x, y float64) (bool, error) {
	var isInside bool
	err := r.db.Raw(`
		SELECT ST_Contains(geometry, ST_Point(?, ?))
		FROM polygon_fences
		WHERE id = ? AND is_active = true
	`, x, y, fenceID).Scan(&isInside).Error
	return isInside, err
}

// FindFencesByPoint 查询某个点所在的所有激活围栏
func (r *PolygonFenceRepo) FindFencesByPoint(x, y float64) ([]model.PolygonFence, error) {
	var fences []model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry, 
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE is_active = true
		AND ST_Contains(geometry, ST_Point(?, ?))
		ORDER BY created_at DESC
	`, x, y).Scan(&fences).Error
	return fences, err
}

// IsPointInAnyFence 检查点是否在任意一个激活的围栏内
func (r *PolygonFenceRepo) IsPointInAnyFence(x, y float64) (bool, error) {
	var count int64
	err := r.db.Raw(`
		SELECT COUNT(*)
		FROM polygon_fences
		WHERE is_active = true
		AND ST_Contains(geometry, ST_Point(?, ?))
	`, x, y).Scan(&count).Error
	if err != nil {
		return false, err
	}
	return count > 0, nil
}

// --------------------------------------------------
// 室内/室外专用查询
// --------------------------------------------------

// IsPointInIndoorFence 检查点是否在指定室内围栏内
func (r *PolygonFenceRepo) IsPointInIndoorFence(fenceID uuid.UUID, x, y float64) (bool, error) {
	var isInside bool
	err := r.db.Raw(`
		SELECT ST_Contains(geometry, ST_Point(?, ?))
		FROM polygon_fences
		WHERE id = ? AND is_active = true AND is_indoor = true
	`, x, y, fenceID).Scan(&isInside).Error
	return isInside, err
}

// IsPointInOutdoorFence 检查点是否在指定室外围栏内
func (r *PolygonFenceRepo) IsPointInOutdoorFence(fenceID uuid.UUID, x, y float64) (bool, error) {
	var isInside bool
	err := r.db.Raw(`
		SELECT ST_Contains(geometry, ST_Point(?, ?))
		FROM polygon_fences
		WHERE id = ? AND is_active = true AND is_indoor = false
	`, x, y, fenceID).Scan(&isInside).Error
	return isInside, err
}

// FindIndoorFencesByPoint 查询某个点所在的所有激活室内围栏
func (r *PolygonFenceRepo) FindIndoorFencesByPoint(x, y float64) ([]model.PolygonFence, error) {
	var fences []model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry, 
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE is_active = true AND is_indoor = true
		AND ST_Contains(geometry, ST_Point(?, ?))
		ORDER BY created_at DESC
	`, x, y).Scan(&fences).Error
	return fences, err
}

// FindOutdoorFencesByPoint 查询某个点所在的所有激活室外围栏
func (r *PolygonFenceRepo) FindOutdoorFencesByPoint(x, y float64) ([]model.PolygonFence, error) {
	var fences []model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry, 
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE is_active = true AND is_indoor = false
		AND ST_Contains(geometry, ST_Point(?, ?))
		ORDER BY created_at DESC
	`, x, y).Scan(&fences).Error
	return fences, err
}

// IsPointInAnyIndoorFence 检查点是否在任意一个激活的室内围栏内
func (r *PolygonFenceRepo) IsPointInAnyIndoorFence(x, y float64) (bool, error) {
	var count int64
	err := r.db.Raw(`
		SELECT COUNT(*)
		FROM polygon_fences
		WHERE is_active = true AND is_indoor = true
		AND ST_Contains(geometry, ST_Point(?, ?))
	`, x, y).Scan(&count).Error
	if err != nil {
		return false, err
	}
	return count > 0, nil
}

// IsPointInAnyOutdoorFence 检查点是否在任意一个激活的室外围栏内
func (r *PolygonFenceRepo) IsPointInAnyOutdoorFence(x, y float64) (bool, error) {
	var count int64
	err := r.db.Raw(`
		SELECT COUNT(*)
		FROM polygon_fences
		WHERE is_active = true AND is_indoor = false
		AND ST_Contains(geometry, ST_Point(?, ?))
	`, x, y).Scan(&count).Error
	if err != nil {
		return false, err
	}
	return count > 0, nil
}

// GetBoundingBox 获取围栏的边界框
func (r *PolygonFenceRepo) GetBoundingBox(id uuid.UUID) (xMin, yMin, xMax, yMax float64, err error) {
	err = r.db.Raw(`
		SELECT 
			ST_XMin(geometry) as x_min,
			ST_YMin(geometry) as y_min,
			ST_XMax(geometry) as x_max,
			ST_YMax(geometry) as y_max
		FROM polygon_fences
		WHERE id = ?
	`, id).Row().Scan(&xMin, &yMin, &xMax, &yMax)
	return
}
