package utils

import (
	"context"
	"fmt"
	"log"
	"net/url"
	"time"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var MongoClient *mongo.Client

// InitMongo 初始化并返回一个 MongoDB client
func InitMongo() (*mongo.Client, error) {
	username := GetEnv("MONGO_INITDB_ROOT_USERNAME", "admin")
	password := GetEnv("MONGO_INITDB_ROOT_PASSWORD", "admin")
	mongoHost := GetEnv("MONGO_HOST", "mongo")
	mongoPort := GetEnv("MONGO_PORT", "27017")
	dbName := GetEnv("MONGO_DB", "mqtt_db")

	// 转义用户名和密码
	escapedUsername := url.QueryEscape(username)
	escapedPassword := url.QueryEscape(password)

	// ✅ 正确构建 MongoDB URI（含用户名密码）
	uri := fmt.Sprintf("mongodb://%s:%s@%s:%s/%s?authSource=admin",
		escapedUsername, escapedPassword, mongoHost, mongoPort, dbName)

	// 使用 ClientOptions 进行配置
	clientOptions := options.Client().
		ApplyURI(uri).
		SetConnectTimeout(10 * time.Second).
		SetMaxPoolSize(50).
		SetMinPoolSize(10).
		SetMaxConnIdleTime(30 * time.Second)

	// 建立连接
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	client, err := mongo.Connect(ctx, clientOptions)
	if err != nil {
		return nil, fmt.Errorf("mongo connect: %w", err)
	}

	// 验证连接
	if err := client.Ping(ctx, nil); err != nil {
		return nil, fmt.Errorf("mongo ping: %w", err)
	}

	log.Println("MongoDB 已连接")
	MongoClient = client
	return client, nil
}

// CloseMongo 关闭全局的 MongoDB 连接
func CloseMongo() {
	if MongoClient == nil {
		return
	}
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := MongoClient.Disconnect(ctx); err != nil {
		log.Printf("mongo disconnect: %v", err)
		return
	}
	log.Println("MongoDB 已断开")
}
