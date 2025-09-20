// service/warning_gate.go
package service

import (
	"log"
	"strconv"
	"sync"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

type WarningGate struct {
	client mqtt.Client
	in     chan warningCmd
	dedup  *sync.Map // key=deviceID+status  1s 内不重复
}

type warningCmd struct {
	deviceID string
	on       bool
}

var defaultGate *WarningGate

func InitWarningGate(c mqtt.Client) {
	defaultGate = &WarningGate{
		client: c,
		in:     make(chan warningCmd, 1000),
		dedup:  &sync.Map{},
	}
	go defaultGate.loop()
}

func (w *WarningGate) loop() {
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()
	for {
		select {
		case cmd := <-w.in:
			key := cmd.deviceID + strconv.FormatBool(cmd.on)
			if _, ok := w.dedup.LoadOrStore(key, time.Now()); ok {
				continue // 1 秒内已发过
			}
			topic := "warning/" + cmd.deviceID
			payload := "0"
			if cmd.on {
				payload = "1"
			}
			// 同步 publish，但只在单 goroutine 里做，不会爆连接
			if tok := w.client.Publish(topic, 1, false, payload); tok.Wait() && tok.Error() != nil {
				log.Printf("[ERROR] publish fail: %v", tok.Error())
			}
		case <-ticker.C:
			// 简单清理过期 key
			w.dedup.Range(func(k, v interface{}) bool {
				if time.Since(v.(time.Time)) > 1*time.Second {
					w.dedup.Delete(k)
				}
				return true
			})
		}
	}
}

// 暴露给外部：非阻塞发送
func SendWarning(deviceID string, on bool) {
	select {
	case defaultGate.in <- warningCmd{deviceID: deviceID, on: on}:
	default:
		log.Printf("[WARN] warning channel full, drop %s %v", deviceID, on)
	}
}
