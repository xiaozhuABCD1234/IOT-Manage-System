package main

import (
	"log"

	"github.com/goccy/go-json"
	"github.com/gofiber/fiber/v2"

	"IOT-Manage-System/mqtt-watch/client"
	"IOT-Manage-System/mqtt-watch/handler"
	"IOT-Manage-System/mqtt-watch/repo"
	"IOT-Manage-System/mqtt-watch/service"
	"IOT-Manage-System/mqtt-watch/utils"
)

func main() {
	utils.InitMQTT()
	defer utils.CloseMQTT()

	db, err := utils.InitDB()
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
	if _, err := utils.InitMongo(); err != nil {
		panic(err)
	}

	mark_repo := repo.NewMarkRepo(db)
	mark_pair_repo := repo.NewMarkPairRepo(db)
	deviceLocRepo := repo.NewMongoRepo(utils.DeviceLocColl())

	mark_service := service.NewMarkService(mark_repo)
	mark_pair_service := service.NewMarkPairService(mark_pair_repo, mark_repo)
	mongoService := service.NewMongoService(deviceLocRepo)
	c := utils.MQTTClient
	mqttCallback := client.NewMqttCallback(c, mark_service, mark_pair_service, mongoService)

	mqttCallback.MustSubscribe()
	mqttService := service.NewMqttService(c)
	mqttHandler := handler.NewMqttService(mqttService)
	mqttService.SendWarningStart("213")

	app := fiber.New(fiber.Config{
		Prefork:            false,
		StrictRouting:      true,
		AppName:            "消息管理服务 v0.0.1",
		CaseSensitive:      true,
		DisableDefaultDate: true,
		ErrorHandler:       handler.CustomErrorHandler,
		JSONEncoder:        json.Marshal,
		JSONDecoder:        json.Unmarshal,
	})

	// 2. 挂路由
	api := app.Group("/api")
	v1 := api.Group("/v1")
	mqtt := v1.Group("/mqtt")
	mqtt.Post("/warning/:deviceId/start", mqttHandler.SendWarningStart)
	// mqtt.Get("/warning/start", mqttHandler.SendWarningStart)

	mqtt.Post("/warning/:deviceId/end", mqttHandler.SendWarningEnd)

	// 3. 打印路由（必须放在 Listen 之前）
	app.Stack() // 或者 app.GetRoutes(true)
	for _, routes := range app.Stack() {
		for _, r := range routes {
			log.Printf("Method: %-6s Path: %s\n", r.Method, r.Path)
		}
	}

	port := utils.GetEnv("PORT", "8003")
	if err := app.Listen(":" + port); err != nil {
		log.Fatalf("启动 HTTP 服务失败: %v", err)
	}
}
