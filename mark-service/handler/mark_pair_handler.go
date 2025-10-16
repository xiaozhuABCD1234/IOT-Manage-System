package handler

import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
	"IOT-Manage-System/mark-service/service"
	"IOT-Manage-System/mark-service/utils"

	"github.com/gofiber/fiber/v2"
)

type MarkPairHandler struct {
	markPairService service.MarkPairService
}

func NewMarkPairHandler(markPairService service.MarkPairService) *MarkPairHandler {
	return &MarkPairHandler{markPairService: markPairService}
}

// SetPairDistance 设置/更新单对标记距离
func (h *MarkPairHandler) SetPairDistance(c *fiber.Ctx) error {
	var req model.SetDistanceMarkReq

	if err := c.BodyParser(&req); err != nil {
		return errs.ErrInvalidInput.WithDetails("参数解析失败")
	}

	if err := h.markPairService.SetPairDistance(req.Mark1ID, req.Mark2ID, req.Distance); err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, nil, "标记对距离设置成功")
}

// SetCombinations 批量设置标记组合距离
func (h *MarkPairHandler) SetCombinations(c *fiber.Ctx) error {
	var req struct {
		MarkIDs  []string `json:"mark_ids" validate:"required,min=2"`
		Distance float64  `json:"distance" validate:"required,min=0"`
	}

	if err := c.BodyParser(&req); err != nil {
		return errs.ErrInvalidInput.WithDetails("参数解析失败")
	}

	if err := h.markPairService.SetCombinations(req.MarkIDs, req.Distance); err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, nil, "标记组合距离批量设置成功")
}

// SetCartesian 笛卡尔积方式设置标记对距离
func (h *MarkPairHandler) SetCartesian(c *fiber.Ctx) error {
	var req model.SetDistanceTypedReq

	if err := c.BodyParser(&req); err != nil {
		return errs.ErrInvalidInput.WithDetails("参数解析失败")
	}

	if err := h.markPairService.SetCartesian(req, req.Distance); err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, nil, "标记对笛卡尔积距离设置成功")
}

// GetDistance 查询单对标记距离
func (h *MarkPairHandler) GetDistance(c *fiber.Ctx) error {
	mark1ID := c.Params("mark1_id")
	mark2ID := c.Params("mark2_id")

	if mark1ID == "" || mark2ID == "" {
		return errs.ErrInvalidInput.WithDetails("标记ID不能为空")
	}

	if mark1ID > mark2ID {
		t := mark1ID
		mark1ID = mark2ID
		mark2ID = t
	}
	distance, err := h.markPairService.GetDistance(mark1ID, mark2ID)
	if err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, map[string]interface{}{
		"mark1_id": mark1ID,
		"mark2_id": mark2ID,
		"distance": distance,
	})
}

// DeletePair 删除单对标记距离
func (h *MarkPairHandler) DeletePair(c *fiber.Ctx) error {
	mark1ID := c.Params("mark1_id")
	mark2ID := c.Params("mark2_id")

	if mark1ID == "" || mark2ID == "" {
		return errs.ErrInvalidInput.WithDetails("标记ID不能为空")
	}
	if mark1ID > mark2ID {
		t := mark1ID
		mark1ID = mark2ID
		mark2ID = t
	}
	if err := h.markPairService.DeletePair(mark1ID, mark2ID); err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, nil, "标记对距离删除成功")
}

// DistanceMapByMark 查询某个标记与其他所有标记的距离映射
func (h *MarkPairHandler) DistanceMapByMark(c *fiber.Ctx) error {
	markID := c.Params("id")

	if markID == "" {
		return errs.ErrInvalidInput.WithDetails("标记ID不能为空")
	}

	distanceMap, err := h.markPairService.DistanceMapByMark(markID)
	if err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, distanceMap)
}

// DistanceMapByDevice 查询某个设备与其他所有标记的距离映射
func (h *MarkPairHandler) DistanceMapByDevice(c *fiber.Ctx) error {
	deviceID := c.Params("device_id")

	if deviceID == "" {
		return errs.ErrInvalidInput.WithDetails("设备ID不能为空")
	}

	distanceMap, err := h.markPairService.DistanceMapByDevice(deviceID)
	if err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, distanceMap)
}

// GetDistanceByDeviceIDs 根据设备ID查询单对标记距离
func (h *MarkPairHandler) GetDistanceByDeviceIDs(c *fiber.Ctx) error {
	device1ID := c.Params("device1_id")
	device2ID := c.Params("device2_id")

	if device1ID == "" || device2ID == "" {
		return errs.ErrInvalidInput.WithDetails("设备ID不能为空")
	}

	distance, err := h.markPairService.GetDistanceByDeviceIDs(device1ID, device2ID)
	if err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, map[string]interface{}{
		"device1_id": device1ID,
		"device2_id": device2ID,
		"distance":   distance,
	})
}

// DistanceMapByDeviceToDeviceIDs 查询某个标记设备ID与所有其他标记的距离映射（设备ID）
func (h *MarkPairHandler) DistanceMapByDeviceToDeviceIDs(c *fiber.Ctx) error {
	deviceID := c.Params("id")

	if deviceID == "" {
		return errs.ErrInvalidInput.WithDetails("设备ID不能为空")
	}

	distanceMap, err := h.markPairService.DistanceMapByDeviceToDeviceIDs(deviceID)
	if err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, distanceMap)
}

// ListMarkPairs 分页查询标记对列表
func (h *MarkPairHandler) ListMarkPairs(c *fiber.Ctx) error {
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
		limit = 100
	}

	pairs, total, err := h.markPairService.ListMarkPairs(page, limit)
	if err != nil {
		return err
	}

	return utils.SendPaginatedResponse(c, pairs, total, page, limit)
}
