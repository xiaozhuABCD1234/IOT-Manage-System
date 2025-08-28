package repository

import (
	"IOT-Manage-System/user-service/model"

	"gorm.io/gorm"
)

type UserRepo interface {
	Create(u *model.User) error
	FindByUsername(username string) (*model.User, error)
	FindByID(id string) (*model.User, error)
	Update(u *model.User) error
	Delete(id string) error
	List(offset, limit int) ([]model.User, int64, error)
}

type userRepo struct{ 
	db *gorm.DB 
}

func NewUserRepo(db *gorm.DB) UserRepo {
	return &userRepo{db: db}
}

func (r *userRepo) Create(u *model.User) error {
	return r.db.Create(u).Error
}

func (r *userRepo) FindByUsername(name string) (*model.User, error) {
	var u model.User
	err := r.db.Where("username = ?", name).First(&u).Error
	return &u, err
}

func (r *userRepo) FindByID(id string) (*model.User, error) {
	var u model.User
	err := r.db.First(&u, "id = ?", id).Error
	return &u, err
}

// Update 更新整条用户记录（零值字段也会更新）
func (r *userRepo) Update(u *model.User) error {
	return r.db.Save(u).Error
}

// Delete 按 ID 软删除（gorm 默认软删，如需硬删：db.Unscoped().Delete(...))
func (r *userRepo) Delete(id string) error {
	return r.db.Delete(&model.User{}, "id = ?", id).Error
}

// List 分页获取用户列表 + 总数
func (r *userRepo) List(offset, limit int) ([]model.User, int64, error) {
	var list []model.User
	var total int64
	if err := r.db.Model(&model.User{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}
	err := r.db.Offset(offset).Limit(limit).Find(&list).Error
	return list, total, err
}
