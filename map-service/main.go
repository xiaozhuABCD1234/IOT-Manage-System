package main

import (
	"log"

	"github.com/goccy/go-json"
	"github.com/gofiber/fiber/v2"

	"IOT-Manage-System/map-service/config"
	"IOT-Manage-System/map-service/handler"
	"IOT-Manage-System/map-service/repo"
	"IOT-Manage-System/map-service/service"
	"IOT-Manage-System/map-service/utils"
)

func main() {
	app := fiber.New(fiber.Config{
		Prefork:            false,
		StrictRouting:      false,
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

	customMapRepo := repo.NewCustomMapRepo(db)
	customMapService := service.NewCustomMapService(customMapRepo)
	customMapHandler := handler.NewCustomMapHandler(customMapService)

	polygonFenceRepo := repo.NewPolygonFenceRepo(db)
	polygonFenceService := service.NewPolygonFenceService(polygonFenceRepo)
	polygonFenceHandler := handler.NewPolygonFenceHandler(polygonFenceService)

	// 健康检查
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok", "service": app.Config().AppName})
	})

	// 静态文件服务（用于访问上传的图片）
	app.Static("/uploads", "./uploads")

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

	// 自制地图相关路由
	customMap := v1.Group("/custom-map")
	customMap.Post("/", customMapHandler.CreateCustomMap)         // 创建（上传图片 + 配置）
	customMap.Get("/", customMapHandler.ListCustomMaps)           // 全量列表
	customMap.Get("/latest", customMapHandler.GetLatestCustomMap) // 获取最新地图
	customMap.Get("/:id", customMapHandler.GetCustomMap)          // 单条查询
	customMap.Put("/:id", customMapHandler.UpdateCustomMap)       // 更新
	customMap.Delete("/:id", customMapHandler.DeleteCustomMap)    // 删除

	// 多边形围栏相关路由
	polygonFence := v1.Group("/polygon-fence")
	polygonFence.Post("/", polygonFenceHandler.CreatePolygonFence)             // 创建围栏
	polygonFence.Get("/", polygonFenceHandler.ListPolygonFences)               // 获取围栏列表（支持 ?active_only=true）
	polygonFence.Get("/:id", polygonFenceHandler.GetPolygonFence)              // 获取单个围栏
	polygonFence.Put("/:id", polygonFenceHandler.UpdatePolygonFence)           // 更新围栏
	polygonFence.Delete("/:id", polygonFenceHandler.DeletePolygonFence)        // 删除围栏
	polygonFence.Post("/:id/check", polygonFenceHandler.CheckPointInFence)     // 检查点是否在指定围栏内
	polygonFence.Post("/check-all", polygonFenceHandler.CheckPointInAllFences) // 检查点在哪些围栏内

	// 启动服务器
	port := utils.GetEnv("PORT", "8002")
	if err := app.Listen(":" + port); err != nil {
		log.Fatalf("启动 HTTP 服务失败: %v", err)
	}
}
