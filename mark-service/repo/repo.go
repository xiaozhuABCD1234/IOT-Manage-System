// repository/repo.go
package repo

import (
	"IOT-Manage-System/mark-service/model"
	"time"

	"gorm.io/gorm"
)

// MarkRepo 定义了 Mark 相关数据访问的接口
type MarkRepo interface {
	// Mark 相关操作
	CreateMark(mark *model.Mark) error
	CreateMarkAutoTag(mark *model.Mark, tagNames []string) error
	GetMarkByID(id string, preload bool) (*model.Mark, error)
	GetMarkByDeviceID(deviceID string, preload bool) (*model.Mark, error)
	// ListMark 列表查询，支持预加载和分页
	ListMark(offset, limit int, preload bool) ([]model.Mark, error)
	// ListMarkWithCount 列表查询，支持预加载、分页，并返回总记录数
	ListMarkWithCount(offset, limit int, preload bool) ([]model.Mark, int64, error)
	UpdateMark(mark *model.Mark, tagNames []string) error
	DeleteMark(id string) error
	UpdateMarkLastOnline(deviceID string, t time.Time) error
	GetMarksByPersistMQTT(persist bool, preload bool, offset, limit int) ([]model.Mark, int64, error)
	GetPersistMQTTByDeviceID(deviceID string) (bool, error)
	GetDeviceIDsByPersistMQTT(persist bool) ([]string, error)
	GetAllMarkDeviceIDsAndNames() (map[string]string, error)
	GetAllMarkIDsAndNames() (map[string]string, error)

	// MarkTag 相关操作
	CreateMarkTag(mt *model.MarkTag) error
	GetMarkTagByID(id int) (*model.MarkTag, error)
	GetMarkTagByName(name string) (*model.MarkTag, error)
	// ListMarkTags 列表查询，支持分页
	ListMarkTags(offset, limit int) ([]model.MarkTag, error)
	// ListMarkTagsWithCount 列表查询，支持分页，并返回总记录数
	ListMarkTagsWithCount(offset, limit int) ([]model.MarkTag, int64, error)
	UpdateMarkTag(tag *model.MarkTag) error
	DeleteMarkTag(id int) error
	FindTagsByNames(names []string) ([]model.MarkTag, []string, error)
	GetOrCreateTags(names []string) ([]model.MarkTag, error)
	GetMarksByTagID(tagID int, preload bool, offset, limit int) ([]model.Mark, int64, error)
	GetMarksByTagName(tagName string, preload bool, offset, limit int) ([]model.Mark, int64, error)
	GetMarkIDsByTagID(tagID int) ([]string, error)
	GetAllTagIDsAndNames() (map[int]string, error)

	// MarkType 相关操作
	CreateMarkType(mt *model.MarkType) error
	GetMarkTypeByID(id int) (*model.MarkType, error)
	GetMarkTypeByName(name string) (*model.MarkType, error)
	// ListMarkTypes 列表查询，支持分页
	ListMarkTypes(offset, limit int) ([]model.MarkType, error)
	// ListMarkTypesWithCount 列表查询，支持分页，并返回总记录数
	ListMarkTypesWithCount(offset, limit int) ([]model.MarkType, int64, error)
	UpdateMarkType(mt *model.MarkType) error
	DeleteMarkType(id int) error
	GetMarksByTypeID(typeID int, preload bool, offset, limit int) ([]model.Mark, int64, error)
	GetMarksByTypeName(typeName string, preload bool, offset, limit int) ([]model.Mark, int64, error)
	GetMarkIDsByTypeID(typeID int) ([]string, error)
	GetAllTypeIDsAndNames() (map[int]string, error)

	//MarkPairSafeDistance
	// Upsert(mark1ID, mark2ID string, safeDistanceM float64) error
	// BatchUpsert(markIDs []string, safeDistanceM float64)
	// CartesianUpsertByMarkIDs(m1IDs, m2IDs []string, safeDistanceM float64) error
	// Get(m1, m2 string) (float64, error)
	// Delete(m1, m2 string) error
	// MapByID(id string) (map[string]float64, error)
	// MapByDeviceID(device_id string) (map[string]float64, error)

	// 判断重复字段
	IsDeviceIDExists(deviceID string) (bool, error)
	IsMarkNameExists(markName string) (bool, error)
	IsTagNameExists(tagName string) (bool, error)
	IsTypeNameExists(typeName string) (bool, error)
}

// markRepo 是接口的具体实现
type markRepo struct {
	db *gorm.DB
}

// NewMarkRepo 返回 MarkRepository 接口实例
func NewMarkRepo(db *gorm.DB) MarkRepo {
	return &markRepo{db: db}
}
