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
	CoordinateX float64 `json:"coordinate_x"` // X坐标（允许0值）
	CoordinateY float64 `json:"coordinate_y"` // Y坐标（允许0值）
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
	ImagePath   string    `gorm:"column:image_path;type:varchar(500)"` // 允许为空
	XMin        float64   `gorm:"column:x_min;type:double precision;not null"`
	XMax        float64   `gorm:"column:x_max;type:double precision;not null"`
	YMin        float64   `gorm:"column:y_min;type:double precision;not null"`
	YMax        float64   `gorm:"column:y_max;type:double precision;not null"`
	CenterX     float64   `gorm:"column:center_x;type:double precision;not null"`
	CenterY     float64   `gorm:"column:center_y;type:double precision;not null"`
	ScaleRatio  float64   `gorm:"column:scale_ratio;type:double precision;not null;default:1.0"` // 底图缩放比例
	Description string    `gorm:"column:description;type:text"`
	CreatedAt   time.Time `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt   time.Time `gorm:"column:updated_at;not null;autoUpdateTime"`
}

func (CustomMap) TableName() string {
	return "custom_maps"
}

type CustomMapCreateReq struct {
	MapName     string  `json:"map_name" validate:"required,min=1,max=255"`
	ImageBase64 string  `json:"image_base64,omitempty"`                                                    // Base64编码的图片数据（可选）
	ImageExt    string  `json:"image_ext,omitempty" validate:"omitempty,oneof=.jpg .jpeg .png .gif .webp"` // 图片扩展名（如果提供图片则必填）
	XMin        float64 `json:"x_min"`                                                                     // 允许0值
	XMax        float64 `json:"x_max"`                                                                     // 允许0值
	YMin        float64 `json:"y_min"`                                                                     // 允许0值
	YMax        float64 `json:"y_max"`                                                                     // 允许0值
	CenterX     float64 `json:"center_x"`                                                                  // 允许0值
	CenterY     float64 `json:"center_y"`                                                                  // 允许0值
	ScaleRatio  float64 `json:"scale_ratio" validate:"omitempty,gt=0"`                                     // 底图缩放比例（默认1.0）
	Description string  `json:"description,omitempty" validate:"omitempty,max=1000"`
}

type CustomMapUpdateReq struct {
	MapName     *string  `json:"map_name,omitempty" validate:"omitempty,min=1,max=255"`
	ImageBase64 *string  `json:"image_base64,omitempty"`                                                    // Base64编码的图片数据（可选）
	ImageExt    *string  `json:"image_ext,omitempty" validate:"omitempty,oneof=.jpg .jpeg .png .gif .webp"` // 图片扩展名（如果更新图片则必填）
	XMin        *float64 `json:"x_min,omitempty" validate:"omitempty"`
	XMax        *float64 `json:"x_max,omitempty" validate:"omitempty"`
	YMin        *float64 `json:"y_min,omitempty" validate:"omitempty"`
	YMax        *float64 `json:"y_max,omitempty" validate:"omitempty"`
	CenterX     *float64 `json:"center_x,omitempty" validate:"omitempty"`
	CenterY     *float64 `json:"center_y,omitempty" validate:"omitempty"`
	ScaleRatio  *float64 `json:"scale_ratio,omitempty" validate:"omitempty,gt=0"` // 底图缩放比例
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
	ScaleRatio  float64   `json:"scale_ratio"` // 底图缩放比例
	Description string    `json:"description"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// CustomMapToCustomMapResp 将 CustomMap 转换为 CustomMapResp
func CustomMapToCustomMapResp(customMap *CustomMap, baseURL string) *CustomMapResp {
	imageURL := ""
	if customMap.ImagePath != "" {
		imageURL = baseURL + customMap.ImagePath
	}
	return &CustomMapResp{
		ID:          customMap.ID.String(),
		MapName:     customMap.MapName,
		ImagePath:   customMap.ImagePath,
		ImageURL:    imageURL,
		XMin:        customMap.XMin,
		XMax:        customMap.XMax,
		YMin:        customMap.YMin,
		YMax:        customMap.YMax,
		CenterX:     customMap.CenterX,
		CenterY:     customMap.CenterY,
		ScaleRatio:  customMap.ScaleRatio,
		Description: customMap.Description,
		CreatedAt:   customMap.CreatedAt,
		UpdatedAt:   customMap.UpdatedAt,
	}
}

// PolygonFence 多边形电子围栏
type PolygonFence struct {
	ID          uuid.UUID `gorm:"column:id;type:uuid;primaryKey;default:gen_random_uuid()"`
	IsIndoor    bool      `gorm:"column:is_indoor;not null;default:true"` // FALSE=室外，TRUE=室内
	FenceName   string    `gorm:"column:fence_name;type:varchar(255);not null;uniqueIndex"`
	Geometry    string    `gorm:"column:geometry;type:geometry(POLYGON,0);not null"` // WKT格式
	Description string    `gorm:"column:description;type:text"`
	IsActive    bool      `gorm:"column:is_active;default:true"`
	CreatedAt   time.Time `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt   time.Time `gorm:"column:updated_at;not null;autoUpdateTime"`
}

func (PolygonFence) TableName() string {
	return "polygon_fences"
}

// Point 坐标点
type Point struct {
	X float64 `json:"x"` // 允许0值
	Y float64 `json:"y"` // 允许0值
}

// PolygonFenceCreateReq 创建多边形围栏请求
type PolygonFenceCreateReq struct {
	IsIndoor    bool    `json:"is_indoor"` // FALSE=室外，TRUE=室内
	FenceName   string  `json:"fence_name" validate:"required,min=1,max=255"`
	Points      []Point `json:"points" validate:"required,min=3"` // 至少3个点才能构成多边形
	Description string  `json:"description,omitempty" validate:"omitempty,max=1000"`
}

// PolygonFenceUpdateReq 更新多边形围栏请求
type PolygonFenceUpdateReq struct {
	IsIndoor    *bool    `json:"is_indoor,omitempty"` // FALSE=室外，TRUE=室内
	FenceName   *string  `json:"fence_name,omitempty" validate:"omitempty,min=1,max=255"`
	Points      *[]Point `json:"points,omitempty" validate:"omitempty,min=3"`
	Description *string  `json:"description,omitempty" validate:"omitempty,max=1000"`
	IsActive    *bool    `json:"is_active,omitempty"`
}

// PolygonFenceResp 多边形围栏响应
type PolygonFenceResp struct {
	ID          string    `json:"id"`
	IsIndoor    bool      `json:"is_indoor"` // FALSE=室外，TRUE=室内
	FenceName   string    `json:"fence_name"`
	Points      []Point   `json:"points"` // 多边形顶点
	Description string    `json:"description"`
	IsActive    bool      `json:"is_active"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

// PointCheckReq 检查点是否在围栏内的请求
type PointCheckReq struct {
	X float64 `json:"x"` // 允许0值
	Y float64 `json:"y"` // 允许0值
}

// PointCheckResp 检查点是否在围栏内的响应
type PointCheckResp struct {
	IsInside   bool     `json:"is_inside"`
	FenceID    string   `json:"fence_id,omitempty"`
	FenceName  string   `json:"fence_name,omitempty"`
	FenceNames []string `json:"fence_names,omitempty"` // 如果在多个围栏内
}
