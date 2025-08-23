package models

type UserLoginRequest struct {
	Username string `json:"username" binding:"required,max=32"`
	Password string `json:"password" binding:"required,max=64"`
}

type UserCreateRequest struct {
	Username string   `json:"username" binding:"required,min=3,max=32"`
	Password string   `json:"password" binding:"required,min=6,max=64"`
	UserType UserType `json:"user_type" binding:"required,oneof=user admin"`
}

// UserUpdateRequest 允许前端修改的字段
type UserUpdateRequest struct {
	Username *string   `json:"username,omitempty"` // 指针：空表示不修改
	UserType *UserType `json:"user_type,omitempty"`
}
