// handler/error_handler.go
package handler

import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/utils"

	"github.com/gofiber/fiber/v2"
	// "log"
	"time"
)

func CustomErrorHandler(c *fiber.Ctx, err error) error {
	// 默认 500
	status := fiber.StatusInternalServerError
	code := "INTERNAL_ERROR"
	message := err.Error()
	var details any

	// 如果是 *errs.AppError 则解析业务码
	if appErr, ok := err.(*errs.AppError); ok {
		status = appErr.Status
		code = appErr.Code
		message = appErr.Message
		details = appErr.Details
	}

	// 如果是 *fiber.Error（用 fiber.NewError 创建）
	if e, ok := err.(*fiber.Error); ok {
		status = e.Code
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
