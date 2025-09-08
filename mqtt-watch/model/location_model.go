package model

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
	"time"
)

type DeviceLoc struct {
	ID         primitive.ObjectID `bson:"_id,omitempty" json:"-"`
	DeviceID   string             `bson:"device_id" json:"id"`
	Latitude   float64            `bson:"latitude" json:"lat"`
	Longitude  float64            `bson:"longitude" json:"lon"`
	Speed      float64            `bson:"speed,omitempty" json:"speed,omitempty"`
	RecordTime time.Time          `bson:"record_time" json:"record_time"`
	CreatedAt  time.Time          `bson:"created_at" json:"created_at"`
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
