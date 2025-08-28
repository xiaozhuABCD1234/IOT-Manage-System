package utils

import (
	"fmt"
	"os"
	"strconv"
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
