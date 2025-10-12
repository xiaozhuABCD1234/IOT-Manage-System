package handler

import (
	"fmt"
	"mime/multipart"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"

	"IOT-Manage-System/map-service/errs"
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
	// 获取上传的文件
	file, err := c.FormFile("image")
	if err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "请上传地图图片")
	}

	// 验证文件类型
	if err := validateImageFile(file); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}

	// 获取表单数据
	req, err := parseCustomMapFormData(c)
	if err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}

	// 验证参数
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}

	// 保存文件
	imagePath, err := saveUploadedFile(file)
	if err != nil {
		return utils.SendErrorResponse(c, fiber.StatusInternalServerError, "保存图片失败")
	}

	// 创建记录
	if err := h.customMapService.CreateCustomMap(req, imagePath); err != nil {
		// 如果创建失败，删除已保存的文件
		_ = os.Remove(filepath.Join(".", imagePath))
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

	// 检查是否有新图片上传
	var newImagePath *string
	file, err := c.FormFile("image")
	if err == nil {
		// 有新图片上传
		if err := validateImageFile(file); err != nil {
			return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
		}

		imagePath, err := saveUploadedFile(file)
		if err != nil {
			return utils.SendErrorResponse(c, fiber.StatusInternalServerError, "保存图片失败")
		}
		newImagePath = &imagePath
	}

	// 解析表单数据
	req := new(model.CustomMapUpdateReq)
	if err := parseCustomMapUpdateFormData(c, req); err != nil {
		// 如果解析失败且已上传新图片，删除新图片
		if newImagePath != nil {
			_ = os.Remove(filepath.Join(".", *newImagePath))
		}
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}

	// 验证参数
	if err := utils.ValidateStruct(req); err != nil {
		if newImagePath != nil {
			_ = os.Remove(filepath.Join(".", *newImagePath))
		}
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
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

// validateImageFile 验证图片文件
func validateImageFile(file *multipart.FileHeader) error {
	// 验证文件大小（限制为 10MB）
	maxSize := int64(10 * 1024 * 1024)
	if file.Size > maxSize {
		return errs.ErrFileTooLarge.WithDetails("图片大小不能超过10MB")
	}

	// 验证文件类型
	ext := strings.ToLower(filepath.Ext(file.Filename))
	allowedExts := map[string]bool{
		".jpg":  true,
		".jpeg": true,
		".png":  true,
		".gif":  true,
		".webp": true,
	}

	if !allowedExts[ext] {
		return errs.ErrUnsupportedFormat.WithDetails("只支持 JPG、PNG、GIF、WEBP 格式的图片")
	}

	return nil
}

// saveUploadedFile 保存上传的文件并返回相对路径
func saveUploadedFile(file *multipart.FileHeader) (string, error) {
	// 创建上传目录
	uploadDir := "uploads/maps"
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		return "", fmt.Errorf("创建上传目录失败: %w", err)
	}

	// 生成唯一文件名
	ext := filepath.Ext(file.Filename)
	filename := fmt.Sprintf("%s_%d%s", uuid.New().String(), time.Now().Unix(), ext)
	relativePath := filepath.Join(uploadDir, filename)

	// 保存文件
	if err := saveFile(file, relativePath); err != nil {
		return "", err
	}

	return "/" + strings.ReplaceAll(relativePath, "\\", "/"), nil
}

// saveFile 保存文件到指定路径
func saveFile(file *multipart.FileHeader, path string) error {
	src, err := file.Open()
	if err != nil {
		return fmt.Errorf("打开上传文件失败: %w", err)
	}
	defer src.Close()

	dst, err := os.Create(path)
	if err != nil {
		return fmt.Errorf("创建目标文件失败: %w", err)
	}
	defer dst.Close()

	buf := make([]byte, 1024*1024) // 1MB buffer
	for {
		n, err := src.Read(buf)
		if n > 0 {
			if _, err := dst.Write(buf[:n]); err != nil {
				return fmt.Errorf("写入文件失败: %w", err)
			}
		}
		if err != nil {
			if err.Error() == "EOF" {
				break
			}
			return fmt.Errorf("读取文件失败: %w", err)
		}
	}

	return nil
}

// parseCustomMapFormData 解析表单数据到 CustomMapCreateReq
func parseCustomMapFormData(c *fiber.Ctx) (*model.CustomMapCreateReq, error) {
	req := new(model.CustomMapCreateReq)

	req.MapName = c.FormValue("map_name")

	xMin, err := parseFloat64(c.FormValue("x_min"))
	if err != nil {
		return nil, fmt.Errorf("x_min 参数错误: %v", err)
	}
	req.XMin = xMin

	xMax, err := parseFloat64(c.FormValue("x_max"))
	if err != nil {
		return nil, fmt.Errorf("x_max 参数错误: %v", err)
	}
	req.XMax = xMax

	yMin, err := parseFloat64(c.FormValue("y_min"))
	if err != nil {
		return nil, fmt.Errorf("y_min 参数错误: %v", err)
	}
	req.YMin = yMin

	yMax, err := parseFloat64(c.FormValue("y_max"))
	if err != nil {
		return nil, fmt.Errorf("y_max 参数错误: %v", err)
	}
	req.YMax = yMax

	centerX, err := parseFloat64(c.FormValue("center_x"))
	if err != nil {
		return nil, fmt.Errorf("center_x 参数错误: %v", err)
	}
	req.CenterX = centerX

	centerY, err := parseFloat64(c.FormValue("center_y"))
	if err != nil {
		return nil, fmt.Errorf("center_y 参数错误: %v", err)
	}
	req.CenterY = centerY

	req.Description = c.FormValue("description")

	return req, nil
}

// parseCustomMapUpdateFormData 解析更新表单数据
func parseCustomMapUpdateFormData(c *fiber.Ctx, req *model.CustomMapUpdateReq) error {
	if mapName := c.FormValue("map_name"); mapName != "" {
		req.MapName = &mapName
	}

	if xMinStr := c.FormValue("x_min"); xMinStr != "" {
		xMin, err := parseFloat64(xMinStr)
		if err != nil {
			return fmt.Errorf("x_min 参数错误: %v", err)
		}
		req.XMin = &xMin
	}

	if xMaxStr := c.FormValue("x_max"); xMaxStr != "" {
		xMax, err := parseFloat64(xMaxStr)
		if err != nil {
			return fmt.Errorf("x_max 参数错误: %v", err)
		}
		req.XMax = &xMax
	}

	if yMinStr := c.FormValue("y_min"); yMinStr != "" {
		yMin, err := parseFloat64(yMinStr)
		if err != nil {
			return fmt.Errorf("y_min 参数错误: %v", err)
		}
		req.YMin = &yMin
	}

	if yMaxStr := c.FormValue("y_max"); yMaxStr != "" {
		yMax, err := parseFloat64(yMaxStr)
		if err != nil {
			return fmt.Errorf("y_max 参数错误: %v", err)
		}
		req.YMax = &yMax
	}

	if centerXStr := c.FormValue("center_x"); centerXStr != "" {
		centerX, err := parseFloat64(centerXStr)
		if err != nil {
			return fmt.Errorf("center_x 参数错误: %v", err)
		}
		req.CenterX = &centerX
	}

	if centerYStr := c.FormValue("center_y"); centerYStr != "" {
		centerY, err := parseFloat64(centerYStr)
		if err != nil {
			return fmt.Errorf("center_y 参数错误: %v", err)
		}
		req.CenterY = &centerY
	}

	if description := c.FormValue("description"); description != "" {
		req.Description = &description
	}

	return nil
}

// parseFloat64 解析字符串为 float64
func parseFloat64(s string) (float64, error) {
	var f float64
	_, err := fmt.Sscanf(s, "%f", &f)
	return f, err
}

// getBaseURL 获取基础URL
func getBaseURL(c *fiber.Ctx) string {
	scheme := "http"
	if c.Protocol() == "https" {
		scheme = "https"
	}
	return fmt.Sprintf("%s://%s", scheme, c.Hostname())
}
