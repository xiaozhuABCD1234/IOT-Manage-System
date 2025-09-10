package client

import (
	"log"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
	"github.com/goccy/go-json"

	"IOT-Manage-System/mqtt-watch/model"
	"IOT-Manage-System/mqtt-watch/service"
	"IOT-Manage-System/mqtt-watch/utils"
)

// MqttCallback 把原来所有 handler 和主动下发接口封装在一起
type MqttCallback struct {
	cli             mqtt.Client
	markService     service.MarkService
	markPairService service.MarkPairService
	mongoService    service.MongoService // <-- 新增
}

// NewMqttClient 构造函数，一次性把 repo & service 注入
func NewMqttCallback(cli mqtt.Client,
	markService service.MarkService,
	markPairService service.MarkPairService,
	mongoService service.MongoService, // <-- 新增
) *MqttCallback {

	return &MqttCallback{
		cli:             cli,
		markService:     markService,
		markPairService: markPairService,
		mongoService:    mongoService, // <-- 保存
	}
}

/* ---------- 以下全部是内部回调 / 主动下发接口 ---------- */

func (m *MqttCallback) defaultMsgHandler(c mqtt.Client, msg mqtt.Message) {
	log.Printf("[INFO] 收到: topic=%s payload=%s\n", msg.Topic(), string(msg.Payload()))
}

// echoMsg 对应原来的 EchoMsg
func (m *MqttCallback) echoMsg(c mqtt.Client, msg mqtt.Message) {
	deviceID := utils.ParseOnlineId(msg.Topic(), msg.Payload())
	tok := c.Publish("echo/"+deviceID, 0, false, "1")
	tok.Wait()
	if err := tok.Error(); err != nil {
		log.Printf("[ERROR] 发布失败: %v", err)
	}
}

// SendWarningStart 外部可调用：开始报警
func (m *MqttCallback) SendWarningStart(deviceID string) {
	tok := m.cli.Publish("warning/"+deviceID, 1, false, "1")
	tok.Wait()
	if err := tok.Error(); err != nil {
		log.Printf("[ERROR] 发布失败: %v", err)
	} else {
		log.Printf("[DEBUG] 警报已发送  deviceID=%s  targetTopic=warning/%s", deviceID, deviceID)
	}
}

// SendWarningEnd 外部可调用：解除报警
func (m *MqttCallback) SendWarningEnd(deviceID string) {
	tok := m.cli.Publish("warning/"+deviceID, 1, false, "0")
	tok.Wait()
	if err := tok.Error(); err != nil {
		log.Printf("[ERROR] 发布失败: %v", err)
	} else {
		log.Printf("[DEBUG] 解除警报已发送  deviceID=%s  targetTopic=warning/%s", deviceID, deviceID)
	}
}

// saveLocation 对应原来的 SaveLocation，现在可以直接用注入的 repo/service 落库
func (m *MqttCallback) saveLocation(c mqtt.Client, msg mqtt.Message) {
	deviceID := utils.ParseOnlineId(msg.Topic(), msg.Payload())

	var locMsg model.LocMsg
	if err := json.Unmarshal(msg.Payload(), &locMsg); err != nil {
		log.Println("[ERROR] json 解析失败:", err)
		return
	}
	if len(locMsg.Sens) == 0 {
		return
	}

	is_save, err := m.markService.GetPersistMQTTByDeviceID(deviceID)
	if err != nil {
		log.Printf("[ERROR] 获取 persist 失败: %v", err)
		return
	}
	if !is_save {
		return
	}

	var rtk, uwb *model.Sens
	for i := range locMsg.Sens {
		switch locMsg.Sens[i].N {
		case "RTK":
			rtk = &locMsg.Sens[i]
		case "UWB":
			uwb = &locMsg.Sens[i] // 原来是 rtk = &locMsg.Sens[i]，属于笔误
		}
	}
	indoor := uwb != nil && len(uwb.V) >= 2

	recTime := time.Now()

	// 构造实体
	data := &model.DeviceLoc{
		DeviceID:   deviceID,
		Indoor:     indoor,
		RecordTime: recTime,
		CreatedAt:  time.Now(), // 服务器收到时间
	}
	data.SetID()
	if rtk != nil && len(rtk.V) >= 2 {
		data.Latitude = &rtk.V[0]
		data.Longitude = &rtk.V[1]
	}
	if uwb != nil && len(uwb.V) >= 2 {
		data.UWBX = &uwb.V[0]
		data.UWBY = &uwb.V[1]
	}
	m.mongoService.SaveDeviceLoc(*data) // <-- 新增
	log.Printf("[INFO] 保存位置信息成功  deviceID=%s  indoor=%t  lat=%f  lon=%f  uwb_x=%f  uwb_y=%f", deviceID, indoor, *data.Latitude, *data.Longitude, *data.UWBX, *data.UWBY)
}

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
