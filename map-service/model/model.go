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

// CustomMap 对应表 custom_maps
type CustomMap struct {
	ID          uuid.UUID `gorm:"column:id;type:uuid;primaryKey;default:gen_random_uuid()"`
	MapName     string    `gorm:"column:map_name;type:varchar(255);not null"`
	ImagePath   string    `gorm:"column:image_path;type:varchar(500);not null"`
	XMin        float64   `gorm:"column:x_min;type:double precision;not null"`
	XMax        float64   `gorm:"column:x_max;type:double precision;not null"`
	YMin        float64   `gorm:"column:y_min;type:double precision;not null"`
	YMax        float64   `gorm:"column:y_max;type:double precision;not null"`
	CenterX     float64   `gorm:"column:center_x;type:double precision;not null"`
	CenterY     float64   `gorm:"column:center_y;type:double precision;not null"`
	Description string    `gorm:"column:description;type:text"`
	CreatedAt   time.Time `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt   time.Time `gorm:"column:updated_at;not null;autoUpdateTime"`
}

func (CustomMap) TableName() string {
	return "custom_maps"
}

type CustomMapCreateReq struct {
	MapName     string  `json:"map_name" validate:"required,min=1,max=255"`
	XMin        float64 `json:"x_min" validate:"required"`
	XMax        float64 `json:"x_max" validate:"required"`
	YMin        float64 `json:"y_min" validate:"required"`
	YMax        float64 `json:"y_max" validate:"required"`
	CenterX     float64 `json:"center_x" validate:"required"`
	CenterY     float64 `json:"center_y" validate:"required"`
	Description string  `json:"description,omitempty" validate:"omitempty,max=1000"`
}

type CustomMapUpdateReq struct {
	MapName     *string  `json:"map_name,omitempty" validate:"omitempty,min=1,max=255"`
	XMin        *float64 `json:"x_min,omitempty" validate:"omitempty"`
	XMax        *float64 `json:"x_max,omitempty" validate:"omitempty"`
	YMin        *float64 `json:"y_min,omitempty" validate:"omitempty"`
	YMax        *float64 `json:"y_max,omitempty" validate:"omitempty"`
	CenterX     *float64 `json:"center_x,omitempty" validate:"omitempty"`
	CenterY     *float64 `json:"center_y,omitempty" validate:"omitempty"`
	Description *string  `json:"description,omitempty" validate:"omitempty,max=1000"`
}

type CustomMapResp struct {
	ID          string    `json:"id"`
	MapName     string    `json:"map_name"`
	ImagePath   string    `json:"image_path"`
	ImageURL    string    `json:"image_url"`
	XMin        float64   `json:"x_min"`
	XMax        float64   `json:"x_max"`
	YMin        float64   `json:"y_min"`
	YMax        float64   `json:"y_max"`
	CenterX     float64   `json:"center_x"`
	CenterY     float64   `json:"center_y"`
	Description string    `json:"description"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// CustomMapToCustomMapResp 将 CustomMap 转换为 CustomMapResp
func CustomMapToCustomMapResp(customMap *CustomMap, baseURL string) *CustomMapResp {
	return &CustomMapResp{
		ID:          customMap.ID.String(),
		MapName:     customMap.MapName,
		ImagePath:   customMap.ImagePath,
		ImageURL:    baseURL + customMap.ImagePath,
		XMin:        customMap.XMin,
		XMax:        customMap.XMax,
		YMin:        customMap.YMin,
		YMax:        customMap.YMax,
		CenterX:     customMap.CenterX,
		CenterY:     customMap.CenterY,
		Description: customMap.Description,
		CreatedAt:   customMap.CreatedAt,
		UpdatedAt:   customMap.UpdatedAt,
	}
}
