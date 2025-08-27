package model

import "time"

// UserResponse 仅包含可对外暴露的字段
type UserResponse struct {
	ID        string    `json:"id"`        // UUID
	Username  string    `json:"username"`  // 用户名
	UserType  UserType  `json:"user_type"` // root | user | admin
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

// 把模型转换成响应对象，屏蔽敏感字段
func (u *User) ToUserResponse() *UserResponse {
	return &UserResponse{
		ID:        u.ID,
		Username:  u.Username,
		UserType:  u.UserType,
		CreatedAt: u.CreatedAt,
		UpdatedAt: u.UpdatedAt,
	}
}
