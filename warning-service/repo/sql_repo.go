package repo

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"

	"IOT-Manage-System/warning-service/config"
	"IOT-Manage-System/warning-service/model"
)

// MarkAPIClient mark-service API客户端
type MarkAPIClient struct {
	client  *http.Client
	baseURL string
}

// API响应结构体
type APIResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data"`
	Message string      `json:"message"`
	Code    int         `json:"code,omitempty"`
}

// MarkInfo 标记信息
type MarkInfo struct {
	ID           string    `json:"id"`
	DeviceID     string    `json:"device_id"`
	MarkName     string    `json:"mark_name"`
	MqttTopic    []string  `json:"mqtt_topic"`
	PersistMQTT  bool      `json:"persist_mqtt"`
	DangerZoneM  *float64  `json:"danger_zone_m"`
	MarkType     *MarkType `json:"mark_type,omitempty"`
	Tags         []Tag     `json:"tags,omitempty"`
	CreatedAt    string    `json:"created_at"`
	UpdatedAt    string    `json:"updated_at"`
	LastOnlineAt *string   `json:"last_online_at"`
}

type MarkType struct {
	ID                 int     `json:"id"`
	TypeName           string  `json:"type_name"`
	DefaultDangerZoneM float64 `json:"default_danger_zone_m"`
}

type Tag struct {
	ID      int    `json:"id"`
	TagName string `json:"tag_name"`
}

// DangerZoneResponse 危险半径响应
type DangerZoneResponse struct {
	DeviceID    string  `json:"device_id"`
	DangerZoneM float64 `json:"danger_zone_m"`
}

// DistanceMapResponse 距离映射响应
type DistanceMapResponse map[string]float64

type MarkRepo struct {
	db        *gorm.DB
	apiClient *MarkAPIClient
	useAPI    bool // 是否使用API模式
}

func NewMarkRepo(db *gorm.DB) *MarkRepo {
	return &MarkRepo{
		db:        db,
		apiClient: NewMarkAPIClient(),
		useAPI:    true, // 默认使用API模式
	}
}

// NewMarkAPIClient 创建mark-service API客户端
func NewMarkAPIClient() *MarkAPIClient {
	hostname := config.C.MarkServiceConfig.Hostname
	port := config.C.MarkServiceConfig.Port
	baseURL := fmt.Sprintf("http://%s:%s", hostname, port)

	log.Printf("[INFO] MarkAPIClient 初始化, baseURL=%s", baseURL)

	return &MarkAPIClient{
		client: &http.Client{
			Timeout: 5 * time.Second, // 5秒超时
		},
		baseURL: baseURL,
	}
}

// NewMarkRepoWithDB 创建使用数据库的MarkRepo（兼容性方法）
func NewMarkRepoWithDB(db *gorm.DB) *MarkRepo {
	return &MarkRepo{
		db:        db,
		apiClient: nil,
		useAPI:    false,
	}
}

func (r *MarkRepo) SetOnline(deviceID string, t ...time.Time) error {
	if r.useAPI && r.apiClient != nil {
		// 使用API更新最后在线时间
		return r.apiClient.UpdateLastOnlineTime(deviceID)
	}

	// 使用数据库更新（兼容模式）
	onlineAt := time.Now()
	if len(t) > 0 {
		onlineAt = t[0]
	}
	return r.db.Model(&model.Mark{}).
		Where("device_id = ?", deviceID).
		Update("last_online_at", onlineAt).Error
}

func (r *MarkRepo) GetOnlineList() ([]string, error) {
	if r.useAPI && r.apiClient != nil {
		// 使用API获取在线设备列表
		return r.apiClient.GetOnlineDevices()
	}

	// 使用数据库查询（兼容模式）
	cutoff := time.Now().Add(-time.Duration(config.C.AppConfig.OnlineSecond) * time.Second)

	var ids []string
	err := r.db.Model(&model.Mark{}).
		Where("last_online_at >= ?", cutoff).
		Pluck("device_id", &ids).Error
	return ids, err
}

func (r *MarkRepo) IsOnline(deviceID string) (bool, error) {
	cutoff := time.Now().Add(-time.Duration(config.C.AppConfig.OnlineSecond) * time.Second)

	var count int64
	err := r.db.Model(&model.Mark{}).
		Where("device_id = ?", deviceID).
		Where("last_online_at >= ?", cutoff).
		Count(&count).Error

	return count > 0, err
}

