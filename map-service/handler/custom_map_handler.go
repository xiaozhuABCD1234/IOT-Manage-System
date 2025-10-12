package handler

import (
	"encoding/base64"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"

	"IOT-Manage-System/map-service/model"
	"IOT-Manage-System/map-service/service"
	"IOT-Manage-System/map-service/utils"
)

type CustomMapHandler struct {
	customMapService *service.CustomMapService
}

// NewCustomMapHandler 构造函数
func NewCustomMapHandler(svc *service.CustomMapService) *CustomMapHandler {
	return &CustomMapHandler{customMapService: svc}
}

/* ---------- 1. 创建（上传图片 + 配置信息） ---------- */

func (h *CustomMapHandler) CreateCustomMap(c *fiber.Ctx) error {
	// 解析JSON请求
	req := new(model.CustomMapCreateReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "参数解析失败")
	}

	// 验证参数
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}

	// 处理图片（如果提供）
	var imagePath string
	if req.ImageBase64 != "" {
		// 验证图片扩展名
		if req.ImageExt == "" {
			return utils.SendErrorResponse(c, fiber.StatusBadRequest, "提供图片时必须指定图片扩展名")
		}

		// 解码Base64图片
		imageData, err := base64.StdEncoding.DecodeString(req.ImageBase64)
		if err != nil {
			return utils.SendErrorResponse(c, fiber.StatusBadRequest, "图片数据解码失败")
		}

		// 验证图片大小（限制为 10MB）
		maxSize := int64(10 * 1024 * 1024)
		if int64(len(imageData)) > maxSize {
			return utils.SendErrorResponse(c, fiber.StatusBadRequest, "图片大小不能超过10MB")
		}

		// 保存Base64图片
		imagePath, err = saveBase64Image(imageData, req.ImageExt)
		if err != nil {
			return utils.SendErrorResponse(c, fiber.StatusInternalServerError, "保存图片失败")
		}
	}

	// 创建记录
	if err := h.customMapService.CreateCustomMap(req, imagePath); err != nil {
		// 如果创建失败且已保存文件，删除已保存的文件
		if imagePath != "" {
			_ = os.Remove(filepath.Join(".", imagePath))
		}
		return err
	}

	return utils.SendCreatedResponse(c, nil, "自制地图创建成功")
}

/* ---------- 2. 单条查询 ---------- */

func (h *CustomMapHandler) GetCustomMap(c *fiber.Ctx) error {
	id := c.Params("id")
	baseURL := getBaseURL(c)

	resp, err := h.customMapService.GetCustomMap(id, baseURL)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}

/* ---------- 3. 全量列表查询 ---------- */

func (h *CustomMapHandler) ListCustomMaps(c *fiber.Ctx) error {
	baseURL := getBaseURL(c)

	list, err := h.customMapService.GetAllCustomMaps(baseURL)
	if err != nil {
		return err
	}

	return utils.SendSuccessResponse(c, list)
}

/* ---------- 3.1 获取最新地图 ---------- */

func (h *CustomMapHandler) GetLatestCustomMap(c *fiber.Ctx) error {
	baseURL := getBaseURL(c)

	resp, err := h.customMapService.GetLatestCustomMap(baseURL)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}

/* ---------- 4. 更新 ---------- */

func (h *CustomMapHandler) UpdateCustomMap(c *fiber.Ctx) error {
	id := c.Params("id")

	// 解析JSON请求
	req := new(model.CustomMapUpdateReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "参数解析失败")
	}

	// 验证参数
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}

	// 检查是否有新图片
	var newImagePath *string
	if req.ImageBase64 != nil && *req.ImageBase64 != "" {
		// 检查是否提供了图片扩展名
		if req.ImageExt == nil || *req.ImageExt == "" {
			return utils.SendErrorResponse(c, fiber.StatusBadRequest, "更新图片时必须提供image_ext")
		}

		// 解码Base64图片
		imageData, err := base64.StdEncoding.DecodeString(*req.ImageBase64)
		if err != nil {
			return utils.SendErrorResponse(c, fiber.StatusBadRequest, "图片数据解码失败")
		}

		// 验证图片大小（限制为 10MB）
		maxSize := int64(10 * 1024 * 1024)
		if int64(len(imageData)) > maxSize {
			return utils.SendErrorResponse(c, fiber.StatusBadRequest, "图片大小不能超过10MB")
		}

		// 保存Base64图片
		imagePath, err := saveBase64Image(imageData, *req.ImageExt)
		if err != nil {
			return utils.SendErrorResponse(c, fiber.StatusInternalServerError, "保存图片失败")
		}
		newImagePath = &imagePath
	}

	// 更新记录
	if err := h.customMapService.UpdateCustomMap(id, req, newImagePath); err != nil {
		// 如果更新失败且已上传新图片，删除新图片
		if newImagePath != nil {
			_ = os.Remove(filepath.Join(".", *newImagePath))
		}
		return err
	}

	return utils.SendSuccessResponse(c, nil, "自制地图更新成功")
}

/* ---------- 5. 删除 ---------- */

func (h *CustomMapHandler) DeleteCustomMap(c *fiber.Ctx) error {
	id := c.Params("id")
	if err := h.customMapService.DeleteCustomMap(id); err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, nil, "自制地图删除成功")
}

/* ---------- 内部辅助函数 ---------- */

// saveBase64Image 保存Base64编码的图片并返回相对路径
func saveBase64Image(imageData []byte, ext string) (string, error) {
	// 创建上传目录
	uploadDir := "uploads/maps"
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		return "", fmt.Errorf("创建上传目录失败: %w", err)
	}

	// 生成唯一文件名
	filename := fmt.Sprintf("%s_%d%s", uuid.New().String(), time.Now().Unix(), ext)
	relativePath := filepath.Join(uploadDir, filename)

	// 保存文件
	if err := os.WriteFile(relativePath, imageData, 0644); err != nil {
		return "", fmt.Errorf("写入文件失败: %w", err)
	}

	return "/" + strings.ReplaceAll(relativePath, "\\", "/"), nil
}

// getBaseURL 获取基础URL
func getBaseURL(c *fiber.Ctx) string {
	scheme := "http"
	if c.Protocol() == "https" {
		scheme = "https"
	}
	return fmt.Sprintf("%s://%s", scheme, c.Hostname())
}
