package service

import (
	"IOT-Manage-System/mark-service/model"
	"IOT-Manage-System/mark-service/repo"
	"time"
)

type MarkService interface {
	// Mark 相关操作
	CreateMark(mark *model.MarkRequest) error
	GetMarkByID(id string, preload bool) (*model.MarkResponse, error)
	GetMarkByDeviceID(deviceID string, preload bool) (*model.MarkResponse, error)
	ListMark(page, limit int, preload bool) ([]model.MarkResponse, int64, error)
	UpdateMark(ID string, req *model.MarkUpdateRequest) error
	DeleteMark(id string) error
	UpdateMarkLastOnline(deviceID string, t time.Time) error
	GetPersistMQTTByDeviceID(deviceID string) (bool, error)
	GetMarksByPersistMQTT(persist bool, page, limit int, preload bool) ([]model.MarkResponse, int64, error)
	GetDeviceIDsByPersistMQTT(persist bool) ([]string, error)

	// MarkTag 相关操作
	CreateMarkTag(mt *model.MarkTagRequest) error
	GetMarkTagByID(id int) (*model.MarkTagResponse, error)
	GetMarkTagByName(name string) (*model.MarkTagResponse, error)
	ListMarkTags(page, limit int) ([]model.MarkTagResponse, int64, error)
	UpdateMarkTag(tag *model.MarkTagRequest) error
	DeleteMarkTag(id int) error
	GetMarksByTagID(tagID int, page, limit int, preload bool) ([]model.MarkResponse, int64, error)
	GetMarksByTagName(tagName string, page, limit int, preload bool) ([]model.MarkResponse, int64, error)

	// MarkType 相关操作
	CreateMarkType(mt *model.MarkTypeRequest) error
	GetMarkTypeByID(id int) (*model.MarkTypeResponse, error)
	GetMarkTypeByName(name string) (*model.MarkTypeResponse, error)
	ListMarkTypes(page, limit int) ([]model.MarkTypeResponse, int64, error)
	UpdateMarkType(mt *model.MarkTypeRequest) error
	DeleteMarkType(id int) error
	GetMarksByTypeID(typeID int, page, limit int, preload bool) ([]model.MarkResponse, int64, error)
	GetMarksByTypeName(typeName string, page, limit int, preload bool) ([]model.MarkResponse, int64, error)
}

type markService struct {
	repo repo.MarkRepo
}

func NewMarkService(repo repo.MarkRepo) MarkService {
	return &markService{repo: repo}
}
