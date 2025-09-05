package client

import (
	mqtt "github.com/eclipse/paho.mqtt.golang"
	"log"

	"IOT-Manage-System/mqtt-watch/utils"
)

func DefaultMsgHandler(c mqtt.Client, m mqtt.Message) {
	log.Printf("[INFO] 收到: topic=%s payload=%s\n", m.Topic(), string(m.Payload()))
}

func LogMsg(c mqtt.Client, m mqtt.Message) {
	log.Printf("[INFO] 收到消息  topic=%s  payload=%s", m.Topic(), m.Payload())
}

func EchoMsg(c mqtt.Client, m mqtt.Message) {
	deviceID := utils.ParseOnlineId(m.Topic(), m.Payload())

	token := c.Publish("echo/"+deviceID, 0, false, "1")
	token.Wait()
	if err := token.Error(); err != nil {
		log.Printf("[ERROR] 发布失败: %v", err)
	} else {
		// log.Printf("[DEBUG] 发送消息  deviceID=%s  targetTopic=echo/%s", deviceID, deviceID)
	}
}

func SendWaring(c mqtt.Client, deviceID string) {
	token := c.Publish("waring/"+deviceID, 1, false, "1")
	token.Wait()
	if err := token.Error(); err != nil {
		log.Printf("[ERROR] 发布失败: %v", err)
	} else {
		// log.Printf("[DEBUG] 警报已发送  deviceID=%s  targetTopic=waring/%s", deviceID, deviceID)
	}
}
