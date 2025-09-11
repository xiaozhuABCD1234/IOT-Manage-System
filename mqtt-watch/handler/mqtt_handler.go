package handler

import (
	"github.com/gofiber/fiber/v2"

	"IOT-Manage-System/mqtt-watch/service"
	"IOT-Manage-System/mqtt-watch/utils"
)

type MqttHandler interface {
	SendWarningStart(c *fiber.Ctx) error
	SendWarningEnd(c *fiber.Ctx) error
}

type mqttHandler struct {
	mqttSer service.MqttService
}

// 发送报警  POST /mqtt/warning/:deviceId/start
func (h *mqttHandler) SendWarningStart(c *fiber.Ctx) error {
	deviceID := c.Params("deviceId")
	if err := h.mqttSer.SendWarningStart(deviceID); err != nil {
		return c.Status(err.Status).JSON(err) // 统一错误 JSON
	}
	return utils.SendSuccessResponse(c, "warning started")
}

// 解除报警  POST /mqtt/warning/:deviceId/end
func (h *mqttHandler) SendWarningEnd(c *fiber.Ctx) error {
	deviceID := c.Params("deviceId")
	if err := h.mqttSer.SendWarningEnd(deviceID); err != nil {
		return c.Status(err.Status).JSON(err)
	}
	return utils.SendSuccessResponse(c, "warning ended")
}

func NewMqttService(s service.MqttService) MqttHandler {
	return &mqttHandler{mqttSer: s}
}
