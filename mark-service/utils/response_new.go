// utils/response_new.go
package utils

import (
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
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
	CurrentPage  int   `json:"currentPage"`
	TotalPages   int   `json:"totalPages"`
	TotalItems   int64 `json:"totalItems"`
	ItemsPerPage int   `json:"itemsPerPage"`
	HasNext      bool  `json:"has_next"`
	HasPrev      bool  `json:"has_prev"`
}

/* ---------- 成功响应 ---------- */

// SendSuccessResponse 200 OK
func SendSuccessResponse(c *fiber.Ctx, data any, msg ...string) error {
	message := "请求成功啦😁"
	if len(msg) > 0 {
		message = msg[0]
	}
	return c.Status(http.StatusOK).JSON(Response{
		Success:   true,
		Data:      data,
		Message:   message,
		Timestamp: time.Now(),
	})
}

// SendCreatedResponse 200 OK (统一返回200)
func SendCreatedResponse(c *fiber.Ctx, data any, msg ...string) error {
	message := "创建成功啦✌️"
	if len(msg) > 0 {
		message = msg[0]
	}
	return c.Status(http.StatusOK).JSON(Response{
		Success:   true,
		Data:      data,
		Message:   message,
		Timestamp: time.Now(),
	})
}

// SendPaginatedResponse 带分页的 200
func SendPaginatedResponse(c *fiber.Ctx, data any, total int64, page, perPage int, msg ...string) error {
	message := "请求成功啦😁"
	if len(msg) > 0 {
		message = msg[0]
	}
	pagination := NewPagination(total, page, perPage)
	return c.Status(http.StatusOK).JSON(Response{
		Success:    true,
		Data:       data,
		Message:    message,
		Pagination: pagination,
		Timestamp:  time.Now(),
	})
}

/* ---------- 错误响应 ---------- */

// SendErrorResponse 统一返回200状态码
func SendErrorResponse(c *fiber.Ctx, statusCode int, message string) error {
	return c.Status(http.StatusOK).JSON(Response{
		Success:   false,
		Message:   message,
		Timestamp: time.Now(),
	})
}

// SendErrorResponseWithData 统一返回200状态码 + 数据
func SendErrorResponseWithData(c *fiber.Ctx, statusCode int, message string, data any) error {
	return c.Status(http.StatusOK).JSON(Response{
		Success:   false,
		Message:   message,
		Data:      data,
		Timestamp: time.Now(),
	})
}

/* ---------- 工具函数 ---------- */

// NewPagination 计算分页信息
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
