package service

import "errors"

// ========= 用户 & 认证 =========
var (
	ErrInvalidInput  = errors.New("参数错误")
	ErrUserExists    = errors.New("用户已存在")
	ErrUserNotFound  = errors.New("用户不存在")
	ErrWrongPassword = errors.New("密码错误")
	ErrTokenExpired  = errors.New("令牌已过期")
	ErrTokenInvalid  = errors.New("令牌无效")
	ErrUnauthorized  = errors.New("未授权访问")
	ErrForbidden     = errors.New("权限不足")
)

// ========= 资源 =========
var (
	ErrResourceNotFound  = errors.New("资源不存在")
	ErrResourceConflict  = errors.New("资源冲突")
	ErrResourceExhausted = errors.New("资源耗尽")
	ErrUploadFailed      = errors.New("文件上传失败")
	ErrFileTooLarge      = errors.New("文件过大")
	ErrUnsupportedFormat = errors.New("不支持的文件格式")
)

// ========= 业务规则 =========
var (
	ErrStatusConflict   = errors.New("状态冲突")
	ErrDuplicateAction  = errors.New("重复操作")
	ErrQuotaExceeded    = errors.New("配额超限")
	ErrOperationTimeout = errors.New("操作超时")
	ErrInvalidToken     = errors.New("错误Token")
)

// ========= 系统 & 网络 =========
var (
	ErrInternal   = errors.New("内部错误")
	ErrDatabase   = errors.New("数据库异常")
	ErrCache      = errors.New("缓存异常")
	ErrNetwork    = errors.New("网络异常")
	ErrThirdParty = errors.New("第三方服务异常")
	ErrConfig     = errors.New("配置错误")
)

// ========= 校验 =========
var (
	ErrValidationFailed = errors.New("数据校验失败")
	ErrCaptchaFailed    = errors.New("验证码错误")
	ErrTooManyRequests  = errors.New("请求过于频繁")
)
