package utils

import (
	"fmt"
	"log"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func InitDB() (*gorm.DB, error) {
	dbHost := GetEnv("DB_HOST", "localhost")
	dbPort := GetEnv("DB_PORT", "5432")
	dbUser := GetEnv("DB_USER", "postgres")
	dbPassword := GetEnv("DB_PASSWORD", "password")
	dbName := GetEnv("DB_NAME", "credit_management")
	dbSSLMode := GetEnv("DB_SSLMODE", "disable")
	maxOpen := GetEnvInt("DB_MAX_OPEN_CONNS", 100)
	maxIdle := GetEnvInt("DB_MAX_IDLE_CONNS", 20)
	maxLifetime := time.Duration(GetEnvInt("DB_MAX_LIFETIME", 1)) * time.Hour
	maxRetries := GetEnvInt("DB_MAX_RETRY", 5)
	retryInterval := time.Duration(GetEnvInt("DB_RETRY_INTERVAL", 2)) * time.Second

	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		dbHost, dbPort, dbUser, dbPassword, dbName, dbSSLMode)

	log.Println("DSN:" + dsn)

	var db *gorm.DB
	var err error

	for i := 0; i <= maxRetries; i++ {
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
			Logger: logger.Default.LogMode(logger.Info),
		})
		if err == nil {
			log.Println("数据库连接成功")
			break
		}
		log.Printf("数据库连接失败（尝试 %d/%d）: %v", i+1, maxRetries, err)
		if i == maxRetries {
			return nil, fmt.Errorf("数据库连接失败，已尝试%d次: %w", maxRetries, err)
		}
		time.Sleep(retryInterval)
	}

	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("获取底层 sql.DB 失败: %w", err)
	}
	sqlDB.SetMaxOpenConns(maxOpen)
	sqlDB.SetMaxIdleConns(maxIdle)
	sqlDB.SetConnMaxLifetime(maxLifetime)

	return db, nil
}

// CloseDB 优雅关闭数据库连接
func CloseDB(db *gorm.DB) error {
	if db == nil {
		return nil
	}
	sqlDB, err := db.DB()
	if err != nil {
		return fmt.Errorf("获取底层 sql.DB 失败: %w", err)
	}
	return sqlDB.Close()
}
