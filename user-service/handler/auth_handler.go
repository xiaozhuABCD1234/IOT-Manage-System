package handler

import (
	"IOT-Manage-System/user-service/model"
	"IOT-Manage-System/user-service/service"
	"IOT-Manage-System/user-service/utils"

	"net/http"

	"github.com/gin-gonic/gin"
)

// UserHandler 用户相关的所有 HTTP 处理契约
type AuthHandler interface {
	Login(c *gin.Context)
	Refresh(c *gin.Context)
}

type authHandler struct {
	authService service.AuthService
}

func NewAuthHandler(as service.AuthService) AuthHandler {
	return &authHandler{
		authService: as,
	}
}

func (h *authHandler) Login(c *gin.Context) {
	var req model.UserLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.SendBadRequest(c, "请求参数错误: "+err.Error())
		return
	}
	resp, err := h.authService.Login(&req)
	switch err {
	case nil:
		utils.SendSuccessResponse(c, resp)
	case service.ErrUserNotFound, service.ErrWrongPassword:
		utils.SendErrorResponse(c, 401, "用户或用户名错误🤔")
	default:
		utils.SendErrorResponse(c, 401, "Token生成失败")
	}
}

func (h *authHandler) Refresh(c *gin.Context) {
	var req model.RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.SendBadRequest(c, "请求参数错误: "+err.Error())
		return
	}
	resp, err := h.authService.Refresh(&req)
	switch err {
	case nil:
		utils.SendSuccessResponse(c, resp)
	case service.ErrInvalidToken:
		utils.SendErrorResponse(c, http.StatusUnauthorized, "无效Token")
	default:
		utils.SendInternalServerError(c, err)
	}
}
