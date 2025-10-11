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
		return nil
	}

	if req.LocationX != nil {
		data.LocationX = *req.LocationX
	}

	if req.LocationY != nil {
		data.LocationY = *req.LocationY
	}

	if req.StationName != nil {
		data.StationName = *req.StationName
	}

	if err := s.stationRepo.UpdateByID(uid, data); err != nil {
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
