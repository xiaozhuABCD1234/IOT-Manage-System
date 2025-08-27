// service/mark_service.go
package service

import (
	"time"

	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
)

// CreateMark 创建标记
// CreateMark 创建标记（已做重复性校验）
func (s *markService) CreateMark(mark *model.MarkRequest) error {
	// 1. 先判断 device_id 是否已存在
	exist, err := s.repo.IsDeviceIDExists(mark.DeviceID)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	if exist {
		// return errs.ErrDuplicate.WithMsg("设备ID已存在")
		return errs.AlreadyExists("DeviceID", "设备ID已存在")
	}

	// 2. 判断 mark_name 是否已存在
	exist, err = s.repo.IsMarkNameExists(mark.MarkName)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	if exist {
		return errs.AlreadyExists("MarkName", "标记名称已存在")
	}

	// 3. 解析默认值
	persistMQTT := false
	if mark.PersistMQTT != nil {
		persistMQTT = *mark.PersistMQTT
	}

	dbMark := model.Mark{
		DeviceID:      mark.DeviceID,
		MarkName:      mark.MarkName,
		MqttTopic:     mark.MqttTopic,
		PersistMQTT:   persistMQTT,
		SafeDistanceM: mark.SafeDistanceM,
		MarkTypeID:    1, // 默认值
	}

	if mark.MarkTypeID != nil {
		dbMark.MarkTypeID = *mark.MarkTypeID
	}

	// 4. 创建标记并处理标签
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
	var responses []model.MarkResponse
	for _, mark := range marks {
		responses = append(responses, *s.convertToMarkResponse(&mark))
	}
	if len(responses) == 0 {
		return nil, total, errs.NotFound("Marks", "未找到相关标记")
	}

	return responses, total, nil
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
		m.MqttTopic = *req.MqttTopic
	}
	if req.PersistMQTT != nil {
		m.PersistMQTT = *req.PersistMQTT
	}
	if req.SafeDistanceM != nil {
		m.SafeDistanceM = req.SafeDistanceM
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
		ID:            mark.ID,
		DeviceID:      mark.DeviceID,
		MarkName:      mark.MarkName,
		MqttTopic:     mark.MqttTopic,
		PersistMQTT:   mark.PersistMQTT,
		SafeDistanceM: mark.SafeDistanceM,
		CreatedAt:     mark.CreatedAt,
		UpdatedAt:     mark.UpdatedAt,
		LastOnlineAt:  mark.LastOnlineAt,
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
