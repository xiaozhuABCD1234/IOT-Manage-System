package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"

	"gorm.io/gorm"

	"IOT-Manage-System/warning-service/config"
	"IOT-Manage-System/warning-service/repo"
	"IOT-Manage-System/warning-service/service"
	"IOT-Manage-System/warning-service/utils"
)

const (
	LocTopic    = "location/#"
	OnlineTopic = "online"
)

func main() {
	config.Load()
	utils.InitMQTT()
	defer utils.CloseMQTT()

	// 在API模式下，我们不再需要数据库连接
	// 但为了兼容性，我们仍然可以初始化数据库（可选）
	var db *gorm.DB
	var err error

	// 检查是否需要数据库连接（用于兼容模式）

	db, err = utils.InitDB()
	if err != nil {
		log.Fatalf("初始化数据库失败: %v", err)
	}
	defer func() {
		if err := utils.CloseDB(db); err != nil {
			log.Printf("关闭数据库失败: %v", err)
		} else {
			log.Println("数据库已正常关闭")
		}
	}()
	log.Println("使用数据库模式")

	// 1. 创建缓存实例
	safeDist := repo.NewSafeDist()
	dangerZone := repo.NewDangerZone()

	// 2. 创建并启动轮询器
	markRepo := repo.NewMarkRepo(db) // 在API模式下，db可以为nil
	poller := service.NewDistancePoller(markRepo, safeDist, dangerZone)
	poller.Start()
	defer poller.Stop() // 3. 优雅停止

	// 原来的 MQTT 逻辑
	fenceChecker := service.NewFenceChecker()
	locator := service.NewLocator(db, safeDist, dangerZone, markRepo, fenceChecker)
	locator.StartDistanceChecker()

	// token := utils.MQTTClient.Subscribe("online/#", 0, locator.Online)
	// if token.Wait() && token.Error() != nil {
	// 	log.Fatalf("[FATAL] 订阅 online/# 失败: %v", token.Error())
	// }

	// token = utils.MQTTClient.Subscribe(LocTopic, 0, locator.OnLocMsg)
	// if token.Wait() && token.Error() != nil {
	// 	log.Fatalf("[FATAL] 订阅 location/# 失败: %v", token.Error())
	// }

	token := utils.MQTTClient.Subscribe(LocTopic, 0, service.MultiHandler(locator.OnLocMsg, locator.Online))
	if token.Wait() && token.Error() != nil {
		log.Fatalf("[FATAL] 订阅 location/# 失败: %v", token.Error())
	}

	log.Println("warning-service started")
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("warning-service exiting")
}
