// service/marktag_service.go
package service

import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
)

// CreateMarkTag 创建标记标签
func (s *markService) CreateMarkTag(mt *model.MarkTagRequest) error {
	// 简单输入校验
	if mt.TagName == "" {
		return errs.ErrInvalidInput.WithDetails("TagName 不能为空")
	}

	// 判断是否已存在同名标签
	if _, err := s.repo.GetMarkTagByName(mt.TagName); err == nil {
		return errs.AlreadyExists("MARK_TAG", "标签名称已存在")
	}

	markTag := model.MarkTag{TagName: mt.TagName}
	if err := s.repo.CreateMarkTag(&markTag); err != nil {
		return errs.ErrDatabase.WithDetails(err)
	}
	return nil
}

// GetMarkTagByID 根据ID获取标记标签
func (s *markService) GetMarkTagByID(id int) (*model.MarkTagResponse, error) {
	markTag, err := s.repo.GetMarkTagByID(id)
	if err != nil {
		return nil, errs.NotFound("MARK_TAG", "标签不存在", err)
	}
	return &model.MarkTagResponse{
		ID:      markTag.ID,
		TagName: markTag.TagName,
	}, nil
}

// GetMarkTagByName 根据名称获取标记标签
func (s *markService) GetMarkTagByName(name string) (*model.MarkTagResponse, error) {
	markTag, err := s.repo.GetMarkTagByName(name)
	if err != nil {
		return nil, errs.NotFound("MARK_TAG", "标签不存在", err)
	}
	return &model.MarkTagResponse{
		ID:      markTag.ID,
		TagName: markTag.TagName,
	}, nil
}

// ListMarkTags 获取标记标签列表（分页），并返回总记录数
func (s *markService) ListMarkTags(page, limit int) ([]model.MarkTagResponse, int64, error) {
	if page <= 0 || limit <= 0 {
		return nil, 0, errs.ErrInvalidInput.WithDetails("page 和 limit 必须大于 0")
	}
	offset := (page - 1) * limit
	markTags, total, err := s.repo.ListMarkTagsWithCount(offset, limit)
	if err != nil {
		return nil, 0, errs.ErrDatabase.WithDetails(err)
	}

	responses := make([]model.MarkTagResponse, 0, len(markTags))
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
	if tag.TagName == "" {
		return errs.ErrInvalidInput.WithDetails("TagName 不能为空")
	}
	// 根据名称找到要更新的记录
	existingTag, err := s.repo.GetMarkTagByName(tag.TagName)
	if err != nil {
		return errs.NotFound("MARK_TAG", "待更新标签不存在", err)
	}
	existingTag.TagName = tag.TagName
	if err := s.repo.UpdateMarkTag(existingTag); err != nil {
		return errs.ErrDatabase.WithDetails(err)
	}
	return nil
}

// DeleteMarkTag 删除标记标签
func (s *markService) DeleteMarkTag(id int) error {
	if err := s.repo.DeleteMarkTag(id); err != nil {
		return errs.ErrDatabase.WithDetails(err)
	}
	return nil
}

// GetMarksByTagID 根据标签ID获取标记列表（分页）
func (s *markService) GetMarksByTagID(tagID int, page, limit int, preload bool) ([]model.MarkResponse, int64, error) {
	offset := (page - 1) * limit
	marks, total, err := s.repo.GetMarksByTagID(tagID, preload, offset, limit)
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

func (s *markService) GetMarksByTagName(tagName string, page, limit int, preload bool) ([]model.MarkResponse, int64, error) {
	offset := (page - 1) * limit
	marks, total, err := s.repo.GetMarksByTagName(tagName, preload, offset, limit)
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
