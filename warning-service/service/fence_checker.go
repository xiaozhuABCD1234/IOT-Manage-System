package service

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"sync"
	"time"

	"IOT-Manage-System/warning-service/config"
	"IOT-Manage-System/warning-service/model"
)

// FenceChecker 围栏检查器
type FenceChecker struct {
	client  *http.Client
	baseURL string

	// 设备围栏状态缓存：避免重复警报
	statusCache map[string]bool // deviceID -> 是否在围栏内
	mu          sync.RWMutex
}

// NewFenceChecker 创建围栏检查器
func NewFenceChecker() *FenceChecker {
	hostname := config.C.MapServiceConfig.Hostname
	port := config.C.MapServiceConfig.Port
	baseURL := fmt.Sprintf("http://%s:%s", hostname, port)

	log.Printf("[INFO] FenceChecker 初始化, baseURL=%s", baseURL)

	return &FenceChecker{
		client: &http.Client{
			Timeout: 3 * time.Second, // 3秒超时
		},
		baseURL:     baseURL,
		statusCache: make(map[string]bool),
	}
}

// CheckPoint 检查点是否在围栏内
func (fc *FenceChecker) CheckPoint(deviceID string, x, y float64) (bool, error) {
	// 构造请求
	reqBody := model.FenceCheckRequest{
		X: x,
		Y: y,
	}

	bodyBytes, err := json.Marshal(reqBody)
	if err != nil {
		return false, fmt.Errorf("序列化请求失败: %w", err)
	}

	url := fc.baseURL + "/api/v1/polygon-fence/check-all"
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(bodyBytes))
	if err != nil {
		return false, fmt.Errorf("创建请求失败: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")

	// 发送请求
	resp, err := fc.client.Do(req)
	if err != nil {
		return false, fmt.Errorf("请求map-service失败: %w", err)
	}
	defer resp.Body.Close()

	// 读取响应
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, fmt.Errorf("读取响应失败: %w", err)
	}

	// 解析响应
	var fenceResp model.FenceCheckResponse
	if err := json.Unmarshal(respBody, &fenceResp); err != nil {
		return false, fmt.Errorf("解析响应失败: %w", err)
	}

	// 检查响应状态
	if !fenceResp.Success {
		return false, fmt.Errorf("map-service返回错误: %s", fenceResp.Message)
	}

	isInside := fenceResp.Data.IsInside

	// 检查状态变化
	fc.mu.Lock()
	prevStatus, exists := fc.statusCache[deviceID]
	fc.statusCache[deviceID] = isInside
	fc.mu.Unlock()

	// 状态变化时记录日志
	if !exists {
		// 首次检查
		if isInside {
			log.Printf("[FENCE] 设备 %s 在围栏内: %v", deviceID, fenceResp.Data.FenceNames)
		}
	} else if prevStatus != isInside {
		// 状态改变
		if isInside {
			log.Printf("[FENCE] 设备 %s 进入围栏: %v", deviceID, fenceResp.Data.FenceNames)
		} else {
			log.Printf("[FENCE] 设备 %s 离开围栏", deviceID)
		}
	}

	return isInside, nil
}

// IsStatusChanged 检查设备围栏状态是否改变（用于决定是否发送警报）
func (fc *FenceChecker) IsStatusChanged(deviceID string, currentStatus bool) bool {
	fc.mu.RLock()
	defer fc.mu.RUnlock()

	prevStatus, exists := fc.statusCache[deviceID]
	if !exists {
		return currentStatus // 首次检查，如果在围栏内就发警报
	}

	return prevStatus != currentStatus
}

// ShouldSendAlert 检查是否应该发送警报（支持持续报警模式）
func (fc *FenceChecker) ShouldSendAlert(deviceID string, currentStatus bool) bool {
	fc.mu.RLock()
	defer fc.mu.RUnlock()

	prevStatus, exists := fc.statusCache[deviceID]
	if !exists {
		return currentStatus // 首次检查，如果在围栏内就发警报
	}

	// 如果在围栏内，总是发送警报（持续报警模式）
	if currentStatus {
		return true
	}

	// 离开围栏时，只在状态改变时发送取消警报
	return prevStatus != currentStatus
}

// GetCurrentStatus 获取设备当前围栏状态
func (fc *FenceChecker) GetCurrentStatus(deviceID string) (bool, bool) {
	fc.mu.RLock()
	defer fc.mu.RUnlock()

	status, exists := fc.statusCache[deviceID]
	return status, exists
}
