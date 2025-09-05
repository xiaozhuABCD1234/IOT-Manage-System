package utils

import (
	"strings"

	"github.com/goccy/go-json"

	"IOT-Manage-System/mqtt-watch/model" // 按实际 module 路径调整
)

// ParseOnlineId 从 topic & payload 中提取设备 id，拿不到返回空串
func ParseOnlineId(topic string, payload []byte) string {
	// 1. 从 topic 截取
	idFromTopic := strings.TrimPrefix(topic, "online")
	idFromTopic = strings.Trim(idFromTopic, "/")

	// 2. 解析 payload
	var msg model.OnlineMsg
	_ = json.Unmarshal(payload, &msg) // 失败时 msg 为零值

	// 3. 优先 data.id，没有再回退 topic
	id := strings.TrimSpace(msg.ID)
	if id == "" {
		id = idFromTopic
	}

	return id
}
