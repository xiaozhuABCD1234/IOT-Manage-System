package model

// FenceCheckRequest 围栏检查请求
type FenceCheckRequest struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
}

// FenceCheckResponse 围栏检查响应
type FenceCheckResponse struct {
	Success   bool           `json:"success"`
	Message   string         `json:"message"`
	Data      FenceCheckData `json:"data"`
	Timestamp string         `json:"timestamp,omitempty"`
}

// FenceCheckData 围栏检查数据
type FenceCheckData struct {
	IsInside   bool     `json:"is_inside"`
	FenceID    string   `json:"fence_id,omitempty"`
	FenceName  string   `json:"fence_name,omitempty"`
	FenceNames []string `json:"fence_names,omitempty"`
}
