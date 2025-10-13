package handler

import (
	"IOT-Manage-System/map-service/model"
	"IOT-Manage-System/map-service/service"
	"IOT-Manage-System/map-service/utils"

	"github.com/gofiber/fiber/v2"
)

type PolygonFenceHandler struct {
	polygonFenceService *service.PolygonFenceService
}

func NewPolygonFenceHandler(svc *service.PolygonFenceService) *PolygonFenceHandler {
	return &PolygonFenceHandler{polygonFenceService: svc}
}

/* ---------- 1. 创建 ---------- */

// CreatePolygonFence 创建多边形围栏
func (h *PolygonFenceHandler) CreatePolygonFence(c *fiber.Ctx) error {
	req := new(model.PolygonFenceCreateReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "请求参数解析失败")
	}

	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}

	if err := h.polygonFenceService.CreatePolygonFence(req); err != nil {
		return err
	}

	return utils.SendCreatedResponse(c, nil, "多边形围栏创建成功")
}

/* ---------- 2. 单条查询 ---------- */

// GetPolygonFence 获取单个围栏
func (h *PolygonFenceHandler) GetPolygonFence(c *fiber.Ctx) error {
	id := c.Params("id")

	resp, err := h.polygonFenceService.GetPolygonFence(id)
	if err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, resp)
}

/* ---------- 3. 列表查询 ---------- */

// ListPolygonFences 获取围栏列表
func (h *PolygonFenceHandler) ListPolygonFences(c *fiber.Ctx) error {
	activeOnly := c.QueryBool("active_only", false)

	list, err := h.polygonFenceService.ListPolygonFences(activeOnly)
	if err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, list)
}

/* ---------- 4. 更新 ---------- */

// UpdatePolygonFence 更新围栏
func (h *PolygonFenceHandler) UpdatePolygonFence(c *fiber.Ctx) error {
	id := c.Params("id")

	req := new(model.PolygonFenceUpdateReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "请求参数解析失败")
	}

	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}

	if err := h.polygonFenceService.UpdatePolygonFence(id, req); err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, nil, "多边形围栏更新成功")
}

/* ---------- 5. 删除 ---------- */

// DeletePolygonFence 删除围栏
func (h *PolygonFenceHandler) DeletePolygonFence(c *fiber.Ctx) error {
	id := c.Params("id")

	if err := h.polygonFenceService.DeletePolygonFence(id); err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, nil, "多边形围栏删除成功")
}

/* ---------- 6. 空间查询 ---------- */

// CheckPointInFence 检查点是否在指定围栏内
func (h *PolygonFenceHandler) CheckPointInFence(c *fiber.Ctx) error {
	fenceID := c.Params("id")

	req := new(model.PointCheckReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "请求参数解析失败")
	}

	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}

	resp, err := h.polygonFenceService.CheckPointInFence(fenceID, req.X, req.Y)
	if err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, resp)
}

// CheckPointInAllFences 检查点在哪些围栏内
func (h *PolygonFenceHandler) CheckPointInAllFences(c *fiber.Ctx) error {
	req := new(model.PointCheckReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "请求参数解析失败")
	}

	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}

	resp, err := h.polygonFenceService.CheckPointInAllFences(req.X, req.Y)
	if err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, resp)
}




