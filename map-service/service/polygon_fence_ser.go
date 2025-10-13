package service

import (
	"errors"
	"fmt"
	"regexp"
	"strings"

	"IOT-Manage-System/map-service/errs"
	"IOT-Manage-System/map-service/model"
	"IOT-Manage-System/map-service/repo"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type PolygonFenceService struct {
	polygonFenceRepo *repo.PolygonFenceRepo
}

func NewPolygonFenceService(repo *repo.PolygonFenceRepo) *PolygonFenceService {
	return &PolygonFenceService{polygonFenceRepo: repo}
}

/* ---------- 创建 ---------- */

// CreatePolygonFence 创建多边形围栏
func (s *PolygonFenceService) CreatePolygonFence(req *model.PolygonFenceCreateReq) error {
	// 验证多边形有效性
	if err := s.validatePolygon(req.Points); err != nil {
		return err
	}

	// 转换为 WKT 格式
	wkt := s.pointsToWKT(req.Points)

	fence := &model.PolygonFence{
		FenceName:   req.FenceName,
		Geometry:    wkt,
		Description: req.Description,
		IsActive:    true,
	}

	if err := s.polygonFenceRepo.Create(fence); err != nil {
		return s.translateRepoErr(err, "PolygonFence")
	}
	return nil
}

/* ---------- 查询 ---------- */

// GetPolygonFence 获取单个围栏
func (s *PolygonFenceService) GetPolygonFence(id string) (*model.PolygonFenceResp, error) {
	uid, err := uuid.Parse(id)
	if err != nil {
		return nil, errs.ErrInvalidID.WithDetails("无效的围栏ID")
	}

	fence, err := s.polygonFenceRepo.GetByID(uid)
	if err != nil {
		return nil, s.translateRepoErr(err, "PolygonFence")
	}

	return s.fenceToResp(fence), nil
}

// ListPolygonFences 获取所有围栏
func (s *PolygonFenceService) ListPolygonFences(activeOnly bool) ([]model.PolygonFenceResp, error) {
	var fences []model.PolygonFence
	var err error

	if activeOnly {
		fences, err = s.polygonFenceRepo.ListActive()
	} else {
		fences, err = s.polygonFenceRepo.ListAll()
	}

	if err != nil {
		return nil, s.translateRepoErr(err, "PolygonFence")
	}

	if len(fences) == 0 {
		return []model.PolygonFenceResp{}, nil
	}

	resp := make([]model.PolygonFenceResp, 0, len(fences))
	for i := range fences {
		resp = append(resp, *s.fenceToResp(&fences[i]))
	}
	return resp, nil
}

/* ---------- 更新 ---------- */

// UpdatePolygonFence 更新围栏
func (s *PolygonFenceService) UpdatePolygonFence(id string, req *model.PolygonFenceUpdateReq) error {
	uid, err := uuid.Parse(id)
	if err != nil {
		return errs.ErrInvalidID.WithDetails("无效的围栏ID")
	}

	// 获取现有数据
	fence, err := s.polygonFenceRepo.GetByID(uid)
	if err != nil {
		return s.translateRepoErr(err, "PolygonFence")
	}

	// 应用更新
	if req.FenceName != nil {
		fence.FenceName = *req.FenceName
	}
	if req.Points != nil {
		if err := s.validatePolygon(*req.Points); err != nil {
			return err
		}
		fence.Geometry = s.pointsToWKT(*req.Points)
	}
	if req.Description != nil {
		fence.Description = *req.Description
	}
	if req.IsActive != nil {
		fence.IsActive = *req.IsActive
	}

	if err := s.polygonFenceRepo.UpdateByID(uid, fence); err != nil {
		return s.translateRepoErr(err, "PolygonFence")
	}
	return nil
}

/* ---------- 删除 ---------- */

// DeletePolygonFence 删除围栏
func (s *PolygonFenceService) DeletePolygonFence(id string) error {
	uid, err := uuid.Parse(id)
	if err != nil {
		return errs.ErrInvalidID.WithDetails("无效的围栏ID")
	}

	// 检查是否存在
	if _, err := s.polygonFenceRepo.GetByID(uid); err != nil {
		return s.translateRepoErr(err, "PolygonFence")
	}

	if err := s.polygonFenceRepo.DeleteByID(uid); err != nil {
		return s.translateRepoErr(err, "PolygonFence")
	}
	return nil
}

/* ---------- 空间查询 ---------- */

// CheckPointInFence 检查点是否在指定围栏内
func (s *PolygonFenceService) CheckPointInFence(fenceID string, x, y float64) (*model.PointCheckResp, error) {
	uid, err := uuid.Parse(fenceID)
	if err != nil {
		return nil, errs.ErrInvalidID.WithDetails("无效的围栏ID")
	}

	fence, err := s.polygonFenceRepo.GetByID(uid)
	if err != nil {
		return nil, s.translateRepoErr(err, "PolygonFence")
	}

	isInside, err := s.polygonFenceRepo.IsPointInFence(uid, x, y)
	if err != nil {
		return nil, errs.ErrInternal.WithDetails(err.Error())
	}

	resp := &model.PointCheckResp{
		IsInside: isInside,
	}
	if isInside {
		resp.FenceID = fence.ID.String()
		resp.FenceName = fence.FenceName
	}

	return resp, nil
}

// CheckPointInAllFences 检查点在哪些围栏内
func (s *PolygonFenceService) CheckPointInAllFences(x, y float64) (*model.PointCheckResp, error) {
	fences, err := s.polygonFenceRepo.FindFencesByPoint(x, y)
	if err != nil {
		return nil, errs.ErrInternal.WithDetails(err.Error())
	}

	resp := &model.PointCheckResp{
		IsInside: len(fences) > 0,
	}

	if len(fences) > 0 {
		resp.FenceID = fences[0].ID.String()
		resp.FenceName = fences[0].FenceName
		resp.FenceNames = make([]string, len(fences))
		for i, f := range fences {
			resp.FenceNames[i] = f.FenceName
		}
	}

	return resp, nil
}

/* ---------- 内部辅助函数 ---------- */

// validatePolygon 验证多边形有效性
func (s *PolygonFenceService) validatePolygon(points []model.Point) error {
	if len(points) < 3 {
		return errs.ErrValidationFailed.WithDetails("多边形至少需要3个顶点")
	}

	if len(points) > 10000 {
		return errs.ErrValidationFailed.WithDetails("多边形顶点数量不能超过10000")
	}

	// 检查是否有重复的连续点
	for i := 0; i < len(points)-1; i++ {
		if points[i].X == points[i+1].X && points[i].Y == points[i+1].Y {
			return errs.ErrValidationFailed.WithDetails(fmt.Sprintf("存在重复的连续顶点: (%f, %f)", points[i].X, points[i].Y))
		}
	}

	return nil
}

// pointsToWKT 将点数组转换为 WKT POLYGON 格式
func (s *PolygonFenceService) pointsToWKT(points []model.Point) string {
	coords := make([]string, len(points)+1) // +1 用于闭合多边形
	for i, p := range points {
		coords[i] = fmt.Sprintf("%f %f", p.X, p.Y)
	}
	// 闭合多边形（最后一个点等于第一个点）
	coords[len(points)] = fmt.Sprintf("%f %f", points[0].X, points[0].Y)

	return fmt.Sprintf("POLYGON((%s))", strings.Join(coords, ","))
}

// wktToPoints 将 WKT POLYGON 格式转换为点数组
func (s *PolygonFenceService) wktToPoints(wkt string) []model.Point {
	// 示例 WKT: POLYGON((0 0,10 0,10 10,0 10,0 0))
	re := regexp.MustCompile(`POLYGON\(\((.*?)\)\)`)
	matches := re.FindStringSubmatch(wkt)
	if len(matches) < 2 {
		return []model.Point{}
	}

	coordsStr := matches[1]
	coordPairs := strings.Split(coordsStr, ",")

	// 去掉最后一个点（闭合点）
	points := make([]model.Point, 0, len(coordPairs)-1)
	for i := 0; i < len(coordPairs)-1; i++ {
		coords := strings.Fields(strings.TrimSpace(coordPairs[i]))
		if len(coords) == 2 {
			var x, y float64
			fmt.Sscanf(coords[0], "%f", &x)
			fmt.Sscanf(coords[1], "%f", &y)
			points = append(points, model.Point{X: x, Y: y})
		}
	}

	return points
}

// fenceToResp 转换为响应格式
func (s *PolygonFenceService) fenceToResp(fence *model.PolygonFence) *model.PolygonFenceResp {
	return &model.PolygonFenceResp{
		ID:          fence.ID.String(),
		FenceName:   fence.FenceName,
		Points:      s.wktToPoints(fence.Geometry),
		Description: fence.Description,
		IsActive:    fence.IsActive,
		CreatedAt:   fence.CreatedAt,
		UpdatedAt:   fence.UpdatedAt,
	}
}

// translateRepoErr 翻译数据库错误
func (s *PolygonFenceService) translateRepoErr(err error, resource string) error {
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return errs.NotFound(resource, fmt.Sprintf("%s 不存在", resource))
	}
	if strings.Contains(err.Error(), "duplicate key") {
		return errs.ErrDuplicateEntry.WithDetails("围栏名称已存在")
	}
	return errs.ErrInternal.WithDetails(err.Error())
}


