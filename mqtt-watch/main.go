package main

import (
	"log"

	"github.com/goccy/go-json"
	"github.com/gofiber/fiber/v2"

	"IOT-Manage-System/mqtt-watch/client"
	"IOT-Manage-System/mqtt-watch/handler"
	"IOT-Manage-System/mqtt-watch/utils"
)

func main() {
	utils.InitMQTT()
	defer utils.CloseMQTT()

	c := utils.MQTTClient
	client.MustSubscribe(c)

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

	// 不再使用 fiberlogger 中间件
	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("MQTT Watch is running")
	})

	port := utils.GetEnv("PORT", "8003")
	if err := app.Listen(":" + port); err != nil {
		log.Fatalf("启动 HTTP 服务失败: %v", err)
	}
}
