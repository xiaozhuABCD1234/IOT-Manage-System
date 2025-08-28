// repository/is_exists.go
package repository

import (
	"IOT-Manage-System/mark-service/model"
)

// IsDeviceIDExists 判断 device_id 是否已存在
func (r *MarkRepo) IsDeviceIDExists(deviceID string) (bool, error) {
	var count int64
	err := r.db.Model(&model.Mark{}).Where("device_id = ?", deviceID).Count(&count).Error
	return count > 0, err
}

// IsMarkNameExists 判断 mark_name 是否已存在
func (r *MarkRepo) IsMarkNameExists(markName string) (bool, error) {
	var count int64
	err := r.db.Model(&model.Mark{}).Where("mark_name = ?", markName).Count(&count).Error
	return count > 0, err
}

// IsTagNameExists 判断 tag_name 是否已存在
func (r *MarkRepo) IsTagNameExists(tagName string) (bool, error) {
	var count int64
	err := r.db.Model(&model.MarkTag{}).Where("tag_name = ?", tagName).Count(&count).Error
	return count > 0, err
}

// IsTypeNameExists 判断 type_name 是否已存在
func (r *MarkRepo) IsTypeNameExists(typeName string) (bool, error) {
	var count int64
	err := r.db.Model(&model.MarkType{}).Where("type_name = ?", typeName).Count(&count).Error
	return count > 0, err
}
