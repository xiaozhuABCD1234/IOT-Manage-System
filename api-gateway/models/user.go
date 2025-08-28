package models

import (
	"time"

	"gorm.io/gorm"
)

// 对应 user_type_enum 的 Go enum
type UserType string

const (
	UserTypeRoot  UserType = "root"
	UserTypeUser  UserType = "user"
	UserTypeAdmin UserType = "admin"
)

// TableName 让 GORM 明白这是枚举类型，避免建表时生成额外的表
func (UserType) GormDataType() string { return "user_type_enum" }

// 对应 users 表
type User struct {
	ID        string    `gorm:"type:uuid;primaryKey;default:gen_random_uuid()"`
	Username  string    `gorm:"type:varchar(255);not null"`
	PwdHash   string    `gorm:"type:varchar(255);not null"`
	UserType  UserType  `gorm:"type:user_type_enum;not null;default:'user'"`
	CreatedAt time.Time `gorm:"type:timestamptz;not null;default:now()"`
	UpdatedAt time.Time `gorm:"type:timestamptz;not null;default:now()"`
}

// TableName 显式指定表名，防止 GORM 自动复数化
func (User) TableName() string {
	return "users"
}

// 在插入/更新时自动维护 updated_at
func (u *User) BeforeSave(tx *gorm.DB) error {
	u.UpdatedAt = time.Now()
	return nil
}
