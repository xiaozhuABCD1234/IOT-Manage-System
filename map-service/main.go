package main

import (
	"github.com/goccy/go-json"
	"github.com/gofiber/fiber/v2"
	"log"

	"IOT-Manage-System/map-service/config"
	"IOT-Manage-System/map-service/handler"
	"IOT-Manage-System/map-service/repo"
	"IOT-Manage-System/map-service/service"
	"IOT-Manage-System/map-service/utils"
)

func main() {
	app := fiber.New(fiber.Config{
		Prefork:            false,
		StrictRouting:      true,
		AppName:            "地图数据服务 v0.0.2",
		CaseSensitive:      true,
		DisableDefaultDate: true,
		JSONEncoder:        json.Marshal,
		JSONDecoder:        json.Unmarshal,
		ErrorHandler:       handler.CustomErrorHandler,
	})	
	config.Load()
	// 初始化数据库
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

	// 依赖注入
	stationRepo := repo.NewStationRepo(db)
	stationService := service.NewStationService(stationRepo)
	stationHandler := handler.NewStationHandler(stationService)

	// 健康检查
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok", "service": app.Config().AppName})
	})

	// 路由分组
	api := app.Group("/api")
	v1 := api.Group("/v1")

	// 基站相关路由
	station := v1.Group("/station")
	station.Post("/", stationHandler.CreateStation)      // 创建
	station.Get("/", stationHandler.ListStation)         // 全量列表（不分页）
	station.Get("/:id", stationHandler.GetStation)       // 单条查询
	station.Put("/:id", stationHandler.UpdateStation)    // 更新
	station.Delete("/:id", stationHandler.DeleteStation) // 删除

	// 启动服务器
	port := utils.GetEnv("PORT", "8002")
	if err := app.Listen(":" + port); err != nil {
		log.Fatalf("启动 HTTP 服务失败: %v", err)
	}
}
