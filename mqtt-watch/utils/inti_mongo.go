package utils

import (
	"context"
	// "errors"
	"fmt"
	"log/slog"
	"net/url"
	"sync"
	"time"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
)

// --------------- 全局变量（只读，初始化后不再写）-----------------
var (
	once        sync.Once
	initErr     error
	mongoClient *mongo.Client
	deviceLocC  *mongo.Collection
)

// --------------- 配置结构（可扩展、可热加载）-----------------------
type MongoConfig struct {
	Host     string
	Port     string
	Username string
	Password string
	DB       string

	ConnectTimeout   time.Duration
	MaxPoolSize      uint64
	MinPoolSize      uint64
	MaxConnIdleTime  time.Duration
}

// DefaultMongoConfig 返回一份默认配置
func DefaultMongoConfig() MongoConfig {
	return MongoConfig{
		Host:            GetEnv("MONGO_HOST", "mongo"),
		Port:            GetEnv("MONGO_PORT", "27017"),
		Username:        GetEnv("MONGO_INITDB_ROOT_USERNAME", "admin"),
		Password:        GetEnv("MONGO_INITDB_ROOT_PASSWORD", "admin"),
		DB:              GetEnv("MONGO_DB", "mqtt_db"),
		ConnectTimeout:  10 * time.Second,
		MaxPoolSize:     50,
		MinPoolSize:     10,
		MaxConnIdleTime: 30 * time.Second,
	}
}

// --------------- 初始化（并发安全，仅执行一次）-----------------------
// InitMongo 保持与原函数签名一致，内部调 NewMongo
func InitMongo() (*mongo.Client, error) {
	once.Do(func() {
		mongoClient, deviceLocC, initErr = NewMongo(DefaultMongoConfig())
	})
	return mongoClient, initErr
}

// NewMongo 真正的初始化逻辑，支持外部传入配置
func NewMongo(cfg MongoConfig) (*mongo.Client, *mongo.Collection, error) {
	uri := buildURI(cfg)

	opts := options.Client().
		ApplyURI(uri).
		SetConnectTimeout(cfg.ConnectTimeout).
		SetMaxPoolSize(cfg.MaxPoolSize).
		SetMinPoolSize(cfg.MinPoolSize).
		SetMaxConnIdleTime(cfg.MaxConnIdleTime)

	// 建立连接
	ctx, cancel := context.WithTimeout(context.Background(), cfg.ConnectTimeout)
	defer cancel()

	client, err := mongo.Connect(ctx, opts)
	if err != nil {
		return nil, nil, fmt.Errorf("mongo connect: %w", err)
	}

	// 心跳检测
	if err := client.Ping(ctx, readpref.Primary()); err != nil {
		_ = client.Disconnect(context.Background()) // 忽略断开错误
		return nil, nil, fmt.Errorf("mongo ping: %w", err)
	}

	coll := client.Database(cfg.DB).Collection("device_loc")
	slog.Info("MongoDB connected", "uri", uri, "db", cfg.DB)
	return client, coll, nil
}

// --------------- 关闭（支持 context 超时） --------------------------
// CloseMongo 保持与原函数签名一致，内部调 Shutdown
func CloseMongo() {
	_ = Shutdown(context.Background(), 5*time.Second)
}

// Shutdown 优雅关闭，支持外部传入 ctx 与超时
func Shutdown(ctx context.Context, timeout time.Duration) error {
	if mongoClient == nil {
		return nil
	}

	ctx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()

	if err := mongoClient.Disconnect(ctx); err != nil {
		return fmt.Errorf("mongo disconnect: %w", err)
	}
	slog.Info("MongoDB disconnected")
	return nil
}

// --------------- 工具函数 ------------------------------------------
func buildURI(cfg MongoConfig) string {
	user := url.QueryEscape(cfg.Username)
	pass := url.QueryEscape(cfg.Password)
	return fmt.Sprintf("mongodb://%s:%s@%s:%s/%s?authSource=admin",
		user, pass, cfg.Host, cfg.Port, cfg.DB)
}

// --------------- Getter（只读，防止外部误写） ------------------------
func Mongo() *mongo.Client {
	if mongoClient == nil {
		panic("mongo not initialized")
	}
	return mongoClient
}

func DeviceLocColl() *mongo.Collection {
	if deviceLocC == nil {
		panic("mongo not initialized")
	}
	return deviceLocC
}