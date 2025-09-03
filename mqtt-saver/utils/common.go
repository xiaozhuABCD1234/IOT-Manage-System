package utils

import (
	"os"
	"strconv"
	"strings"
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

// ParsePositiveInt 把字符串解析为正整数（>0）。
// 成功返回 (value, true)；否则返回 (0, false)。
func ParsePositiveInt(s string) (int, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0, nil
	}
	v, err := strconv.Atoi(s)
	if err != nil || v <= 0 {
		return 0, nil
	}
	return v, err
}

// ParsePositiveInt64 同上，但返回 int64，适配大数场景。
func ParsePositiveInt64(s string) (int64, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0, nil
	}
	v, err := strconv.ParseInt(s, 10, 64)
	if err != nil || v <= 0 {
		return 0, nil
	}
	return v, err
}
