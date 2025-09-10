package model

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
	"time"
)

type DeviceLoc struct {
	ID         primitive.ObjectID `bson:"_id,omitempty" json:"-"`
	Indoor     bool               `bson:"indoor" json:"indoor"`
	DeviceID   string             `bson:"device_id" json:"id"`
	Latitude   *float64           `bson:"latitude,omitempty" json:"lat,omitempty"`
	Longitude  *float64           `bson:"longitude,omitempty" json:"lon,omitempty"`
	UWBX       *float64           `bson:"uwb_x,omitempty" json:"uwb_x,omitempty"` // 局部坐标系 X
	UWBY       *float64           `bson:"uwb_y,omitempty" json:"uwb_y,omitempty"`
	Speed      *float64           `bson:"speed,omitempty" json:"speed,omitempty"`
	RecordTime time.Time          `bson:"record_time" json:"record_time"`
	CreatedAt  time.Time          `bson:"created_at" json:"created_at"`
}

func (d *DeviceLoc) SetID() {
	if d.ID.IsZero() {
		d.ID = primitive.NewObjectID()
	}
}

type LocMsg struct {
	ID   string `json:"id"`
	Sens []Sens `json:"sens"`
}

type Sens struct {
	N string    `json:"n"` // 传感器名称
	U string    `json:"u"` // 单位
	V []float64 `json:"v"` // 数值数组
}
