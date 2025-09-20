package model

type LocMsg struct {
	ID   string `json:"id"`
	Sens []Sens `json:"sens"`
}

type Sens struct {
	N string    `json:"n"` // 传感器名称
	U string    `json:"u"` // 单位
	V []float64 `json:"v"` // 数值数组
}

type RTKLoc struct {
	ID     string
	Indoor bool
	Lon    float64
	Lat    float64
}

type UWBLoc struct {
	ID string
	X  float64
	Y  float64
}

type OnlineMsg struct {
	ID string `json:"id"`
}
