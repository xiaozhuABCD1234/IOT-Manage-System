package utils

import (
	"IOT-Manage-System/api-gateway/models"
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

const (
	AccessTokenExpire  = 24 * time.Hour
	RefreshTokenExpire = 7 * 24 * time.Hour
	AccessTokenIssuer  = "user-access"
	RefreshTokenIssuer = "user-refresh"
)

var (
	jwtSecret       = []byte(GetEnv("JWT_SECRET", "your-secret-key"))
	ErrInvalidToken = errors.New("invalid token")
)

type CustomClaims struct {
	UserID   string          `json:"user_id"`
	Username string          `json:"username"`
	UserType models.UserType `json:"user_type"`
	jwt.RegisteredClaims
}

// 生成 token 的公共方法
func generateToken(u *models.User, expiresIn time.Duration, issuer string) (string, error) {
	claims := CustomClaims{
		UserID:   u.ID,
		Username: u.Username,
		UserType: u.UserType,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(expiresIn)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    issuer,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(jwtSecret)
}

// 生成 access token（有效期 24 小时）
func GenerateToken(u *models.User) (string, error) {
	return generateToken(u, AccessTokenExpire, AccessTokenIssuer)
}

// 生成 refresh token（有效期 7 天）
func GenerateRefreshToken(u *models.User) (string, error) {
	return generateToken(u, RefreshTokenExpire, RefreshTokenIssuer)
}

// 解析 access token
func ParseAccessToken(tokenString string) (*CustomClaims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &CustomClaims{}, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrInvalidToken
		}
		return jwtSecret, nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(*CustomClaims); ok && token.Valid {
		if claims.Issuer != AccessTokenIssuer {
			return nil, ErrInvalidToken
		}
		return claims, nil
	}

	return nil, ErrInvalidToken
}

// 刷新 access token
func RefreshAccessToken(refreshToken string) (string, error) {
	// 解析 refresh token
	token, err := jwt.ParseWithClaims(refreshToken, &CustomClaims{}, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrInvalidToken
		}
		return jwtSecret, nil
	})

	if err != nil || !token.Valid {
		return "", ErrInvalidToken
	}

	claims, ok := token.Claims.(*CustomClaims)
	if !ok || claims.Issuer != RefreshTokenIssuer {
		return "", ErrInvalidToken
	}

	// 重新生成 access token
	user := &models.User{
		ID:       claims.UserID,
		Username: claims.Username,
		UserType: claims.UserType,
	}

	return GenerateToken(user)
}
