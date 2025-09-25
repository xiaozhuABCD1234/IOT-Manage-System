// service/warning_gate.go
package service

import (
	// "go/token"
	"log"
	// "strconv"
	// "sync"
	// "time"

	"IOT-Manage-System/warning-service/utils"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

func SendWarning(deviceID string, on bool) {
	var token mqtt.Token
	switch on {
	case true:
		token = utils.MQTTClient.Publish("warning/"+deviceID, 2, false, "1")
	case false:
		token = utils.MQTTClient.Publish("warning/"+deviceID, 2, false, "0")
	}
	token.Wait()
	if err := token.Error(); err != nil {
		log.Fatalln("❌")
	}
	log.Printf("[PUB] topic=%s payload=%s", "warning/"+deviceID, "1")
}

// type WarningGate struct {
// 	client mqtt.Client
// 	in     chan warningCmd
// 	dedup  *sync.Map // key=deviceID+status  1s 内不重复
// }

// type warningCmd struct {
// 	deviceID string
// 	on       bool
// }

// var defaultGate *WarningGate

// // InitWarningGate 初始化并启动后台 loop
// func InitWarningGate(c mqtt.Client) {
// 	defaultGate = &WarningGate{
// 		client: c,
// 		in:     make(chan warningCmd, 1000),
// 		dedup:  &sync.Map{},
// 	}
// 	log.Printf("[INFO] WarningGate initialized, chanSize=1000")
// 	go defaultGate.loop()
// }

// // 后台单 goroutine 循环
// func (w *WarningGate) loop() {
// 	ticker := time.NewTicker(1 * time.Second)
// 	defer ticker.Stop()
// 	log.Printf("[INFO] WarningGate loop started")
// 	for {
// 		select {
// 		case cmd := <-w.in:
// 			key := cmd.deviceID + strconv.FormatBool(cmd.on)
// 			if _, loaded := w.dedup.LoadOrStore(key, time.Now()); loaded {
// 				log.Printf("[DEBUG] duplicate warning dropped, device=%s on=%v", cmd.deviceID, cmd.on)
// 				continue // 1 秒内已发过
// 			}
// 			topic := "warning/" + cmd.deviceID
// 			payload := "0"
// 			if cmd.on {
// 				payload = "1"
// 			}
// 			log.Printf("[DEBUG] publish mqtt, topic=%s payload=%s", topic, payload)
// 			if tok := w.client.Publish(topic, 1, false, payload); tok.Wait() && tok.Error() != nil {
// 				log.Printf("[ERROR] publish fail: %v", tok.Error())
// 			} else {
// 				log.Printf("[DEBUG] publish ok, topic=%s payload=%s", topic, payload)
// 			}

// 		case <-ticker.C:
// 			// 简单清理过期 key
// 			w.dedup.Range(func(k, v interface{}) bool {
// 				if time.Since(v.(time.Time)) > 1*time.Second {
// 					w.dedup.Delete(k)
// 				}
// 				return true
// 			})
// 			log.Printf("[TRACE] dedup map cleaned, remaining=%d", syncMapLen(w.dedup))
// 		}
// 	}
// }

// SendWarning 非阻塞发送
// func SendWarning(deviceID string, on bool) {
// 	cmd := warningCmd{deviceID: deviceID, on: on}
// 	select {
// 	case defaultGate.in <- cmd:
// 		log.Printf("[DEBUG] SendWarning enqueued, device=%s on=%v", deviceID, on)
// 	default:
// 		log.Printf("[WARN] warning channel full, drop %s %v", deviceID, on)
// 	}
// }

// // 辅助：统计 sync.Map 长度
// func syncMapLen(m *sync.Map) int {
// 	n := 0
// 	m.Range(func(_, _ interface{}) bool {
// 		n++
// 		return true
// 	})
// 	return n
// }
