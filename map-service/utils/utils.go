package utils

import (
	"fmt"
	"os"
	"strconv"
	"strings"

	"github.com/go-playground/validator/v10"
)

func GetEnv(key, defaultValue string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultValue
}

// GetEnvInt 读取环境变量并解析为 int,如果不存在则返回默认值
func GetEnvInt(key string, defaultValue int) int {
	val := os.Getenv(key)
	if val == "" {
		return defaultValue
	}
	i, err := strconv.Atoi(val)
	if err != nil {
		return defaultValue
	}
	return i
}

func GetDSN() string {
	dbHost := GetEnv("DB_HOST", "postgres")
	dbPort := GetEnv("DB_PORT", "5432")
	dbUser := GetEnv("DB_USER", "postgres")
	dbPasswd := GetEnv("DB_PASSWD", "password")
	dbName := GetEnv("DB_NAME", "iot_manager_db")

	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable TimeZone=Asia/Shanghai",
		dbHost, dbPort, dbUser, dbPasswd, dbName,
	)
}

// ParsePositiveInt 把字符串解析为正整数（>0）。
// 成功返回 (value, nil)；否则返回 (0, error)。
func ParsePositiveInt(s string) (int, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0, fmt.Errorf("字符串为空")
	}
	v, err := strconv.Atoi(s)
	if err != nil {
		return 0, fmt.Errorf("解析失败: %w", err)
	}
	if v <= 0 {
		return 0, fmt.Errorf("值必须为正整数，当前值: %d", v)
	}
	return v, nil
}

// ParsePositiveInt64 同上，但返回 int64，适配大数场景。
func ParsePositiveInt64(s string) (int64, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0, fmt.Errorf("字符串为空")
	}
	v, err := strconv.ParseInt(s, 10, 64)
	if err != nil {
		return 0, fmt.Errorf("解析失败: %w", err)
	}
	if v <= 0 {
		return 0, fmt.Errorf("值必须为正整数，当前值: %d", v)
	}
	return v, nil
}

// Validator 全局验证器实例
var Validator = validator.New()

// ValidateStruct 验证结构体
func ValidateStruct(s interface{}) error {
	if err := Validator.Struct(s); err != nil {
		if validationErrors, ok := err.(validator.ValidationErrors); ok {
			// 构建更友好的错误信息
			errMsgs := make([]string, 0, len(validationErrors))
			for _, e := range validationErrors {
				errMsgs = append(errMsgs, formatValidationError(e))
			}
			return fmt.Errorf("%s", strings.Join(errMsgs, "; "))
		}
		return err
	}
	return nil
}

// formatValidationError 格式化验证错误信息
func formatValidationError(e validator.FieldError) string {
	field := e.Field()
	switch e.Tag() {
	case "required":
		return fmt.Sprintf("%s 是必填项", field)
	case "min":
		return fmt.Sprintf("%s 的最小长度/值为 %s", field, e.Param())
	case "max":
		return fmt.Sprintf("%s 的最大长度/值为 %s", field, e.Param())
	case "email":
		return fmt.Sprintf("%s 必须是有效的邮箱地址", field)
	case "url":
		return fmt.Sprintf("%s 必须是有效的URL", field)
	default:
		return fmt.Sprintf("%s 验证失败: %s", field, e.Tag())
	}
}
