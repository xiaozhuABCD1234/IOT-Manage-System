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
		AppName:            "地图数据服务 v0.1.0",
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

	// ==================== 基站管理 ====================
	station := v1.Group("/station")
	{
		// CRUD 操作
		station.Post("/", stationHandler.CreateStation)      // 创建基站
		station.Get("/", stationHandler.ListStation)         // 获取基站列表
		station.Get("/:id", stationHandler.GetStation)       // 获取单个基站
		station.Put("/:id", stationHandler.UpdateStation)    // 更新基站
		station.Delete("/:id", stationHandler.DeleteStation) // 删除基站
	}

	// ==================== 自定义地图管理 ====================
	customMap := v1.Group("/custom-map")
	{
		// 特殊查询（放在参数路由之前）
		customMap.Get("/latest", customMapHandler.GetLatestCustomMap) // 获取最新地图

		// CRUD 操作
		customMap.Post("/", customMapHandler.CreateCustomMap)      // 创建地图（上传图片 + 配置）
		customMap.Get("/", customMapHandler.ListCustomMaps)        // 获取地图列表
		customMap.Get("/:id", customMapHandler.GetCustomMap)       // 获取单个地图
		customMap.Put("/:id", customMapHandler.UpdateCustomMap)    // 更新地图
		customMap.Delete("/:id", customMapHandler.DeleteCustomMap) // 删除地图
	}

	// ==================== 多边形围栏管理 ====================
	polygonFence := v1.Group("/polygon-fence")
	{
		// 通用查询（放在参数路由之前）
		polygonFence.Post("/check-all", polygonFenceHandler.CheckPointInAllFences) // 检查点在哪些围栏内

		// 室内围栏专用查询
		polygonFence.Post("/check-indoor-all", polygonFenceHandler.CheckPointInIndoorFences) // 检查点在哪些室内围栏内
		polygonFence.Post("/check-indoor-any", polygonFenceHandler.IsPointInAnyIndoorFence)  // 检查点是否在任意一个室内围栏内

		// 室外围栏专用查询
		polygonFence.Post("/check-outdoor-all", polygonFenceHandler.CheckPointInOutdoorFences) // 检查点在哪些室外围栏内
		polygonFence.Post("/check-outdoor-any", polygonFenceHandler.IsPointInAnyOutdoorFence)  // 检查点是否在任意一个室外围栏内

		// 围栏列表查询（放在参数路由之前）
		polygonFence.Get("/indoor", polygonFenceHandler.ListIndoorFences)   // 获取室内围栏（支持 ?active_only=true）
		polygonFence.Get("/outdoor", polygonFenceHandler.ListOutdoorFences) // 获取室外围栏（支持 ?active_only=true）

		// CRUD 操作
		polygonFence.Post("/", polygonFenceHandler.CreatePolygonFence)      // 创建围栏
		polygonFence.Get("/", polygonFenceHandler.ListPolygonFences)        // 获取围栏列表（支持 ?active_only=true）
		polygonFence.Get("/:id", polygonFenceHandler.GetPolygonFence)       // 获取单个围栏
		polygonFence.Put("/:id", polygonFenceHandler.UpdatePolygonFence)    // 更新围栏
		polygonFence.Delete("/:id", polygonFenceHandler.DeletePolygonFence) // 删除围栏

		// 围栏特定操作（需要围栏ID）
		polygonFence.Post("/:id/check", polygonFenceHandler.CheckPointInFence)                // 检查点是否在指定围栏内
		polygonFence.Post("/:id/check-indoor", polygonFenceHandler.CheckPointInIndoorFence)   // 检查点是否在指定室内围栏内
		polygonFence.Post("/:id/check-outdoor", polygonFenceHandler.CheckPointInOutdoorFence) // 检查点是否在指定室外围栏内
	}

	// 启动服务器
	port := utils.GetEnv("PORT", "8002")
	if err := app.Listen(":" + port); err != nil {
		log.Fatalf("启动 HTTP 服务失败: %v", err)
	}
}
