package service

import (
	"IOT-Manage-System/mqtt-watch/errs"
	// "IOT-Manage-System/mqtt-watch/model"
	"IOT-Manage-System/mqtt-watch/repo"
	"sort"
)

type MarkPairService interface {
	// 设置/更新 单对距离
	SetPairDistance(mark1ID, mark2ID string, distance float64) error
	// 批量设置：对传入的 MarkID 列表做全组合
	SetCombinations(ids []string, distance float64) error
	// 查询单对距离
	GetDistance(mark1ID, mark2ID string) (float64, error)
	// 删除单对
	DeletePair(mark1ID, mark2ID string) error
	// 查询某个 Mark 与其它所有 Mark 的距离映射
	DistanceMapByMark(id string) (map[string]float64, error)
	// 查询某个 Device 与其它所有 Mark 的距离映射
	DistanceMapByDevice(deviceID string) (map[string]float64, error)
}

type markPairService struct {
	markPairRepo repo.MarkPairRepo
	markRepo     repo.MarkRepo
}

func NewMarkPairService(r1 repo.MarkPairRepo, r2 repo.MarkRepo) MarkPairService {
	return &markPairService{markPairRepo: r1, markRepo: r2}
}

func (s *markPairService) SetPairDistance(mark1ID, mark2ID string, distance float64) error {
	if mark1ID == "" || mark2ID == "" {
		return errs.ErrInvalidInput.WithDetails("mark IDs cannot be empty")
	}

	if distance < 0 {
		return errs.ErrInvalidInput.WithDetails("distance cannot be negative")
	}

	err := s.markPairRepo.Upsert(mark1ID, mark2ID, distance)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	return nil
}

func (s *markPairService) SetCombinations(ids []string, distance float64) error {
	if len(ids) < 2 {
		return nil
	}

	if distance < 0 {
		return errs.ErrInvalidInput.WithDetails("distance cannot be negative")
	}

	// 去重 & 排序，保证幂等
	m := make(map[string]struct{})
	for _, id := range ids {
		if id == "" {
			return errs.ErrInvalidInput.WithDetails("mark ID cannot be empty")
		}
		m[id] = struct{}{}
	}
	uniq := make([]string, 0, len(m))
	for id := range m {
		uniq = append(uniq, id)
	}
	sort.Strings(uniq)

	err := s.markPairRepo.BatchUpsert(uniq, distance)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	return nil
}

func (s *markPairService) GetDistance(mark1ID, mark2ID string) (float64, error) {
	if mark1ID == "" || mark2ID == "" {
		return 0, errs.ErrInvalidInput.WithDetails("mark IDs cannot be empty")
	}

	distance, err := s.markPairRepo.Get(mark1ID, mark2ID)
	if err != nil {
		return 0, errs.ErrDatabase.WithDetails(err.Error())
	}
	return distance, nil
}

func (s *markPairService) DeletePair(mark1ID, mark2ID string) error {
	if mark1ID == "" || mark2ID == "" {
		return errs.ErrInvalidInput.WithDetails("mark IDs cannot be empty")
	}

	err := s.markPairRepo.Delete(mark1ID, mark2ID)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	return nil
}

func (s *markPairService) DistanceMapByMark(id string) (map[string]float64, error) {
	if id == "" {
		return nil, errs.ErrInvalidInput.WithDetails("mark ID cannot be empty")
	}

	result, err := s.markPairRepo.MapByID(id)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return result, nil
}

func (s *markPairService) DistanceMapByDevice(deviceID string) (map[string]float64, error) {
	if deviceID == "" {
		return nil, errs.ErrInvalidInput.WithDetails("device ID cannot be empty")
	}

	result, err := s.markPairRepo.MapByDeviceID(deviceID)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return result, nil
}
