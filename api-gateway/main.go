package main

import (
	"IOT-Manage-System/api-gateway/middleware"
	"IOT-Manage-System/api-gateway/utils"
	"log"

	"net/http/httputil"
	"net/url"
	"strings"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()
	r.RedirectTrailingSlash = false // 关闭 301
	r.Use(middleware.Cors())
	r.Use(middleware.JWTMiddleware())

	userServiceURL := utils.GetEnv("USER_SERVICE_URL", "user-service:8001")
	mapServiceUrl := utils.GetEnv("MAP_SERVICE_URL", "map-service:8002")
	mqttServiceUrl := utils.GetEnv("MQTT_SERVICE_URL", "mqtt-service:8003")
	markServiceUrl := utils.GetEnv("MARK_SERVICE_URL", "mark-service:8004")

	log.Printf("用户 服务地址: %s", userServiceURL)
	log.Printf("标记 服务地址: %s", markServiceUrl)
	
	r.Any("/api/v1/users/*proxyPath", createProxyHandler(userServiceURL))

	r.Any("/api/v1/marks/*proxyPath", createProxyHandler(markServiceUrl))
	r.Any("/api/v1/tags/*proxyPath", createProxyHandler(markServiceUrl))
	r.Any("/api/v1/types/*proxyPath", createProxyHandler(markServiceUrl))

	r.Any("/api/v1/mqtt/*proxyPath", createProxyHandler(mqttServiceUrl))

	r.Any("/api/v1/station/*proxyPath", createProxyHandler(mapServiceUrl))
	// Gin？启动！
	port := utils.GetEnv("PORT", "8000")
	log.Printf("服务即将启动，监听端口: %s\n", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("启动服务失败: %v", err)
	}
}

func createProxyHandler(raw string) gin.HandlerFunc {
	// 自动补全协议
	if !strings.HasPrefix(raw, "http://") && !strings.HasPrefix(raw, "https://") {
		raw = "http://" + raw
	}
	target, err := url.Parse(raw)
	if err != nil {
		panic(err) // 启动时直接报错，避免运行时才发现
	}

	proxy := httputil.NewSingleHostReverseProxy(target)

	return func(c *gin.Context) {
		// 透传网关解析出的用户信息
		if uid := c.GetHeader("X-UserID"); uid != "" {
			c.Request.Header.Set("X-UserID", uid)
			c.Request.Header.Set("X-UserName", c.GetHeader("X-UserName"))
			c.Request.Header.Set("X-UserType", c.GetHeader("X-UserType"))
		}

		proxy.ServeHTTP(c.Writer, c.Request)
	}
}
