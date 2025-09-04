// service/mark_type_service.go
package service

import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
)

// 转换为响应模型
func (s *markService) convertToMarkTypeResponse(markType *model.MarkType) *model.MarkTypeResponse {
	return &model.MarkTypeResponse{
		ID:       markType.ID,
		TypeName: markType.TypeName,
	}
}

// CreateMarkType 创建标记类型
func (s *markService) CreateMarkType(mt *model.MarkTypeRequest) error {
	// 将请求模型转换为数据库模型
	markType := model.MarkType{
		TypeName: mt.TypeName,
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
	offset := (page - 1) * limit
	markTypes, total, err := s.repo.ListMarkTypesWithCount(offset, limit)
	if err != nil {
		return nil, 0, err
	}

	// 转换为响应模型列表
	var responses []model.MarkTypeResponse
	for _, mt := range markTypes {
		responses = append(responses, *s.convertToMarkTypeResponse(&mt))
	}

	return responses, total, nil
}

// UpdateMarkType 更新标记类型
func (s *markService) UpdateMarkType(mt *model.MarkTypeRequest) error {
	// 首先获取现有记录
	existingType, err := s.repo.GetMarkTypeByName(mt.TypeName)
	if err != nil {
		return err
	}

	// 更新字段
	existingType.TypeName = mt.TypeName

	return s.repo.UpdateMarkType(existingType)
}

// DeleteMarkType 删除标记类型
func (s *markService) DeleteMarkType(id int) error {
	return s.repo.DeleteMarkType(id)
}

func (s *markService) GetMarksByTypeID(typeID int, page, limit int, preload bool) ([]model.MarkResponse, int64, error) {
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
	offset := (page - 1) * limit
	marks, total, err := s.repo.GetMarksByTagName(typeName, preload, offset, limit)
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
