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
		Prefork: false,

		StrictRouting: true,
		// ServerHeader:       "Fiber",
		AppName:            "电子标记服务 v0.0.1",
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
	v1 := api.Group("/v1")   // /api/v1

	// ---------------- mark 相关路由 ----------------
	mark := v1.Group("/marks")
	mark.Post("/", h.CreateMark)                                       // 创建标记
	mark.Get("/", h.ListMark)                                          // 分页获取标记列表
	mark.Get("/:id", h.GetMarkByID)                                    // 根据 ID 获取标记
	mark.Put("/:id", h.UpdateMark)                                     // 更新标记
	mark.Delete("/:id", h.DeleteMark)                                  // 删除标记
	mark.Get("/device/:device_id", h.GetMarkByDeviceID)                // 根据设备 ID 获取标记
	mark.Put("/device/:device_id/last-online", h.UpdateMarkLastOnline) // 更新最后在线时间

	// ---------------- markTag 相关路由 ----------------
	markTag := v1.Group("/tags")
	markTag.Post("/", h.CreateMarkTag)                        // 创建标签
	markTag.Get("/", h.ListMarkTags)                          // 分页获取标签列表
	markTag.Get("/:tag_id", h.GetMarkTagByID)                 // 根据 ID 获取标签
	markTag.Get("/name/:tag_name", h.GetMarkTagByName)        // 根据名称获取标签
	markTag.Put("/:tag_id", h.UpdateMarkTag)                  // 更新标签
	markTag.Delete("/:tag_id", h.DeleteMarkTag)               // 删除标签
	markTag.Get("/:tag_id/marks", h.GetMarksByTagID)          // 根据标签 ID 获取标记列表（分页）
	markTag.Get("/name/:tag_name/marks", h.GetMarksByTagName) // 根据标签名称获取标记列表（分页）

	// ---------------- type 相关路由 ----------------
	markType := v1.Group("/types")
	markType.Post("/", h.CreateMarkType)                         // 创建类型
	markType.Get("/", h.ListMarkTypes)                           // 分页获取类型列表
	markType.Get("/:type_id", h.GetMarkTypeByID)                 // 根据 ID 获取类型
	markType.Get("/name/:type_name", h.GetMarkTypeByName)        // 根据名称获取类型
	markType.Put("/:type_id", h.UpdateMarkType)                  // 更新类型
	markType.Delete("/:type_id", h.DeleteMarkType)               // 删除类型
	markType.Get("/:type_id/marks", h.GetMarksByTypeID)          // 根据类型 ID 获取标记列表（分页）
	markType.Get("/name/:type_name/marks", h.GetMarksByTypeName) // 根据类型名称获取标记列表（分页）

	// 启动服务器
	port := utils.GetEnv("PORT", "8004")
	app.Listen(":" + port)
}
