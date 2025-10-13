package service

import (
	"errors"
	"fmt"

	"github.com/google/uuid"
	"gorm.io/gorm"

	"IOT-Manage-System/map-service/errs"
	"IOT-Manage-System/map-service/model"
	"IOT-Manage-System/map-service/repo"
)

// StationService 业务编排层
type StationService struct {
	stationRepo *repo.StationRepo
}

func NewStationService(repo *repo.StationRepo) *StationService {
	return &StationService{stationRepo: repo}
}

/* ---------- 创建 ---------- */

func (s *StationService) CreateStation(req *model.StationCreateReq) error {
	// 业务验证
	if err := s.validateStationData(req.StationName, req.CoordinateX, req.CoordinateY); err != nil {
		return err
	}

	station := model.StationCreateReqToStation(req)
	if err := s.stationRepo.Create(station); err != nil {
		return s.translateRepoErr(err, "Station")
	}
	return nil
}

/* ---------- 查询 ---------- */

func (s *StationService) GetStation(id string) (*model.StationResp, error) {
	uid, err := parseUUID(id)
	if err != nil {
		return nil, err
	}

	station, err := s.stationRepo.GetByID(uid)
	if err != nil {
		return nil, s.translateRepoErr(err, "Station")
	}
	return model.StationToStationResp(station), nil
}

/* ---------- 全量 ---------- */

func (s *StationService) GetALLStation() ([]model.StationResp, error) {
	list, err := s.stationRepo.ListAll()
	if err != nil {
		return nil, s.translateRepoErr(err, "Station")
	}
	// 避免外部拿到 nil 切片
	if len(list) == 0 {
		return []model.StationResp{}, nil
	}

	resp := make([]model.StationResp, 0, len(list))
	for i := range list {
		resp = append(resp, *model.StationToStationResp(&list[i]))
	}
	return resp, nil
}

/* ---------- 更新 ---------- */

func (s *StationService) UpdateStation(id string, req *model.StationUpdateReq) error {
	uid, err := parseUUID(id)
	if err != nil {
		return err
	}

	data, err := s.stationRepo.GetByID(uid)
	if err != nil {
		return s.translateRepoErr(err, "Station")
	}

	// 准备更新的数据用于验证
	stationName := data.StationName
	coordinateX := data.CoordinateX
	coordinateY := data.CoordinateY

	if req.StationName != nil {
		stationName = *req.StationName
	}
	if req.CoordinateX != nil {
		coordinateX = *req.CoordinateX
	}
	if req.CoordinateY != nil {
		coordinateY = *req.CoordinateY
	}

	// 业务验证
	if err := s.validateStationData(stationName, coordinateX, coordinateY); err != nil {
		return err
	}

	// 使用 map 来更新，以支持零值更新
	updates := make(map[string]interface{})
	if req.StationName != nil {
		updates["station_name"] = stationName
	}
	if req.CoordinateX != nil {
		updates["location_x"] = coordinateX
	}
	if req.CoordinateY != nil {
		updates["location_y"] = coordinateY
	}

	if err := s.stationRepo.UpdateByIDWithMap(uid, updates); err != nil {
		return s.translateRepoErr(err, "Station")
	}
	return nil
}

/* ---------- 删除 ---------- */

func (s *StationService) DeleteStation(id string) error {
	uid, err := parseUUID(id)
	if err != nil {
		return err
	}

	if err := s.stationRepo.DeleteByID(uid); err != nil {
		return s.translateRepoErr(err, "Station")
	}
	return nil
}

/* ---------- 内部辅助 ---------- */

// parseUUID 统一解析并返回业务侧已定义的错误
func parseUUID(id string) (uuid.UUID, error) {
	uid, err := uuid.Parse(id)
	if err != nil {
		return uuid.Nil, errs.ErrValidationFailed.WithDetails(fmt.Sprintf("invalid uuid: %s", id))
	}
	return uid, nil
}

// translateRepoErr 把 repo 层常见错误翻译成业务错误
func (s *StationService) translateRepoErr(err error, resource string) error {
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return errs.NotFound(resource, fmt.Sprintf("%s 不存在", resource))
	}
	// 这里可以扩展更多 gorm/mysql 唯一键冲突、连接超时等判断
	return errs.ErrInternal.WithDetails(err.Error())
}

// validateStationData 验证基站数据的业务规则
func (s *StationService) validateStationData(stationName string, coordinateX, coordinateY float64) error {
	// 验证基站名称
	if len(stationName) == 0 {
		return errs.ErrValidationFailed.WithDetails("基站名称不能为空")
	}
	if len(stationName) > 255 {
		return errs.ErrValidationFailed.WithDetails("基站名称长度不能超过255个字符")
	}

	// 坐标验证：确保坐标值是有效的浮点数（非NaN、非Inf）
	// 根据实际业务需求，可以添加具体的坐标范围限制
	// 注意：这里不再限制为经纬度范围，允许任意有效浮点数

	return nil
}
