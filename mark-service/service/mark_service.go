// service/mark_service.go
package service

import (
	"time"

	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
)

// CreateMark 创建标记（已做重复性校验）
func (s *markService) CreateMark(mark *model.MarkRequest) error {
	// 1. 设备 ID 重复检查
	exist, err := s.repo.IsDeviceIDExists(mark.DeviceID)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	if exist {
		return errs.AlreadyExists("DeviceID", "设备ID已存在")
	}

	// 2. 名称重复检查
	exist, err = s.repo.IsMarkNameExists(mark.MarkName)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	if exist {
		return errs.AlreadyExists("MarkName", "标记名称已存在")
	}

	// 3. 解析指针默认值
	persistMQTT := false
	if mark.PersistMQTT != nil {
		persistMQTT = *mark.PersistMQTT
	}

	// 4. 确定要使用的类型 ID
	markTypeID := 1 // 默认类型
	if mark.MarkTypeID != nil {
		markTypeID = *mark.MarkTypeID
	}

	// 5. 如果 SafeDistanceM 为空，取类型默认值
	safeDistance := mark.SafeDistanceM
	if safeDistance == nil || *safeDistance < 0 { // nil 或显式负值都视为“空”
		typ, err := s.repo.GetMarkTypeByID(markTypeID)
		if err != nil {
			return errs.ErrDatabase.WithDetails("获取MarkType失败: " + err.Error())
		}
		if typ.DefaultSafeDistanceM != nil {
			safeDistance = typ.DefaultSafeDistanceM
		} else {
			// 数据库也 NULL，给 0 或业务兜底值
			safeDistance = new(float64) // 0
		}
	}

	// 6. 组装持久化对象
	dbMark := model.Mark{
		DeviceID:      mark.DeviceID,
		MarkName:      mark.MarkName,
		MqttTopic:     mark.MqttTopic,
		PersistMQTT:   persistMQTT,
		SafeDistanceM: safeDistance,
		MarkTypeID:    markTypeID,
	}

	// 7. 入库并自动处理标签
	if err := s.repo.CreateMarkAutoTag(&dbMark, mark.Tags); err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}

	return nil
}

// GetMarkByID 根据ID获取标记
func (s *markService) GetMarkByID(id string, preload bool) (*model.MarkResponse, error) {
	mark, err := s.repo.GetMarkByID(id, preload)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	if mark == nil {
		return nil, errs.NotFound("Mark", "标记未找到")
	}

	return s.convertToMarkResponse(mark), nil
}

// GetMarkByDeviceID 根据设备ID获取标记
func (s *markService) GetMarkByDeviceID(deviceID string, preload bool) (*model.MarkResponse, error) {
	mark, err := s.repo.GetMarkByDeviceID(deviceID, preload)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	if mark == nil {
		return nil, errs.NotFound("Mark", "标记未找到")
	}

	return s.convertToMarkResponse(mark), nil
}

// ListMark 获取标记列表（分页）
func (s *markService) ListMark(page, limit int, preload bool) ([]model.MarkResponse, int64, error) {
	offset := (page - 1) * limit
	marks, total, err := s.repo.ListMarkWithCount(offset, limit, preload)
	if err != nil {
		return nil, 0, errs.ErrDatabase.WithDetails(err.Error())
	}

	// 转换为响应模型列表
	responses := make([]model.MarkResponse, 0, len(marks))
	for _, mark := range marks {
		responses = append(responses, *s.convertToMarkResponse(&mark))
	}

	return responses, total, nil
}

func (s *markService) fallbackSafeDistance(reqSafe *float64, markTypeID int) (*float64, error) {
	if reqSafe != nil && *reqSafe >= 0 { // 显式给出合法值，直接用它
		return reqSafe, nil
	}
	typ, err := s.repo.GetMarkTypeByID(markTypeID)
	if err != nil {
		return nil, err
	}
	if typ.DefaultSafeDistanceM != nil {
		return typ.DefaultSafeDistanceM, nil
	}
	zero := 0.0
	return &zero, nil
}