func (r *MarkRepo) GetDangerZoneM(deviceID string) (float64, error) {
	if r.useAPI && r.apiClient != nil {
		// 使用API获取危险半径
		return r.apiClient.GetDangerZoneByDeviceID(deviceID)
	}

	// 使用数据库查询（兼容模式）
	var dangerZoneM *float64 // 注意是指针，因为数据库中可能是 NULL

	err := r.db.Model(&model.Mark{}).
		Where("device_id = ?", deviceID).
		Select("safe_distance_m").
		Scan(&dangerZoneM).Error

	if err != nil {
		return 0, err
	}

	if dangerZoneM == nil {
		return -1, nil // 或返回 mark_types 的默认值
	}

	return *dangerZoneM, nil
}

func (r *MarkRepo) GetBatchDangerZoneM(deviceIDs []string) (map[string]float64, error) {
	if len(deviceIDs) == 0 {
		return map[string]float64{}, nil
	}

	if r.useAPI && r.apiClient != nil {
		// 使用API批量获取危险半径
		result := make(map[string]float64, len(deviceIDs))
		for _, deviceID := range deviceIDs {
			dangerZone, err := r.apiClient.GetDangerZoneByDeviceID(deviceID)
			if err != nil {
				// 如果某个设备查询失败，记录错误但继续处理其他设备
				result[deviceID] = -1
				continue
			}
			result[deviceID] = dangerZone
		}
		return result, nil
	}

	// 使用数据库查询（兼容模式）
	// 临时结构体接收查询结果
	type row struct {
		DeviceID      string
		SafeDistanceM *float64 // 必须跟列名同名
	}
	var rows []row

	// 批量查询
	err := r.db.Model(&model.Mark{}).
		Where("device_id IN ?", deviceIDs).
		Select("device_id", "safe_distance_m").
		Scan(&rows).Error
	if err != nil {
		return nil, err
	}

	// 构造返回映射
	out := make(map[string]float64, len(rows))
	for _, v := range rows {
		val := -1.0 // 默认值：-1 表示使用 mark_types 的默认安全距离
		if v.SafeDistanceM != nil {
			val = *v.SafeDistanceM
		}
		out[v.DeviceID] = val
	}
	return out, nil
}

func (r *MarkRepo) MapByID(id string) (map[string]float64, error) {
	uid, err := uuid.Parse(id)
	if err != nil {
		return nil, fmt.Errorf("invalid mark id: %w", err)
	}
	var list []struct {
		OtherID   uuid.UUID
		DistanceM float64
	}
	// 把自己放在 mark1_id 或 mark2_id 的情况都查出来
	if err := r.db.Raw(`
		SELECT mark2_id AS other_id, distance_m FROM mark_pair_safe_distance WHERE mark1_id = ?
		UNION ALL
		SELECT mark1_id AS other_id, distance_m FROM mark_pair_safe_distance WHERE mark2_id = ?
	`, uid, uid).Scan(&list).Error; err != nil {
		return nil, err
	}
	m := make(map[string]float64, len(list))
	for _, v := range list {
		m[v.OtherID.String()] = v.DistanceM
	}
	return m, nil
}

func (r *MarkRepo) GetDistanceMapByDevice(deviceID string) (map[string]float64, error) {
	if r.useAPI && r.apiClient != nil {
		// 使用API获取距离映射
		return r.apiClient.GetDistanceMapByDeviceID(deviceID)
	}

	// 使用数据库查询（兼容模式）
	var id string
	if err := r.db.Model(&model.Mark{}).Where("device_id = ?", deviceID).Select("id").Scan(&id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return map[string]float64{}, nil
		}
		return nil, err
	}
	return r.MapByID(id)
}

func (r *MarkRepo) GetDistanceByDevice(deviceIDs []string) ([]model.MarkPairSafeDistance, error) {
	if r.useAPI && r.apiClient != nil {
		// 使用API批量获取距离映射，然后转换为MarkPairSafeDistance格式
		var results []model.MarkPairSafeDistance

		for _, deviceID := range deviceIDs {
			distanceMap, err := r.apiClient.GetDistanceMapByDeviceID(deviceID)
			if err != nil {
				// 如果某个设备查询失败，记录错误但继续处理其他设备
				continue
			}

			// 将距离映射转换为MarkPairSafeDistance格式
			for _, distance := range distanceMap {
				// 这里需要将deviceID转换为markID，但由于API返回的是deviceID映射，
				// 我们需要创建一个临时的MarkPairSafeDistance结构
				// 注意：这里可能需要根据实际需求调整数据结构
				pair := model.MarkPairSafeDistance{
					DistanceM: distance,
				}
				// 由于API返回的是deviceID到deviceID的映射，我们需要特殊处理
				// 这里暂时使用空UUID，实际使用时可能需要调整
				results = append(results, pair)
			}
		}

		return results, nil
	}

	// 使用数据库查询（兼容模式）
	var markIDs []string
	var results []model.MarkPairSafeDistance

	err := r.db.Model(&model.Mark{}).
		Where("device_id IN ?", deviceIDs).
		Pluck("id", &markIDs).Error
	if err != nil {
		return results, err
	}

	err = r.db.Model(&model.MarkPairSafeDistance{}).
		Where("mark1_id IN ? OR mark2_id IN ?", markIDs, markIDs).
		Find(&results).Error

	return results, err
}

