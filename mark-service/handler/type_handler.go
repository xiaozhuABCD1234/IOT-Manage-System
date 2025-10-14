// handler/type_handler.go
package handler

import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
	"IOT-Manage-System/mark-service/utils"

	"github.com/gofiber/fiber/v2"
)

// CreateMarkType 创建标记类型
func (h *MarkHandler) CreateMarkType(c *fiber.Ctx) error {
	req := new(model.MarkTypeCreateRequest)
	if err := c.BodyParser(req); err != nil {
		return errs.ErrInvalidInput.WithDetails(err)
	}

	appErr := h.markService.CreateMarkType(req)
	if appErr != nil {
		return appErr
	}

	return utils.SendCreatedResponse(c, nil, "标记类型创建成功")
}

// GetMarkTypeByID 根据 ID 获取标记类型
func (h *MarkHandler) GetMarkTypeByID(c *fiber.Ctx) error {
	typeID := c.Params("type_id")
	if typeID == "" {
		return errs.ErrInvalidInput.WithDetails("type_id 不能为空")
	}
	typeIDInt, err := utils.ParsePositiveInt(typeID)
	if err != nil {
		return errs.ErrInvalidInput.WithDetails("type_id 必须是正整数")
	}

	typ, appErr := h.markService.GetMarkTypeByID(typeIDInt)
	if appErr != nil {
		return appErr
	}

	return utils.SendSuccessResponse(c, typ)
}

// ListMarkTypes 分页获取标记类型列表
func (h *MarkHandler) ListMarkTypes(c *fiber.Ctx) error {
	// 分页参数
	page := c.QueryInt("page", 1)
	if page < 1 {
		page = 1
	}
	limit := c.QueryInt("limit", 10)
	if limit < 1 {
		limit = 10
	}
	if limit > 100 {
		limit = 100 // 限制最大值
	}

	if page <= 0 || limit <= 0 {
		return errs.ErrInvalidInput.WithDetails("page 和 limit 必须大于 0")
	}

	types, total, appErr := h.markService.ListMarkTypes(page, limit)
	if appErr != nil {
		return appErr
	}

	return utils.SendPaginatedResponse(c, types, total, page, limit)
}

// GetMarkTypeByName 根据名称获取标记类型
func (h *MarkHandler) GetMarkTypeByName(c *fiber.Ctx) error {
	name := c.Params("type_name")
	if name == "" {
		return errs.ErrInvalidInput.WithDetails("type_name 不能为空")
	}

	typ, appErr := h.markService.GetMarkTypeByName(name)
	if appErr != nil {
		return appErr
	}

	return utils.SendSuccessResponse(c, typ)
}

// UpdateMarkType 更新标记类型
func (h *MarkHandler) UpdateMarkType(c *fiber.Ctx) error {
	typeID := c.Params("type_id")
	if typeID == "" {
		return errs.ErrInvalidInput.WithDetails("type_id 不能为空")
	}
	typeIDInt, err := utils.ParsePositiveInt(typeID)
	if err != nil {
		return errs.ErrInvalidInput.WithDetails("type_id 必须是正整数")
	}

	req := new(model.MarkTypeUpdateRequest)
	if err := c.BodyParser(req); err != nil {
		return errs.ErrInvalidInput.WithDetails(err.Error())
	}

	// 4. 调用服务层（签名已对齐）
	if appErr := h.markService.UpdateMarkType(typeIDInt, req); appErr != nil {
		return appErr
	}

	return utils.SendSuccessResponse(c, nil, "标记类型更新成功")
}

// DeleteMarkType 删除标记类型
func (h *MarkHandler) DeleteMarkType(c *fiber.Ctx) error {
	typeID := c.Params("type_id")
	if typeID == "" {
		return errs.ErrInvalidInput.WithDetails("type_id 不能为空")
	}
	typeIDInt, err := utils.ParsePositiveInt(typeID)
	if err != nil {
		return errs.ErrInvalidInput.WithDetails("type_id 必须是正整数")
	}

	appErr := h.markService.DeleteMarkType(typeIDInt)
	if appErr != nil {
		return appErr
	}

	return utils.SendSuccessResponse(c, nil, "标记类型删除成功")
}

// GetMarksByTypeID 根据类型 ID 获取标记列表（分页）
func (h *MarkHandler) GetMarksByTypeID(c *fiber.Ctx) error {
	typeID := c.Params("type_id")
	if typeID == "" {
		return errs.ErrInvalidInput.WithDetails("type_id 不能为空")
	}
	typeIDInt, err := utils.ParsePositiveInt(typeID)
	if err != nil {
		return errs.ErrInvalidInput.WithDetails("type_id 必须是正整数")
	}
	// 分页参数
	page := c.QueryInt("page", 1)
	if page < 1 {
		page = 1
	}
	limit := c.QueryInt("limit", 10)
	if limit < 1 {
		limit = 10
	}
	if limit > 100 {
		limit = 100 // 限制最大值
	}
	preload := c.Query("preload", "false") == "true"

	marks, total, appErr := h.markService.GetMarksByTypeID(typeIDInt, page, limit, preload)
	if appErr != nil {
		return appErr
	}

	return utils.SendPaginatedResponse(c, marks, total, page, limit)
}

// GetMarksByTypeName 根据类型名称获取标记列表（分页）
func (h *MarkHandler) GetMarksByTypeName(c *fiber.Ctx) error {
	name := c.Params("type_name")
	if name == "" {
		return errs.ErrInvalidInput.WithDetails("type_name 不能为空")
	}
	// 分页参数
	page := c.QueryInt("page", 1)
	if page < 1 {
		page = 1
	}
	limit := c.QueryInt("limit", 10)
	if limit < 1 {
		limit = 10
	}
	if limit > 100 {
		limit = 100 // 限制最大值
	}
	preload := c.Query("preload", "false") == "true"

	marks, total, appErr := h.markService.GetMarksByTypeName(name, page, limit, preload)
	if appErr != nil {
		return appErr
	}

	return utils.SendPaginatedResponse(c, marks, total, page, limit)
}

// GetAllTypeIDToName 获取所有类型ID到类型名称的映射
func (h *MarkHandler) GetAllTypeIDToName(c *fiber.Ctx) error {
	resp, err := h.markService.GetAllTypeIDToName()
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}
