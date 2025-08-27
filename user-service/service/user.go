package service

import (
	"IOT-Manage-System/user-service/model"
	"IOT-Manage-System/user-service/repository"
	"IOT-Manage-System/user-service/utils"
	"errors"

	"gorm.io/gorm"
)

type UserService interface {
	Register(req *model.UserCreateRequest) (*model.UserResponse, error)
	GetUserById(id string) (*model.UserResponse, error)
	UpdateUser(id string, req *model.UserUpdateRequest) (*model.UserResponse, error)
	DeleteUser(id string) error
	ListUsers(page, limit int) (*[]model.UserResponse, int64, error)
}

type userService struct {
	repo repository.UserRepo
}

func NewUserService(r repository.UserRepo) UserService {
	return &userService{repo: r}
}

func (s *userService) Register(req *model.UserCreateRequest) (*model.UserResponse, error) {
	if req.Username == "" || req.Password == "" {
		return nil, ErrInvalidInput
	}
	if _, err := s.repo.FindByUsername(req.Username); err == nil {
		return nil, ErrUserExists
	}
	hash, err := utils.GetPwd(req.Password)
	if err != nil {
		return nil, ErrInternal
	}

	user := &model.User{
		Username: req.Username,
		PwdHash:  hash,
		UserType: req.UserType,
	}
	if err := s.repo.Create(user); err != nil {
		return nil, ErrInternal
	}
	return user.ToUserResponse(), nil
}

func (s *userService) GetUserById(id string) (*model.UserResponse, error) {
	if id == "" {
		return nil, ErrInvalidInput
	}
	user, err := s.repo.FindByID(id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, ErrInternal
	}
	return user.ToUserResponse(), nil
}

// UpdateUser 更新用户信息
func (s *userService) UpdateUser(id string, req *model.UserUpdateRequest) (*model.UserResponse, error) {
	if id == "" {
		return nil, ErrInvalidInput
	}
	user, err := s.repo.FindByID(id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, ErrInternal
	}

	// 按需修改
	if req.Username != nil {
		// 检查重名
		if exist, _ := s.repo.FindByUsername(*req.Username); exist != nil && exist.ID != id {
			return nil, ErrUserExists
		}
		user.Username = *req.Username
	}
	if req.UserType != nil {
		user.UserType = *req.UserType
	}

	if err := s.repo.Update(user); err != nil {
		return nil, ErrInternal
	}
	return user.ToUserResponse(), nil
}

// DeleteUser 软删除用户
func (s *userService) DeleteUser(id string) error {
	if id == "" {
		return ErrInvalidInput
	}
	if _, err := s.repo.FindByID(id); errors.Is(err, gorm.ErrRecordNotFound) {
		return ErrUserNotFound
	}
	return s.repo.Delete(id)
}

// ListUsers 分页列表
func (s *userService) ListUsers(page, limit int) (*[]model.UserResponse, int64, error) {
	if page <= 0 {
		page = 1
	}
	if limit <= 0 || limit > 100 {
		limit = 10
	}
	offset := (page - 1) * limit

	users, total, err := s.repo.List(offset, limit)
	if err != nil {
		return nil, 0, ErrInternal
	}

	// 把 []models.User 转成 []models.UserResponse
	resp := make([]model.UserResponse, len(users))
	for i, u := range users {
		resp[i] = *u.ToUserResponse()
	}
	return &resp, total, nil
}
