// service/marktag_service.go
package service

import (
	"IOT-Manage-System/mark-service/model"
)

// CreateMarkTag 创建标记标签
func (s *markService) CreateMarkTag(mt *model.MarkTagRequest) error {
	// 将请求模型转换为数据库模型
	markTag := model.MarkTag{
		TagName: mt.TagName,
	}

	return s.repo.CreateMarkTag(&markTag)
}

// GetMarkTagByID 根据ID获取标记标签
func (s *markService) GetMarkTagByID(id int) (*model.MarkTagResponse, error) {
	markTag, err := s.repo.GetMarkTagByID(id)
	if err != nil {
		return nil, err
	}

	// 转换为响应模型
	return &model.MarkTagResponse{
		ID:      markTag.ID,
		TagName: markTag.TagName,
	}, nil
}

// GetMarkTagByName 根据名称获取标记标签
func (s *markService) GetMarkTagByName(name string) (*model.MarkTagResponse, error) {
	markTag, err := s.repo.GetMarkTagByName(name)
	if err != nil {
		return nil, err
	}

	// 转换为响应模型
	return &model.MarkTagResponse{
		ID:      markTag.ID,
		TagName: markTag.TagName,
	}, nil
}

// ListMarkTags 获取标记标签列表（分页），并返回总记录数
func (s *markService) ListMarkTags(page, limit int) ([]model.MarkTagResponse, int64, error) {
	offset := (page - 1) * limit
	markTags, total, err := s.repo.ListMarkTagsWithCount(offset, limit)
	if err != nil {
		return nil, 0, err
	}

	// 转换为响应模型列表
	var responses []model.MarkTagResponse
	for _, mt := range markTags {
		responses = append(responses, model.MarkTagResponse{
			ID:      mt.ID,
			TagName: mt.TagName,
		})
	}

	return responses, total, nil
}

// UpdateMarkTag 更新标记标签
func (s *markService) UpdateMarkTag(tag *model.MarkTagRequest) error {
	// 首先获取现有记录
	existingTag, err := s.repo.GetMarkTagByName(tag.TagName)
	if err != nil {
		return err
	}

	// 更新字段
	existingTag.TagName = tag.TagName

	return s.repo.UpdateMarkTag(existingTag)
}

// DeleteMarkTag 删除标记标签
func (s *markService) DeleteMarkTag(id int) error {
	return s.repo.DeleteMarkTag(id)
}
