// errs/appErrors.go
package errs

import (
	"fmt"
	// "net/http"
)

// AppError 统一业务错误类型
type AppError struct {
	Code    string // 业务码
	Message string // 可读信息
	Status  int    // HTTP 状态码
	Details any    // 扩展字段
}

func (e *AppError) Error() string { return e.Message }

// ========= 用户 & 认证 =========
var (
	ErrInvalidInput  = &AppError{"INVALID_INPUT", "参数错误", 400, nil}
	ErrUserExists    = &AppError{"USER_EXISTS", "用户已存在", 409, nil}
	ErrUserNotFound  = &AppError{"USER_NOT_FOUND", "用户不存在", 404, nil}
	ErrWrongPassword = &AppError{"WRONG_PASSWORD", "密码错误", 401, nil}
	ErrTokenExpired  = &AppError{"TOKEN_EXPIRED", "令牌已过期", 401, nil}
	ErrTokenInvalid  = &AppError{"TOKEN_INVALID", "令牌无效", 401, nil}
	ErrUnauthorized  = &AppError{"UNAUTHORIZED", "未授权访问", 401, nil}
	ErrForbidden     = &AppError{"FORBIDDEN", "权限不足", 403, nil}
)

// ========= 资源 =========
var (
	ErrResourceNotFound  = &AppError{"RESOURCE_NOT_FOUND", "资源不存在", 404, nil}
	ErrResourceConflict  = &AppError{"RESOURCE_CONFLICT", "资源冲突", 409, nil}
	ErrResourceExhausted = &AppError{"RESOURCE_EXHAUSTED", "资源耗尽", 429, nil}
	ErrUploadFailed      = &AppError{"UPLOAD_FAILED", "文件上传失败", 500, nil}
	ErrFileTooLarge      = &AppError{"FILE_TOO_LARGE", "文件过大", 413, nil}
	ErrUnsupportedFormat = &AppError{"UNSUPPORTED_FORMAT", "不支持的文件格式", 415, nil}
)

// ========= 业务规则 =========
var (
	ErrStatusConflict   = &AppError{"STATUS_CONFLICT", "状态冲突", 409, nil}
	ErrDuplicateAction  = &AppError{"DUPLICATE_ACTION", "重复操作", 409, nil}
	ErrQuotaExceeded    = &AppError{"QUOTA_EXCEEDED", "配额超限", 429, nil}
	ErrOperationTimeout = &AppError{"OPERATION_TIMEOUT", "操作超时", 408, nil}
	ErrInvalidToken     = &AppError{"INVALID_TOKEN", "错误Token", 401, nil}
)

// ========= 系统 & 网络 =========
var (
	ErrInternal   = &AppError{"INTERNAL_ERROR", "内部错误", 500, nil}
	ErrDatabase   = &AppError{"DATABASE_ERROR", "数据库异常", 500, nil}
	ErrCache      = &AppError{"CACHE_ERROR", "缓存异常", 500, nil}
	ErrNetwork    = &AppError{"NETWORK_ERROR", "网络异常", 503, nil}
	ErrThirdParty = &AppError{"THIRD_PARTY_ERROR", "第三方服务异常", 502, nil}
	ErrConfig     = &AppError{"CONFIG_ERROR", "配置错误", 500, nil}
)

// ========= 校验 =========
var (
	ErrValidationFailed = &AppError{"VALIDATION_FAILED", "数据校验失败", 400, nil}
	ErrCaptchaFailed    = &AppError{"CAPTCHA_FAILED", "验证码错误", 400, nil}
	ErrTooManyRequests  = &AppError{"TOO_MANY_REQUESTS", "请求过于频繁", 429, nil}
)

// 资源已存在（409）
func AlreadyExists(resource, msg string, details ...any) *AppError {
	detail := any(nil)
	if len(details) > 0 {
		detail = details[0]
	}
	return &AppError{
		Code:    fmt.Sprintf("%s_EXISTS", resource),
		Message: msg,
		Status:  409,
		Details: detail,
	}
}

// 资源不存在（404）
func NotFound(resource, msg string, details ...any) *AppError {
	detail := any(nil)
	if len(details) > 0 {
		detail = details[0]
	}
	return &AppError{
		Code:    fmt.Sprintf("%s_NOT_FOUND", resource),
		Message: msg,
		Status:  404,
		Details: detail,
	}
}

// WithDetails 为现有的 AppError 添加详细信息并返回新实例
func (e *AppError) WithDetails(details any) *AppError {
	return &AppError{
		Code:    e.Code,
		Message: e.Message,
		Status:  e.Status,
		Details: details,
	}
}