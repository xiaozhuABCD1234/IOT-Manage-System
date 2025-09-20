package utils

import (
	"fmt"
	"log"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	"IOT-Manage-System/warning-service/config"
)

func InitDB() (*gorm.DB, error) {
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		config.C.PSQLConfig.Host, config.C.PSQLConfig.Port, config.C.PSQLConfig.User, config.C.PSQLConfig.Password, config.C.PSQLConfig.Name, config.C.PSQLConfig.SSLMode)
	log.Println("DSN:" + dsn)

	var db *gorm.DB
	var err error

	for i := 0; i <= config.C.PSQLConfig.MaxRetries; i++ {
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
			Logger: logger.Default.LogMode(logger.Info),
		})
		if err == nil {
			log.Println("数据库连接成功")
			break
		}
		log.Printf("数据库连接失败（尝试 %d/%d）: %v", i+1, config.C.PSQLConfig.MaxRetries, err)
		if i == config.C.PSQLConfig.MaxRetries {
			return nil, fmt.Errorf("数据库连接失败，已尝试%d次: %w", config.C.PSQLConfig.MaxRetries, err)
		}
		time.Sleep(config.C.PSQLConfig.RetryInterval)
	}

	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("获取底层 sql.DB 失败: %w", err)
	}
	sqlDB.SetMaxOpenConns(config.C.PSQLConfig.MaxOpen)
	sqlDB.SetMaxIdleConns(config.C.PSQLConfig.MaxIdle)
	sqlDB.SetConnMaxLifetime(config.C.PSQLConfig.MaxLifetime)

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
