package service

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"

	"gorm.io/gorm"

	"IOT-Manage-System/map-service/errs"
	"IOT-Manage-System/map-service/model"
	"IOT-Manage-System/map-service/repo"
)

// CustomMapService 业务编排层
type CustomMapService struct {
	customMapRepo *repo.CustomMapRepo
}

func NewCustomMapService(repo *repo.CustomMapRepo) *CustomMapService {
	return &CustomMapService{customMapRepo: repo}
}

/* ---------- 创建 ---------- */

func (s *CustomMapService) CreateCustomMap(req *model.CustomMapCreateReq, imagePath string) error {
	// 业务验证
	if err := s.validateCustomMapData(req); err != nil {
		return err
	}

	customMap := &model.CustomMap{
		MapName:     req.MapName,
		ImagePath:   imagePath,
		XMin:        req.XMin,
		XMax:        req.XMax,
		YMin:        req.YMin,
		YMax:        req.YMax,
		CenterX:     req.CenterX,
		CenterY:     req.CenterY,
		Description: req.Description,
	}

	if err := s.customMapRepo.Create(customMap); err != nil {
		return s.translateRepoErr(err, "CustomMap")
	}
	return nil
}

/* ---------- 查询 ---------- */

func (s *CustomMapService) GetCustomMap(id string, baseURL string) (*model.CustomMapResp, error) {
	uid, err := parseUUID(id)
	if err != nil {
		return nil, err
	}

	customMap, err := s.customMapRepo.GetByID(uid)
	if err != nil {
		return nil, s.translateRepoErr(err, "CustomMap")
	}
	return model.CustomMapToCustomMapResp(customMap, baseURL), nil
}

/* ---------- 全量 ---------- */

func (s *CustomMapService) GetAllCustomMaps(baseURL string) ([]model.CustomMapResp, error) {
	list, err := s.customMapRepo.ListAll()
	if err != nil {
		return nil, s.translateRepoErr(err, "CustomMap")
	}
	// 避免外部拿到 nil 切片
	if len(list) == 0 {
		return []model.CustomMapResp{}, nil
	}

	resp := make([]model.CustomMapResp, 0, len(list))
	for i := range list {
		resp = append(resp, *model.CustomMapToCustomMapResp(&list[i], baseURL))
	}
	return resp, nil
}

/* ---------- 获取最新 ---------- */

func (s *CustomMapService) GetLatestCustomMap(baseURL string) (*model.CustomMapResp, error) {
	customMap, err := s.customMapRepo.GetLatest()
	if err != nil {
		return nil, s.translateRepoErr(err, "CustomMap")
	}
	return model.CustomMapToCustomMapResp(customMap, baseURL), nil
}

/* ---------- 更新 ---------- */

func (s *CustomMapService) UpdateCustomMap(id string, req *model.CustomMapUpdateReq, newImagePath *string) error {
	uid, err := parseUUID(id)
	if err != nil {
		return err
	}

	data, err := s.customMapRepo.GetByID(uid)
	if err != nil {
		return s.translateRepoErr(err, "CustomMap")
	}

	// 保存旧图片路径，以便在更新成功后删除
	oldImagePath := data.ImagePath

	// 准备更新的数据
	mapName := data.MapName
	xMin := data.XMin
	xMax := data.XMax
	yMin := data.YMin
	yMax := data.YMax
	centerX := data.CenterX
	centerY := data.CenterY
	description := data.Description

	if req.MapName != nil {
		mapName = *req.MapName
	}
	if req.XMin != nil {
		xMin = *req.XMin
	}
	if req.XMax != nil {
		xMax = *req.XMax
	}
	if req.YMin != nil {
		yMin = *req.YMin
	}
	if req.YMax != nil {
		yMax = *req.YMax
	}
	if req.CenterX != nil {
		centerX = *req.CenterX
	}
	if req.CenterY != nil {
		centerY = *req.CenterY
	}
	if req.Description != nil {
		description = *req.Description
	}

	// 业务验证
	validateReq := &model.CustomMapCreateReq{
		MapName:     mapName,
		XMin:        xMin,
		XMax:        xMax,
		YMin:        yMin,
		YMax:        yMax,
		CenterX:     centerX,
		CenterY:     centerY,
		Description: description,
	}
	if err := s.validateCustomMapData(validateReq); err != nil {
		return err
	}

	// 应用更新
	data.MapName = mapName
	data.XMin = xMin
	data.XMax = xMax
	data.YMin = yMin
	data.YMax = yMax
	data.CenterX = centerX
	data.CenterY = centerY
	data.Description = description

	// 如果有新图片，更新图片路径
	if newImagePath != nil {
		data.ImagePath = *newImagePath
	}

	if err := s.customMapRepo.UpdateByID(uid, data); err != nil {
		return s.translateRepoErr(err, "CustomMap")
	}

	// 如果更新了图片且更新成功，删除旧图片
	if newImagePath != nil && *newImagePath != oldImagePath {
		_ = os.Remove(filepath.Join(".", oldImagePath))
	}

	return nil
}

/* ---------- 删除 ---------- */

func (s *CustomMapService) DeleteCustomMap(id string) error {
	uid, err := parseUUID(id)
	if err != nil {
		return err
	}

	// 先查询记录，获取图片路径
	customMap, err := s.customMapRepo.GetByID(uid)
	if err != nil {
		return s.translateRepoErr(err, "CustomMap")
	}

	// 删除数据库记录
	if err := s.customMapRepo.DeleteByID(uid); err != nil {
		return s.translateRepoErr(err, "CustomMap")
	}

	// 删除关联的图片文件
	if customMap.ImagePath != "" {
		_ = os.Remove(filepath.Join(".", customMap.ImagePath))
	}

	return nil
}

/* ---------- 内部辅助 ---------- */

// translateRepoErr 把 repo 层常见错误翻译成业务错误
func (s *CustomMapService) translateRepoErr(err error, resource string) error {
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return errs.NotFound(resource, fmt.Sprintf("%s 不存在", resource))
	}
	return errs.ErrInternal.WithDetails(err.Error())
}

// validateCustomMapData 验证自制地图数据的业务规则
func (s *CustomMapService) validateCustomMapData(req *model.CustomMapCreateReq) error {
	// 验证地图名称
	if len(req.MapName) == 0 {
		return errs.ErrValidationFailed.WithDetails("地图名称不能为空")
	}
	if len(req.MapName) > 255 {
		return errs.ErrValidationFailed.WithDetails("地图名称长度不能超过255个字符")
	}

	// 验证坐标范围
	if req.XMin >= req.XMax {
		return errs.ErrValidationFailed.WithDetails("X坐标最小值必须小于最大值")
	}
	if req.YMin >= req.YMax {
		return errs.ErrValidationFailed.WithDetails("Y坐标最小值必须小于最大值")
	}

	// 验证中心点是否在坐标范围内
	if req.CenterX < req.XMin || req.CenterX > req.XMax {
		return errs.ErrValidationFailed.WithDetails("地图中心点X坐标必须在X坐标范围内")
	}
	if req.CenterY < req.YMin || req.CenterY > req.YMax {
		return errs.ErrValidationFailed.WithDetails("地图中心点Y坐标必须在Y坐标范围内")
	}

	// 验证描述长度
	if len(req.Description) > 1000 {
		return errs.ErrValidationFailed.WithDetails("地图描述长度不能超过1000个字符")
	}

	return nil
}
