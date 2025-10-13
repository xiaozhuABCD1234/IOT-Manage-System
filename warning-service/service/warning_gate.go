// service/warning_gate.go
package service

import (
	"log"
	"strconv"
	"sync"
	"time"

	"IOT-Manage-System/warning-service/utils"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

// WarningRateLimiter 警报限流器：每秒每个设备最多发送2次
type WarningRateLimiter struct {
	records map[string][]time.Time // deviceID -> 最近发送时间列表
	mu      sync.RWMutex
	maxRate int           // 每秒最大发送次数
	window  time.Duration // 时间窗口
}

var rateLimiter *WarningRateLimiter

func init() {
	rateLimiter = &WarningRateLimiter{
		records: make(map[string][]time.Time),
		maxRate: 2,               // 每秒最多2次
		window:  1 * time.Second, // 1秒时间窗口
	}
	// 启动清理协程
	go rateLimiter.cleanupLoop()
}

// Allow 检查是否允许发送警报
func (r *WarningRateLimiter) Allow(deviceID string, on bool) bool {
	r.mu.Lock()
	defer r.mu.Unlock()

	now := time.Now()
	key := deviceID + ":" + strconv.FormatBool(on)

	// 获取该设备的发送记录
	times, exists := r.records[key]
	if !exists {
		r.records[key] = []time.Time{now}
		return true
	}

	// 清理过期记录（超过时间窗口的）
	validTimes := make([]time.Time, 0, len(times))
	for _, t := range times {
		if now.Sub(t) < r.window {
			validTimes = append(validTimes, t)
		}
	}

	// 检查是否超过限流阈值
	if len(validTimes) >= r.maxRate {
		log.Printf("[RATE_LIMIT] 设备 %s 警报被限流，当前窗口内已发送 %d 次", deviceID, len(validTimes))
		return false
	}

	// 允许发送，记录时间
	validTimes = append(validTimes, now)
	r.records[key] = validTimes
	return true
}

// cleanupLoop 定期清理过期记录，避免内存泄漏
func (r *WarningRateLimiter) cleanupLoop() {
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()

	for range ticker.C {
		r.mu.Lock()
		now := time.Now()
		for key, times := range r.records {
			// 清理超过窗口的记录
			validTimes := make([]time.Time, 0)
			for _, t := range times {
				if now.Sub(t) < r.window {
					validTimes = append(validTimes, t)
				}
			}
			if len(validTimes) == 0 {
				delete(r.records, key)
			} else {
				r.records[key] = validTimes
			}
		}
		r.mu.Unlock()
	}
}

// SendWarning 发送警报（带限流）
func SendWarning(deviceID string, on bool) {
	// 限流检查
	if !rateLimiter.Allow(deviceID, on) {
		return
	}

	var token mqtt.Token
	payload := "0"
	if on {
		payload = "1"
	}

	token = utils.MQTTClient.Publish("warning/"+deviceID, 0, false, payload)
	token.Wait()
	if err := token.Error(); err != nil {
		log.Printf("[ERROR] 发送警报失败: %v", err)
		return
	}
	log.Printf("[PUB] topic=warning/%s payload=%s", deviceID, payload)
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
