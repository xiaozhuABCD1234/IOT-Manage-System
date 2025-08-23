package handler

import (
	"IOT-Manage-System/user-service/models"
	"IOT-Manage-System/user-service/service"
	"IOT-Manage-System/user-service/utils"

	"github.com/gin-gonic/gin"
	"strconv"
)

// UserHandler 用户相关的所有 HTTP 处理契约
type UserHandler interface {
	Create(c *gin.Context)
	GetMe(c *gin.Context)
	GetUser(c *gin.Context)
	UpdateUser(c *gin.Context)
	DeleteUser(c *gin.Context)
	ListUsers(c *gin.Context)
}

type userHandler struct {
	userService service.UserService
}

func NewUserHandler(us service.UserService) UserHandler {
	return &userHandler{
		userService: us,
	}
}

// --------------------------------------------------
// 1. 创建用户
// --------------------------------------------------
func (h *userHandler) Create(c *gin.Context) {
	var req models.UserCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.SendBadRequest(c, "请求参数错误: "+err.Error())
		return
	}
	currentUserType := utils.GetUserType(c.Request.Header)
	switch currentUserType {
	case "":
		utils.SendUnauthorized(c)
	case "user":
		return
	case "admin":
		req.UserType = models.UserTypeUser
	default:
	}
	user, err := h.userService.Register(&req)
	switch err {
	case nil:
		utils.SendCreatedResponse(c, user, "用户创建成功")
	case service.ErrUserExists:
		utils.SendConflict(c, "用户名已存在")
	case service.ErrInvalidInput:
		utils.SendBadRequest(c, "用户名或密码不能为空")
	default:
		utils.SendInternalServerError(c, err)
	}
}

// --------------------------------------------------
// 2. 当前登录用户信息
// --------------------------------------------------
func (h *userHandler) GetMe(c *gin.Context) {
	id := utils.GetUserID(c.Request.Header)
	if id == "" {
		utils.SendUnauthorized(c)
		return
	}
	user, err := h.userService.GetUserById(id)
	switch err {
	case nil:
		utils.SendSuccessResponse(c, user)
	case service.ErrUserNotFound:
		utils.SendNotFound(c, "用户不存在")
	default:
		utils.SendInternalServerError(c, err)
	}
}

// --------------------------------------------------
// 3. 根据 ID 获取用户
// --------------------------------------------------
func (h *userHandler) GetUser(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		utils.SendBadRequest(c, "缺少用户 ID")
		return
	}
	user, err := h.userService.GetUserById(id)
	switch err {
	case nil:
		utils.SendSuccessResponse(c, user)
	case service.ErrUserNotFound:
		utils.SendNotFound(c, "用户不存在")
	default:
		utils.SendInternalServerError(c, err)
	}
}

// --------------------------------------------------
// 4. 更新用户信息
// --------------------------------------------------
func (h *userHandler) UpdateUser(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		utils.SendBadRequest(c, "缺少用户 ID")
		return
	}
	var req models.UserUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.SendBadRequest(c, "参数错误: "+err.Error())
		return
	}
	user, err := h.userService.UpdateUser(id, &req)
	switch err {
	case nil:
		utils.SendSuccessResponse(c, user)
	case service.ErrUserNotFound:
		utils.SendNotFound(c, "用户不存在")
	case service.ErrUserExists:
		utils.SendConflict(c, "用户名已被占用")
	default:
		utils.SendInternalServerError(c, err)
	}
}

// --------------------------------------------------
// 5. 删除用户
// --------------------------------------------------
func (h *userHandler) DeleteUser(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		utils.SendBadRequest(c, "缺少用户 ID")
		return
	}
	if err := h.userService.DeleteUser(id); err != nil {
		switch err {
		case service.ErrUserNotFound:
			utils.SendNotFound(c, "用户不存在")
		default:
			utils.SendInternalServerError(c, err)
		}
		return
	}
	utils.SendSuccessResponse(c, "删除成功")
}

// --------------------------------------------------
// 6. 分页列表
// --------------------------------------------------
func (h *userHandler) ListUsers(c *gin.Context) {
	page, _ := strconv.Atoi(c.Query("page"))
	if page <= 0 {
		page = 1
	}
	limit, _ := strconv.Atoi(c.Query("limit"))
	if limit <= 0 || limit > 100 {
		limit = 10
	}
	resp, total, err := h.userService.ListUsers(page, limit)
	if err != nil {
		utils.SendInternalServerError(c, err)
		return
	}
	utils.SendPaginatedResponse(c, resp, total, page, limit)
}