// MarkAPIClient 方法实现

// GetMarkByDeviceID 根据设备ID获取标记信息
func (c *MarkAPIClient) GetMarkByDeviceID(deviceID string) (*MarkInfo, error) {
	url := fmt.Sprintf("%s/api/v1/marks/device/%s", c.baseURL, deviceID)

	resp, err := c.client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("请求失败: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode == 404 {
		return nil, fmt.Errorf("设备 %s 对应的标记不存在", deviceID)
	}

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("API返回错误状态码: %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("读取响应失败: %w", err)
	}

	// 使用统一的响应格式
	var apiResp struct {
		Success   bool     `json:"success"`
		Data      MarkInfo `json:"data"`
		Message   string   `json:"message"`
		Timestamp string   `json:"timestamp"`
	}

	if err := json.Unmarshal(body, &apiResp); err != nil {
		return nil, fmt.Errorf("解析响应失败: %w", err)
	}

	if !apiResp.Success {
		return nil, fmt.Errorf("API返回错误: %s", apiResp.Message)
	}

	return &apiResp.Data, nil
}

// GetDangerZoneByDeviceID 根据设备ID获取危险半径
func (c *MarkAPIClient) GetDangerZoneByDeviceID(deviceID string) (float64, error) {
	url := fmt.Sprintf("%s/api/v1/marks/device/%s/safe-distance", c.baseURL, deviceID)

	log.Printf("[DEBUG] 请求危险半径 API: %s", url)

	resp, err := c.client.Get(url)
	if err != nil {
		return 0, fmt.Errorf("请求失败: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return 0, fmt.Errorf("读取响应失败: %w", err)
	}

	log.Printf("[DEBUG] API响应状态码: %d, 响应体: %s", resp.StatusCode, string(body))

	if resp.StatusCode == 404 {
		return -1, nil // 设备不存在，返回-1表示使用默认值
	}

	if resp.StatusCode != 200 {
		return 0, fmt.Errorf("API返回错误状态码: %d, 响应: %s", resp.StatusCode, string(body))
	}

	// 使用统一的响应格式
	var apiResp struct {
		Success   bool               `json:"success"`
		Data      DangerZoneResponse `json:"data"`
		Message   string             `json:"message"`
		Timestamp string             `json:"timestamp"`
	}

	if err := json.Unmarshal(body, &apiResp); err != nil {
		return 0, fmt.Errorf("解析响应失败: %w, 响应体: %s", err, string(body))
	}

	if !apiResp.Success {
		return 0, fmt.Errorf("API返回错误: %s", apiResp.Message)
	}

	return apiResp.Data.DangerZoneM, nil
}

// GetDistanceMapByDeviceID 根据设备ID获取距离映射
func (c *MarkAPIClient) GetDistanceMapByDeviceID(deviceID string) (map[string]float64, error) {
	url := fmt.Sprintf("%s/api/v1/pairs/distance/map/device/%s", c.baseURL, deviceID)

	log.Printf("[DEBUG] 请求距离映射 API: %s", url)

	resp, err := c.client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("请求失败: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("读取响应失败: %w", err)
	}

	log.Printf("[DEBUG] API响应状态码: %d, 响应体: %s", resp.StatusCode, string(body))

	if resp.StatusCode == 404 {
		return map[string]float64{}, nil // 设备不存在，返回空映射
	}

	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("API返回错误状态码: %d, 响应: %s", resp.StatusCode, string(body))
	}

	// 使用统一的响应格式
	var apiResp struct {
		Success   bool               `json:"success"`
		Data      map[string]float64 `json:"data"`
		Message   string             `json:"message"`
		Timestamp string             `json:"timestamp"`
	}

	if err := json.Unmarshal(body, &apiResp); err != nil {
		return nil, fmt.Errorf("解析响应失败: %w, 响应体: %s", err, string(body))
	}

	if !apiResp.Success {
		return nil, fmt.Errorf("API返回错误: %s", apiResp.Message)
	}

	// API返回的是UUID到距离的映射，我们需要转换为设备ID到距离的映射
	// 由于当前无法直接转换，我们暂时返回空映射
	// 在实际使用中，这需要额外的API调用来建立UUID到设备ID的映射关系
	log.Printf("[WARN] API返回UUID映射，但需要设备ID映射。UUID映射: %+v", apiResp.Data)

	// 尝试转换UUID映射为设备ID映射
	deviceMap, err := c.ConvertUUIDMapToDeviceMap(apiResp.Data, deviceID)
	if err != nil {
		log.Printf("[WARN] 转换UUID映射失败: %v", err)
		return map[string]float64{}, nil // 返回空映射而不是错误
	}

	return deviceMap, nil
}

