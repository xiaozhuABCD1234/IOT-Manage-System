package client

import (
	"log"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
	"github.com/goccy/go-json"

	"IOT-Manage-System/mqtt-watch/model"
	"IOT-Manage-System/mqtt-watch/utils"
)

func DefaultMsgHandler(c mqtt.Client, m mqtt.Message) {
	log.Printf("[INFO] 收到: topic=%s payload=%s\n", m.Topic(), string(m.Payload()))
}

func logMsg(c mqtt.Client, m mqtt.Message) {
	log.Printf("[INFO] 收到消息  topic=%s  payload=%s", m.Topic(), string(m.Payload()))
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

func SendWaringStart(c mqtt.Client, deviceID string) {
	token := c.Publish("warning/"+deviceID, 1, false, "1")
	token.Wait()
	if err := token.Error(); err != nil {
		log.Printf("[ERROR] 发布失败: %v", err)
	} else {
		log.Printf("[DEBUG] 警报已发送  deviceID=%s  targetTopic=waring/%s", deviceID, deviceID)
	}
}

func SendWarningEnd(c mqtt.Client, deviceID string) {
	token := c.Publish("warning/"+deviceID, 1, false, "0")
	token.Wait()
	if err := token.Error(); err != nil {
		log.Printf("[ERROR] 发布失败: %v", err)
	} else {
		log.Printf("[DEBUG] 解除警报已发送  deviceID=%s  targetTopic=waring/%s", deviceID, deviceID)
	}
}

func SaveLocation(c mqtt.Client, m mqtt.Message) {
	deviceID := utils.ParseOnlineId(m.Topic(), m.Payload())
	var msg model.LocMsg
	if err := json.Unmarshal(m.Payload(), &msg); err != nil {
		log.Println(err)
	}
	if len(msg.Sens) == 0 {
		return
	}
	var rtk *model.Sens
	for i := range msg.Sens {
		if msg.Sens[i].N == "RTK" {
			rtk = &msg.Sens[i]
			break
		}
	}
	data := &model.DeviceLoc{
		DeviceID:   deviceID,
		Longitude:  rtk.V[0],
		Latitude:   rtk.V[1],
		RecordTime: time.Now(),
	}
	if b, err := json.MarshalIndent(data, "", "  "); err == nil {
		log.Println(string(b))
	} else {
		log.Println("marshal error:", err)
	}
}
