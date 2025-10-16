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
		maxRate: 1,
		window: 500 * time.Millisecond, // 500 毫秒
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
