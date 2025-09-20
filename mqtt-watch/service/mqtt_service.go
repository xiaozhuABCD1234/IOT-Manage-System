package service

import (
	"IOT-Manage-System/mqtt-watch/errs"
	"log"

	"github.com/eclipse/paho.mqtt.golang"
)

type MqttService interface {
	// 发送报警
	SendWarningStart(deviceID string) *errs.AppError
	// 解除报警
	SendWarningEnd(deviceID string) *errs.AppError
}

type mqttService struct {
	c mqtt.Client
}

func (m *mqttService) SendWarningStart(deviceID string) *errs.AppError {
	token := m.c.Publish("warning/"+deviceID, 2, false, "1")
	token.Wait()
	if err := token.Error(); err != nil {
		log.Fatalln("❌")
		// 网络 / Broker 不可用 → 503 第三方服务异常
		return errs.ErrThirdParty.WithDetails(err.Error())
	}
	log.Printf("[PUB] topic=%s payload=%s", "warning/"+deviceID, "1")
	return nil
}

func (m *mqttService) SendWarningEnd(deviceID string) *errs.AppError {
	token := m.c.Publish("warning/"+deviceID, 2, false, "0")
	token.Wait()
	if err := token.Error(); err != nil {
		return errs.ErrThirdParty.WithDetails(err.Error())
	}
	return nil
}

func NewMqttService(c mqtt.Client) MqttService {
	return &mqttService{c: c}
}
