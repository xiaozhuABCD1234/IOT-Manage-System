package repo

import (
	"errors"
	"fmt"

	"github.com/google/uuid"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"

	"IOT-Manage-System/mark-service/model"
)

// IMarkPairRepo 标记对安全距离仓库接口
type MarkPairRepo interface {
	// Upsert 插入或更新一对标记的安全距离
	Upsert(mark1ID, mark2ID string, safeDistanceM float64) error
	// BatchUpsert 批量插入或更新多对标记的安全距离（全链接）
	BatchUpsert(ids []string, safeDistanceM float64) error
	// CartesianUpsertByMarkIDs 笛卡尔积方式批量插入或更新标记对安全距离
	CartesianUpsertByMarkIDs(m1IDs, m2IDs []string, safeDistanceM float64) error
	// Get 查询单条安全距离
	Get(mark1ID, mark2ID string) (float64, error)
	// Delete 删除单条记录
	Delete(mark1ID, mark2ID string) error
	// MapByID 根据 MarkID 查询它与所有其它 Mark 的安全距离映射
	MapByID(id string) (map[string]float64, error)
	// MapByDeviceID 根据 DeviceID 查询它与所有其它 Mark 的安全距离映射
	MapByDeviceID(deviceID string) (map[string]float64, error)
}

// MarkPairRepo 标记对安全距离仓库实现
type markPairRepo struct {
	db *gorm.DB
}

// 确保 MarkPairRepo 实现了 IMarkPairRepo 接口

func NewMarkPairRepo(db *gorm.DB) MarkPairRepo {
	return &markPairRepo{db: db}
}

// --------------------------------------------------
// 单条 Upsert
// --------------------------------------------------
func (r *markPairRepo) Upsert(mark1ID, mark2ID string, safeDistanceM float64) error {
	pair, err := normalizePair(mark1ID, mark2ID, safeDistanceM)
	if err != nil {
		return err
	}
	return r.db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "mark1_id"}, {Name: "mark2_id"}},
		UpdateAll: true,
	}).Create(&pair).Error
}

// --------------------------------------------------
// 批量按索引一一配对 Upsert
// --------------------------------------------------
func (r *markPairRepo) BatchUpsert(ids []string, safeDistanceM float64) error {
	n := len(ids)
	if n < 2 {
		return nil // 不足两条，无组合
	}

	batch := make([]model.MarkPairSafeDistance, 0, n*(n-1)/2)
	for i := 0; i < n; i++ {
		for j := i + 1; j < n; j++ { // 只取 j > i，避免重复 & 自环
			pair, err := normalizePair(ids[i], ids[j], safeDistanceM)
			if err != nil {
				return err
			}
			batch = append(batch, pair)
		}
	}

	return r.db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "mark1_id"}, {Name: "mark2_id"}},
		UpdateAll: true,
	}).CreateInBatches(&batch, 200).Error
}

// --------------------------------------------------
// 笛卡尔积 Upsert
// --------------------------------------------------
func (r *markPairRepo) CartesianUpsertByMarkIDs(m1IDs, m2IDs []string, safeDistanceM float64) error {
	pairs := make([]model.MarkPairSafeDistance, 0, len(m1IDs)*len(m2IDs))
	for _, id1 := range m1IDs {
		for _, id2 := range m2IDs {
			if id1 == id2 {
				continue
			}
			pair, err := normalizePair(id1, id2, safeDistanceM)
			if err != nil {
				return err
			}
			pairs = append(pairs, pair)
		}
	}
	return r.db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "mark1_id"}, {Name: "mark2_id"}},
		UpdateAll: true,
	}).CreateInBatches(&pairs, 200).Error
}

// --------------------------------------------------
// 查询单条距离
// --------------------------------------------------
func (r *markPairRepo) Get(mark1ID, mark2ID string) (float64, error) {
	id1, id2, err := mustUUIDPair(mark1ID, mark2ID)
	if err != nil {
		return 0, err
	}
	var pair model.MarkPairSafeDistance
	if err := r.db.Where("mark1_id = ? AND mark2_id = ?", id1, id2).First(&pair).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return 0, nil // 未配置时视为 0
		}
		return 0, err
	}
	return pair.DistanceM, nil
}

// --------------------------------------------------
// 删除单条记录
// --------------------------------------------------
func (r *markPairRepo) Delete(mark1ID, mark2ID string) error {
	id1, id2, err := mustUUIDPair(mark1ID, mark2ID)
	if err != nil {
		return err
	}
	return r.db.Where("mark1_id = ? AND mark2_id = ?", id1, id2).Delete(&model.MarkPairSafeDistance{}).Error
}

// --------------------------------------------------
// 根据 MarkID 查询「它与所有其它 Mark」的安全距离映射
// key = 对端 MarkID，value = 距离（米）
// --------------------------------------------------
func (r *markPairRepo) MapByID(id string) (map[string]float64, error) {
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

// --------------------------------------------------
// 根据 DeviceID 查询「它与所有其它 Mark」的安全距离映射
// 先通过 marks 表把 device_id -> mark_id，再复用 MapByID 逻辑
// --------------------------------------------------
func (r *markPairRepo) MapByDeviceID(deviceID string) (map[string]float64, error) {
	var id string
	if err := r.db.Model(&model.Mark{}).Where("device_id = ?", deviceID).Select("id").Scan(&id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return map[string]float64{}, nil
		}
		return nil, err
	}
	return r.MapByID(id)
}

// --------------------------------------------------
// 内部工具
// --------------------------------------------------
// normalizePair 把两个字符串 ID 转成 UUID 并归一化顺序
func normalizePair(id1, id2 string, distance float64) (model.MarkPairSafeDistance, error) {
	uid1, err := uuid.Parse(id1)
	if err != nil {
		return model.MarkPairSafeDistance{}, fmt.Errorf("invalid mark1ID: %w", err)
	}
	uid2, err := uuid.Parse(id2)
	if err != nil {
		return model.MarkPairSafeDistance{}, fmt.Errorf("invalid mark2ID: %w", err)
	}
	if uid1.String() > uid2.String() {
		uid1, uid2 = uid2, uid1
	}
	return model.MarkPairSafeDistance{Mark1ID: uid1, Mark2ID: uid2, DistanceM: distance}, nil
}

func mustUUIDPair(id1, id2 string) (uuid.UUID, uuid.UUID, error) {
	uid1, err := uuid.Parse(id1)
	if err != nil {
		return uuid.UUID{}, uuid.UUID{}, fmt.Errorf("invalid mark1ID: %w", err)
	}
	uid2, err := uuid.Parse(id2)
	if err != nil {
		return uuid.UUID{}, uuid.UUID{}, fmt.Errorf("invalid mark2ID: %w", err)
	}
	if uid1.String() > uid2.String() {
		uid1, uid2 = uid2, uid1
	}
	return uid1, uid2, nil
}
