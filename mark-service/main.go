package main

import (
	"github.com/goccy/go-json"
	"github.com/gofiber/fiber/v2"
	"log"

	"IOT-Manage-System/mark-service/handler"
	"IOT-Manage-System/mark-service/repository"
	"IOT-Manage-System/mark-service/service"
	"IOT-Manage-System/mark-service/utils"
)

func main() {
	app := fiber.New(fiber.Config{
		Prefork: true,

		StrictRouting: true,
		// ServerHeader:       "Fiber",
		AppName:            "mark-service v0.0.1",
		CaseSensitive:      true,
		DisableDefaultDate: true,
		JSONEncoder:        json.Marshal,
		JSONDecoder:        json.Unmarshal,
		ErrorHandler:       handler.CustomErrorHandler,
	})

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

	repo := repository.NewMarkRepo(db)
	srv := service.NewMarkService(repo)
	h := handler.NewMarkHandler(srv)

	// 定义路由和处理函数
	app.Get("/health", func(c *fiber.Ctx) error {
		c.Append("status", "ok")
		return c.SendString("服务运行正常")
	})
	api := app.Group("/api") // /api

	v1 := api.Group("/v1") // /api/v1
	v1.Post("/marks", h.CreateMark)
	v1.Get("/marks/:id", h.GetMarkByID)
	v1.Put("/marks/:id", h.UpdateMark)
	v1.Delete("/marks/:id", h.DeleteMark)
	v1.Get("/marks", h.ListMark)
	v1.Get("/marks/device/:device_id", h.GetMarkByDeviceID)
	v1.Put("/marks/device/:device_id/last-online", h.UpdateMarkLastOnline)
	v1.Get("/tags/:tag_id/marks", h.GetMarksByTagID)

	// 启动服务器
	port := utils.GetEnv("PORT", "8004")
	app.Listen(":" + port)
}
