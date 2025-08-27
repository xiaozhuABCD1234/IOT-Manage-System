// handler/tag_handler.go
package handler

import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
	// "IOT-Manage-System/mark-service/service"
	"IOT-Manage-System/mark-service/utils"

	"github.com/gofiber/fiber/v2"
)

func (h *MarkHandler) CreateMarkTag(c *fiber.Ctx) error {
	req := new(model.MarkTagRequest)
	if err := c.BodyParser(req); err != nil {
		return errs.ErrInvalidInput.WithDetails(err)
	}

	appErr := h.markService.CreateMarkTag(req)
	if appErr != nil {
		return appErr
	}

	return utils.SendCreatedResponse(c, nil, "标签创建成功")
}

func (h *MarkHandler) GetMarkTagByID(c *fiber.Ctx) error {
	tagID := c.Params("tag_id")
	if tagID == "" {
		return errs.ErrInvalidInput.WithDetails("tag_id 不能为空")
	}
	tagIDInt, err := utils.ParsePositiveInt(tagID)
	if err != nil {
		return errs.ErrInvalidInput.WithDetails("tag_id 必须是正整数")
	}
	tag, err := h.markService.GetMarkTagByID(tagIDInt)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, tag)
}

// ListMarkTags 分页获取标签列表
func (h *MarkHandler) ListMarkTags(c *fiber.Ctx) error {
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 10)

	if page <= 0 || limit <= 0 {
		return errs.ErrInvalidInput.WithDetails("page 和 limit 必须大于 0")
	}

	tags, total, appErr := h.markService.ListMarkTags(page, limit)
	if appErr != nil {
		return appErr
	}

	return utils.SendPaginatedResponse(c, tags, total, page, limit)
}

// GetMarkTagByName 根据名称获取标签
func (h *MarkHandler) GetMarkTagByName(c *fiber.Ctx) error {
	name := c.Params("tag_name")
	if name == "" {
		return errs.ErrInvalidInput.WithDetails("tag_name 不能为空")
	}

	tag, appErr := h.markService.GetMarkTagByName(name)
	if appErr != nil {
		return appErr
	}

	return utils.SendSuccessResponse(c, tag)
}

// UpdateMarkTag 更新标签
func (h *MarkHandler) UpdateMarkTag(c *fiber.Ctx) error {
	req := new(model.MarkTagRequest)
	if err := c.BodyParser(req); err != nil {
		return errs.ErrInvalidInput.WithDetails(err)
	}

	if req.TagName == "" {
		return errs.ErrInvalidInput.WithDetails("TagName 不能为空")
	}

	appErr := h.markService.UpdateMarkTag(req)
	if appErr != nil {
		return appErr
	}

	return utils.SendSuccessResponse(c, nil, "标签更新成功")
}

// DeleteMarkTag 删除标签
func (h *MarkHandler) DeleteMarkTag(c *fiber.Ctx) error {
	tagID := c.Params("tag_id")
	if tagID == "" {
		return errs.ErrInvalidInput.WithDetails("tag_id 不能为空")
	}
	tagIDInt, err := utils.ParsePositiveInt(tagID)
	if err != nil {
		return errs.ErrInvalidInput.WithDetails("tag_id 必须是正整数")
	}

	appErr := h.markService.DeleteMarkTag(tagIDInt)
	if appErr != nil {
		return appErr
	}

	return utils.SendSuccessResponse(c, nil, "标签删除成功")
}

// GetMarksByTagID 根据标签ID获取标记列表（分页）
func (h *MarkHandler) GetMarksByTagID(c *fiber.Ctx) error {
	tagID := c.Params("tag_id")
	if tagID == "" {
		return errs.ErrInvalidInput.WithDetails("tag_id 不能为空")
	}
	tagIDInt, err := utils.ParsePositiveInt(tagID)
	if err != nil {
		return errs.ErrInvalidInput.WithDetails("tag_id 必须是正整数")
	}
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 10)
	preload := c.Query("preload", "false") == "true"

	marks, total, appErr := h.markService.GetMarksByTagID(tagIDInt, page, limit, preload)
	if appErr != nil {
		return appErr
	}

	return utils.SendPaginatedResponse(c, marks, total, page, limit)
}

func (h *MarkHandler) GetMarksByTagName(c *fiber.Ctx) error {
	name := c.Params("tag_name")
	if name == "" {
		return errs.ErrInvalidInput.WithDetails("tag_name 不能为空")
	}
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 10)
	preload := c.Query("preload", "false") == "true"

	marks, total, appErr := h.markService.GetMarksByTagName(name, page, limit, preload)
	if appErr != nil {
		return appErr
	}

	return utils.SendPaginatedResponse(c, marks, total, page, limit)
}
