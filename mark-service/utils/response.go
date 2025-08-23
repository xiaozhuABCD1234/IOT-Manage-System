package utils

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// Response 统一响应结构
type Response struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
}

// PaginatedResponse 分页响应结构
type PaginatedResponse struct {
	Data       interface{} `json:"data"`
	Total      int64       `json:"total"`
	Page       int         `json:"page"`
	Limit      int         `json:"limit"`
	TotalPages int         `json:"total_pages"`
}

// SendErrorResponse 发送错误响应
func SendErrorResponse(c *gin.Context, statusCode int, message string) {
	c.JSON(statusCode, Response{
		Code:    statusCode,
		Message: message,
		Data:    nil,
	})
}

// SendErrorResponseWithData 发送带自定义数据的错误响应
func SendErrorResponseWithData(c *gin.Context, statusCode int, message string, data interface{}) {
	c.JSON(statusCode, Response{
		Code:    statusCode,
		Message: message,
		Data:    data,
	})
}

// SendSuccessResponse 发送成功响应
func SendSuccessResponse(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, Response{
		Code:    http.StatusOK,
		Message: "success",
		Data:    data,
	})
}

// SendCreatedResponse 发送创建成功响应
func SendCreatedResponse(c *gin.Context, message string, data interface{}) {
	c.JSON(http.StatusCreated, Response{
		Code:    http.StatusCreated,
		Message: message,
		Data:    data,
	})
}

// SendPaginatedResponse 发送分页响应
func SendPaginatedResponse(c *gin.Context, data interface{}, total int64, page, limit int) {
	totalPages := (int(total) + limit - 1) / limit
	c.JSON(http.StatusOK, Response{
		Code:    0,
		Message: "success",
		Data: PaginatedResponse{
			Data:       data,
			Total:      total,
			Page:       page,
			Limit:      limit,
			TotalPages: totalPages,
		},
	})
}

// Common error responses
func SendBadRequest(c *gin.Context, message string) {
	SendErrorResponse(c, http.StatusBadRequest, message)
}

func SendBadRequestWithData(c *gin.Context, message string, data interface{}) {
	SendErrorResponseWithData(c, http.StatusBadRequest, message, data)
}

func SendUnauthorized(c *gin.Context) {
	SendErrorResponse(c, http.StatusUnauthorized, "未认证")
}

func SendForbidden(c *gin.Context, message string) {
	SendErrorResponse(c, http.StatusForbidden, message)
}

func SendNotFound(c *gin.Context, message string) {
	SendErrorResponse(c, http.StatusNotFound, message)
}

func SendConflict(c *gin.Context, message string) {
	SendErrorResponse(c, http.StatusConflict, message)
}

func SendInternalServerError(c *gin.Context, err error) {
	SendErrorResponse(c, http.StatusInternalServerError, "服务器内部错误: "+err.Error())
}

func SendInternalError(c *gin.Context, msg string) {
	SendErrorResponse(c, http.StatusInternalServerError, msg)
}
