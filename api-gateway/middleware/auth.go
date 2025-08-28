package middleware

import (
	"IOT-Manage-System/api-gateway/utils"
	"net/http"
	"strings"
	"log"

	"github.com/gin-gonic/gin"
)

// JWTMiddleware 没 token 直接放过，有 token 就校验并把用户信息注入请求头
func JWTMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.Next()
			return
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.Next() // 格式不对也放过
			return
		}

		claims, err := utils.ParseAccessToken(parts[1])
		if err != nil {
			log.Printf("token=%s, err=%v", parts[1], err) // 👈 关键
			// c.Next() // 校验失败也放过
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"code":    401,
				"message": "认证失败",
				"data":    nil,
			})
			return
		}

		// token 合法，写入请求头
		c.Request.Header.Set("X-UserID", claims.UserID)
		c.Request.Header.Set("X-UserName", claims.Username)
		c.Request.Header.Set("X-UserType", string(claims.UserType))

		c.Next()
	}
}
