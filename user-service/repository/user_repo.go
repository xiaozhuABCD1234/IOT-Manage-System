package repository

import (
	"IOT-Manage-System/user-service/models"

	"gorm.io/gorm"
)

type UserRepo interface {
	Create(u *models.User) error
	FindByUsername(username string) (*models.User, error)
	FindByID(id string) (*models.User, error)
	Update(u *models.User) error
	Delete(id string) error
	List(offset, limit int) ([]models.User, int64, error)
}

type userRepo struct{ db *gorm.DB }

func NewUserRepo(db *gorm.DB) UserRepo {
	return &userRepo{db: db}
}

func (r *userRepo) Create(u *models.User) error {
	return r.db.Create(u).Error
}

func (r *userRepo) FindByUsername(name string) (*models.User, error) {
	var u models.User
	err := r.db.Where("username = ?", name).First(&u).Error
	return &u, err
}

func (r *userRepo) FindByID(id string) (*models.User, error) {
	var u models.User
	err := r.db.First(&u, "id = ?", id).Error
	return &u, err
}

// Update 更新整条用户记录（零值字段也会更新）
func (r *userRepo) Update(u *models.User) error {
	return r.db.Save(u).Error
}

// Delete 按 ID 软删除（gorm 默认软删，如需硬删：db.Unscoped().Delete(...))
func (r *userRepo) Delete(id string) error {
	return r.db.Delete(&models.User{}, "id = ?", id).Error
}

// List 分页获取用户列表 + 总数
func (r *userRepo) List(offset, limit int) ([]models.User, int64, error) {
	var list []models.User
	var total int64
	if err := r.db.Model(&models.User{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}
	err := r.db.Offset(offset).Limit(limit).Find(&list).Error
	return list, total, err
}
