package utils

import (
	"fmt"
	"log"
	"os"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"

	"IOT-Manage-System/map-service/config"
)

func InitDB() (*gorm.DB, error) {
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		config.C.PSQLConfig.Host, config.C.PSQLConfig.Port, config.C.PSQLConfig.User, config.C.PSQLConfig.Password, config.C.PSQLConfig.Name, config.C.PSQLConfig.SSLMode)
	log.Println("DSN:" + dsn)

	var db *gorm.DB
	var err error

	for i := 0; i <= config.C.PSQLConfig.MaxRetries; i++ {
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
			Logger: logger.New(
				log.New(os.Stdout, "\r\n", log.LstdFlags), // io writer
				logger.Config{
					SlowThreshold:             200 * time.Millisecond, // 慢查询阈值
					LogLevel:                  logger.Error,            // 级别
					IgnoreRecordNotFoundError: true,                   // 屏蔽 ErrRecordNotFound
					Colorful:                  true,                   // 彩色
				},
			),
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
