package main

import (
	"log"

	"github.com/goccy/go-json"
	"github.com/gofiber/fiber/v2"

	"IOT-Manage-System/mqtt-watch/client"
	"IOT-Manage-System/mqtt-watch/handler"
	"IOT-Manage-System/mqtt-watch/service"
	"IOT-Manage-System/mqtt-watch/utils"
)

func main() {
	utils.InitMQTT()
	defer utils.CloseMQTT()

	c := utils.MQTTClient
	client.MustSubscribe(c)
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