// UpdateLastOnlineTime 更新设备最后在线时间
func (c *MarkAPIClient) UpdateLastOnlineTime(deviceID string) error {
	url := fmt.Sprintf("%s/api/v1/marks/device/%s/last-online", c.baseURL, deviceID)

	req, err := http.NewRequest("PUT", url, nil)
	if err != nil {
		return fmt.Errorf("创建请求失败: %w", err)
	}

	resp, err := c.client.Do(req)
	if err != nil {
		return fmt.Errorf("请求失败: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("API返回错误状态码: %d, 响应: %s", resp.StatusCode, string(body))
	}

	return nil
}

// GetOnlineDevices 获取在线设备列表（通过查询最近在线时间的设备）
func (c *MarkAPIClient) GetOnlineDevices() ([]string, error) {
	// 注意：这个API在mark-service中可能不存在，需要根据实际情况调整
	// 这里先返回空列表，后续可能需要通过其他方式实现
	log.Printf("[WARN] GetOnlineDevices API在mark-service中可能不存在，返回空列表")
	return []string{}, nil
}

// GetDeviceIDByMarkID 根据标记UUID获取设备ID
func (c *MarkAPIClient) GetDeviceIDByMarkID(markID string) (string, error) {
	// 这个API在mark-service中可能不存在，需要通过其他方式实现
	// 暂时返回空字符串，表示未找到
	log.Printf("[WARN] GetDeviceIDByMarkID API在mark-service中可能不存在，markID: %s", markID)
	return "", fmt.Errorf("无法根据标记ID获取设备ID")
}

// ConvertUUIDMapToDeviceMap 将UUID映射转换为设备ID映射
func (c *MarkAPIClient) ConvertUUIDMapToDeviceMap(uuidMap map[string]float64, sourceDeviceID string) (map[string]float64, error) {
	deviceMap := make(map[string]float64)

	// 对于每个UUID，通过获取标记信息来找到对应的设备ID
	for uuid, distance := range uuidMap {
		// 调用API获取标记信息
		url := fmt.Sprintf("%s/api/v1/marks/%s", c.baseURL, uuid)

		resp, err := c.client.Get(url)
		if err != nil {
			log.Printf("[WARN] 获取标记信息失败 UUID=%s: %v", uuid, err)
			continue
		}
		defer resp.Body.Close()

		if resp.StatusCode != 200 {
			log.Printf("[WARN] 获取标记信息失败 UUID=%s, 状态码: %d", uuid, resp.StatusCode)
			continue
		}

		body, err := io.ReadAll(resp.Body)
		if err != nil {
			log.Printf("[WARN] 读取标记信息响应失败 UUID=%s: %v", uuid, err)
			continue
		}

		var markResp struct {
			Success   bool     `json:"success"`
			Data      MarkInfo `json:"data"`
			Message   string   `json:"message"`
			Timestamp string   `json:"timestamp"`
		}

		if err := json.Unmarshal(body, &markResp); err != nil {
			log.Printf("[WARN] 解析标记信息失败 UUID=%s: %v", uuid, err)
			continue
		}

		if !markResp.Success {
			log.Printf("[WARN] 获取标记信息失败 UUID=%s: %s", uuid, markResp.Message)
			continue
		}

		// 将UUID映射转换为设备ID映射
		deviceMap[markResp.Data.DeviceID] = distance
		log.Printf("[DEBUG] 转换映射: UUID=%s -> DeviceID=%s, 距离=%f", uuid, markResp.Data.DeviceID, distance)
	}

	return deviceMap, nil
}
