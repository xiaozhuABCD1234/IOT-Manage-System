package main

import (
	"log"

	"github.com/goccy/go-json"
	"github.com/gofiber/fiber/v2"

	"IOT-Manage-System/mark-service/handler"
	"IOT-Manage-System/mark-service/repo"
	"IOT-Manage-System/mark-service/service"
	"IOT-Manage-System/mark-service/utils"
)

func main() {
	app := fiber.New(fiber.Config{
		Prefork: false,

		StrictRouting: true,
		// ServerHeader:       "Fiber",
		AppName:            "电子标记服务 v0.0.3",
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

	r1 := repo.NewMarkRepo(db)
	r2 := repo.NewMarkPairRepo(db)
	s1 := service.NewMarkService(r1)
	s2 := service.NewMarkPairService(r2, r1)
	h1 := handler.NewMarkHandler(s1)
	h2 := handler.NewMarkPairHandler(s2)

	// 定义路由和处理函数
	app.Get("/health", func(c *fiber.Ctx) error {
		c.Append("status", "ok")
		return c.SendString("服务运行正常")
	})
	api := app.Group("/api") // /api
	v1 := api.Group("/v1")   // /api/v1

	// ---------------- mark 相关路由 ----------------
	mark := v1.Group("/marks")
	mark.Post("/", h1.CreateMark)                                       // 创建标记
	mark.Get("/", h1.ListMark)                                          // 分页获取标记列表
	mark.Get("/:id", h1.GetMarkByID)                                    // 根据 ID 获取标记
	mark.Put("/:id", h1.UpdateMark)                                     // 更新标记
	mark.Delete("/:id", h1.DeleteMark)                                  // 删除标记
	mark.Get("/id-to-name", h1.GetAllMarkIDToName)                      // 获取全部 markID→markName 映射
	mark.Get("/device/id-to-name", h1.GetAllDeviceIDToName)             // 获取全部 deviceID→markName 映射
	mark.Get("/device/:device_id", h1.GetMarkByDeviceID)                // 根据设备 ID 获取标记
	mark.Put("/device/:device_id/last-online", h1.UpdateMarkLastOnline) // 更新最后在线时间
	mark.Get("/persist/device/:device_id", h1.GetPersistMQTTByDeviceID) // GET /api/marks/persist/device/:device_id
	mark.Get("/persist/list", h1.GetMarksByPersistMQTT)                 // GET /api/marks/persist/list?persist=true&page=1&limit=10
	mark.Get("/persist/device-ids", h1.GetDeviceIDsByPersistMQTT)       // GET /api/marks/persist/device-ids?persist=true
	mark.Get("", h1.ListMark)
	mark.Post("", h1.CreateMark)

	// ---------------- markTag 相关路由 ----------------
	markTag := v1.Group("/tags")
	markTag.Post("/", h1.CreateMarkTag)                        // 创建标签
	markTag.Get("/", h1.ListMarkTags)                          // 分页获取标签列表
	markTag.Get("/id-to-name", h1.GetAllTagIDToName)           // 获取全部 tagID→tagName 映射
	markTag.Get("/:tag_id", h1.GetMarkTagByID)                 // 根据 ID 获取标签
	markTag.Get("/name/:tag_name", h1.GetMarkTagByName)        // 根据名称获取标签
	markTag.Put("/:tag_id", h1.UpdateMarkTag)                  // 更新标签
	markTag.Delete("/:tag_id", h1.DeleteMarkTag)               // 删除标签
	markTag.Get("/:tag_id/marks", h1.GetMarksByTagID)          // 根据标签 ID 获取标记列表（分页）
	markTag.Get("/name/:tag_name/marks", h1.GetMarksByTagName) // 根据标签名称获取标记列表（分页）
	markTag.Post("", h1.CreateMarkTag)
	markTag.Get("", h1.ListMarkTags)

	// ---------------- type 相关路由 ----------------
	markType := v1.Group("/types")
	markType.Post("/", h1.CreateMarkType)                         // 创建类型
	markType.Get("/", h1.ListMarkTypes)                           // 分页获取类型列表
	markType.Get("/id-to-name", h1.GetAllTypeIDToName)            // 获取全部 typeID→typeName 映射
	markType.Get("/:type_id", h1.GetMarkTypeByID)                 // 根据 ID 获取类型
	markType.Get("/name/:type_name", h1.GetMarkTypeByName)        // 根据名称获取类型
	markType.Put("/:type_id", h1.UpdateMarkType)                  // 更新类型
	markType.Delete("/:type_id", h1.DeleteMarkType)               // 删除类型
	markType.Get("/:type_id/marks", h1.GetMarksByTypeID)          // 根据类型 ID 获取标记列表（分页）
	markType.Get("/name/:type_name/marks", h1.GetMarksByTypeName) // 根据类型名称获取标记列表（分页）
	markType.Post("/", h1.CreateMarkType)
	markType.Get("/", h1.ListMarkTypes)

	// ---------------- markPair 相关路由 ----------------
	markPair := v1.Group("/pairs")
	markPair.Get("/", h2.ListMarkPairs)                                     // 分页获取标记对列表
	markPair.Post("/distance", h2.SetPairDistance)                          // 设置/更新单对标记距离
	markPair.Post("/combinations", h2.SetCombinations)                      // 批量设置标记组合距离
	markPair.Post("/cartesian", h2.SetCartesian)                            // 笛卡尔积方式设置标记对距离
	markPair.Get("/distance/:mark1_id/:mark2_id", h2.GetDistance)           // 查询单对标记距离
	markPair.Delete("/distance/:mark1_id/:mark2_id", h2.DeletePair)         // 删除单对标记距离
	markPair.Get("/distance/map/mark/:id", h2.DistanceMapByMark)            // 查询某个标记与其他所有标记的距离映射
	markPair.Get("/distance/map/device/:device_id", h2.DistanceMapByDevice) // 查询某个设备与其他所有标记的距离映射

	// 启动服务器
	port := utils.GetEnv("PORT", "8004")
	if err := app.Listen(":" + port); err != nil {
		log.Fatalf("启动 HTTP 服务失败: %v", err)
	}
}
