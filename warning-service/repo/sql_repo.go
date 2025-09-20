package repo

import (
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"

	"IOT-Manage-System/warning-service/config"
	"IOT-Manage-System/warning-service/model"
)

type MarkRepo struct {
	db *gorm.DB
}

func NewMarkRepo(db *gorm.DB) *MarkRepo {
	return &MarkRepo{db: db}
}

func (r *MarkRepo) SetOnline(deviceID string, t ...time.Time) error {
	onlineAt := time.Now()
	if len(t) > 0 {
		onlineAt = t[0]
	}
	return r.db.Model(&model.Mark{}).
		Where("device_id = ?", deviceID).
		Update("last_online_at", onlineAt).Error
}

func (r *MarkRepo) GetOnlineList() ([]string, error) {
	cutoff := time.Now().Add(-time.Duration(config.C.AppConfig.OnlineSecond) * time.Second)

	var ids []string
	err := r.db.Model(&model.Mark{}).
		Where("last_online_at >= ?", cutoff).
		Pluck("device_id", &ids).Error
	return ids, err
}

func (r *MarkRepo) IsOnline(deviceID string) (bool, error) {
	cutoff := time.Now().Add(-time.Duration(config.C.AppConfig.OnlineSecond) * time.Second)

	var count int64
	err := r.db.Model(&model.Mark{}).
		Where("device_id = ?", deviceID).
		Where("last_online_at >= ?", cutoff).
		Count(&count).Error

	return count > 0, err
}

func (r *MarkRepo) GetDangerZoneM(deviceID string) (float64, error) {
	var dangerZoneM *float64 // 注意是指针，因为数据库中可能是 NULL

	err := r.db.Model(&model.Mark{}).
		Where("device_id = ?", deviceID).
		Select("safe_distance_m").
		Scan(&dangerZoneM).Error

	if err != nil {
		return 0, err
	}

	if dangerZoneM == nil {
		return -1, nil // 或返回 mark_types 的默认值
	}

	return *dangerZoneM, nil
}

func (r *MarkRepo) GetBatchDangerZoneM(deviceIDs []string) (map[string]float64, error) {
	if len(deviceIDs) == 0 {
		return map[string]float64{}, nil
	}

	// 临时结构体接收查询结果
	type row struct {
		DeviceID    string
		DangerZoneM *float64
	}
	var rows []row

	// 批量查询
	err := r.db.Model(&model.Mark{}).
		Where("device_id IN ?", deviceIDs).
		Select("device_id", "safe_distance_m").
		Scan(&rows).Error
	if err != nil {
		return nil, err
	}

	// 构造返回映射
	out := make(map[string]float64, len(rows))
	for _, v := range rows {
		val := -1.0 // 默认值：-1 表示使用 mark_types 的默认安全距离
		if v.DangerZoneM != nil {
			val = *v.DangerZoneM
		}
		out[v.DeviceID] = val
	}
	return out, nil
}

func (r *MarkRepo) MapByID(id string) (map[string]float64, error) {
	uid, err := uuid.Parse(id)
	if err != nil {
		return nil, fmt.Errorf("invalid mark id: %w", err)
	}
	var list []struct {
		OtherID   uuid.UUID
		DistanceM float64
	}
	// 把自己放在 mark1_id 或 mark2_id 的情况都查出来
	if err := r.db.Raw(`
		SELECT mark2_id AS other_id, distance_m FROM mark_pair_safe_distance WHERE mark1_id = ?
		UNION ALL
		SELECT mark1_id AS other_id, distance_m FROM mark_pair_safe_distance WHERE mark2_id = ?
	`, uid, uid).Scan(&list).Error; err != nil {
		return nil, err
	}
	m := make(map[string]float64, len(list))
	for _, v := range list {
		m[v.OtherID.String()] = v.DistanceM
	}
	return m, nil
}

func (r *MarkRepo) GetDistanceMapByDevice(deviceID string) (map[string]float64, error) {
	var id string
	if err := r.db.Model(&model.Mark{}).Where("device_id = ?", deviceID).Select("id").Scan(&id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return map[string]float64{}, nil
		}
		return nil, err
	}
	return r.MapByID(id)
}

func (r *MarkRepo) GetDistanceByDevice(deviceIDs []string) ([]model.MarkPairSafeDistance, error) {
	var markIDs []string
	var results []model.MarkPairSafeDistance

	err := r.db.Model(&model.Mark{}).
		Where("device_id IN ?", deviceIDs).
		Pluck("id", &markIDs).Error
	if err != nil {
		return results, err
	}

	err = r.db.Model(&model.MarkPairSafeDistance{}).
		Where("mark1_id IN ? OR mark2_id IN ?", markIDs, markIDs).
		Find(&results).Error

	return results, err
}
