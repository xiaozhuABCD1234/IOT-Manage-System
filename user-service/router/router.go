package router

import (
	"IOT-Manage-System/user-service/handler"
	"IOT-Manage-System/user-service/utils"

	"github.com/gin-gonic/gin"
)

func RegisterUserRoutes(r *gin.Engine, userHandler handler.UserHandler, authHandler handler.AuthHandler) {
	r.GET("/health", func(c *gin.Context) {
		utils.SendSuccessResponse(c, gin.H{"status": "ok"}, "服务运行正常")
	})

	ug := r.Group("/api/v1/users/")
	{
		ug.POST("", userHandler.Create)      // POST /api/v1/users
		ug.POST("/token", authHandler.Login) // POST /api/v1/users/token
		ug.POST("/refresh", authHandler.Refresh)
		ug.GET("/me", userHandler.GetMe)          // GET  /api/v1/users/me
		ug.GET("/:id", userHandler.GetUser)       // GET  /api/v1/users/:id
		ug.PUT("/:id", userHandler.UpdateUser)    // PUT  /api/v1/users/:id
		ug.DELETE("/:id", userHandler.DeleteUser) // DELETE /api/v1/users/:id
		ug.GET("", userHandler.ListUsers)         // GET  /api/v1/users?page=1&limit=10
	}

	r.NoRoute(func(c *gin.Context) {
		utils.SendNotFound(c)
	})
}
