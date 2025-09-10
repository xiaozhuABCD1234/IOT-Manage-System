// service/mongo_service.go
package service

import (
	"IOT-Manage-System/mqtt-watch/model"
	"IOT-Manage-System/mqtt-watch/repo"
)

// 定义接口 -
type MongoService interface {
	SaveDeviceLoc(loc model.DeviceLoc) error
}

// 实现层 -------------------------------------------------
type mongoService struct {
	deviceLocRepo repo.MongoRepo // 接口依赖
}

// 构造函数 ----------------------------------------------
func NewMongoService(dr repo.MongoRepo) MongoService {
	return &mongoService{deviceLocRepo: dr}
}

// 业务方法 ----------------------------------------------
func (s *mongoService) SaveDeviceLoc(loc model.DeviceLoc) error {
	return s.deviceLocRepo.CreateLoc(loc)
}
