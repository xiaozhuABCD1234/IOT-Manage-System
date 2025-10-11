package config

import (
	"os"
	"strconv"
	"sync"
	"time"
)

var C *Config

type Config struct {
	PSQLConfig struct {
		Host          string
		Port          string
		User          string
		Password      string
		Name          string
		SSLMode       string
		MaxOpen       int
		MaxIdle       int
		MaxLifetime   time.Duration
		MaxRetries    int
		RetryInterval time.Duration
	}
}

var once sync.Once

func Load() {
	once.Do(func() {
		C = &Config{}
		// 1. 数据库
		C.PSQLConfig.Host = getEnvStr("DB_HOST", "localhost")
		C.PSQLConfig.Port = getEnvStr("DB_PORT", "5432")
		C.PSQLConfig.User = getEnvStr("DB_USER", "postgres")
		C.PSQLConfig.Password = getEnvStr("DB_PASSWORD", "password")
		C.PSQLConfig.Name = getEnvStr("DB_NAME", "iot_manager_db")
		C.PSQLConfig.SSLMode = getEnvStr("DB_SSLMODE", "disable")
		C.PSQLConfig.MaxOpen = getEnvInt("DB_MAX_OPEN_CONNS", 100)
		C.PSQLConfig.MaxIdle = getEnvInt("DB_MAX_IDLE_CONNS", 20)
		C.PSQLConfig.MaxLifetime = getEnvDuration("DB_MAX_LIFETIME", time.Hour)
		C.PSQLConfig.MaxRetries = getEnvInt("DB_MAX_RETRY", 5)
		C.PSQLConfig.RetryInterval = getEnvDuration("DB_RETRY_INTERVAL", 2*time.Second)
	})
}

func getEnvStr(key, defaultValue string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultValue
}

func getEnvInt(key string, defaultValue int) int {
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

func getEnvDuration(key string, def time.Duration) time.Duration {
	v := os.Getenv(key)
	if v == "" {
		return def
	}
	d, err := time.ParseDuration(v)
	if err != nil {
		return def
	}
	return d
}
