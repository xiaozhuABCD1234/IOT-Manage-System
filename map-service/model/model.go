package model

import (
	"time"

	"github.com/google/uuid"
)

// Station 对应表 base_stations
type Station struct {
	ID          uuid.UUID `gorm:"column:id;type:uuid;primaryKey;default:gen_random_uuid()"`
	StationName string    `gorm:"column:station_name;type:varchar(255);not null"`
	CoordinateX float64   `gorm:"column:location_x;type:double precision;not null"` // X坐标（平面坐标系）
	CoordinateY float64   `gorm:"column:location_y;type:double precision;not null"` // Y坐标（平面坐标系）
	CreatedAt   time.Time `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt   time.Time `gorm:"column:updated_at;not null;autoUpdateTime"`
}

func (Station) TableName() string {
	return "base_stations"
}

type StationCreateReq struct {
	StationName string  `json:"station_name" validate:"required,min=1,max=255"`
	CoordinateX float64 `json:"coordinate_x" validate:"required"` // X坐标
	CoordinateY float64 `json:"coordinate_y" validate:"required"` // Y坐标
}

type StationUpdateReq struct {
	StationName *string  `json:"station_name,omitempty" validate:"omitempty,min=1,max=255"`
	CoordinateX *float64 `json:"coordinate_x,omitempty" validate:"omitempty"` // X坐标
	CoordinateY *float64 `json:"coordinate_y,omitempty" validate:"omitempty"` // Y坐标
}

type StationResp struct {
	ID          string    `json:"id"`
	StationName string    `json:"station_name"`
	CoordinateX float64   `json:"coordinate_x"` // X坐标
	CoordinateY float64   `json:"coordinate_y"` // Y坐标
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// StationToStationResp 将 Station 转换为 StationResp
func StationToStationResp(station *Station) *StationResp {
	return &StationResp{
		ID:          station.ID.String(),
		StationName: station.StationName,
		CoordinateX: station.CoordinateX,
		CoordinateY: station.CoordinateY,
		CreatedAt:   station.CreatedAt,
		UpdatedAt:   station.UpdatedAt,
	}
}

// StationCreateReqToStation 将 StationCreateReq 转换为 Station
func StationCreateReqToStation(req *StationCreateReq) *Station {
	return &Station{
		StationName: req.StationName,
		CoordinateX: req.CoordinateX,
		CoordinateY: req.CoordinateY,
	}
}
