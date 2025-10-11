package model

import (
	"time"

	"github.com/google/uuid"
)

// Station 对应表 base_stations
type Station struct {
	ID          uuid.UUID `gorm:"column:id;type:uuid;primaryKey;default:gen_random_uuid()"`
	StationName string    `gorm:"column:station_name;type:varchar(255);not null"`
	LocationX   float64   `gorm:"column:location_x;type:double precision;not null"`
	LocationY   float64   `gorm:"column:location_y;type:double precision;not null"`
	CreatedAt   time.Time `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt   time.Time `gorm:"column:updated_at;not null;autoUpdateTime"`
}

func (Station) TableName() string {
	return "base_stations"
}

type StationCreateReq struct {
	StationName string  `json:"station_name"`
	LocationX   float64 `json:"location_x"`
	LocationY   float64 `json:"location_y"`
}

type StationUpdateReq struct {
	StationName *string  `json:"stationName,omitempty"`
	LocationX   *float64 `json:"locationX,omitempty"`
	LocationY   *float64 `json:"locationY,omitempty"`
}

type StationResp struct {
	ID          string    `json:"id"`
	StationName string    `json:"station_name"`
	LocationX   float64   `json:"location_x"`
	LocationY   float64   `json:"location_y"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// StationToStationResp 将 Station 转换为 StationResp
func StationToStationResp(station *Station) *StationResp {
	return &StationResp{
		ID:          station.ID.String(),
		StationName: station.StationName,
		LocationX:   station.LocationX,
		LocationY:   station.LocationY,
		CreatedAt:   station.CreatedAt,
		UpdatedAt:   station.UpdatedAt,
	}
}

// StationCreateReqToStation 将 StationCreateReq 转换为 Station
func StationCreateReqToStation(req *StationCreateReq) *Station {
	return &Station{
		StationName: req.StationName,
		LocationX:   req.LocationX,
		LocationY:   req.LocationY,
	}
}

// StationUpdateReqToStation 将 StationUpdateReq 转换为 Station
func StationUpdateReqToStation(req *StationUpdateReq) *Station {
	return &Station{
		StationName: *req.StationName,
		LocationX:   *req.LocationX,
		LocationY:   *req.LocationY,
	}
}
