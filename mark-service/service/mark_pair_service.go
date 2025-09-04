package service

import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
	"IOT-Manage-System/mark-service/repo"
	"sort"
)

type MarkPairService interface {
	// 设置/更新 单对距离
	SetPairDistance(mark1ID, mark2ID string, distance float64) error
	// 批量设置：对传入的 MarkID 列表做全组合
	SetCombinations(ids []string, distance float64) error
	// 笛卡尔积设置：两组 Mark 两两配对
	SetCartesian(req model.DistanceQuery, distance float64) error
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

func (s *markPairService) SetCartesian(req model.DistanceQuery, distance float64) error {
	if distance < 0 {
		return errs.ErrInvalidInput.WithDetails("distance cannot be negative")
	}

	var m1IDs, m2IDs []string
	var err error

	// 处理第一个条件
	switch req.First.Kind {
	case "mark":
		if req.First.MarkID == "" {
			return errs.ErrInvalidInput.WithDetails("mark ID cannot be empty")
		}
		m1IDs = []string{req.First.MarkID}
	case "tag":
		if req.First.TagID <= 0 {
			return errs.ErrInvalidInput.WithDetails("tag ID must be positive")
		}
		m1IDs, err = s.markRepo.GetMarkIDsByTagID(req.First.TagID)
		if err != nil {
			return errs.ErrDatabase.WithDetails(err.Error())
		}
	case "type":
		if req.First.TypeID <= 0 {
			return errs.ErrInvalidInput.WithDetails("type ID must be positive")
		}
		m1IDs, err = s.markRepo.GetMarkIDsByTypeID(req.First.TypeID)
		if err != nil {
			return errs.ErrDatabase.WithDetails(err.Error())
		}
	default:
		return errs.ErrInvalidInput.WithDetails("unknown first condition kind: " + req.First.Kind)
	}

	// 处理第二个条件
	switch req.Second.Kind {
	case "mark":
		if req.Second.MarkID == "" {
			return errs.ErrInvalidInput.WithDetails("mark ID cannot be empty")
		}
		m2IDs = []string{req.Second.MarkID}
	case "tag":
		if req.Second.TagID <= 0 {
			return errs.ErrInvalidInput.WithDetails("tag ID must be positive")
		}
		m2IDs, err = s.markRepo.GetMarkIDsByTagID(req.Second.TagID)
		if err != nil {
			return errs.ErrDatabase.WithDetails(err.Error())
		}
	case "type":
		if req.Second.TypeID <= 0 {
			return errs.ErrInvalidInput.WithDetails("type ID must be positive")
		}
		m2IDs, err = s.markRepo.GetMarkIDsByTypeID(req.Second.TypeID)
		if err != nil {
			return errs.ErrDatabase.WithDetails(err.Error())
		}
	default:
		return errs.ErrInvalidInput.WithDetails("unknown second condition kind: " + req.Second.Kind)
	}

	if len(m1IDs) == 0 {
		return errs.NotFound("MARK", "no mark IDs found for first condition")
	}

	if len(m2IDs) == 0 {
		return errs.NotFound("MARK", "no mark IDs found for second condition")
	}

	err = s.markPairRepo.CartesianUpsertByMarkIDs(m1IDs, m2IDs, distance)
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
