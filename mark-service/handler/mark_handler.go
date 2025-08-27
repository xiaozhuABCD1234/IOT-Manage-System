package handler

import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
	"IOT-Manage-System/mark-service/service"
	"IOT-Manage-System/mark-service/utils"

	"github.com/gofiber/fiber/v2"

	"time"
)

type MarkHandler struct {
	markService service.MarkService
}

func NewMarkHandler(markService service.MarkService) *MarkHandler {
	return &MarkHandler{markService: markService}
}

// CreateMark 创建新标签
func (h *MarkHandler) CreateMark(c *fiber.Ctx) error {
	var req model.MarkRequest
	if err := c.BodyParser(&req); err != nil {
		// 参数解析错误
		return errs.ErrInvalidInput
	}

	// 调用 Service
	if appErr := h.markService.CreateMark(&req); appErr != nil {
		return appErr
	}

	return utils.SendCreatedResponse(c, nil, "标记创建成功")
}

// GetMarkByID 根据 ID 获取标签
func (h *MarkHandler) GetMarkByID(c *fiber.Ctx) error {
	id := c.Params("id")
	preload := c.Query("preload", "false") == "true"
	mark, appErr := h.markService.GetMarkByID(id, preload)
	if appErr != nil {
		return appErr
	}
	return utils.SendSuccessResponse(c, mark)
}

// GetMarkByDeviceID 根据 DeviceID 获取标签
func (h *MarkHandler) GetMarkByDeviceID(c *fiber.Ctx) error {
	deviceID := c.Params("device_id")
	preload := c.Query("preload", "false") == "true"
	mark, appErr := h.markService.GetMarkByDeviceID(deviceID, preload)
	if appErr != nil {
		return appErr
	}
	return utils.SendSuccessResponse(c, mark)
}

// ListMark 列表查询，支持分页和预加载
func (h *MarkHandler) ListMark(c *fiber.Ctx) error {
	page := c.QueryInt("page", 1)
	limit := c.QueryInt("limit", 10)
	preload := c.Query("preload", "false") == "true"

	marks, total, appErr := h.markService.ListMark(page, limit, preload)
	if appErr != nil {
		return appErr
	}

	return utils.SendPaginatedResponse(c, marks, total, page, limit)
}

// UpdateMark 更新标签信息（支持部分更新）
func (h *MarkHandler) UpdateMark(c *fiber.Ctx) error {
	id := c.Params("id")
	var req model.MarkUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		// 参数解析错误
		return errs.ErrInvalidInput
	}

	// 调用 Service
	if appErr := h.markService.UpdateMark(id, &req); appErr != nil {
		return appErr
	}

	return utils.SendSuccessResponse(c, nil, "标记更新成功")
}

// DeleteMark 删除标签
func (h *MarkHandler) DeleteMark(c *fiber.Ctx) error {
	id := c.Params("id")

	// 调用 Service
	if appErr := h.markService.DeleteMark(id); appErr != nil {
		return appErr
	}

	return utils.SendSuccessResponse(c, nil, "标记删除成功")
}

// UpdateMarkLastOnline 更新标记的最后在线时间
func (h *MarkHandler) UpdateMarkLastOnline(c *fiber.Ctx) error {
	deviceID := c.Params("device_id")
	if deviceID == "" {
		return errs.ErrInvalidInput.WithDetails("device_id 不能为空")
	}
	if err := h.markService.UpdateMarkLastOnline(deviceID, time.Now()); err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, nil, "标记最后在线时间更新成功")
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
