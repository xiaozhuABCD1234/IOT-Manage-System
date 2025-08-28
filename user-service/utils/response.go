// utils/response_new.go
package utils

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// 统一的响应格式
type Response struct {
	Success    bool           `json:"success"`
	Data       any            `json:"data,omitempty"`
	Message    string         `json:"message,omitempty"`
	Error      *ErrorObj      `json:"error,omitempty"`
	Pagination *PaginationObj `json:"pagination,omitempty"`
	Timestamp  time.Time      `json:"timestamp"`
}

type ErrorObj struct {
	Code    string `json:"code"`
	Message string `json:"message"`
	Details any    `json:"details,omitempty"`
}

type PaginationObj struct {
	CurrentPage  int   `json:"currentPage"`  // 当前页
	TotalPages   int   `json:"totalPages"`   // 总页数
	TotalItems   int64 `json:"totalItems"`   // 总记录数
	ItemsPerPage int   `json:"itemsPerPage"` // 每页条数
	HasNext      bool  `json:"has_next"`     // 是否有下一页
	HasPrev      bool  `json:"has_prev"`     // 是否有上一页
}

// SendSuccessResponse 发送成功响应
func SendSuccessResponse(c *gin.Context, data any, msg ...string) {
	message := "请求成功啦😁"
	if len(msg) > 0 {
		message = msg[0] // 只取第一个
	}
	c.JSON(http.StatusOK, Response{
		Success:   true,
		Data:      data,
		Message:   message, // 注意是指针，便于 omitempty
		Timestamp: time.Now(),
	})
}

// SendCreatedResponse 发送创建成功响应
func SendCreatedResponse(c *gin.Context, data any, message string) {
	c.JSON(http.StatusCreated, Response{
		Success:   true,
		Data:      data,
		Message:   message,
		Timestamp: time.Now(),
	})
}

// SendPaginatedResponse 发送分页响应
func SendPaginatedResponse(c *gin.Context, data any, total int64, page, perPage int) {
	pagination := NewPagination(total, page, perPage)
	c.JSON(http.StatusOK, Response{
		Success:    true,
		Data:       data,
		Message:    "请求成功啦😁",
		Pagination: pagination,
		Timestamp:  time.Now(),
	})
}

// NewPagination 生成分页响应
func NewPagination(total int64, page, perPage int) *PaginationObj {
	if perPage <= 0 {
		perPage = 10
	}
	totalPages := int((total + int64(perPage) - 1) / int64(perPage))
	return &PaginationObj{
		CurrentPage:  page,
		TotalPages:   totalPages,
		TotalItems:   total,
		ItemsPerPage: perPage,
		HasNext:      page < totalPages,
		HasPrev:      page > 1,
	}
}

// SendErrorResponse 发送错误响应
func SendErrorResponse(c *gin.Context, statusCode int, message string) {
	c.JSON(statusCode, Response{
		Success:   false,
		Message:   message,
		Timestamp: time.Now(),
	})
}

// SendErrorResponseWithData 发送带自定义数据的错误响应
func SendErrorResponseWithData(c *gin.Context, statusCode int, message string, data any) {
	c.JSON(statusCode, Response{
		Success: false,
		Message: message,
		Data:    data,
	})
}

// newErrorObj 构造 ErrorObj；details 只取第一个
func newErrorObj(code, msg string, details ...any) *ErrorObj {
	e := &ErrorObj{Code: code, Message: msg}
	if len(details) > 0 {
		e.Details = details[0]
	}
	return e
}

// SendUnauthorized 401 未认证
func SendUnauthorized(c *gin.Context, msg ...any) {
	message := "请先登录哦🤨"
	if len(msg) > 0 {
		message, _ = msg[0].(string)
	}
	c.JSON(http.StatusUnauthorized, Response{
		Success:   false,
		Message:   message,
		Error:     newErrorObj("UNAUTHORIZED", "未认证"),
		Timestamp: time.Now(),
	})
}

// SendForbidden 403 无权限
func SendForbidden(c *gin.Context, msg ...any) {
	message := "权限不足🙅"
	if len(msg) > 0 {
		message, _ = msg[0].(string)
	}
	c.JSON(http.StatusForbidden, Response{
		Success:   false,
		Message:   message,
		Error:     newErrorObj("FORBIDDEN", "权限不足"),
		Timestamp: time.Now(),
	})
}

// SendNotFound 404 资源不存在
func SendNotFound(c *gin.Context, msg ...any) {
	message := "资源没有找到😕"
	if len(msg) > 0 {
		message, _ = msg[0].(string)
	}
	c.JSON(http.StatusNotFound, Response{
		Success:   false,
		Message:   message,
		Error:     newErrorObj("NOT_FOUND", "资源不存在"),
		Timestamp: time.Now(),
	})
}

// ========= 400 Bad Request =========
func SendBadRequest(c *gin.Context, msg ...any) {
	message := "请求参数有误🙅"
	if len(msg) > 0 {
		message, _ = msg[0].(string)
	}
	c.JSON(http.StatusBadRequest, Response{
		Success:   false,
		Message:   message,
		Error:     newErrorObj("BAD_REQUEST", "请求参数有误"),
		Timestamp: time.Now(),
	})
}

// 400 Bad Request 带自定义数据
func SendBadRequestWithData(c *gin.Context, msg string, data any) {
	c.JSON(http.StatusBadRequest, Response{
		Success:   false,
		Message:   msg,
		Data:      data,
		Error:     newErrorObj("BAD_REQUEST", "请求参数有误"),
		Timestamp: time.Now(),
	})
}

// ========= 409 Conflict =========
func SendConflict(c *gin.Context, msg ...any) {
	message := "数据冲突，请稍后再试😔"
	if len(msg) > 0 {
		message, _ = msg[0].(string)
	}
	c.JSON(http.StatusConflict, Response{
		Success:   false,
		Message:   message,
		Error:     newErrorObj("CONFLICT", "数据冲突"),
		Timestamp: time.Now(),
	})
}

// ========= 500 Internal Server Error =========
// 版本 1：直接传入 error
func SendInternalServerError(c *gin.Context, err error) {
	c.JSON(http.StatusInternalServerError, Response{
		Success:   false,
		Message:   "服务器内部错误🥺",
		Error:     newErrorObj("INTERNAL_SERVER_ERROR", err.Error()),
		Timestamp: time.Now(),
	})
}
