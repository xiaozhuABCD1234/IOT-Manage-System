package main

import (
	"IOT-Manage-System/user-service/handler"
	"IOT-Manage-System/user-service/repository"
	"IOT-Manage-System/user-service/router"
	"IOT-Manage-System/user-service/service"
	"IOT-Manage-System/user-service/utils"
	"log"

	"github.com/gin-gonic/gin"
)

func main() {
	log.Println("正在启动用户服务...")
	// port := util.GetEnv("PORT", "8081")

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
	if err := utils.InitRootUser(db); err != nil {
		log.Println(err)
	}

	userRepo := repository.NewUserRepo(db)
	userService := service.NewUserService(userRepo)
	authService := service.NewAuthService(userRepo)
	userHandler := handler.NewUserHandler(userService)
	authHandler := handler.NewAuthHandler(authService)

	r := gin.Default()
	router.RegisterUserRoutes(r, userHandler, authHandler)

	// Gin？启动！
	port := utils.GetEnv("PORT", "8001")
	log.Printf("服务即将启动，监听端口: %s\n", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("启动服务失败: %v", err)
	}
}
