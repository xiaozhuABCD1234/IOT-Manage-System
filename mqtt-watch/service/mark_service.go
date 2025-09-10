package service

import (
	"IOT-Manage-System/mqtt-watch/errs"
	// "IOT-Manage-System/mqtt-watch/model"
	"IOT-Manage-System/mqtt-watch/repo"
	// "time"
)

type MarkService interface {
	GetPersistMQTTByDeviceID(deviceID string) (bool, error)
	GetDeviceIDsByPersistMQTT(persist bool) ([]string, error)
}

type markService struct {
	repo repo.MarkRepo
}

func NewMarkService(repo repo.MarkRepo) MarkService {
	return &markService{repo: repo}
}

// GetPersistMQTTByDeviceID 根据设备ID查询 PersistMQTT 字段的值
func (s *markService) GetPersistMQTTByDeviceID(deviceID string) (bool, error) {
	persist, err := s.repo.GetPersistMQTTByDeviceID(deviceID)
	if err != nil {
		return false, errs.ErrDatabase.WithDetails(err.Error())
	}
	return persist, nil
}

// GetDeviceIDsByPersistMQTT 根据 PersistMQTT 的值查询所有对应的 DeviceID 列表
func (s *markService) GetDeviceIDsByPersistMQTT(persist bool) ([]string, error) {
	deviceIDs, err := s.repo.GetDeviceIDsByPersistMQTT(persist)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return deviceIDs, nil
}
