package models

type LoginResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}

// UserHeader 网关透传的用户信息
type UserHeader struct {
	ID       string
	Username string
	UserType string
}

// RefreshTokenRequest 请求体
type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

// RefreshTokenResponse 响应体
type RefreshTokenResponse struct {
	AccessToken string `json:"access_token"`
}
