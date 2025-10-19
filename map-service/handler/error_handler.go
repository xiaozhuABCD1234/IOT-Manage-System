// handler/error_handler.go
package handler

import (
	"IOT-Manage-System/map-service/errs"
	"IOT-Manage-System/map-service/utils"

	"github.com/gofiber/fiber/v2"
	// "log"
	"time"
)

func CustomErrorHandler(c *fiber.Ctx, err error) error {
	// 统一返回 200 状态码
	status := fiber.StatusOK
	code := "INTERNAL_ERROR"
	message := err.Error()
	var details any

	// 如果是 *errs.AppError 则解析业务码
	if appErr, ok := err.(*errs.AppError); ok {
		code = appErr.Code
		message = appErr.Message
		details = appErr.Details
	}

	// 如果是 *fiber.Error（用 fiber.NewError 创建）
	if e, ok := err.(*fiber.Error); ok {
		message = e.Message
	}

	resp := utils.Response{
		Success:   false,
		Message:   message,
		Error:     &utils.ErrorObj{Code: code, Message: message, Details: details},
		Timestamp: time.Now(),
	}
	return c.Status(status).JSON(resp)
}
