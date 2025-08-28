package utils

import (
	"net/http"
)

// UserHeader 网关透传的用户信息
type UserHeader struct {
	ID       string
	Username string
	UserType string
}

// ExtractUserFromHeader 从 http.Header 提取网关注入的信息
func ExtractUserFromHeader(h http.Header) (UserHeader, bool) {
	id := h.Get("X-UserID")
	name := h.Get("X-UserName")
	typ := h.Get("X-UserType")
	if id == "" || name == "" || typ == "" {
		return UserHeader{}, false
	}
	return UserHeader{
		ID:       id,
		Username: name,
		UserType: typ,
	}, true
}

// GetUserID 只取 X-UserID
func GetUserID(h http.Header) string {
	return h.Get("X-UserID")
}

// GetUserName 只取 X-UserName
func GetUserName(h http.Header) string {
	return h.Get("X-UserName")
}

// GetUserType 只取 X-UserType
func GetUserType(h http.Header) string {
	return h.Get("X-UserType")
}