// UpdateMark 更新标记
func (s *markService) UpdateMark(ID string, req *model.MarkUpdateRequest) error {
	// 先拿到现有记录
	m, err := s.repo.GetMarkByID(ID, true)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	if m == nil {
		return errs.NotFound("Mark", "标记未找到")
	}
	// 按需更新 + 重复校验
	if req.MarkName != nil {
		// 判断新名字是否跟别人冲突
		if ok, _ := s.repo.IsMarkNameExists(*req.MarkName); ok && *req.MarkName != m.MarkName {
			return errs.AlreadyExists("MarkName", "标记名称已存在")
		}
		m.MarkName = *req.MarkName
	}

	if req.DeviceID != nil {
		// 判断新 DeviceID 是否跟别人冲突
		if ok, _ := s.repo.IsDeviceIDExists(*req.DeviceID); ok && *req.DeviceID != m.DeviceID {
			return errs.AlreadyExists("DeviceID", "设备ID已存在")
		}
		m.DeviceID = *req.DeviceID
	}

	if req.MqttTopic != nil {
		m.MqttTopic = req.MqttTopic
	}
	if req.PersistMQTT != nil {
		m.PersistMQTT = *req.PersistMQTT
	}
	if req.SafeDistanceM != nil || req.MarkTypeID != nil {
		newTypeID := m.MarkTypeID
		if req.MarkTypeID != nil {
			newTypeID = *req.MarkTypeID
		}
		fallback, err := s.fallbackSafeDistance(req.SafeDistanceM, newTypeID)
		if err != nil {
			return errs.ErrDatabase.WithDetails("获取默认安全距离失败: " + err.Error())
		}
		m.SafeDistanceM = fallback
	}
	if req.MarkTypeID != nil {
		m.MarkTypeID = *req.MarkTypeID
	}

	// 更新数据库（含标签）
	if err := s.repo.UpdateMark(m, req.Tags); err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	return nil
}

// DeleteMark 删除标记
func (s *markService) DeleteMark(id string) error {
	return s.repo.DeleteMark(id)
}

// UpdateMarkLastOnline 更新标记的最后在线时间
func (s *markService) UpdateMarkLastOnline(deviceID string, t time.Time) error {
	return s.repo.UpdateMarkLastOnline(deviceID, t)
}

// convertToMarkResponse 将数据库模型转换为响应模型
func (s *markService) convertToMarkResponse(mark *model.Mark) *model.MarkResponse {
	response := &model.MarkResponse{
		ID:           mark.ID.String(),
		DeviceID:     mark.DeviceID,
		MarkName:     mark.MarkName,
		MqttTopic:    mark.MqttTopic,
		PersistMQTT:  mark.PersistMQTT,
		DangerZoneM:  mark.SafeDistanceM,
		CreatedAt:    mark.CreatedAt,
		UpdatedAt:    mark.UpdatedAt,
		LastOnlineAt: mark.LastOnlineAt,
	}

	// 处理 MarkType
	if mark.MarkType.ID != 0 {
		response.MarkType = &model.MarkTypeResponse{
			ID:       mark.MarkType.ID,
			TypeName: mark.MarkType.TypeName,
		}
	}

	// 处理 Tags
	if len(mark.Tags) > 0 {
		var tagResponses []model.MarkTagResponse
		for _, tag := range mark.Tags {
			tagResponses = append(tagResponses, model.MarkTagResponse{
				ID:      tag.ID,
				TagName: tag.TagName,
			})
		}
		response.Tags = tagResponses
	}

	return response
}

// GetPersistMQTTByDeviceID 根据设备ID查询 PersistMQTT 字段的值
func (s *markService) GetPersistMQTTByDeviceID(deviceID string) (bool, error) {
	persist, err := s.repo.GetPersistMQTTByDeviceID(deviceID)
	if err != nil {
		return false, errs.ErrDatabase.WithDetails(err.Error())
	}
	return persist, nil
}

// GetMarksByPersistMQTT 根据 PersistMQTT 字段查询标记列表（分页）
func (s *markService) GetMarksByPersistMQTT(persist bool, page, limit int, preload bool) ([]model.MarkResponse, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit <= 0 || limit > 200 {
		limit = 20
	}
	offset := (page - 1) * limit

	marks, total, err := s.repo.GetMarksByPersistMQTT(persist, preload, offset, limit)
	if err != nil {
		return nil, 0, errs.ErrDatabase.WithDetails(err.Error())
	}

	if len(marks) == 0 {
		return nil, total, errs.NotFound("Marks", "未找到 PersistMQTT=%v 的标记", persist)
	}
	// 转换为响应模型
	var responses []model.MarkResponse
	for _, mark := range marks {
		responses = append(responses, *s.convertToMarkResponse(&mark))
	}

	return responses, total, nil
}

// GetDeviceIDsByPersistMQTT 根据 PersistMQTT 的值查询所有对应的 DeviceID 列表
func (s *markService) GetDeviceIDsByPersistMQTT(persist bool) ([]string, error) {
	deviceIDs, err := s.repo.GetDeviceIDsByPersistMQTT(persist)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return deviceIDs, nil
}

func (s *markService) GetAllDeviceIDToName() (map[string]string, error) {
	m, err := s.repo.GetAllMarkDeviceIDsAndNames()
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return m, nil
}

// GetAllMarkIDToName 获取所有标记ID到标记名称的映射
func (s *markService) GetAllMarkIDToName() (map[string]string, error) {
	m, err := s.repo.GetAllMarkIDsAndNames()
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return m, nil
}
