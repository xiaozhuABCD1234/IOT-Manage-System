// service/marktype_service.go
package service

import (
	"IOT-Manage-System/mark-service/model"
)

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
	return &model.MarkTypeResponse{
		ID:       markType.ID,
		TypeName: markType.TypeName,
	}, nil
}

// GetMarkTypeByName 根据名称获取标记类型
func (s *markService) GetMarkTypeByName(name string) (*model.MarkTypeResponse, error) {
	markType, err := s.repo.GetMarkTypeByName(name)
	if err != nil {
		return nil, err
	}

	// 转换为响应模型
	return &model.MarkTypeResponse{
		ID:       markType.ID,
		TypeName: markType.TypeName,
	}, nil
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
		responses = append(responses, model.MarkTypeResponse{
			ID:       mt.ID,
			TypeName: mt.TypeName,
		})
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
