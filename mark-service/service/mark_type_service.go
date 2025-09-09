// service/mark_type_service.go
package service

import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
)

// 转换为响应模型
func (s *markService) convertToMarkTypeResponse(markType *model.MarkType) *model.MarkTypeResponse {
	if markType == nil {
		return nil
	}
	return &model.MarkTypeResponse{
		ID:                   markType.ID,
		TypeName:             markType.TypeName,
		DefaultSafeDistanceM: markType.DefaultSafeDistanceM,
	}
}

// CreateMarkType 创建标记类型
func (s *markService) CreateMarkType(mt *model.MarkTypeCreateRequest) error {
	// 将请求模型转换为数据库模型
	markType := model.MarkType{
		TypeName:             mt.TypeName,
		DefaultSafeDistanceM: mt.DefaultSafeDistanceM,
	}

	return s.repo.CreateMarkType(&markType)
}

// GetMarkTypeByID 根据ID获取标记类型
func (s *markService) GetMarkTypeByID(id int) (*model.MarkTypeResponse, error) {
	markType, err := s.repo.GetMarkTypeByID(id)
	if err != nil {
		return nil, err
	}

	// 转换为响应模型
	return s.convertToMarkTypeResponse(markType), nil
}

// GetMarkTypeByName 根据名称获取标记类型
func (s *markService) GetMarkTypeByName(name string) (*model.MarkTypeResponse, error) {
	markType, err := s.repo.GetMarkTypeByName(name)
	if err != nil {
		return nil, err
	}

	// 转换为响应模型
	return s.convertToMarkTypeResponse(markType), nil
}

// ListMarkTypes 获取标记类型列表（分页）
func (s *markService) ListMarkTypes(page, limit int) ([]model.MarkTypeResponse, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit <= 0 || limit > 200 {
		limit = 20
	}
	offset := (page - 1) * limit
	markTypes, total, err := s.repo.ListMarkTypesWithCount(offset, limit)
	if err != nil {
		return nil, 0, err
	}

	// 转换为响应模型列表
	responses := make([]model.MarkTypeResponse, 0, len(markTypes))
	for _, mt := range markTypes {
		responses = append(responses, *s.convertToMarkTypeResponse(&mt))
	}

	return responses, total, nil
}

// UpdateMarkType 仅更新非空字段
func (s *markService) UpdateMarkType(typeID int, req *model.MarkTypeUpdateRequest) error {
	// 1. 按 ID 拿记录
	mt, err := s.repo.GetMarkTypeByID(typeID)
	if err != nil {
		return err
	}
	if mt == nil {
		return errs.ErrResourceNotFound
	}
	if req.TypeName != nil && *req.TypeName != mt.TypeName {
		exist, err := s.repo.IsMarkNameExists(*req.TypeName)
		if err == nil && exist != false {
			return errs.ErrResourceConflict
		}
	}

	// 2. 仅更新传过来的字段
	if req.TypeName != nil {
		mt.TypeName = *req.TypeName
	}
	if req.DefaultSafeDistanceM != nil {
		mt.DefaultSafeDistanceM = req.DefaultSafeDistanceM
	}

	// 3. 入库
	return s.repo.UpdateMarkType(mt)
}

// DeleteMarkType 删除标记类型
func (s *markService) DeleteMarkType(id int) error {
	return s.repo.DeleteMarkType(id)
}

func (s *markService) GetMarksByTypeID(typeID int, page, limit int, preload bool) ([]model.MarkResponse, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit <= 0 || limit > 200 {
		limit = 20
	}
	offset := (page - 1) * limit
	marks, total, err := s.repo.GetMarksByTypeID(typeID, preload, offset, limit)
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

func (s *markService) GetMarksByTypeName(typeName string, page, limit int, preload bool) ([]model.MarkResponse, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit <= 0 || limit > 200 {
		limit = 20
	}
	offset := (page - 1) * limit
	marks, total, err := s.repo.GetMarksByTypeName(typeName, preload, offset, limit)
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
