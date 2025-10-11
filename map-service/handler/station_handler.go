package handler

import (
	"github.com/gofiber/fiber/v2"

	"IOT-Manage-System/map-service/model"
	"IOT-Manage-System/map-service/service"
	"IOT-Manage-System/map-service/utils"
)

type StationHandler struct {
	stationService *service.StationService
}

// NewStationHandler 构造函数（注意指针写法）
func NewStationHandler(svc *service.StationService) *StationHandler {
	return &StationHandler{stationService: svc}
}

/* ---------- 1. 创建 ---------- */

func (h *StationHandler) CreateStation(c *fiber.Ctx) error {
	req := new(model.StationCreateReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "参数解析失败")
	}

	if err := h.stationService.CreateStation(req); err != nil {
		return err // 统一错误处理见 global_error_handler
	}
	return utils.SendCreatedResponse(c, nil, "基站创建成功")
}

/* ---------- 2. 单条查询 ---------- */

func (h *StationHandler) GetStation(c *fiber.Ctx) error {
	id := c.Params("id")
	resp, err := h.stationService.GetStation(id)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}

/* ---------- 3. 全量（不分页查询） ---------- */

func (h *StationHandler) ListStation(c *fiber.Ctx) error { // 如果不需要分页，perPage <= 0 时内部会返回全量
	list, err := h.stationService.GetALLStation()
	if err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, list)
}

/* ---------- 4. 更新 ---------- */

func (h *StationHandler) UpdateStation(c *fiber.Ctx) error {
	id := c.Params("id")
	req := new(model.StationUpdateReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "参数解析失败")
	}

	if err := h.stationService.UpdateStation(id, req); err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, nil, "基站更新成功")
}

/* ---------- 5. 删除 ---------- */

func (h *StationHandler) DeleteStation(c *fiber.Ctx) error {
	id := c.Params("id")
	if err := h.stationService.DeleteStation(id); err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, nil, "基站删除成功")
}
