#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#show: codly-init.with()

// ===== 软著格式页眉 =====
#set page(
  margin: (top: 2.8cm, bottom: 2.5cm, x: 2cm),
  header: context {
    // 0.13 推荐用 context 取代 locate
    if here().page() >= 1 {
      // 正文页码从第 1 页开始才显示页眉
      set text(size: 10.5pt, font: "SimSun")
      "基于RTK与UWB融合定位的物联网管后台系统 V1.0.0"
      h(1fr)
      "第 " + str(counter(page).at(here()).first()) + " 页"
    }
  },
  numbering: none,
)
// ========================


#codly(languages: codly-languages, zebra-fill: none, number-format: none)



#show raw: set text(size: 0.8em)
#show raw: set par(leading: 12em)  // 行间距


```go
package model
type LoginResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
}
type UserHeader struct {
	ID       string
	Username string
	UserType string
}
type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}
type RefreshTokenResponse struct {
	AccessToken string `json:"access_token"`
}
package utils
import (
	"net/http"
	"time"
	"github.com/gin-gonic/gin"
)
type Response struct {
	Success    bool           `json:"success"`
	Data       any            `json:"data,omitempty"`
	Message    string         `json:"message,omitempty"`
	Error      *ErrorObj      `json:"error,omitempty"`
	Pagination *PaginationObj `json:"pagination,omitempty"`
	Timestamp  time.Time      `json:"timestamp"`
}
type ErrorObj struct {
	Code    string `json:"code"`
	Message string `json:"message"`
	Details any    `json:"details,omitempty"`
}
type PaginationObj struct {
	CurrentPage  int   `json:"currentPage"`  
	TotalPages   int   `json:"totalPages"`   
	TotalItems   int64 `json:"totalItems"`   
	ItemsPerPage int   `json:"itemsPerPage"` 
	HasNext      bool  `json:"has_next"`     
	HasPrev      bool  `json:"has_prev"`     
}
func SendSuccessResponse(c *gin.Context, data any, msg ...string) {
	message := "请求成功啦😁"
	if len(msg) > 0 {
		message = msg[0] 
	}
	c.JSON(http.StatusOK, Response{
		Success:   true,
		Data:      data,
		Message:   message, 
		Timestamp: time.Now(),
	})
}
func SendCreatedResponse(c *gin.Context, data any, message string) {
	c.JSON(http.StatusOK, Response{
		Success:   true,
		Data:      data,
		Message:   message,
		Timestamp: time.Now(),
	})
}
func SendPaginatedResponse(c *gin.Context, data any, total int64, page, perPage int) {
	pagination := NewPagination(total, page, perPage)
	c.JSON(http.StatusOK, Response{
		Success:    true,
		Data:       data,
		Message:    "请求成功啦😁",
		Pagination: pagination,
		Timestamp:  time.Now(),
	})
}
func NewPagination(total int64, page, perPage int) *PaginationObj {
	if perPage <= 0 {
		perPage = 10
	}
	totalPages := int((total + int64(perPage) - 1) / int64(perPage))
	return &PaginationObj{
		CurrentPage:  page,
		TotalPages:   totalPages,
		TotalItems:   total,
		ItemsPerPage: perPage,
		HasNext:      page < totalPages,
		HasPrev:      page > 1,
	}
}
func SendErrorResponse(c *gin.Context, statusCode int, message string) {
	c.JSON(http.StatusOK, Response{
		Success:   false,
		Message:   message,
		Timestamp: time.Now(),
	})
}
func SendErrorResponseWithData(c *gin.Context, statusCode int, message string, data any) {
	c.JSON(http.StatusOK, Response{
		Success: false,
		Message: message,
		Data:    data,
	})
}
func newErrorObj(code, msg string, details ...any) *ErrorObj {
	e := &ErrorObj{Code: code, Message: msg}
	if len(details) > 0 {
		e.Details = details[0]
	}
	return e
}
func SendUnauthorized(c *gin.Context, msg ...any) {
	message := "请先登录哦🤨"
	if len(msg) > 0 {
		message, _ = msg[0].(string)
	}
	c.JSON(http.StatusOK, Response{
		Success:   false,
		Message:   message,
		Error:     newErrorObj("UNAUTHORIZED", "未认证"),
		Timestamp: time.Now(),
	})
}
func SendForbidden(c *gin.Context, msg ...any) {
	message := "权限不足🙅"
	if len(msg) > 0 {
		message, _ = msg[0].(string)
	}
	c.JSON(http.StatusOK, Response{
		Success:   false,
		Message:   message,
		Error:     newErrorObj("FORBIDDEN", "权限不足"),
		Timestamp: time.Now(),
	})
}
func SendNotFound(c *gin.Context, msg ...any) {
	message := "资源没有找到😕"
	if len(msg) > 0 {
		message, _ = msg[0].(string)
	}
	c.JSON(http.StatusOK, Response{
		Success:   false,
		Message:   message,
		Error:     newErrorObj("NOT_FOUND", "资源不存在"),
		Timestamp: time.Now(),
	})
}
func SendBadRequest(c *gin.Context, msg ...any) {
	message := "请求参数有误🙅"
	if len(msg) > 0 {
		message, _ = msg[0].(string)
	}
	c.JSON(http.StatusOK, Response{
		Success:   false,
		Message:   message,
		Error:     newErrorObj("BAD_REQUEST", "请求参数有误"),
		Timestamp: time.Now(),
	})
}
func SendBadRequestWithData(c *gin.Context, msg string, data any) {
	c.JSON(http.StatusOK, Response{
		Success:   false,
		Message:   msg,
		Data:      data,
		Error:     newErrorObj("BAD_REQUEST", "请求参数有误"),
		Timestamp: time.Now(),
	})
}
func SendConflict(c *gin.Context, msg ...any) {
	message := "数据冲突，请稍后再试😔"
	if len(msg) > 0 {
		message, _ = msg[0].(string)
	}
	c.JSON(http.StatusOK, Response{
		Success:   false,
		Message:   message,
		Error:     newErrorObj("CONFLICT", "数据冲突"),
		Timestamp: time.Now(),
	})
}
func SendInternalServerError(c *gin.Context, err error) {
	c.JSON(http.StatusOK, Response{
		Success:   false,
		Message:   "服务器内部错误🥺",
		Error:     newErrorObj("INTERNAL_SERVER_ERROR", err.Error()),
		Timestamp: time.Now(),
	})
}
package model
type OnlineMsg struct {
	ID string `json:"id"`
}
package service
import (
	"IOT-Manage-System/mqtt-watch/errs"
	"log"
	"github.com/eclipse/paho.mqtt.golang"
)
type MqttService interface {
	SendWarningStart(deviceID string) *errs.AppError
	SendWarningEnd(deviceID string) *errs.AppError
}
type mqttService struct {
	c mqtt.Client
}
func (m *mqttService) SendWarningStart(deviceID string) *errs.AppError {
	token := m.c.Publish("warning/"+deviceID, 2, false, "1")
	token.Wait()
	if err := token.Error(); err != nil {
		log.Fatalln("❌")
		return errs.ErrThirdParty.WithDetails(err.Error())
	}
	log.Printf("[PUB] topic=%s payload=%s", "warning/"+deviceID, "1")
	return nil
}
func (m *mqttService) SendWarningEnd(deviceID string) *errs.AppError {
	token := m.c.Publish("warning/"+deviceID, 2, false, "0")
	token.Wait()
	if err := token.Error(); err != nil {
		return errs.ErrThirdParty.WithDetails(err.Error())
	}
	return nil
}
func NewMqttService(c mqtt.Client) MqttService {
	return &mqttService{c: c}
}
package service
import (
	"IOT-Manage-System/mqtt-watch/model"
	"IOT-Manage-System/mqtt-watch/repo"
)
type MongoService interface {
	SaveDeviceLoc(loc model.DeviceLoc) error
}
type mongoService struct {
	deviceLocRepo repo.MongoRepo 
}
func NewMongoService(dr repo.MongoRepo) MongoService {
	return &mongoService{deviceLocRepo: dr}
}
func (s *mongoService) SaveDeviceLoc(loc model.DeviceLoc) error {
	return s.deviceLocRepo.CreateLoc(loc)
}
package service
import (
	"IOT-Manage-System/user-service/model"
	"IOT-Manage-System/user-service/repository"
	"IOT-Manage-System/user-service/utils"
	"errors"
	"gorm.io/gorm"
)
type UserService interface {
	Register(req *model.UserCreateRequest) (*model.UserResponse, error)
	GetUserById(id string) (*model.UserResponse, error)
	UpdateUser(id string, req *model.UserUpdateRequest) (*model.UserResponse, error)
	DeleteUser(id string) error
	ListUsers(page, limit int) (*[]model.UserResponse, int64, error)
}
type userService struct {
	repo repository.UserRepo
}
func NewUserService(r repository.UserRepo) UserService {
	return &userService{repo: r}
}
func (s *userService) Register(req *model.UserCreateRequest) (*model.UserResponse, error) {
	if req.Username == "" || req.Password == "" {
		return nil, ErrInvalidInput
	}
	if _, err := s.repo.FindByUsername(req.Username); err == nil {
		return nil, ErrUserExists
	}
	hash, err := utils.GetPwd(req.Password)
	if err != nil {
		return nil, ErrInternal
	}
	user := &model.User{
		Username: req.Username,
		PwdHash:  hash,
		UserType: req.UserType,
	}
	if err := s.repo.Create(user); err != nil {
		return nil, ErrInternal
	}
	return user.ToUserResponse(), nil
}
func (s *userService) GetUserById(id string) (*model.UserResponse, error) {
	if id == "" {
		return nil, ErrInvalidInput
	}
	user, err := s.repo.FindByID(id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, ErrInternal
	}
	return user.ToUserResponse(), nil
}
func (s *userService) UpdateUser(id string, req *model.UserUpdateRequest) (*model.UserResponse, error) {
	if id == "" {
		return nil, ErrInvalidInput
	}
	user, err := s.repo.FindByID(id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, ErrInternal
	}
	if req.Username != nil {
		if exist, _ := s.repo.FindByUsername(*req.Username); exist != nil && exist.ID != id {
			return nil, ErrUserExists
		}
		user.Username = *req.Username
	}
	if req.UserType != nil {
		user.UserType = *req.UserType
	}
	if err := s.repo.Update(user); err != nil {
		return nil, ErrInternal
	}
	return user.ToUserResponse(), nil
}
func (s *userService) DeleteUser(id string) error {
	if id == "" {
		return ErrInvalidInput
	}
	if _, err := s.repo.FindByID(id); errors.Is(err, gorm.ErrRecordNotFound) {
		return ErrUserNotFound
	}
	return s.repo.Delete(id)
}
func (s *userService) ListUsers(page, limit int) (*[]model.UserResponse, int64, error) {
	if page <= 0 {
		page = 1
	}
	if limit <= 0 || limit > 100 {
		limit = 10
	}
	offset := (page - 1) * limit
	users, total, err := s.repo.List(offset, limit)
	if err != nil {
		return nil, 0, ErrInternal
	}
	resp := make([]model.UserResponse, len(users))
	for i, u := range users {
		resp[i] = *u.ToUserResponse()
	}
	return &resp, total, nil
}
package model
import (
	"time"
	"gorm.io/gorm"
)
type UserType string
const (
	UserTypeRoot  UserType = "root"
	UserTypeUser  UserType = "user"
	UserTypeAdmin UserType = "admin"
)
func (UserType) GormDataType() string { return "user_type_enum" }
type User struct {
	ID        string    `gorm:"type:uuid;primaryKey;default:gen_random_uuid()"`
	Username  string    `gorm:"type:varchar(255);not null"`
	PwdHash   string    `gorm:"type:varchar(255);not null"`
	UserType  UserType  `gorm:"type:user_type_enum;not null;default:'user'"`
	CreatedAt time.Time `gorm:"type:timestamptz;not null;default:now()"`
	UpdatedAt time.Time `gorm:"type:timestamptz;not null;default:now()"`
}
func (User) TableName() string {
	return "users"
}
func (u *User) BeforeSave(tx *gorm.DB) error {
	u.UpdatedAt = time.Now()
	return nil
}
package service
import (
	"IOT-Manage-System/mqtt-watch/errs"
	"IOT-Manage-System/mqtt-watch/repo"
)
type MarkService interface {
	GetPersistMQTTByDeviceID(deviceID string) (bool, error)
	GetDeviceIDsByPersistMQTT(persist bool) ([]string, error)
}
type markService struct {
	repo repo.MarkRepo
}
func NewMarkService(repo repo.MarkRepo) MarkService {
	return &markService{repo: repo}
}
func (s *markService) GetPersistMQTTByDeviceID(deviceID string) (bool, error) {
	persist, err := s.repo.GetPersistMQTTByDeviceID(deviceID)
	if err != nil {
		return false, errs.ErrDatabase.WithDetails(err.Error())
	}
	return persist, nil
}
func (s *markService) GetDeviceIDsByPersistMQTT(persist bool) ([]string, error) {
	deviceIDs, err := s.repo.GetDeviceIDsByPersistMQTT(persist)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return deviceIDs, nil
}
package service
import (
	"IOT-Manage-System/mqtt-watch/errs"
	"IOT-Manage-System/mqtt-watch/repo"
	"sort"
)
type MarkPairService interface {
	SetPairDistance(mark1ID, mark2ID string, distance float64) error
	SetCombinations(ids []string, distance float64) error
	GetDistance(mark1ID, mark2ID string) (float64, error)
	DeletePair(mark1ID, mark2ID string) error
	DistanceMapByMark(id string) (map[string]float64, error)
	DistanceMapByDevice(deviceID string) (map[string]float64, error)
}
type markPairService struct {
	markPairRepo repo.MarkPairRepo
	markRepo     repo.MarkRepo
}
func NewMarkPairService(r1 repo.MarkPairRepo, r2 repo.MarkRepo) MarkPairService {
	return &markPairService{markPairRepo: r1, markRepo: r2}
}
func (s *markPairService) SetPairDistance(mark1ID, mark2ID string, distance float64) error {
	if mark1ID == "" || mark2ID == "" {
		return errs.ErrInvalidInput.WithDetails("mark IDs cannot be empty")
	}
	if distance < 0 {
		return errs.ErrInvalidInput.WithDetails("distance cannot be negative")
	}
	err := s.markPairRepo.Upsert(mark1ID, mark2ID, distance)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	return nil
}
func (s *markPairService) SetCombinations(ids []string, distance float64) error {
	if len(ids) < 2 {
		return nil
	}
	if distance < 0 {
		return errs.ErrInvalidInput.WithDetails("distance cannot be negative")
	}
	m := make(map[string]struct{})
	for _, id := range ids {
		if id == "" {
			return errs.ErrInvalidInput.WithDetails("mark ID cannot be empty")
		}
		m[id] = struct{}{}
	}
	uniq := make([]string, 0, len(m))
	for id := range m {
		uniq = append(uniq, id)
	}
	sort.Strings(uniq)
	err := s.markPairRepo.BatchUpsert(uniq, distance)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	return nil
}
func (s *markPairService) GetDistance(mark1ID, mark2ID string) (float64, error) {
	if mark1ID == "" || mark2ID == "" {
		return 0, errs.ErrInvalidInput.WithDetails("mark IDs cannot be empty")
	}
	distance, err := s.markPairRepo.Get(mark1ID, mark2ID)
	if err != nil {
		return 0, errs.ErrDatabase.WithDetails(err.Error())
	}
	return distance, nil
}
func (s *markPairService) DeletePair(mark1ID, mark2ID string) error {
	if mark1ID == "" || mark2ID == "" {
		return errs.ErrInvalidInput.WithDetails("mark IDs cannot be empty")
	}
	err := s.markPairRepo.Delete(mark1ID, mark2ID)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	return nil
}
func (s *markPairService) DistanceMapByMark(id string) (map[string]float64, error) {
	if id == "" {
		return nil, errs.ErrInvalidInput.WithDetails("mark ID cannot be empty")
	}
	result, err := s.markPairRepo.MapByID(id)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return result, nil
}
func (s *markPairService) DistanceMapByDevice(deviceID string) (map[string]float64, error) {
	if deviceID == "" {
		return nil, errs.ErrInvalidInput.WithDetails("device ID cannot be empty")
	}
	result, err := s.markPairRepo.MapByDeviceID(deviceID)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return result, nil
}
package repository
import (
	"IOT-Manage-System/user-service/model"
	"gorm.io/gorm"
)
type UserRepo interface {
	Create(u *model.User) error
	FindByUsername(username string) (*model.User, error)
	FindByID(id string) (*model.User, error)
	Update(u *model.User) error
	Delete(id string) error
	List(offset, limit int) ([]model.User, int64, error)
}
type userRepo struct{ 
	db *gorm.DB 
}
func NewUserRepo(db *gorm.DB) UserRepo {
	return &userRepo{db: db}
}
func (r *userRepo) Create(u *model.User) error {
	return r.db.Create(u).Error
}
func (r *userRepo) FindByUsername(name string) (*model.User, error) {
	var u model.User
	err := r.db.Where("username = ?", name).First(&u).Error
	return &u, err
}
func (r *userRepo) FindByID(id string) (*model.User, error) {
	var u model.User
	err := r.db.First(&u, "id = ?", id).Error
	return &u, err
}
func (r *userRepo) Update(u *model.User) error {
	return r.db.Save(u).Error
}
func (r *userRepo) Delete(id string) error {
	return r.db.Delete(&model.User{}, "id = ?", id).Error
}
func (r *userRepo) List(offset, limit int) ([]model.User, int64, error) {
	var list []model.User
	var total int64
	if err := r.db.Model(&model.User{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}
	err := r.db.Offset(offset).Limit(limit).Find(&list).Error
	return list, total, err
}
package router
import (
	"IOT-Manage-System/user-service/handler"
	"IOT-Manage-System/user-service/utils"
	"github.com/gin-gonic/gin"
)
func RegisterUserRoutes(r *gin.Engine, userHandler handler.UserHandler, authHandler handler.AuthHandler) {
	r.GET("/health", func(c *gin.Context) {
		utils.SendSuccessResponse(c, gin.H{"status": "ok"}, "服务运行正常")
	})
	ug := r.Group("/api/v1/users/")
	{
		ug.POST("", userHandler.Create)      
		ug.POST("/token", authHandler.Login) 
		ug.POST("/refresh", authHandler.Refresh)
		ug.GET("/me", userHandler.GetMe)          
		ug.GET("/:id", userHandler.GetUser)       
		ug.PUT("/:id", userHandler.UpdateUser)    
		ug.DELETE("/:id", userHandler.DeleteUser) 
		ug.GET("", userHandler.ListUsers)         
	}
	r.NoRoute(func(c *gin.Context) {
		utils.SendNotFound(c)
	})
}
package model
import (
	"time"
	"github.com/google/uuid"
	"github.com/lib/pq"
	"gorm.io/gorm"
)
type MarkType struct {
	ID                   int      `gorm:"primaryKey;autoIncrement;column:id"`        
	TypeName             string   `gorm:"unique;size:255;not null;column:type_name"` 
	DefaultSafeDistanceM *float64 `gorm:"column:default_safe_distance_m;default:-1"` 
	Marks []Mark `gorm:"foreignKey:MarkTypeID;references:ID"`
}
func (MarkType) TableName() string { return "mark_types" }
type MarkTag struct {
	ID      int    `gorm:"primaryKey;autoIncrement;column:id"`       
	TagName string `gorm:"unique;size:255;not null;column:tag_name"` 
	Marks []Mark `gorm:"many2many:mark_tag_relation;foreignKey:ID;joinForeignKey:TagID;references:ID;joinReferences:MarkID"`
}
func (MarkTag) TableName() string { return "mark_tags" }
type Mark struct {
	ID            uuid.UUID      `gorm:"primaryKey;type:uuid;default:gen_random_uuid();column:id"` 
	DeviceID      string         `gorm:"unique;size:255;not null;column:device_id"`                
	MarkName      string         `gorm:"size:255;not null;column:mark_name"`                       
	MqttTopic     pq.StringArray `gorm:"type:text[];not null;default:'{}';column:mqtt_topic"`      
	PersistMQTT   bool           `gorm:"not null;default:false;column:persist_mqtt"`               
	SafeDistanceM *float64       `gorm:"column:safe_distance_m"`                                   
	MarkTypeID    int            `gorm:"not null;column:mark_type_id"`                             
	CreatedAt     time.Time      `gorm:"not null;default:now();column:created_at"`                 
	UpdatedAt     time.Time      `gorm:"not null;default:now();column:updated_at"`                 
	LastOnlineAt  *time.Time     `gorm:"column:last_online_at"`                                    
	MarkType MarkType `gorm:"foreignKey:MarkTypeID;references:ID;constraint:OnDelete:RESTRICT"`
	Tags []MarkTag `gorm:"many2many:mark_tag_relation;foreignKey:ID;joinForeignKey:MarkID;references:ID;joinReferences:TagID;constraint:OnDelete:CASCADE"`
}
func (Mark) TableName() string { return "marks" }
type MarkPairSafeDistance struct {
	Mark1ID   uuid.UUID `gorm:"primaryKey"` 
	Mark2ID   uuid.UUID `gorm:"primaryKey"` 
	DistanceM float64   
}
func (MarkPairSafeDistance) TableName() string { return "mark_pair_safe_distance" }
func (m *MarkPairSafeDistance) BeforeCreate(tx *gorm.DB) error {
	if m.Mark1ID.String() > m.Mark2ID.String() {
		m.Mark1ID, m.Mark2ID = m.Mark2ID, m.Mark1ID
	}
	return nil
}
package utils
import (
	"IOT-Manage-System/user-service/model"
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
	signingMethod   = jwt.SigningMethodHS256 
	ErrInvalidToken = errors.New("错误Token")
)
type CustomClaims struct {
	UserID   string         `json:"user_id"`
	Username string         `json:"username"`
	UserType model.UserType `json:"user_type"`
	jwt.RegisteredClaims
}
func generateToken(u *model.User, expiresIn time.Duration, issuer string) (string, error) {
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
	token := jwt.NewWithClaims(signingMethod, claims)
	return token.SignedString(jwtSecret)
}
func GenerateToken(u *model.User) (string, error) {
	return generateToken(u, AccessTokenExpire, AccessTokenIssuer)
}
func GenerateRefreshToken(u *model.User) (string, error) {
	return generateToken(u, RefreshTokenExpire, RefreshTokenIssuer)
}
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
func RefreshAccessToken(refreshToken string) (string, error) {
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
	user := &model.User{
		ID:       claims.UserID,
		Username: claims.Username,
		UserType: claims.UserType,
	}
	return GenerateToken(user)
}
package utils
import (
	"os"
	"strconv"
	"strings"
)
func GetEnv(key, defaultValue string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultValue
}
func GetEnvInt(key string, defaultValue int) int {
	val := os.Getenv(key)
	if val == "" {
		return defaultValue
	}
	i, err := strconv.Atoi(val)
	if err != nil {
		return defaultValue
	}
	return i
}
func ParsePositiveInt(s string) (int, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0, nil
	}
	v, err := strconv.Atoi(s)
	if err != nil || v <= 0 {
		return 0, nil
	}
	return v, err
}
func ParsePositiveInt64(s string) (int64, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0, nil
	}
	v, err := strconv.ParseInt(s, 10, 64)
	if err != nil || v <= 0 {
		return 0, nil
	}
	return v, err
}
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
	UWBX       *float64           `bson:"uwb_x,omitempty" json:"uwb_x,omitempty"` 
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
	N string    `json:"n"` 
	U string    `json:"u"` 
	V []float64 `json:"v"` 
}
package utils
import (
	"fmt"
	"os"
	"strconv"
)
func GetEnv(key, defaultValue string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultValue
}
func GetEnvInt(key string, defaultValue int) int {
	val := os.Getenv(key)
	if val == "" {
		return defaultValue
	}
	i, err := strconv.Atoi(val)
	if err != nil {
		return defaultValue
	}
	return i
}
func GetDSN() string {
	dbHost := GetEnv("DB_HOST", "postgres")
	dbPort := GetEnv("DB_PORT", "5432")
	dbUser := GetEnv("DB_USER", "postgres")
	dbPasswd := GetEnv("DB_PASSWD", "password")
	dbName := GetEnv("DB_NAME", "iot_manager_db")
	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable TimeZone=Asia/Shanghai",
		dbHost, dbPort, dbUser, dbPasswd, dbName,
	)
}
package utils
import (
	"IOT-Manage-System/user-service/model"
	"fmt"
	"log"
	"time"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)
func InitDB() (*gorm.DB, error) {
	dbHost := GetEnv("DB_HOST", "localhost")
	dbPort := GetEnv("DB_PORT", "5432")
	dbUser := GetEnv("DB_USER", "postgres")
	dbPassword := GetEnv("DB_PASSWORD", "password")
	dbName := GetEnv("DB_NAME", "credit_management")
	dbSSLMode := GetEnv("DB_SSLMODE", "disable")
	maxOpen := GetEnvInt("DB_MAX_OPEN_CONNS", 100)
	maxIdle := GetEnvInt("DB_MAX_IDLE_CONNS", 20)
	maxLifetime := time.Duration(GetEnvInt("DB_MAX_LIFETIME", 1)) * time.Hour
	maxRetries := GetEnvInt("DB_MAX_RETRY", 5)
	retryInterval := time.Duration(GetEnvInt("DB_RETRY_INTERVAL", 2)) * time.Second
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		dbHost, dbPort, dbUser, dbPassword, dbName, dbSSLMode)
	var db *gorm.DB
	var err error
	for i := 0; i <= maxRetries; i++ {
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
			Logger: logger.Default.LogMode(logger.Info),
		})
		if err == nil {
			log.Println("数据库连接成功")
			break
		}
		log.Printf("数据库连接失败（尝试 %d/%d）: %v", i+1, maxRetries, err)
		if i == maxRetries {
			return nil, fmt.Errorf("数据库连接失败，已尝试%d次: %w", maxRetries, err)
		}
		time.Sleep(retryInterval)
	}
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("获取底层 sql.DB 失败: %w", err)
	}
	sqlDB.SetMaxOpenConns(maxOpen)
	sqlDB.SetMaxIdleConns(maxIdle)
	sqlDB.SetConnMaxLifetime(maxLifetime)
	return db, nil
}
func CloseDB(db *gorm.DB) error {
	if db == nil {
		return nil
	}
	sqlDB, err := db.DB()
	if err != nil {
		return fmt.Errorf("获取底层 sql.DB 失败: %w", err)
	}
	return sqlDB.Close()
}
func InitRootUser(db *gorm.DB) error {
	return db.Transaction(func(tx *gorm.DB) error {
		var count int64
		if err := tx.Model(&model.User{}).
			Where("user_type = ?", model.UserTypeRoot).
			Limit(1).
			Count(&count).Error; err != nil {
			return err
		}
		if count > 0 {
			return nil
		}
		pwdHash, _ := GetPwd(GetEnv("ADMIN_PWD", "admin"))
		admin := model.User{
			Username:  GetEnv("ADMIN_NAME", "admin"),
			PwdHash:   pwdHash,
			UserType:  model.UserTypeRoot,
			CreatedAt: time.Now(),
			UpdatedAt: time.Now(),
		}
		if err := tx.Create(&admin).Error; err != nil {
			return fmt.Errorf("创建系统管理员用户失败: %w", err)
		}
		log.Println("成功插入系统管理员用户")
		return nil
	})
}
package service
import "errors"
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
var (
	ErrResourceNotFound  = errors.New("资源不存在")
	ErrResourceConflict  = errors.New("资源冲突")
	ErrResourceExhausted = errors.New("资源耗尽")
	ErrUploadFailed      = errors.New("文件上传失败")
	ErrFileTooLarge      = errors.New("文件过大")
	ErrUnsupportedFormat = errors.New("不支持的文件格式")
)
var (
	ErrStatusConflict   = errors.New("状态冲突")
	ErrDuplicateAction  = errors.New("重复操作")
	ErrQuotaExceeded    = errors.New("配额超限")
	ErrOperationTimeout = errors.New("操作超时")
	ErrInvalidToken     = errors.New("错误Token")
)
var (
	ErrInternal   = errors.New("内部错误")
	ErrDatabase   = errors.New("数据库异常")
	ErrCache      = errors.New("缓存异常")
	ErrNetwork    = errors.New("网络异常")
	ErrThirdParty = errors.New("第三方服务异常")
	ErrConfig     = errors.New("配置错误")
)
var (
	ErrValidationFailed = errors.New("数据校验失败")
	ErrCaptchaFailed    = errors.New("验证码错误")
	ErrTooManyRequests  = errors.New("请求过于频繁")
)
package service
import (
	"IOT-Manage-System/user-service/model"
	"IOT-Manage-System/user-service/repository"
	"IOT-Manage-System/user-service/utils"
)
type AuthService interface {
	Login(*model.UserLoginRequest) (*model.LoginResponse, error)
	Refresh(*model.RefreshTokenRequest) (*model.RefreshTokenResponse, error)
}
type authService struct {
	repo repository.UserRepo
}
func NewAuthService(r repository.UserRepo) AuthService {
	return &authService{
		repo: r,
	}
}
func (a *authService) Login(req *model.UserLoginRequest) (*model.LoginResponse, error) {
	user, err := a.repo.FindByUsername(req.Username)
	if err != nil {
		return nil, ErrUserNotFound
	}
	if !utils.ComparePwd(req.Password, user.PwdHash) {
		return nil, ErrWrongPassword
	}
	accessToken, err := utils.GenerateToken(user)
	if err != nil {
		return nil, err
	}
	refreshToken, err := utils.GenerateRefreshToken(user)
	if err != nil {
		return nil, err
	}
	return &model.LoginResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}
func (a *authService) Refresh(req *model.RefreshTokenRequest) (*model.RefreshTokenResponse, error) {
	newAccess, err := utils.RefreshAccessToken(req.RefreshToken)
	if err != nil {
		return nil, ErrInvalidToken
	}
	return &model.RefreshTokenResponse{AccessToken: newAccess}, nil
}
package utils
import (
	"golang.org/x/crypto/bcrypt"
)
func GetPwd(pwd string) (string, error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(pwd), bcrypt.DefaultCost)
	return string(hash), err
}
func ComparePwd(plain, hashed string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hashed), []byte(plain))
	return err == nil
}
package main
import (
	"log"
	"github.com/goccy/go-json"
	"github.com/gofiber/fiber/v2"
	"IOT-Manage-System/mqtt-watch/client"
	"IOT-Manage-System/mqtt-watch/handler"
	"IOT-Manage-System/mqtt-watch/repo"
	"IOT-Manage-System/mqtt-watch/service"
	"IOT-Manage-System/mqtt-watch/utils"
)
func main() {
	utils.InitMQTT()
	defer utils.CloseMQTT()
	db, err := utils.InitDB()
	if err != nil {
		log.Fatalf("初始化数据库失败: %v", err)
	}
	defer func() {
		if err := utils.CloseDB(db); err != nil {
			log.Printf("关闭数据库失败: %v", err)
		} else {
			log.Println("数据库已正常关闭")
		}
	}()
	if _, err := utils.InitMongo(); err != nil {
		panic(err)
	}
	mark_repo := repo.NewMarkRepo(db)
	mark_pair_repo := repo.NewMarkPairRepo(db)
	deviceLocRepo := repo.NewMongoRepo(utils.DeviceLocColl())
	mark_service := service.NewMarkService(mark_repo)
	mark_pair_service := service.NewMarkPairService(mark_pair_repo, mark_repo)
	mongoService := service.NewMongoService(deviceLocRepo)
	c := utils.MQTTClient
	mqttCallback := client.NewMqttCallback(c, mark_service, mark_pair_service, mongoService)
	mqttCallback.MustSubscribe()
	mqttService := service.NewMqttService(c)
	mqttHandler := handler.NewMqttService(mqttService)
	app := fiber.New(fiber.Config{
		Prefork:            false,
		StrictRouting:      true,
		AppName:            "消息管理服务 v0.0.1",
		CaseSensitive:      true,
		DisableDefaultDate: true,
		ErrorHandler:       handler.CustomErrorHandler,
		JSONEncoder:        json.Marshal,
		JSONDecoder:        json.Unmarshal,
	})
	api := app.Group("/api")
	v1 := api.Group("/v1")
	mqtt := v1.Group("/mqtt")
	mqtt.Post("/warning/:deviceId/start", mqttHandler.SendWarningStart)
	mqtt.Post("/warning/:deviceId/end", mqttHandler.SendWarningEnd)
	app.Stack() 
	for _, routes := range app.Stack() {
		for _, r := range routes {
			log.Printf("Method: %-6s Path: %s\n", r.Method, r.Path)
		}
	}
	port := utils.GetEnv("PORT", "8003")
	if err := app.Listen(":" + port); err != nil {
		log.Fatalf("启动 HTTP 服务失败: %v", err)
	}
}
package utils
import (
	"fmt"
	"log"
	"time"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)
func InitDB() (*gorm.DB, error) {
	dbHost := GetEnv("DB_HOST", "localhost")
	dbPort := GetEnv("DB_PORT", "5432")
	dbUser := GetEnv("DB_USER", "postgres")
	dbPassword := GetEnv("DB_PASSWORD", "password")
	dbName := GetEnv("DB_NAME", "iot_manager_db")
	dbSSLMode := GetEnv("DB_SSLMODE", "disable")
	maxOpen := GetEnvInt("DB_MAX_OPEN_CONNS", 100)
	maxIdle := GetEnvInt("DB_MAX_IDLE_CONNS", 20)
	maxLifetime := time.Duration(GetEnvInt("DB_MAX_LIFETIME", 1)) * time.Hour
	maxRetries := GetEnvInt("DB_MAX_RETRY", 5)
	retryInterval := time.Duration(GetEnvInt("DB_RETRY_INTERVAL", 2)) * time.Second
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		dbHost, dbPort, dbUser, dbPassword, dbName, dbSSLMode)
	log.Println("DSN:" + dsn)
	var db *gorm.DB
	var err error
	for i := 0; i <= maxRetries; i++ {
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
			Logger: logger.Default.LogMode(logger.Info),
		})
		if err == nil {
			log.Println("数据库连接成功")
			break
		}
		log.Printf("数据库连接失败（尝试 %d/%d）: %v", i+1, maxRetries, err)
		if i == maxRetries {
			return nil, fmt.Errorf("数据库连接失败，已尝试%d次: %w", maxRetries, err)
		}
		time.Sleep(retryInterval)
	}
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("获取底层 sql.DB 失败: %w", err)
	}
	sqlDB.SetMaxOpenConns(maxOpen)
	sqlDB.SetMaxIdleConns(maxIdle)
	sqlDB.SetConnMaxLifetime(maxLifetime)
	return db, nil
}
func CloseDB(db *gorm.DB) error {
	if db == nil {
		return nil
	}
	sqlDB, err := db.DB()
	if err != nil {
		return fmt.Errorf("获取底层 sql.DB 失败: %w", err)
	}
	return sqlDB.Close()
}
package utils
import (
	"net/http"
)
type UserHeader struct {
	ID       string
	Username string
	UserType string
}
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
func GetUserID(h http.Header) string {
	return h.Get("X-UserID")
}
func GetUserName(h http.Header) string {
	return h.Get("X-UserName")
}
func GetUserType(h http.Header) string {
	return h.Get("X-UserType")
}
package model
type UserLoginRequest struct {
	Username string `json:"username" binding:"required,max=32"`
	Password string `json:"password" binding:"required,max=64"`
}
type UserCreateRequest struct {
	Username string   `json:"username" binding:"required,min=3,max=32"`
	Password string   `json:"password" binding:"required,min=6,max=64"`
	UserType UserType `json:"user_type" binding:"required,oneof=user admin"`
}
type UserUpdateRequest struct {
	Username *string   `json:"username,omitempty"` 
	UserType *UserType `json:"user_type,omitempty"`
}
package config
import (
	"os"
	"strconv"
	"sync"
	"time"
)
var C *Config
type Config struct {
	PSQLConfig struct {
		Host          string
		Port          string
		User          string
		Password      string
		Name          string
		SSLMode       string
		MaxOpen       int
		MaxIdle       int
		MaxLifetime   time.Duration
		MaxRetries    int
		RetryInterval time.Duration
	}
	MQTTConfig struct {
		MQTT_BROKER   string
		MQTT_USERNAME string
		MQTT_PASSWORD string
	}
	MapServiceConfig struct {
		Hostname string
		Port     string
	}
	MarkServiceConfig struct {
		Hostname string
		Port     string
	}
	AppConfig struct {
		OnlineSecond int
	}
}
var once sync.Once
func Load() {
	once.Do(func() {
		C = &Config{}
		C.PSQLConfig.Host = getEnvStr("DB_HOST", "localhost")
		C.PSQLConfig.Port = getEnvStr("DB_PORT", "5432")
		C.PSQLConfig.User = getEnvStr("DB_USER", "postgres")
		C.PSQLConfig.Password = getEnvStr("DB_PASSWORD", "password")
		C.PSQLConfig.Name = getEnvStr("DB_NAME", "iot_manager_db")
		C.PSQLConfig.SSLMode = getEnvStr("DB_SSLMODE", "disable")
		C.PSQLConfig.MaxOpen = getEnvInt("DB_MAX_OPEN_CONNS", 100)
		C.PSQLConfig.MaxIdle = getEnvInt("DB_MAX_IDLE_CONNS", 20)
		C.PSQLConfig.MaxLifetime = getEnvDuration("DB_MAX_LIFETIME", time.Hour)
		C.PSQLConfig.MaxRetries = getEnvInt("DB_MAX_RETRY", 5)
		C.PSQLConfig.RetryInterval = getEnvDuration("DB_RETRY_INTERVAL", 2*time.Second)
		C.MQTTConfig.MQTT_BROKER = getEnvStr("MQTT_BROKER", "ws://8.133.17.175:8083")
		C.MQTTConfig.MQTT_USERNAME = getEnvStr("MQTT_USERNAME", "admin")
		C.MQTTConfig.MQTT_PASSWORD = getEnvStr("MQTT_PASSWORD", "admin")
		C.MapServiceConfig.Hostname = getEnvStr("MAP_SERVICE_HOST", "map-service")
		C.MapServiceConfig.Port = getEnvStr("MAP_SERVICE_PORT", "8002")
		C.MarkServiceConfig.Hostname = getEnvStr("MARK_SERVICE_HOST", "mark-service")
		C.MarkServiceConfig.Port = getEnvStr("MARK_SERVICE_PORT", "8004")
		C.AppConfig.OnlineSecond = getEnvInt("OFFLINE_SECOND", 3)
	})
}
func getEnvStr(key, defaultValue string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultValue
}
func getEnvInt(key string, defaultValue int) int {
	val := os.Getenv(key)
	if val == "" {
		return defaultValue
	}
	i, err := strconv.Atoi(val)
	if err != nil {
		return defaultValue
	}
	return i
}
func getEnvDuration(key string, def time.Duration) time.Duration {
	v := os.Getenv(key)
	if v == "" {
		return def
	}
	d, err := time.ParseDuration(v)
	if err != nil {
		return def
	}
	return d
}
package model
import "time"
type UserResponse struct {
	ID        string    `json:"id"`        
	Username  string    `json:"username"`  
	UserType  UserType  `json:"user_type"` 
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
func (u *User) ToUserResponse() *UserResponse {
	return &UserResponse{
		ID:        u.ID,
		Username:  u.Username,
		UserType:  u.UserType,
		CreatedAt: u.CreatedAt,
		UpdatedAt: u.UpdatedAt,
	}
}
package main
import (
	"IOT-Manage-System/user-service/handler"
	"IOT-Manage-System/user-service/repository"
	"IOT-Manage-System/user-service/router"
	"IOT-Manage-System/user-service/service"
	"IOT-Manage-System/user-service/utils"
	"log"
	"github.com/gin-gonic/gin"
)
func main() {
	log.Println("正在启动用户服务...")
	db, err := utils.InitDB()
	if err != nil {
		log.Fatalf("初始化数据库失败: %v", err)
	}
	defer func() {
		if err := utils.CloseDB(db); err != nil {
			log.Printf("关闭数据库失败: %v", err)
		} else {
			log.Println("数据库已正常关闭")
		}
	}()
	if err := utils.InitRootUser(db); err != nil {
		log.Println(err)
	}
	userRepo := repository.NewUserRepo(db)
	userService := service.NewUserService(userRepo)
	authService := service.NewAuthService(userRepo)
	userHandler := handler.NewUserHandler(userService)
	authHandler := handler.NewAuthHandler(authService)
	r := gin.Default()
	router.RegisterUserRoutes(r, userHandler, authHandler)
	port := utils.GetEnv("PORT", "8001")
	log.Printf("服务即将启动，监听端口: %s\n", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("启动服务失败: %v", err)
	}
}
package utils
import (
	"strings"
	"github.com/goccy/go-json"
	"IOT-Manage-System/mqtt-watch/model" 
)
func ParseOnlineId(topic string, payload []byte) string {
	idFromTopic := strings.TrimPrefix(topic, "online")
	idFromTopic = strings.Trim(idFromTopic, "/")
	var msg model.OnlineMsg
	_ = json.Unmarshal(payload, &msg) 
	id := strings.TrimSpace(msg.ID)
	if id == "" {
		id = idFromTopic
	}
	return id
}
package utils
import (
	"fmt"
	"log"
	"time"
	mqtt "github.com/eclipse/paho.mqtt.golang"
)
var MQTTClient mqtt.Client
func InitMQTT() {
	url := GetEnv("MQTT_BROKER", "ws://8.133.17.175:8083")
	opts := mqtt.NewClientOptions().
		AddBroker(url).
		SetClientID(fmt.Sprintf("warning-watch-%d", time.Now().UnixNano())).
		SetUsername(GetEnv("MQTT_USERNAME", "admin")).
		SetPassword(GetEnv("MQTT_PASSWORD", "admin")).
		SetKeepAlive(60 * time.Second).
		SetPingTimeout(10 * time.Second).
		SetAutoReconnect(true).
		SetMaxReconnectInterval(10 * time.Second).
		SetCleanSession(false)
	MQTTClient = mqtt.NewClient(opts)
	if token := MQTTClient.Connect(); token.Wait() && token.Error() != nil {
		log.Fatalf("mqtt connect error: %v", token.Error())
	}
	log.Println("连接" + url + " mqtt broker 成功")
}
func CloseMQTT() {
	if MQTTClient != nil && MQTTClient.IsConnected() {
		MQTTClient.Disconnect(250) 
		log.Println("mqtt disconnected")
	}
	MQTTClient = nil 
	log.Println("断开mqtt broker连接成功")
}
package repo
import (
	"context"
	"go.mongodb.org/mongo-driver/mongo"
	"IOT-Manage-System/mqtt-watch/model"
)
type MongoRepo interface {
	CreateLoc(loc model.DeviceLoc) error
}
type mongoRepo struct {
	coll *mongo.Collection
}
func NewMongoRepo(coll *mongo.Collection) MongoRepo {
	return &mongoRepo{
		coll: coll,
	}
}
func (r *mongoRepo) CreateLoc(loc model.DeviceLoc) error {
	_, err := r.coll.InsertOne(context.TODO(), loc)
	return err
}
package repo
import (
	"IOT-Manage-System/mqtt-watch/model"
	"errors"
	"gorm.io/gorm"
)
type MarkRepo interface {
	GetPersistMQTTByDeviceID(deviceID string) (bool, error)
	GetDeviceIDsByPersistMQTT(persist bool) ([]string, error)
}
type markRepo struct {
	db *gorm.DB
}
func NewMarkRepo(db *gorm.DB) MarkRepo {
	return &markRepo{db: db}
}
func (r *markRepo) GetPersistMQTTByDeviceID(deviceID string) (bool, error) {
	var persist bool
	result := r.db.Model(&model.Mark{}).
		Select("persist_mqtt").
		Where("device_id = ?", deviceID).
		First(&persist)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return false, nil
		}
		return false, result.Error
	}
	return persist, nil
}
func (r *markRepo) GetDeviceIDsByPersistMQTT(persist bool) ([]string, error) {
	var deviceIDs []string
	result := r.db.Model(&model.Mark{}).
		Select("device_id").
		Where("persist_mqtt = ?", persist).
		Pluck("device_id", &deviceIDs)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, result.Error
	}
	return deviceIDs, nil
}
package middleware
import (
	"IOT-Manage-System/user-service/utils"
	"strings"
	"github.com/gin-gonic/gin"
)
func JWTMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.Next()
			return
		}
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.Next() 
			return
		}
		claims, err := utils.ParseAccessToken(parts[1])
		if err != nil {
			c.Next() 
			return
		}
		c.Request.Header.Set("X-UserID", claims.UserID)
		c.Request.Header.Set("X-UserName", claims.Username)
		c.Request.Header.Set("X-UserType", string(claims.UserType))
		c.Next()
	}
}
package repo
import (
	"errors"
	"fmt"
	"github.com/google/uuid"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
	"IOT-Manage-System/mqtt-watch/model"
)
type MarkPairRepo interface {
	Upsert(mark1ID, mark2ID string, safeDistanceM float64) error
	BatchUpsert(ids []string, safeDistanceM float64) error
	CartesianUpsertByMarkIDs(m1IDs, m2IDs []string, safeDistanceM float64) error
	Get(mark1ID, mark2ID string) (float64, error)
	Delete(mark1ID, mark2ID string) error
	MapByID(id string) (map[string]float64, error)
	MapByDeviceID(deviceID string) (map[string]float64, error)
}
type markPairRepo struct {
	db *gorm.DB
}
func NewMarkPairRepo(db *gorm.DB) MarkPairRepo {
	return &markPairRepo{db: db}
}
func (r *markPairRepo) Upsert(mark1ID, mark2ID string, safeDistanceM float64) error {
	pair, err := normalizePair(mark1ID, mark2ID, safeDistanceM)
	if err != nil {
		return err
	}
	return r.db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "mark1_id"}, {Name: "mark2_id"}},
		UpdateAll: true,
	}).Create(&pair).Error
}
func (r *markPairRepo) BatchUpsert(ids []string, safeDistanceM float64) error {
	n := len(ids)
	if n < 2 {
		return nil 
	}
	batch := make([]model.MarkPairSafeDistance, 0, n*(n-1)/2)
	for i := 0; i < n; i++ {
		for j := i + 1; j < n; j++ { 
			pair, err := normalizePair(ids[i], ids[j], safeDistanceM)
			if err != nil {
				return err
			}
			batch = append(batch, pair)
		}
	}
	return r.db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "mark1_id"}, {Name: "mark2_id"}},
		UpdateAll: true,
	}).CreateInBatches(&batch, 200).Error
}
func (r *markPairRepo) CartesianUpsertByMarkIDs(m1IDs, m2IDs []string, safeDistanceM float64) error {
	pairs := make([]model.MarkPairSafeDistance, 0, len(m1IDs)*len(m2IDs))
	for _, id1 := range m1IDs {
		for _, id2 := range m2IDs {
			if id1 == id2 {
				continue
			}
			pair, err := normalizePair(id1, id2, safeDistanceM)
			if err != nil {
				return err
			}
			pairs = append(pairs, pair)
		}
	}
	return r.db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "mark1_id"}, {Name: "mark2_id"}},
		UpdateAll: true,
	}).CreateInBatches(&pairs, 200).Error
}
func (r *markPairRepo) Get(mark1ID, mark2ID string) (float64, error) {
	id1, id2, err := mustUUIDPair(mark1ID, mark2ID)
	if err != nil {
		return 0, err
	}
	var pair model.MarkPairSafeDistance
	if err := r.db.Where("mark1_id = ? AND mark2_id = ?", id1, id2).First(&pair).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return 0, nil 
		}
		return 0, err
	}
	return pair.DistanceM, nil
}
func (r *markPairRepo) Delete(mark1ID, mark2ID string) error {
	id1, id2, err := mustUUIDPair(mark1ID, mark2ID)
	if err != nil {
		return err
	}
	return r.db.Where("mark1_id = ? AND mark2_id = ?", id1, id2).Delete(&model.MarkPairSafeDistance{}).Error
}
func (r *markPairRepo) MapByID(id string) (map[string]float64, error) {
	uid, err := uuid.Parse(id)
	if err != nil {
		return nil, fmt.Errorf("invalid mark id: %w", err)
	}
	var list []struct {
		OtherID   uuid.UUID
		DistanceM float64
	}
	if err := r.db.Raw(`
		SELECT mark2_id AS other_id, distance_m FROM mark_pair_safe_distance WHERE mark1_id = ?
		UNION ALL
		SELECT mark1_id AS other_id, distance_m FROM mark_pair_safe_distance WHERE mark2_id = ?
	`, uid, uid).Scan(&list).Error; err != nil {
		return nil, err
	}
	m := make(map[string]float64, len(list))
	for _, v := range list {
		m[v.OtherID.String()] = v.DistanceM
	}
	return m, nil
}
func (r *markPairRepo) MapByDeviceID(deviceID string) (map[string]float64, error) {
	var id string
	if err := r.db.Model(&model.Mark{}).Where("device_id = ?", deviceID).Select("id").Scan(&id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return map[string]float64{}, nil
		}
		return nil, err
	}
	return r.MapByID(id)
}
func normalizePair(id1, id2 string, distance float64) (model.MarkPairSafeDistance, error) {
	uid1, err := uuid.Parse(id1)
	if err != nil {
		return model.MarkPairSafeDistance{}, fmt.Errorf("invalid mark1ID: %w", err)
	}
	uid2, err := uuid.Parse(id2)
	if err != nil {
		return model.MarkPairSafeDistance{}, fmt.Errorf("invalid mark2ID: %w", err)
	}
	if uid1.String() > uid2.String() {
		uid1, uid2 = uid2, uid1
	}
	return model.MarkPairSafeDistance{Mark1ID: uid1, Mark2ID: uid2, DistanceM: distance}, nil
}
func mustUUIDPair(id1, id2 string) (uuid.UUID, uuid.UUID, error) {
	uid1, err := uuid.Parse(id1)
	if err != nil {
		return uuid.UUID{}, uuid.UUID{}, fmt.Errorf("invalid mark1ID: %w", err)
	}
	uid2, err := uuid.Parse(id2)
	if err != nil {
		return uuid.UUID{}, uuid.UUID{}, fmt.Errorf("invalid mark2ID: %w", err)
	}
	if uid1.String() > uid2.String() {
		uid1, uid2 = uid2, uid1
	}
	return uid1, uid2, nil
}
package handler
import (
	"time"
	"github.com/gofiber/fiber/v2"
	"IOT-Manage-System/mqtt-watch/errs"
	"IOT-Manage-System/mqtt-watch/utils"
)
func CustomErrorHandler(c *fiber.Ctx, err error) error {
	status := fiber.StatusInternalServerError
	code := "INTERNAL_ERROR"
	message := err.Error()
	var details any
	if appErr, ok := err.(*errs.AppError); ok {
		status = appErr.Status
		code = appErr.Code
		message = appErr.Message
		details = appErr.Details
	}
	if e, ok := err.(*fiber.Error); ok {
		status = e.Code
		message = e.Message
	}
	resp := utils.Response{
		Success:   false,
		Message:   message,
		Error:     &utils.ErrorObj{Code: code, Message: message, Details: details},
		Timestamp: time.Now(),
	}
	return c.Status(status).JSON(resp)
}
package handler
import (
	"github.com/gofiber/fiber/v2"
	"IOT-Manage-System/mqtt-watch/service"
	"IOT-Manage-System/mqtt-watch/utils"
)
type MqttHandler interface {
	SendWarningStart(c *fiber.Ctx) error
	SendWarningEnd(c *fiber.Ctx) error
}
type mqttHandler struct {
	mqttSer service.MqttService
}
func (h *mqttHandler) SendWarningStart(c *fiber.Ctx) error {
	deviceID := c.Params("deviceId")
	if err := h.mqttSer.SendWarningStart(deviceID); err != nil {
		return c.Status(err.Status).JSON(err) 
	}
	return utils.SendSuccessResponse(c, "warning started")
}
func (h *mqttHandler) SendWarningEnd(c *fiber.Ctx) error {
	deviceID := c.Params("deviceId")
	if err := h.mqttSer.SendWarningEnd(deviceID); err != nil {
		return c.Status(err.Status).JSON(err)
	}
	return utils.SendSuccessResponse(c, "warning ended")
}
func NewMqttService(s service.MqttService) MqttHandler {
	return &mqttHandler{mqttSer: s}
}
package utils
import (
	"net/http"
	"time"
	"github.com/gofiber/fiber/v2"
)
type Response struct {
	Success    bool           `json:"success"`
	Data       any            `json:"data,omitempty"`
	Message    string         `json:"message,omitempty"`
	Error      *ErrorObj      `json:"error,omitempty"`
	Pagination *PaginationObj `json:"pagination,omitempty"`
	Timestamp  time.Time      `json:"timestamp"`
}
type ErrorObj struct {
	Code    string `json:"code"`
	Message string `json:"message"`
	Details any    `json:"details,omitempty"`
}
type PaginationObj struct {
	CurrentPage  int   `json:"currentPage"`
	TotalPages   int   `json:"totalPages"`
	TotalItems   int64 `json:"totalItems"`
	ItemsPerPage int   `json:"itemsPerPage"`
	HasNext      bool  `json:"has_next"`
	HasPrev      bool  `json:"has_prev"`
}
func SendSuccessResponse(c *fiber.Ctx, data any, msg ...string) error {
	message := "请求成功啦😁"
	if len(msg) > 0 {
		message = msg[0]
	}
	return c.Status(http.StatusOK).JSON(Response{
		Success:   true,
		Data:      data,
		Message:   message,
		Timestamp: time.Now(),
	})
}
func SendCreatedResponse(c *fiber.Ctx, data any, msg ...string) error {
	message := "创建成功啦✌️"
	if len(msg) > 0 {
		message = msg[0]
	}
	return c.Status(http.StatusCreated).JSON(Response{
		Success:   true,
		Data:      data,
		Message:   message,
		Timestamp: time.Now(),
	})
}
func SendPaginatedResponse(c *fiber.Ctx, data any, total int64, page, perPage int, msg ...string) error {
	message := "请求成功啦😁"
	if len(msg) > 0 {
		message = msg[0]
	}
	pagination := NewPagination(total, page, perPage)
	return c.Status(http.StatusOK).JSON(Response{
		Success:    true,
		Data:       data,
		Message:    message,
		Pagination: pagination,
		Timestamp:  time.Now(),
	})
}
func SendErrorResponse(c *fiber.Ctx, statusCode int, message string) error {
	return c.Status(statusCode).JSON(Response{
		Success:   false,
		Message:   message,
		Timestamp: time.Now(),
	})
}
func SendErrorResponseWithData(c *fiber.Ctx, statusCode int, message string, data any) error {
	return c.Status(statusCode).JSON(Response{
		Success: false,
		Message: message,
		Data:    data,
	})
}
func NewPagination(total int64, page, perPage int) *PaginationObj {
	if perPage <= 0 {
		perPage = 10
	}
	totalPages := int((total + int64(perPage) - 1) / int64(perPage))
	return &PaginationObj{
		CurrentPage:  page,
		TotalPages:   totalPages,
		TotalItems:   total,
		ItemsPerPage: perPage,
		HasNext:      page < totalPages,
		HasPrev:      page > 1,
	}
}
package utils
import (
	"context"
	"fmt"
	"log/slog"
	"net/url"
	"sync"
	"time"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
)
var (
	once        sync.Once
	initErr     error
	mongoClient *mongo.Client
	deviceLocC  *mongo.Collection
)
type MongoConfig struct {
	Host     string
	Port     string
	Username string
	Password string
	DB       string
	ConnectTimeout   time.Duration
	MaxPoolSize      uint64
	MinPoolSize      uint64
	MaxConnIdleTime  time.Duration
}
func DefaultMongoConfig() MongoConfig {
	return MongoConfig{
		Host:            GetEnv("MONGO_HOST", "mongo"),
		Port:            GetEnv("MONGO_PORT", "27017"),
		Username:        GetEnv("MONGO_INITDB_ROOT_USERNAME", "admin"),
		Password:        GetEnv("MONGO_INITDB_ROOT_PASSWORD", "admin"),
		DB:              GetEnv("MONGO_DB", "mqtt_db"),
		ConnectTimeout:  10 * time.Second,
		MaxPoolSize:     50,
		MinPoolSize:     10,
		MaxConnIdleTime: 30 * time.Second,
	}
}
func InitMongo() (*mongo.Client, error) {
	once.Do(func() {
		mongoClient, deviceLocC, initErr = NewMongo(DefaultMongoConfig())
	})
	return mongoClient, initErr
}
func NewMongo(cfg MongoConfig) (*mongo.Client, *mongo.Collection, error) {
	uri := buildURI(cfg)
	opts := options.Client().
		ApplyURI(uri).
		SetConnectTimeout(cfg.ConnectTimeout).
		SetMaxPoolSize(cfg.MaxPoolSize).
		SetMinPoolSize(cfg.MinPoolSize).
		SetMaxConnIdleTime(cfg.MaxConnIdleTime)
	ctx, cancel := context.WithTimeout(context.Background(), cfg.ConnectTimeout)
	defer cancel()
	client, err := mongo.Connect(ctx, opts)
	if err != nil {
		return nil, nil, fmt.Errorf("mongo connect: %w", err)
	}
	if err := client.Ping(ctx, readpref.Primary()); err != nil {
		_ = client.Disconnect(context.Background()) 
		return nil, nil, fmt.Errorf("mongo ping: %w", err)
	}
	coll := client.Database(cfg.DB).Collection("device_loc")
	slog.Info("MongoDB connected", "uri", uri, "db", cfg.DB)
	return client, coll, nil
}
func CloseMongo() {
	_ = Shutdown(context.Background(), 5*time.Second)
}
func Shutdown(ctx context.Context, timeout time.Duration) error {
	if mongoClient == nil {
		return nil
	}
	ctx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()
	if err := mongoClient.Disconnect(ctx); err != nil {
		return fmt.Errorf("mongo disconnect: %w", err)
	}
	slog.Info("MongoDB disconnected")
	return nil
}
func buildURI(cfg MongoConfig) string {
	user := url.QueryEscape(cfg.Username)
	pass := url.QueryEscape(cfg.Password)
	return fmt.Sprintf("mongodb://%s:%s@%s:%s/%s?authSource=admin",
		user, pass, cfg.Host, cfg.Port, cfg.DB)
}
func Mongo() *mongo.Client {
	if mongoClient == nil {
		panic("mongo not initialized")
	}
	return mongoClient
}
func DeviceLocColl() *mongo.Collection {
	if deviceLocC == nil {
		panic("mongo not initialized")
	}
	return deviceLocC
}
package main
import (
	"log"
	"os"
	"os/signal"
	"syscall"
	"gorm.io/gorm"
	"IOT-Manage-System/warning-service/config"
	"IOT-Manage-System/warning-service/repo"
	"IOT-Manage-System/warning-service/service"
	"IOT-Manage-System/warning-service/utils"
)
const (
	LocTopic    = "location/#"
	OnlineTopic = "online"
)
func main() {
	config.Load()
	utils.InitMQTT()
	defer utils.CloseMQTT()
	var db *gorm.DB
	var err error
	db, err = utils.InitDB()
	if err != nil {
		log.Fatalf("初始化数据库失败: %v", err)
	}
	defer func() {
		if err := utils.CloseDB(db); err != nil {
			log.Printf("关闭数据库失败: %v", err)
		} else {
			log.Println("数据库已正常关闭")
		}
	}()
	log.Println("使用数据库模式")
	safeDist := repo.NewSafeDist()
	dangerZone := repo.NewDangerZone()
	markRepo := repo.NewMarkRepo(db) 
	poller := service.NewDistancePoller(markRepo, safeDist, dangerZone)
	poller.Start()
	defer poller.Stop() 
	fenceChecker := service.NewFenceChecker()
	locator := service.NewLocator(db, safeDist, dangerZone, markRepo, fenceChecker)
	locator.StartDistanceChecker()
	token := utils.MQTTClient.Subscribe(LocTopic, 0, service.MultiHandler(locator.OnLocMsg, locator.Online))
	if token.Wait() && token.Error() != nil {
		log.Fatalf("[FATAL] 订阅 location/# 失败: %v", token.Error())
	}
	log.Println("warning-service started")
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	log.Println("warning-service exiting")
}
package handler
import (
	"IOT-Manage-System/user-service/model"
	"IOT-Manage-System/user-service/service"
	"IOT-Manage-System/user-service/utils"
	"strconv"
	"github.com/gin-gonic/gin"
)
type UserHandler interface {
	Create(c *gin.Context)
	GetMe(c *gin.Context)
	GetUser(c *gin.Context)
	UpdateUser(c *gin.Context)
	DeleteUser(c *gin.Context)
	ListUsers(c *gin.Context)
}
type userHandler struct {
	userService service.UserService
}
func NewUserHandler(us service.UserService) UserHandler {
	return &userHandler{
		userService: us,
	}
}
func (h *userHandler) Create(c *gin.Context) {
	var req model.UserCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.SendBadRequest(c, "请求参数错误: "+err.Error())
		return
	}
	currentUserType := utils.GetUserType(c.Request.Header)
	switch currentUserType {
	case "":
		utils.SendUnauthorized(c)
	case "user":
		return
	case "admin":
		req.UserType = model.UserTypeUser
	default:
	}
	user, err := h.userService.Register(&req)
	switch err {
	case nil:
		utils.SendCreatedResponse(c, user, "用户创建成功")
	case service.ErrUserExists:
		utils.SendConflict(c, "用户名已存在")
	case service.ErrInvalidInput:
		utils.SendBadRequest(c, "用户名或密码不能为空")
	default:
		utils.SendInternalServerError(c, err)
	}
}
func (h *userHandler) GetMe(c *gin.Context) {
	id := utils.GetUserID(c.Request.Header)
	if id == "" {
		utils.SendUnauthorized(c)
		return
	}
	user, err := h.userService.GetUserById(id)
	switch err {
	case nil:
		utils.SendSuccessResponse(c, user)
	case service.ErrUserNotFound:
		utils.SendNotFound(c, "用户不存在")
	default:
		utils.SendInternalServerError(c, err)
	}
}
func (h *userHandler) GetUser(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		utils.SendBadRequest(c, "缺少用户 ID")
		return
	}
	user, err := h.userService.GetUserById(id)
	switch err {
	case nil:
		utils.SendSuccessResponse(c, user)
	case service.ErrUserNotFound:
		utils.SendNotFound(c, "用户不存在")
	default:
		utils.SendInternalServerError(c, err)
	}
}
func (h *userHandler) UpdateUser(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		utils.SendBadRequest(c, "缺少用户 ID")
		return
	}
	var req model.UserUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.SendBadRequest(c, "参数错误: "+err.Error())
		return
	}
	user, err := h.userService.UpdateUser(id, &req)
	switch err {
	case nil:
		utils.SendSuccessResponse(c, user)
	case service.ErrUserNotFound:
		utils.SendNotFound(c, "用户不存在")
	case service.ErrUserExists:
		utils.SendConflict(c, "用户名已被占用")
	default:
		utils.SendInternalServerError(c, err)
	}
}
func (h *userHandler) DeleteUser(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		utils.SendBadRequest(c, "缺少用户 ID")
		return
	}
	if err := h.userService.DeleteUser(id); err != nil {
		switch err {
		case service.ErrUserNotFound:
			utils.SendNotFound(c, "用户不存在")
		default:
			utils.SendInternalServerError(c, err)
		}
		return
	}
	utils.SendSuccessResponse(c, "删除成功")
}
func (h *userHandler) ListUsers(c *gin.Context) {
	page, _ := strconv.Atoi(c.Query("page"))
	if page <= 0 {
		page = 1
	}
	limit, _ := strconv.Atoi(c.Query("limit"))
	if limit <= 0 || limit > 100 {
		limit = 10
	}
	resp, total, err := h.userService.ListUsers(page, limit)
	if err != nil {
		utils.SendInternalServerError(c, err)
		return
	}
	utils.SendPaginatedResponse(c, resp, total, page, limit)
}
package model
import (
	"time"
	"github.com/google/uuid"
	"github.com/lib/pq"
)
type Mark struct {
	ID            uuid.UUID      `gorm:"primaryKey;type:uuid;default:gen_random_uuid();column:id"` 
	DeviceID      string         `gorm:"unique;size:255;not null;column:device_id"`                
	MarkName      string         `gorm:"size:255;not null;column:mark_name"`                       
	MqttTopic     pq.StringArray `gorm:"type:text[];not null;default:'{}';column:mqtt_topic"`      
	PersistMQTT   bool           `gorm:"not null;default:false;column:persist_mqtt"`               
	SafeDistanceM *float64       `gorm:"column:safe_distance_m"`                                   
	MarkTypeID    int            `gorm:"not null;column:mark_type_id"`                             
	CreatedAt     time.Time      `gorm:"not null;default:now();column:created_at"`                 
	UpdatedAt     time.Time      `gorm:"not null;default:now();column:updated_at"`                 
	LastOnlineAt  *time.Time     `gorm:"column:last_online_at"`                                    
}
func (Mark) TableName() string {
	return "marks"
}
type MarkPairSafeDistance struct {
	Mark1ID   uuid.UUID `gorm:"primaryKey"` 
	Mark2ID   uuid.UUID `gorm:"primaryKey"` 
	DistanceM float64   
}
func (MarkPairSafeDistance) TableName() string {
	return "mark_pair_safe_distance"
}
package service
import (
	"log"
	"time"
	"IOT-Manage-System/warning-service/repo"
)
type DistancePoller struct {
	r    *repo.MarkRepo
	sd   *repo.SafeDist
	dz   *repo.DangerZone
	tick *time.Ticker
	stop chan struct{}
	done chan struct{}
}
func NewDistancePoller(r *repo.MarkRepo, sd *repo.SafeDist, dz *repo.DangerZone) *DistancePoller {
	return &DistancePoller{
		r:    r,
		sd:   sd,
		dz:   dz,
		stop: make(chan struct{}),
		done: make(chan struct{}),
	}
}
func (p *DistancePoller) Start() {
	p.tick = time.NewTicker(time.Second)
	go p.loop()
}
func (p *DistancePoller) Stop() {
	close(p.stop)
	<-p.done
}
func (p *DistancePoller) loop() {
	defer close(p.done)
	defer p.tick.Stop()
	for {
		select {
		case <-p.tick.C:
			onlineDeviceIDs, err := p.r.GetOnlineList()
			if err != nil {
				log.Printf("GetOnlineList error: %v", err)
				continue 
			}
			if len(onlineDeviceIDs) == 0 {
				continue
			}
			pairs, err := p.r.GetDistanceByDevice(onlineDeviceIDs)
			if err != nil {
				log.Printf("GetDistanceByDevice error: %v", err)
				continue
			}
			maps, err := p.r.GetBatchDangerZoneM(onlineDeviceIDs)
			if err != nil {
				log.Printf("GetBatchDangerZoneM error: %v", err)
				continue
			}
			p.sd.SetBatch(pairs)
			p.dz.SetBatch(maps)
		case <-p.stop:
			return
		}
	}
}
package handler
import (
	"IOT-Manage-System/user-service/model"
	"IOT-Manage-System/user-service/service"
	"IOT-Manage-System/user-service/utils"
	"net/http"
	"github.com/gin-gonic/gin"
)
type AuthHandler interface {
	Login(c *gin.Context)
	Refresh(c *gin.Context)
}
type authHandler struct {
	authService service.AuthService
}
func NewAuthHandler(as service.AuthService) AuthHandler {
	return &authHandler{
		authService: as,
	}
}
func (h *authHandler) Login(c *gin.Context) {
	var req model.UserLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.SendBadRequest(c, "请求参数错误: "+err.Error())
		return
	}
	resp, err := h.authService.Login(&req)
	switch err {
	case nil:
		utils.SendSuccessResponse(c, resp)
	case service.ErrUserNotFound, service.ErrWrongPassword:
		utils.SendErrorResponse(c, 200, "用户或用户名错误🤔")
	default:
		utils.SendErrorResponse(c, 200, "Token生成失败")
	}
}
func (h *authHandler) Refresh(c *gin.Context) {
	var req model.RefreshTokenRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		utils.SendBadRequest(c, "请求参数错误: "+err.Error())
		return
	}
	resp, err := h.authService.Refresh(&req)
	switch err {
	case nil:
		utils.SendSuccessResponse(c, resp)
	case service.ErrInvalidToken:
		utils.SendErrorResponse(c, http.StatusOK, "无效Token")
	default:
		utils.SendInternalServerError(c, err)
	}
}
package model
type LocMsg struct {
	ID   string `json:"id"`
	Sens []Sens `json:"sens"`
}
type Sens struct {
	N string    `json:"n"` 
	U string    `json:"u"` 
	V []float64 `json:"v"` 
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
package service
import (
	"log"
	"strconv"
	"sync"
	"time"
	"IOT-Manage-System/warning-service/utils"
	mqtt "github.com/eclipse/paho.mqtt.golang"
)
type WarningRateLimiter struct {
	records map[string][]time.Time 
	mu      sync.RWMutex
	maxRate int           
	window  time.Duration 
}
var rateLimiter *WarningRateLimiter
func init() {
	rateLimiter = &WarningRateLimiter{
		records: make(map[string][]time.Time),
		maxRate: 1,
		window:  1000 * time.Millisecond, 
	}
	go rateLimiter.cleanupLoop()
}
func (r *WarningRateLimiter) Allow(deviceID string, on bool) bool {
	r.mu.Lock()
	defer r.mu.Unlock()
	now := time.Now()
	key := deviceID + ":" + strconv.FormatBool(on)
	times, exists := r.records[key]
	if !exists {
		r.records[key] = []time.Time{now}
		return true
	}
	validTimes := make([]time.Time, 0, len(times))
	for _, t := range times {
		if now.Sub(t) < r.window {
			validTimes = append(validTimes, t)
		}
	}
	if len(validTimes) >= r.maxRate {
		return false
	}
	validTimes = append(validTimes, now)
	r.records[key] = validTimes
	return true
}
func (r *WarningRateLimiter) cleanupLoop() {
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()
	for range ticker.C {
		r.mu.Lock()
		now := time.Now()
		for key, times := range r.records {
			validTimes := make([]time.Time, 0)
			for _, t := range times {
				if now.Sub(t) < r.window {
					validTimes = append(validTimes, t)
				}
			}
			if len(validTimes) == 0 {
				delete(r.records, key)
			} else {
				r.records[key] = validTimes
			}
		}
		r.mu.Unlock()
	}
}
func SendWarning(deviceID string, on bool) {
	if !rateLimiter.Allow(deviceID, on) {
		return
	}
	var token mqtt.Token
	payload := "0"
	if on {
		payload = "1"
	}
	token = utils.MQTTClient.Publish("warning/"+deviceID, 0, false, payload)
	token.Wait()
	if err := token.Error(); err != nil {
		log.Printf("[ERROR] 发送警报失败: %v", err)
		return
	}
}
package model
type FenceCheckRequest struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
}
type FenceCheckResponse struct {
	Success   bool           `json:"success"`
	Message   string         `json:"message"`
	Data      FenceCheckData `json:"data"`
	Timestamp string         `json:"timestamp,omitempty"`
}
type FenceCheckData struct {
	IsInside   bool     `json:"is_inside"`
	FenceID    string   `json:"fence_id,omitempty"`
	FenceName  string   `json:"fence_name,omitempty"`
	FenceNames []string `json:"fence_names,omitempty"`
}
package service
import (
	"log"
	"math"
	"time"
	"github.com/goccy/go-json"
	mqtt "github.com/eclipse/paho.mqtt.golang"
	"gorm.io/gorm"
	"IOT-Manage-System/warning-service/model"
	"IOT-Manage-System/warning-service/repo"
	"IOT-Manage-System/warning-service/utils"
)
type Locator struct {
	MemRepo      *repo.MemRepo
	SafeDist     *repo.SafeDist
	DangerZone   *repo.DangerZone
	MarkRepo     *repo.MarkRepo
	FenceChecker *FenceChecker
}
func NewLocator(db *gorm.DB, SafeDist *repo.SafeDist, DangerZone *repo.DangerZone, MarkRepo *repo.MarkRepo, FenceChecker *FenceChecker) *Locator {
	return &Locator{
		MemRepo:      repo.NewMemRepo(),
		SafeDist:     SafeDist,
		DangerZone:   DangerZone,
		MarkRepo:     MarkRepo,
		FenceChecker: FenceChecker,
	}
}
func (l *Locator) OnLocMsg(c mqtt.Client, m mqtt.Message) {
	log.Println("data: \v", string(m.Payload()))
	var msg model.LocMsg
	if err := json.Unmarshal(m.Payload(), &msg); err != nil {
		log.Println("[WARN] json err:", err)
		return
	}
	if len(msg.Sens) == 0 {
		return
	}
	var rtkS, uwbS *model.Sens
	for i := range msg.Sens {
		switch msg.Sens[i].N {
		case "RTK":
			rtkS = &msg.Sens[i]
		case "UWB":
			uwbS = &msg.Sens[i]
		}
	}
	if rtkS != nil && len(rtkS.V) >= 2 && rtkS.V[0] != 0 && rtkS.V[1] != 0 {
		l.MemRepo.SetRTK(&model.RTKLoc{
			ID:     msg.ID,
			Indoor: uwbS != nil,
			Lon:    rtkS.V[0],
			Lat:    rtkS.V[1],
		})
		if l.FenceChecker != nil {
			go l.checkFenceOutdoor(msg.ID, rtkS.V[0], rtkS.V[1])
		}
	}
	rtkValid := rtkS != nil && len(rtkS.V) >= 2 && rtkS.V[0] != 0 && rtkS.V[1] != 0
	uwbValid := uwbS != nil && len(uwbS.V) >= 2
	uwbIsZero := uwbS != nil && len(uwbS.V) >= 2 && uwbS.V[0] == 0 && uwbS.V[1] == 0
	if uwbValid && !(uwbIsZero && rtkValid) {
		l.MemRepo.SetUWB(&model.UWBLoc{
			ID: msg.ID,
			X:  uwbS.V[0],
			Y:  uwbS.V[1],
		})
		if l.FenceChecker != nil {
			go l.checkFenceIndoor(msg.ID, uwbS.V[0], uwbS.V[1])
		}
	} else if uwbIsZero && rtkValid {
	} else if uwbIsZero && !rtkValid {
		l.MemRepo.SetUWB(&model.UWBLoc{
			ID: msg.ID,
			X:  uwbS.V[0],
			Y:  uwbS.V[1],
		})
		if l.FenceChecker != nil {
			go l.checkFenceIndoor(msg.ID, uwbS.V[0], uwbS.V[1])
		}
	}
}
func (l *Locator) Online(c mqtt.Client, m mqtt.Message) {
	var msg model.OnlineMsg
	if err := json.Unmarshal(m.Payload(), &msg); err != nil {
		log.Println("[WARN] json err:", err)
		return
	}
	l.MarkRepo.SetOnline(msg.ID, time.Now())
}
func (l *Locator) checkFenceIndoor(deviceID string, x, y float64) {
	isInside, err := l.FenceChecker.CheckPointIndoor(deviceID, x, y)
	if err != nil {
		log.Printf("[WARN] 检查室内围栏失败 deviceID=%s error=%v", deviceID, err)
		return
	}
	if l.FenceChecker.ShouldSendAlert(deviceID, isInside) {
		if isInside {
			log.Printf("[FENCE_ALERT] 设备 %s 在室内电子围栏内，发送警报", deviceID)
			SendWarning(deviceID, true)
		} else {
			log.Printf("[FENCE_ALERT] 设备 %s 离开室内电子围栏，取消警报", deviceID)
			SendWarning(deviceID, false)
		}
	}
}
func (l *Locator) checkFenceOutdoor(deviceID string, x, y float64) {
	isInside, err := l.FenceChecker.CheckPointOutdoor(deviceID, x, y)
	if err != nil {
		log.Printf("[WARN] 检查室外围栏失败 deviceID=%s error=%v", deviceID, err)
		return
	}
	if l.FenceChecker.ShouldSendAlert(deviceID, isInside) {
		if isInside {
			log.Printf("[FENCE_ALERT] 设备 %s 在室外围栏内，发送警报", deviceID)
			SendWarning(deviceID, true)
		} else {
			log.Printf("[FENCE_ALERT] 设备 %s 离开室外围栏，取消警报", deviceID)
			SendWarning(deviceID, false)
		}
	}
}
func (l *Locator) StartDistanceChecker() {
	go func() {
		ticker := time.NewTicker(100 * time.Millisecond)
		defer ticker.Stop()
		for range ticker.C {
			l.batchCheckRTK()
			l.batchCheckUWB()
		}
	}()
}
func (l *Locator) batchCheckRTK() {
	snapshot := l.MemRepo.RTKSnapshot()
	ids := make([]string, 0, len(snapshot))
	for id := range snapshot {
		ids = append(ids, id)
	}
	for i := 0; i < len(ids); i++ {
		for j := i + 1; j < len(ids); j++ {
			a, b := snapshot[ids[i]], snapshot[ids[j]]
			distance := utils.CalculateRTK(*a, *b)
			safeDistanceMap, err := l.MarkRepo.GetDistanceMapByDevice(a.ID)
			if err != nil {
				log.Printf("[WARN] 查询设备 %s 安全距离失败: %v", a.ID, err)
				safeDistanceMap = make(map[string]float64)
			}
			safe := safeDistanceMap[b.ID]
			if safe <= 0 {
				safeDistanceMap, err := l.MarkRepo.GetDistanceMapByDevice(b.ID)
				if err != nil {
					log.Printf("[WARN] 查询设备 %s 安全距离失败: %v", b.ID, err)
					safe = -1
				} else {
					safe = safeDistanceMap[a.ID]
				}
			}
			if safe > 0 && distance < safe {
				go SendWarning(a.ID, true)
				go SendWarning(b.ID, true)
				l.MemRepo.ClearRTK()
			}
			dangerZoneA, _ := l.MarkRepo.GetDangerZoneM(a.ID)
			dangerZoneB, _ := l.MarkRepo.GetDangerZoneM(b.ID)
			dangerZone := math.Max(dangerZoneA, dangerZoneB)
			if dangerZone > 0 && distance < dangerZone {
				go SendWarning(a.ID, true)
				go SendWarning(b.ID, true)
				l.MemRepo.ClearRTK()
			}
		}
	}
}
func (l *Locator) batchCheckUWB() {
	snapshot := l.MemRepo.UWBSnapshot()
	ids := make([]string, 0, len(snapshot))
	for id := range snapshot {
		ids = append(ids, id)
	}
	for i := 0; i < len(ids); i++ {
		for j := i + 1; j < len(ids); j++ {
			a, b := snapshot[ids[i]], snapshot[ids[j]]
			distance := utils.CalculateUWB(*a, *b)
			safeDistanceMap, err := l.MarkRepo.GetDistanceMapByDevice(a.ID)
			if err != nil {
				log.Printf("[WARN] 查询设备 %s 安全距离失败: %v", a.ID, err)
				safeDistanceMap = make(map[string]float64)
			}
			safe := safeDistanceMap[b.ID]
			if safe <= 0 {
				safeDistanceMap, err := l.MarkRepo.GetDistanceMapByDevice(b.ID)
				if err != nil {
					log.Printf("[WARN] 查询设备 %s 安全距离失败: %v", b.ID, err)
					safe = -1
				} else {
					safe = safeDistanceMap[a.ID]
				}
			}
			if safe > 0 && distance < safe {
				go SendWarning(a.ID, true)
				go SendWarning(b.ID, true)
				l.MemRepo.ClearUWB()
			}
			dangerZoneA, _ := l.MarkRepo.GetDangerZoneM(a.ID)
			dangerZoneB, _ := l.MarkRepo.GetDangerZoneM(b.ID)
			dangerZone := math.Max(dangerZoneA, dangerZoneB)
			if dangerZone > 0 && distance < dangerZone {
				go SendWarning(a.ID, true)
				go SendWarning(b.ID, true)
				l.MemRepo.ClearUWB()
			}
		}
	}
}
func MultiHandler(handlers ...mqtt.MessageHandler) mqtt.MessageHandler {
	return func(c mqtt.Client, m mqtt.Message) {
		for _, h := range handlers {
			h(c, m)
		}
	}
}
package service
import (
	"bytes"
	"fmt"
	"io"
	"log"
	"net/http"
	"sync"
	"time"
	"github.com/goccy/go-json"
	"IOT-Manage-System/warning-service/config"
	"IOT-Manage-System/warning-service/model"
)
type FenceRateLimiter struct {
	records map[string][]time.Time 
	mu      sync.RWMutex
	maxRate int           
	window  time.Duration 
}
type FenceChecker struct {
	client  *http.Client
	baseURL string
	statusCache map[string]bool 
	mu          sync.RWMutex
	rateLimiter *FenceRateLimiter
}
func NewFenceRateLimiter() *FenceRateLimiter {
	limiter := &FenceRateLimiter{
		records: make(map[string][]time.Time),
		maxRate: 5,               
		window:  1 * time.Second, 
	}
	go limiter.cleanupLoop()
	return limiter
}
func (r *FenceRateLimiter) Allow(deviceID string) bool {
	r.mu.Lock()
	defer r.mu.Unlock()
	now := time.Now()
	times, exists := r.records[deviceID]
	if !exists {
		r.records[deviceID] = []time.Time{now}
		return true
	}
	validTimes := make([]time.Time, 0, len(times))
	for _, t := range times {
		if now.Sub(t) < r.window {
			validTimes = append(validTimes, t)
		}
	}
	if len(validTimes) >= r.maxRate {
		return false
	}
	validTimes = append(validTimes, now)
	r.records[deviceID] = validTimes
	return true
}
func (r *FenceRateLimiter) cleanupLoop() {
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()
	for range ticker.C {
		r.mu.Lock()
		now := time.Now()
		for deviceID, times := range r.records {
			validTimes := make([]time.Time, 0)
			for _, t := range times {
				if now.Sub(t) < r.window {
					validTimes = append(validTimes, t)
				}
			}
			if len(validTimes) == 0 {
				delete(r.records, deviceID)
			} else {
				r.records[deviceID] = validTimes
			}
		}
		r.mu.Unlock()
	}
}
func NewFenceChecker() *FenceChecker {
	hostname := config.C.MapServiceConfig.Hostname
	port := config.C.MapServiceConfig.Port
	baseURL := fmt.Sprintf("http://%s:%s", hostname, port)
	log.Printf("[INFO] FenceChecker 初始化, baseURL=%s", baseURL)
	return &FenceChecker{
		client: &http.Client{
			Timeout: 3 * time.Second, 
		},
		baseURL:     baseURL,
		statusCache: make(map[string]bool),
		rateLimiter: NewFenceRateLimiter(),
	}
}
func (fc *FenceChecker) CheckPoint(deviceID string, x, y float64) (bool, error) {
	if !fc.rateLimiter.Allow(deviceID) {
		fc.mu.RLock()
		cachedStatus, exists := fc.statusCache[deviceID]
		fc.mu.RUnlock()
		if exists {
			return cachedStatus, nil
		}
		return false, nil
	}
	reqBody := model.FenceCheckRequest{
		X: x,
		Y: y,
	}
	bodyBytes, err := json.Marshal(reqBody)
	if err != nil {
		return false, fmt.Errorf("序列化请求失败: %w", err)
	}
	url := fc.baseURL + "/api/v1/polygon-fence/check-all"
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(bodyBytes))
	if err != nil {
		return false, fmt.Errorf("创建请求失败: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	resp, err := fc.client.Do(req)
	if err != nil {
		return false, fmt.Errorf("请求map-service失败: %w", err)
	}
	defer resp.Body.Close()
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, fmt.Errorf("读取响应失败: %w", err)
	}
	var fenceResp model.FenceCheckResponse
	if err := json.Unmarshal(respBody, &fenceResp); err != nil {
		return false, fmt.Errorf("解析响应失败: %w", err)
	}
	if !fenceResp.Success {
		return false, fmt.Errorf("map-service返回错误: %s", fenceResp.Message)
	}
	isInside := fenceResp.Data.IsInside
	fc.mu.Lock()
	prevStatus, exists := fc.statusCache[deviceID]
	fc.statusCache[deviceID] = isInside
	fc.mu.Unlock()
	if !exists {
		if isInside {
		}
	} else if prevStatus != isInside {
		if isInside {
		} else {
		}
	}
	return isInside, nil
}
func (fc *FenceChecker) CheckPointIndoor(deviceID string, x, y float64) (bool, error) {
	if !fc.rateLimiter.Allow(deviceID) {
		fc.mu.RLock()
		cachedStatus, exists := fc.statusCache[deviceID]
		fc.mu.RUnlock()
		if exists {
			return cachedStatus, nil
		}
		return false, nil
	}
	reqBody := model.FenceCheckRequest{X: x, Y: y}
	bodyBytes, err := json.Marshal(reqBody)
	if err != nil {
		return false, fmt.Errorf("序列化请求失败: %w", err)
	}
	url := fc.baseURL + "/api/v1/polygon-fence/check-indoor-any"
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(bodyBytes))
	if err != nil {
		return false, fmt.Errorf("创建请求失败: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	resp, err := fc.client.Do(req)
	if err != nil {
		return false, fmt.Errorf("请求map-service失败: %w", err)
	}
	defer resp.Body.Close()
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, fmt.Errorf("读取响应失败: %w", err)
	}
	var fenceResp model.FenceCheckResponse
	if err := json.Unmarshal(respBody, &fenceResp); err != nil {
		return false, fmt.Errorf("解析响应失败: %w", err)
	}
	if !fenceResp.Success {
		return false, fmt.Errorf("map-service返回错误: %s", fenceResp.Message)
	}
	isInside := fenceResp.Data.IsInside
	fc.mu.Lock()
	fc.statusCache[deviceID] = isInside
	fc.mu.Unlock()
	return isInside, nil
}
func (fc *FenceChecker) CheckPointOutdoor(deviceID string, x, y float64) (bool, error) {
	if !fc.rateLimiter.Allow(deviceID) {
		fc.mu.RLock()
		cachedStatus, exists := fc.statusCache[deviceID]
		fc.mu.RUnlock()
		if exists {
			return cachedStatus, nil
		}
		return false, nil
	}
	reqBody := model.FenceCheckRequest{X: x, Y: y}
	bodyBytes, err := json.Marshal(reqBody)
	if err != nil {
		return false, fmt.Errorf("序列化请求失败: %w", err)
	}
	url := fc.baseURL + "/api/v1/polygon-fence/check-outdoor-any"
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(bodyBytes))
	if err != nil {
		return false, fmt.Errorf("创建请求失败: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	resp, err := fc.client.Do(req)
	if err != nil {
		return false, fmt.Errorf("请求map-service失败: %w", err)
	}
	defer resp.Body.Close()
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, fmt.Errorf("读取响应失败: %w", err)
	}
	var fenceResp model.FenceCheckResponse
	if err := json.Unmarshal(respBody, &fenceResp); err != nil {
		return false, fmt.Errorf("解析响应失败: %w", err)
	}
	if !fenceResp.Success {
		return false, fmt.Errorf("map-service返回错误: %s", fenceResp.Message)
	}
	isInside := fenceResp.Data.IsInside
	fc.mu.Lock()
	fc.statusCache[deviceID] = isInside
	fc.mu.Unlock()
	return isInside, nil
}
func (fc *FenceChecker) IsStatusChanged(deviceID string, currentStatus bool) bool {
	fc.mu.RLock()
	defer fc.mu.RUnlock()
	prevStatus, exists := fc.statusCache[deviceID]
	if !exists {
		return currentStatus 
	}
	return prevStatus != currentStatus
}
func (fc *FenceChecker) ShouldSendAlert(deviceID string, currentStatus bool) bool {
	fc.mu.RLock()
	defer fc.mu.RUnlock()
	prevStatus, exists := fc.statusCache[deviceID]
	if !exists {
		return currentStatus 
	}
	if currentStatus {
		return true
	}
	return prevStatus != currentStatus
}
func (fc *FenceChecker) GetCurrentStatus(deviceID string) (bool, bool) {
	fc.mu.RLock()
	defer fc.mu.RUnlock()
	status, exists := fc.statusCache[deviceID]
	return status, exists
}
package utils
import (
	"fmt"
	"log"
	"time"
	mqtt "github.com/eclipse/paho.mqtt.golang"
	"IOT-Manage-System/warning-service/config"
)
var MQTTClient mqtt.Client
func InitMQTT() {
	url := config.C.MQTTConfig.MQTT_BROKER
	opts := mqtt.NewClientOptions().
		AddBroker(url).
		SetClientID(fmt.Sprintf("warning-service-%d", time.Now().UnixNano())).
		SetUsername(config.C.MQTTConfig.MQTT_USERNAME).
		SetPassword(config.C.MQTTConfig.MQTT_PASSWORD).
		SetKeepAlive(60 * time.Second).
		SetPingTimeout(10 * time.Second).
		SetAutoReconnect(true).
		SetMaxReconnectInterval(10 * time.Second).
		SetCleanSession(false)
	MQTTClient = mqtt.NewClient(opts)
	if token := MQTTClient.Connect(); token.Wait() && token.Error() != nil {
		log.Fatalf("mqtt connect error: %v", token.Error())
	}
	log.Println("连接" + url + " mqtt broker 成功")
}
func CloseMQTT() {
	if MQTTClient != nil && MQTTClient.IsConnected() {
		MQTTClient.Disconnect(250) 
		log.Println("mqtt disconnected")
	}
	MQTTClient = nil 
	log.Println("断开mqtt broker连接成功")
}
package repo
import (
	"errors"
	"fmt"
	"io"
	"log"
	"net/http"
	"time"
	"github.com/goccy/go-json"
	"github.com/google/uuid"
	"gorm.io/gorm"
	"IOT-Manage-System/warning-service/config"
	"IOT-Manage-System/warning-service/model"
)
type MarkAPIClient struct {
	client  *http.Client
	baseURL string
}
type APIResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data"`
	Message string      `json:"message"`
	Code    int         `json:"code,omitempty"`
}
type MarkInfo struct {
	ID           string    `json:"id"`
	DeviceID     string    `json:"device_id"`
	MarkName     string    `json:"mark_name"`
	MqttTopic    []string  `json:"mqtt_topic"`
	PersistMQTT  bool      `json:"persist_mqtt"`
	DangerZoneM  *float64  `json:"danger_zone_m"`
	MarkType     *MarkType `json:"mark_type,omitempty"`
	Tags         []Tag     `json:"tags,omitempty"`
	CreatedAt    string    `json:"created_at"`
	UpdatedAt    string    `json:"updated_at"`
	LastOnlineAt *string   `json:"last_online_at"`
}
type MarkType struct {
	ID                 int     `json:"id"`
	TypeName           string  `json:"type_name"`
	DefaultDangerZoneM float64 `json:"default_danger_zone_m"`
}
type Tag struct {
	ID      int    `json:"id"`
	TagName string `json:"tag_name"`
}
type DangerZoneResponse struct {
	DeviceID    string  `json:"device_id"`
	DangerZoneM float64 `json:"danger_zone_m"`
}
type DistanceMapResponse map[string]float64
type MarkRepo struct {
	db        *gorm.DB
	apiClient *MarkAPIClient
	useAPI    bool 
}
func NewMarkRepo(db *gorm.DB) *MarkRepo {
	return &MarkRepo{
		db:        db,
		apiClient: NewMarkAPIClient(),
		useAPI:    true, 
	}
}
func NewMarkAPIClient() *MarkAPIClient {
	hostname := config.C.MarkServiceConfig.Hostname
	port := config.C.MarkServiceConfig.Port
	baseURL := fmt.Sprintf("http://%s:%s", hostname, port)
	log.Printf("[INFO] MarkAPIClient 初始化, baseURL=%s", baseURL)
	return &MarkAPIClient{
		client: &http.Client{
			Timeout: 5 * time.Second, 
		},
		baseURL: baseURL,
	}
}
func NewMarkRepoWithDB(db *gorm.DB) *MarkRepo {
	return &MarkRepo{
		db:        db,
		apiClient: nil,
		useAPI:    false,
	}
}
func (r *MarkRepo) SetOnline(deviceID string, t ...time.Time) error {
	if r.useAPI && r.apiClient != nil {
		return r.apiClient.UpdateLastOnlineTime(deviceID)
	}
	onlineAt := time.Now()
	if len(t) > 0 {
		onlineAt = t[0]
	}
	return r.db.Model(&model.Mark{}).
		Where("device_id = ?", deviceID).
		Update("last_online_at", onlineAt).Error
}
func (r *MarkRepo) GetOnlineList() ([]string, error) {
	if r.useAPI && r.apiClient != nil {
		return r.apiClient.GetOnlineDevices()
	}
	cutoff := time.Now().Add(-time.Duration(config.C.AppConfig.OnlineSecond) * time.Second)
	var ids []string
	err := r.db.Model(&model.Mark{}).
		Where("last_online_at >= ?", cutoff).
		Pluck("device_id", &ids).Error
	return ids, err
}
func (r *MarkRepo) IsOnline(deviceID string) (bool, error) {
	cutoff := time.Now().Add(-time.Duration(config.C.AppConfig.OnlineSecond) * time.Second)
	var count int64
	err := r.db.Model(&model.Mark{}).
		Where("device_id = ?", deviceID).
		Where("last_online_at >= ?", cutoff).
		Count(&count).Error
	return count > 0, err
}
func (r *MarkRepo) GetDangerZoneM(deviceID string) (float64, error) {
	if r.useAPI && r.apiClient != nil {
		return r.apiClient.GetDangerZoneByDeviceID(deviceID)
	}
	var dangerZoneM *float64 
	err := r.db.Model(&model.Mark{}).
		Where("device_id = ?", deviceID).
		Select("safe_distance_m").
		Scan(&dangerZoneM).Error
	if err != nil {
		return 0, err
	}
	if dangerZoneM == nil {
		return -1, nil 
	}
	return *dangerZoneM, nil
}
func (r *MarkRepo) GetBatchDangerZoneM(deviceIDs []string) (map[string]float64, error) {
	if len(deviceIDs) == 0 {
		return map[string]float64{}, nil
	}
	if r.useAPI && r.apiClient != nil {
		result := make(map[string]float64, len(deviceIDs))
		for _, deviceID := range deviceIDs {
			dangerZone, err := r.apiClient.GetDangerZoneByDeviceID(deviceID)
			if err != nil {
				result[deviceID] = -1
				continue
			}
			result[deviceID] = dangerZone
		}
		return result, nil
	}
	type row struct {
		DeviceID      string
		SafeDistanceM *float64 
	}
	var rows []row
	err := r.db.Model(&model.Mark{}).
		Where("device_id IN ?", deviceIDs).
		Select("device_id", "safe_distance_m").
		Scan(&rows).Error
	if err != nil {
		return nil, err
	}
	out := make(map[string]float64, len(rows))
	for _, v := range rows {
		val := -1.0 
		if v.SafeDistanceM != nil {
			val = *v.SafeDistanceM
		}
		out[v.DeviceID] = val
	}
	return out, nil
}
func (r *MarkRepo) MapByID(id string) (map[string]float64, error) {
	uid, err := uuid.Parse(id)
	if err != nil {
		return nil, fmt.Errorf("invalid mark id: %w", err)
	}
	var list []struct {
		OtherID   uuid.UUID
		DistanceM float64
	}
	if err := r.db.Raw(`
		SELECT mark2_id AS other_id, distance_m FROM mark_pair_safe_distance WHERE mark1_id = ?
		UNION ALL
		SELECT mark1_id AS other_id, distance_m FROM mark_pair_safe_distance WHERE mark2_id = ?
	`, uid, uid).Scan(&list).Error; err != nil {
		return nil, err
	}
	m := make(map[string]float64, len(list))
	for _, v := range list {
		m[v.OtherID.String()] = v.DistanceM
	}
	return m, nil
}
func (r *MarkRepo) GetDistanceMapByDevice(deviceID string) (map[string]float64, error) {
	if r.useAPI && r.apiClient != nil {
		return r.apiClient.GetDistanceMapByDeviceID(deviceID)
	}
	var id string
	if err := r.db.Model(&model.Mark{}).Where("device_id = ?", deviceID).Select("id").Scan(&id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return map[string]float64{}, nil
		}
		return nil, err
	}
	return r.MapByID(id)
}
func (r *MarkRepo) GetDistanceByDevice(deviceIDs []string) ([]model.MarkPairSafeDistance, error) {
	if r.useAPI && r.apiClient != nil {
		var results []model.MarkPairSafeDistance
		for _, deviceID := range deviceIDs {
			distanceMap, err := r.apiClient.GetDistanceMapByDeviceID(deviceID)
			if err != nil {
				continue
			}
			for _, distance := range distanceMap {
				pair := model.MarkPairSafeDistance{
					DistanceM: distance,
				}
				results = append(results, pair)
			}
		}
		return results, nil
	}
	var markIDs []string
	var results []model.MarkPairSafeDistance
	err := r.db.Model(&model.Mark{}).
		Where("device_id IN ?", deviceIDs).
		Pluck("id", &markIDs).Error
	if err != nil {
		return results, err
	}
	err = r.db.Model(&model.MarkPairSafeDistance{}).
		Where("mark1_id IN ? OR mark2_id IN ?", markIDs, markIDs).
		Find(&results).Error
	return results, err
}
func (c *MarkAPIClient) GetMarkByDeviceID(deviceID string) (*MarkInfo, error) {
	url := fmt.Sprintf("%s/api/v1/marks/device/%s", c.baseURL, deviceID)
	resp, err := c.client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("请求失败: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode == 404 {
		return nil, fmt.Errorf("设备 %s 对应的标记不存在", deviceID)
	}
	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("API返回错误状态码: %d", resp.StatusCode)
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("读取响应失败: %w", err)
	}
	var apiResp struct {
		Success   bool     `json:"success"`
		Data      MarkInfo `json:"data"`
		Message   string   `json:"message"`
		Timestamp string   `json:"timestamp"`
	}
	if err := json.Unmarshal(body, &apiResp); err != nil {
		return nil, fmt.Errorf("解析响应失败: %w", err)
	}
	if !apiResp.Success {
		return nil, fmt.Errorf("API返回错误: %s", apiResp.Message)
	}
	return &apiResp.Data, nil
}
func (c *MarkAPIClient) GetDangerZoneByDeviceID(deviceID string) (float64, error) {
	url := fmt.Sprintf("%s/api/v1/marks/device/%s/safe-distance", c.baseURL, deviceID)
	log.Printf("[DEBUG] 请求危险半径 API: %s", url)
	resp, err := c.client.Get(url)
	if err != nil {
		return 0, fmt.Errorf("请求失败: %w", err)
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return 0, fmt.Errorf("读取响应失败: %w", err)
	}
	log.Printf("[DEBUG] API响应状态码: %d, 响应体: %s", resp.StatusCode, string(body))
	if resp.StatusCode == 404 {
		return -1, nil 
	}
	if resp.StatusCode != 200 {
		return 0, fmt.Errorf("API返回错误状态码: %d, 响应: %s", resp.StatusCode, string(body))
	}
	var apiResp struct {
		Success   bool               `json:"success"`
		Data      DangerZoneResponse `json:"data"`
		Message   string             `json:"message"`
		Timestamp string             `json:"timestamp"`
	}
	if err := json.Unmarshal(body, &apiResp); err != nil {
		return 0, fmt.Errorf("解析响应失败: %w, 响应体: %s", err, string(body))
	}
	if !apiResp.Success {
		return 0, fmt.Errorf("API返回错误: %s", apiResp.Message)
	}
	return apiResp.Data.DangerZoneM, nil
}
func (c *MarkAPIClient) GetDistanceMapByDeviceID(deviceID string) (map[string]float64, error) {
	url := fmt.Sprintf("%s/api/v1/pairs/distance/map/device/%s", c.baseURL, deviceID)
	log.Printf("[DEBUG] 请求距离映射 API: %s", url)
	resp, err := c.client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("请求失败: %w", err)
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("读取响应失败: %w", err)
	}
	log.Printf("[DEBUG] API响应状态码: %d, 响应体: %s", resp.StatusCode, string(body))
	if resp.StatusCode == 404 {
		return map[string]float64{}, nil 
	}
	if resp.StatusCode != 200 {
		return nil, fmt.Errorf("API返回错误状态码: %d, 响应: %s", resp.StatusCode, string(body))
	}
	var apiResp struct {
		Success   bool               `json:"success"`
		Data      map[string]float64 `json:"data"`
		Message   string             `json:"message"`
		Timestamp string             `json:"timestamp"`
	}
	if err := json.Unmarshal(body, &apiResp); err != nil {
		return nil, fmt.Errorf("解析响应失败: %w, 响应体: %s", err, string(body))
	}
	if !apiResp.Success {
		return nil, fmt.Errorf("API返回错误: %s", apiResp.Message)
	}
	log.Printf("[WARN] API返回UUID映射，但需要设备ID映射。UUID映射: %+v", apiResp.Data)
	deviceMap, err := c.ConvertUUIDMapToDeviceMap(apiResp.Data, deviceID)
	if err != nil {
		log.Printf("[WARN] 转换UUID映射失败: %v", err)
		return map[string]float64{}, nil 
	}
	return deviceMap, nil
}
func (c *MarkAPIClient) UpdateLastOnlineTime(deviceID string) error {
	url := fmt.Sprintf("%s/api/v1/marks/device/%s/last-online", c.baseURL, deviceID)
	req, err := http.NewRequest("PUT", url, nil)
	if err != nil {
		return fmt.Errorf("创建请求失败: %w", err)
	}
	resp, err := c.client.Do(req)
	if err != nil {
		return fmt.Errorf("请求失败: %w", err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("API返回错误状态码: %d, 响应: %s", resp.StatusCode, string(body))
	}
	return nil
}
func (c *MarkAPIClient) GetOnlineDevices() ([]string, error) {
	log.Printf("[WARN] GetOnlineDevices API在mark-service中可能不存在，返回空列表")
	return []string{}, nil
}
func (c *MarkAPIClient) GetDeviceIDByMarkID(markID string) (string, error) {
	log.Printf("[WARN] GetDeviceIDByMarkID API在mark-service中可能不存在，markID: %s", markID)
	return "", fmt.Errorf("无法根据标记ID获取设备ID")
}
func (c *MarkAPIClient) ConvertUUIDMapToDeviceMap(uuidMap map[string]float64, sourceDeviceID string) (map[string]float64, error) {
	deviceMap := make(map[string]float64)
	for uuid, distance := range uuidMap {
		url := fmt.Sprintf("%s/api/v1/marks/%s", c.baseURL, uuid)
		resp, err := c.client.Get(url)
		if err != nil {
			log.Printf("[WARN] 获取标记信息失败 UUID=%s: %v", uuid, err)
			continue
		}
		defer resp.Body.Close()
		if resp.StatusCode != 200 {
			log.Printf("[WARN] 获取标记信息失败 UUID=%s, 状态码: %d", uuid, resp.StatusCode)
			continue
		}
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			log.Printf("[WARN] 读取标记信息响应失败 UUID=%s: %v", uuid, err)
			continue
		}
		var markResp struct {
			Success   bool     `json:"success"`
			Data      MarkInfo `json:"data"`
			Message   string   `json:"message"`
			Timestamp string   `json:"timestamp"`
		}
		if err := json.Unmarshal(body, &markResp); err != nil {
			log.Printf("[WARN] 解析标记信息失败 UUID=%s: %v", uuid, err)
			continue
		}
		if !markResp.Success {
			log.Printf("[WARN] 获取标记信息失败 UUID=%s: %s", uuid, markResp.Message)
			continue
		}
		deviceMap[markResp.Data.DeviceID] = distance
		log.Printf("[DEBUG] 转换映射: UUID=%s -> DeviceID=%s, 距离=%f", uuid, markResp.Data.DeviceID, distance)
	}
	return deviceMap, nil
}
package repo
import (
	"log"
	"sync"
	"IOT-Manage-System/warning-service/model"
)
type MemRepo struct {
	mtx sync.RWMutex
	rtk map[string]model.RTKLoc
	uwb map[string]model.UWBLoc
}
func NewMemRepo() *MemRepo {
	return &MemRepo{
		rtk: make(map[string]model.RTKLoc),
		uwb: make(map[string]model.UWBLoc),
	}
}
func (m *MemRepo) SetRTK(v *model.RTKLoc) {
	m.mtx.Lock()
	defer m.mtx.Unlock()
	m.rtk[v.ID] = *v
}
func (m *MemRepo) RTK(id string) *model.RTKLoc {
	m.mtx.RLock()
	defer m.mtx.RUnlock()
	v, ok := m.rtk[id]
	if !ok {
		return nil
	}
	return &v
}
func (m *MemRepo) RangeRTK(fn func(id string, loc *model.RTKLoc) bool) {
	m.mtx.RLock()
	defer m.mtx.RUnlock()
	for k, v := range m.rtk {
		if !fn(k, &v) {
			return
		}
	}
}
func (m *MemRepo) SetUWB(v *model.UWBLoc) {
	m.mtx.Lock()
	defer m.mtx.Unlock()
	m.uwb[v.ID] = *v
}
func (m *MemRepo) UWB(id string) *model.UWBLoc {
	m.mtx.RLock()
	defer m.mtx.RUnlock()
	v, ok := m.uwb[id]
	if !ok {
		return nil
	}
	return &v
}
func (m *MemRepo) RTKSnapshot() map[string]*model.RTKLoc {
	m.mtx.RLock()
	defer m.mtx.RUnlock()
	snap := make(map[string]*model.RTKLoc, len(m.rtk))
	for k, v := range m.rtk {
		vCopy := v 
		snap[k] = &vCopy
	}
	return snap
}
func (m *MemRepo) UWBSnapshot() map[string]*model.UWBLoc {
	m.mtx.RLock()
	defer m.mtx.RUnlock()
	snap := make(map[string]*model.UWBLoc, len(m.uwb))
	for k, v := range m.uwb {
		vCopy := v
		snap[k] = &vCopy
	}
	return snap
}
func (m *MemRepo) ClearRTK() {
	m.mtx.Lock()
	defer m.mtx.Unlock()
	m.rtk = make(map[string]model.RTKLoc)
}
func (m *MemRepo) ClearUWB() {
	m.mtx.Lock()
	defer m.mtx.Unlock()
	m.uwb = make(map[string]model.UWBLoc)
}
type SafeDist struct {
	m  map[string]float64
	mu sync.RWMutex
}
func NewSafeDist() *SafeDist { return &SafeDist{m: make(map[string]float64)} }
func (s *SafeDist) keyOf(a, b string) string {
	if a < b {
		return a + ":" + b
	}
	return b + ":" + a
}
func (s *SafeDist) Set(a, b string, d float64) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.m[s.keyOf(a, b)] = d
}
func (s *SafeDist) Get(a, b string) float64 {
	s.mu.RLock()
	defer s.mu.RUnlock()
	if v, ok := s.m[s.keyOf(a, b)]; ok {
		return v
	}
	return -1
}
func (s *SafeDist) SetBatch(list []model.MarkPairSafeDistance) {
	newMap := make(map[string]float64, len(list))
	for _, p := range list {
		k := s.keyOf(p.Mark1ID.String(), p.Mark2ID.String())
		newMap[k] = p.DistanceM
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	s.m = newMap 
}
type DangerZone struct {
	m  map[string]float64
	mu sync.RWMutex
}
func NewDangerZone() *DangerZone {
	dz := &DangerZone{m: make(map[string]float64)}
	return dz
}
func (d *DangerZone) Set(id string, r float64) {
	d.mu.Lock()
	defer d.mu.Unlock()
	d.m[id] = r
}
func (d *DangerZone) Get(id string) float64 {
	d.mu.RLock()
	defer d.mu.RUnlock()
	log.Printf("Get key=%q", id)
	if v, ok := d.m[id]; ok {
		return v
	}
	log.Printf("DangerZone.Get(%s) not found", id)
	return -1
}
func (d *DangerZone) SetBatch(m map[string]float64) {
	d.mu.Lock()
	defer d.mu.Unlock()
	for k := range d.m {
		delete(d.m, k)
	}
	for k, v := range m {
		d.m[k] = v
	}
	if len(m) == 0 {
		log.Printf("⚠️  DangerZone.SetBatch flushed to EMPTY")
	}
}
package utils
import (
	"fmt"
	"log"
	"os"
	"time"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"IOT-Manage-System/warning-service/config"
)
func InitDB() (*gorm.DB, error) {
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		config.C.PSQLConfig.Host, config.C.PSQLConfig.Port, config.C.PSQLConfig.User, config.C.PSQLConfig.Password, config.C.PSQLConfig.Name, config.C.PSQLConfig.SSLMode)
	log.Println("DSN:" + dsn)
	var db *gorm.DB
	var err error
	for i := 0; i <= config.C.PSQLConfig.MaxRetries; i++ {
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
			Logger: logger.New(
				log.New(os.Stdout, "\r\n", log.LstdFlags), 
				logger.Config{
					SlowThreshold:             200 * time.Millisecond, 
					LogLevel:                  logger.Error,            
					IgnoreRecordNotFoundError: true,                   
					Colorful:                  true,                   
				},
			),
		})
		if err == nil {
			log.Println("数据库连接成功")
			break
		}
		log.Printf("数据库连接失败（尝试 %d/%d）: %v", i+1, config.C.PSQLConfig.MaxRetries, err)
		if i == config.C.PSQLConfig.MaxRetries {
			return nil, fmt.Errorf("数据库连接失败，已尝试%d次: %w", config.C.PSQLConfig.MaxRetries, err)
		}
		time.Sleep(config.C.PSQLConfig.RetryInterval)
	}
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("获取底层 sql.DB 失败: %w", err)
	}
	sqlDB.SetMaxOpenConns(config.C.PSQLConfig.MaxOpen)
	sqlDB.SetMaxIdleConns(config.C.PSQLConfig.MaxIdle)
	sqlDB.SetConnMaxLifetime(config.C.PSQLConfig.MaxLifetime)
	return db, nil
}
func CloseDB(db *gorm.DB) error {
	if db == nil {
		return nil
	}
	sqlDB, err := db.DB()
	if err != nil {
		return fmt.Errorf("获取底层 sql.DB 失败: %w", err)
	}
	return sqlDB.Close()
}
package errs
import (
	"fmt"
)
type AppError struct {
	Code    string 
	Message string 
	Status  int    
	Details any    
}
func (e *AppError) Error() string { return e.Message }
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
var (
	ErrResourceNotFound  = &AppError{"RESOURCE_NOT_FOUND", "资源不存在", 404, nil}
	ErrResourceConflict  = &AppError{"RESOURCE_CONFLICT", "资源冲突", 409, nil}
	ErrResourceExhausted = &AppError{"RESOURCE_EXHAUSTED", "资源耗尽", 429, nil}
	ErrUploadFailed      = &AppError{"UPLOAD_FAILED", "文件上传失败", 500, nil}
	ErrFileTooLarge      = &AppError{"FILE_TOO_LARGE", "文件过大", 413, nil}
	ErrUnsupportedFormat = &AppError{"UNSUPPORTED_FORMAT", "不支持的文件格式", 415, nil}
)
var (
	ErrStatusConflict   = &AppError{"STATUS_CONFLICT", "状态冲突", 409, nil}
	ErrDuplicateAction  = &AppError{"DUPLICATE_ACTION", "重复操作", 409, nil}
	ErrQuotaExceeded    = &AppError{"QUOTA_EXCEEDED", "配额超限", 429, nil}
	ErrOperationTimeout = &AppError{"OPERATION_TIMEOUT", "操作超时", 408, nil}
	ErrInvalidToken     = &AppError{"INVALID_TOKEN", "错误Token", 401, nil}
)
var (
	ErrInternal   = &AppError{"INTERNAL_ERROR", "内部错误", 500, nil}
	ErrDatabase   = &AppError{"DATABASE_ERROR", "数据库异常", 500, nil}
	ErrCache      = &AppError{"CACHE_ERROR", "缓存异常", 500, nil}
	ErrNetwork    = &AppError{"NETWORK_ERROR", "网络异常", 503, nil}
	ErrThirdParty = &AppError{"THIRD_PARTY_ERROR", "第三方服务异常", 502, nil}
	ErrConfig     = &AppError{"CONFIG_ERROR", "配置错误", 500, nil}
)
var (
	ErrValidationFailed = &AppError{"VALIDATION_FAILED", "数据校验失败", 400, nil}
	ErrCaptchaFailed    = &AppError{"CAPTCHA_FAILED", "验证码错误", 400, nil}
	ErrTooManyRequests  = &AppError{"TOO_MANY_REQUESTS", "请求过于频繁", 429, nil}
)
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
func (e *AppError) WithDetails(details any) *AppError {
	return &AppError{
		Code:    e.Code,
		Message: e.Message,
		Status:  e.Status,
		Details: details,
	}
}
package utils
import (
	"os"
	"strconv"
	"strings"
)
func GetEnv(key, defaultValue string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultValue
}
func GetEnvInt(key string, defaultValue int) int {
	val := os.Getenv(key)
	if val == "" {
		return defaultValue
	}
	i, err := strconv.Atoi(val)
	if err != nil {
		return defaultValue
	}
	return i
}
func ParsePositiveInt(s string) (int, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0, nil
	}
	v, err := strconv.Atoi(s)
	if err != nil || v <= 0 {
		return 0, nil
	}
	return v, err
}
func ParsePositiveInt64(s string) (int64, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0, nil
	}
	v, err := strconv.ParseInt(s, 10, 64)
	if err != nil || v <= 0 {
		return 0, nil
	}
	return v, err
}
package utils
import (
	"log"
	"math"
	"IOT-Manage-System/warning-service/model"
)
const earthRadius float64 = 6371393
func toRadians(degree float64) float64 {
	return degree * math.Pi / 180.0
}
func CalculateRTK(l1, l2 model.RTKLoc) float64 {
	dLat := toRadians(l1.Lat - l2.Lat)
	dLon := toRadians(l1.Lon - l2.Lon)
	a := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Cos(toRadians(l1.Lat))*math.Cos(toRadians(l2.Lat))*
			math.Sin(dLon/2)*math.Sin(dLon/2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))
	return earthRadius * c
}
func CalculateUWB(l1, l2 model.UWBLoc) float64 {
	dx := (l1.X - l2.X) / 100.0
	dy := (l1.Y - l2.Y) / 100.0
	distance := math.Sqrt(dx*dx + dy*dy)
	log.Printf("UWB distance: %f", distance)
	return distance
}
package main
import (
	"log"
	"github.com/goccy/go-json"
	"github.com/gofiber/fiber/v2"
	"IOT-Manage-System/map-service/config"
	"IOT-Manage-System/map-service/handler"
	"IOT-Manage-System/map-service/repo"
	"IOT-Manage-System/map-service/service"
	"IOT-Manage-System/map-service/utils"
)
func main() {
	app := fiber.New(fiber.Config{
		Prefork:            false,
		StrictRouting:      false,
		AppName:            "地图数据服务 v0.1.0",
		CaseSensitive:      true,
		DisableDefaultDate: true,
		JSONEncoder:        json.Marshal,
		JSONDecoder:        json.Unmarshal,
		ErrorHandler:       handler.CustomErrorHandler,
	})
	config.Load()
	db, err := utils.InitDB()
	if err != nil {
		log.Fatalf("初始化数据库失败: %v", err)
	}
	defer func() {
		if err := utils.CloseDB(db); err != nil {
			log.Printf("关闭数据库失败: %v", err)
		} else {
			log.Println("数据库已正常关闭")
		}
	}()
	stationRepo := repo.NewStationRepo(db)
	stationService := service.NewStationService(stationRepo)
	stationHandler := handler.NewStationHandler(stationService)
	customMapRepo := repo.NewCustomMapRepo(db)
	customMapService := service.NewCustomMapService(customMapRepo)
	customMapHandler := handler.NewCustomMapHandler(customMapService)
	polygonFenceRepo := repo.NewPolygonFenceRepo(db)
	polygonFenceService := service.NewPolygonFenceService(polygonFenceRepo)
	polygonFenceHandler := handler.NewPolygonFenceHandler(polygonFenceService)
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok", "service": app.Config().AppName})
	})
	app.Static("/uploads", "./uploads")
	api := app.Group("/api")
	v1 := api.Group("/v1")
	station := v1.Group("/station")
	{
		station.Post("/", stationHandler.CreateStation)      
		station.Get("/", stationHandler.ListStation)         
		station.Get("/:id", stationHandler.GetStation)       
		station.Put("/:id", stationHandler.UpdateStation)    
		station.Delete("/:id", stationHandler.DeleteStation) 
	}
	customMap := v1.Group("/custom-map")
	{
		customMap.Get("/latest", customMapHandler.GetLatestCustomMap) 
		customMap.Post("/", customMapHandler.CreateCustomMap)      
		customMap.Get("/", customMapHandler.ListCustomMaps)        
		customMap.Get("/:id", customMapHandler.GetCustomMap)       
		customMap.Put("/:id", customMapHandler.UpdateCustomMap)    
		customMap.Delete("/:id", customMapHandler.DeleteCustomMap) 
	}
	polygonFence := v1.Group("/polygon-fence")
	{
		polygonFence.Post("/check-all", polygonFenceHandler.CheckPointInAllFences) 
		polygonFence.Post("/check-indoor-all", polygonFenceHandler.CheckPointInIndoorFences) 
		polygonFence.Post("/check-indoor-any", polygonFenceHandler.IsPointInAnyIndoorFence)  
		polygonFence.Post("/check-outdoor-all", polygonFenceHandler.CheckPointInOutdoorFences) 
		polygonFence.Post("/check-outdoor-any", polygonFenceHandler.IsPointInAnyOutdoorFence)  
		polygonFence.Get("/indoor", polygonFenceHandler.ListIndoorFences)   
		polygonFence.Get("/outdoor", polygonFenceHandler.ListOutdoorFences) 
		polygonFence.Post("/", polygonFenceHandler.CreatePolygonFence)      
		polygonFence.Get("/", polygonFenceHandler.ListPolygonFences)        
		polygonFence.Get("/:id", polygonFenceHandler.GetPolygonFence)       
		polygonFence.Put("/:id", polygonFenceHandler.UpdatePolygonFence)    
		polygonFence.Delete("/:id", polygonFenceHandler.DeletePolygonFence) 
		polygonFence.Post("/:id/check", polygonFenceHandler.CheckPointInFence)                
		polygonFence.Post("/:id/check-indoor", polygonFenceHandler.CheckPointInIndoorFence)   
		polygonFence.Post("/:id/check-outdoor", polygonFenceHandler.CheckPointInOutdoorFence) 
	}
	port := utils.GetEnv("PORT", "8002")
	if err := app.Listen(":" + port); err != nil {
		log.Fatalf("启动 HTTP 服务失败: %v", err)
	}
}
package errs
import (
	"fmt"
)
type AppError struct {
	Code    string 
	Message string 
	Details any    
}
func (e *AppError) Error() string { return e.Message }
var (
	ErrInvalidInput  = &AppError{"INVALID_INPUT", "参数错误", nil}
	ErrUserExists    = &AppError{"USER_EXISTS", "用户已存在", nil}
	ErrUserNotFound  = &AppError{"USER_NOT_FOUND", "用户不存在", nil}
	ErrWrongPassword = &AppError{"WRONG_PASSWORD", "密码错误", nil}
	ErrTokenExpired  = &AppError{"TOKEN_EXPIRED", "令牌已过期", nil}
	ErrTokenInvalid  = &AppError{"TOKEN_INVALID", "令牌无效", nil}
	ErrUnauthorized  = &AppError{"UNAUTHORIZED", "未授权访问", nil}
	ErrForbidden     = &AppError{"FORBIDDEN", "权限不足", nil}
)
var (
	ErrResourceNotFound  = &AppError{"RESOURCE_NOT_FOUND", "资源不存在", nil}
	ErrResourceConflict  = &AppError{"RESOURCE_CONFLICT", "资源冲突", nil}
	ErrResourceExhausted = &AppError{"RESOURCE_EXHAUSTED", "资源耗尽", nil}
	ErrUploadFailed      = &AppError{"UPLOAD_FAILED", "文件上传失败", nil}
	ErrFileTooLarge      = &AppError{"FILE_TOO_LARGE", "文件过大", nil}
	ErrUnsupportedFormat = &AppError{"UNSUPPORTED_FORMAT", "不支持的文件格式", nil}
)
var (
	ErrStatusConflict   = &AppError{"STATUS_CONFLICT", "状态冲突", nil}
	ErrDuplicateAction  = &AppError{"DUPLICATE_ACTION", "重复操作", nil}
	ErrQuotaExceeded    = &AppError{"QUOTA_EXCEEDED", "配额超限", nil}
	ErrOperationTimeout = &AppError{"OPERATION_TIMEOUT", "操作超时", nil}
	ErrInvalidToken     = &AppError{"INVALID_TOKEN", "错误Token", nil}
)
var (
	ErrInternal   = &AppError{"INTERNAL_ERROR", "内部错误", nil}
	ErrDatabase   = &AppError{"DATABASE_ERROR", "数据库异常", nil}
	ErrCache      = &AppError{"CACHE_ERROR", "缓存异常", nil}
	ErrNetwork    = &AppError{"NETWORK_ERROR", "网络异常", nil}
	ErrThirdParty = &AppError{"THIRD_PARTY_ERROR", "第三方服务异常", nil}
	ErrConfig     = &AppError{"CONFIG_ERROR", "配置错误", nil}
)
var (
	ErrValidationFailed = &AppError{"VALIDATION_FAILED", "数据校验失败", nil}
	ErrCaptchaFailed    = &AppError{"CAPTCHA_FAILED", "验证码错误", nil}
	ErrTooManyRequests  = &AppError{"TOO_MANY_REQUESTS", "请求过于频繁", nil}
	ErrInvalidID        = &AppError{"INVALID_ID", "无效的ID", nil}
	ErrDuplicateEntry   = &AppError{"DUPLICATE_ENTRY", "数据重复", nil}
)
func AlreadyExists(resource, msg string, details ...any) *AppError {
	detail := any(nil)
	if len(details) > 0 {
		detail = details[0]
	}
	return &AppError{
		Code:    fmt.Sprintf("%s_EXISTS", resource),
		Message: msg,
		Details: detail,
	}
}
func NotFound(resource, msg string, details ...any) *AppError {
	detail := any(nil)
	if len(details) > 0 {
		detail = details[0]
	}
	return &AppError{
		Code:    fmt.Sprintf("%s_NOT_FOUND", resource),
		Message: msg,
		Details: detail,
	}
}
func (e *AppError) WithDetails(details any) *AppError {
	return &AppError{
		Code:    e.Code,
		Message: e.Message,
		Details: details,
	}
}
package model
import (
	"time"
	"github.com/google/uuid"
)
type Station struct {
	ID          uuid.UUID `gorm:"column:id;type:uuid;primaryKey;default:gen_random_uuid()"`
	StationName string    `gorm:"column:station_name;type:varchar(255);not null"`
	CoordinateX float64   `gorm:"column:location_x;type:double precision;not null"` 
	CoordinateY float64   `gorm:"column:location_y;type:double precision;not null"` 
	CreatedAt   time.Time `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt   time.Time `gorm:"column:updated_at;not null;autoUpdateTime"`
}
func (Station) TableName() string {
	return "base_stations"
}
type StationCreateReq struct {
	StationName string  `json:"station_name" validate:"required,min=1,max=255"`
	CoordinateX float64 `json:"coordinate_x"` 
	CoordinateY float64 `json:"coordinate_y"` 
}
type StationUpdateReq struct {
	StationName *string  `json:"station_name,omitempty" validate:"omitempty,min=1,max=255"`
	CoordinateX *float64 `json:"coordinate_x,omitempty" validate:"omitempty"` 
	CoordinateY *float64 `json:"coordinate_y,omitempty" validate:"omitempty"` 
}
type StationResp struct {
	ID          string    `json:"id"`
	StationName string    `json:"station_name"`
	CoordinateX float64   `json:"coordinate_x"` 
	CoordinateY float64   `json:"coordinate_y"` 
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}
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
func StationCreateReqToStation(req *StationCreateReq) *Station {
	return &Station{
		StationName: req.StationName,
		CoordinateX: req.CoordinateX,
		CoordinateY: req.CoordinateY,
	}
}
type CustomMap struct {
	ID          uuid.UUID `gorm:"column:id;type:uuid;primaryKey;default:gen_random_uuid()"`
	MapName     string    `gorm:"column:map_name;type:varchar(255);not null"`
	ImagePath   string    `gorm:"column:image_path;type:varchar(500)"` 
	XMin        float64   `gorm:"column:x_min;type:double precision;not null"`
	XMax        float64   `gorm:"column:x_max;type:double precision;not null"`
	YMin        float64   `gorm:"column:y_min;type:double precision;not null"`
	YMax        float64   `gorm:"column:y_max;type:double precision;not null"`
	CenterX     float64   `gorm:"column:center_x;type:double precision;not null"`
	CenterY     float64   `gorm:"column:center_y;type:double precision;not null"`
	ScaleRatio  float64   `gorm:"column:scale_ratio;type:double precision;not null;default:1.0"` 
	Description string    `gorm:"column:description;type:text"`
	CreatedAt   time.Time `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt   time.Time `gorm:"column:updated_at;not null;autoUpdateTime"`
}
func (CustomMap) TableName() string {
	return "custom_maps"
}
type CustomMapCreateReq struct {
	MapName     string  `json:"map_name" validate:"required,min=1,max=255"`
	ImageBase64 string  `json:"image_base64,omitempty"`                                                    
	ImageExt    string  `json:"image_ext,omitempty" validate:"omitempty,oneof=.jpg .jpeg .png .gif .webp"` 
	XMin        float64 `json:"x_min"`                                                                     
	XMax        float64 `json:"x_max"`                                                                     
	YMin        float64 `json:"y_min"`                                                                     
	YMax        float64 `json:"y_max"`                                                                     
	CenterX     float64 `json:"center_x"`                                                                  
	CenterY     float64 `json:"center_y"`                                                                  
	ScaleRatio  float64 `json:"scale_ratio" validate:"omitempty,gt=0"`                                     
	Description string  `json:"description,omitempty" validate:"omitempty,max=1000"`
}
type CustomMapUpdateReq struct {
	MapName     *string  `json:"map_name,omitempty" validate:"omitempty,min=1,max=255"`
	ImageBase64 *string  `json:"image_base64,omitempty"`                                                    
	ImageExt    *string  `json:"image_ext,omitempty" validate:"omitempty,oneof=.jpg .jpeg .png .gif .webp"` 
	XMin        *float64 `json:"x_min,omitempty" validate:"omitempty"`
	XMax        *float64 `json:"x_max,omitempty" validate:"omitempty"`
	YMin        *float64 `json:"y_min,omitempty" validate:"omitempty"`
	YMax        *float64 `json:"y_max,omitempty" validate:"omitempty"`
	CenterX     *float64 `json:"center_x,omitempty" validate:"omitempty"`
	CenterY     *float64 `json:"center_y,omitempty" validate:"omitempty"`
	ScaleRatio  *float64 `json:"scale_ratio,omitempty" validate:"omitempty,gt=0"` 
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
	ScaleRatio  float64   `json:"scale_ratio"` 
	Description string    `json:"description"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}
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
type PolygonFence struct {
	ID          uuid.UUID `gorm:"column:id;type:uuid;primaryKey;default:gen_random_uuid()"`
	IsIndoor    bool      `gorm:"column:is_indoor;not null;default:true"` 
	FenceName   string    `gorm:"column:fence_name;type:varchar(255);not null;uniqueIndex"`
	Geometry    string    `gorm:"column:geometry;type:geometry(POLYGON,0);not null"` 
	Description string    `gorm:"column:description;type:text"`
	IsActive    bool      `gorm:"column:is_active;default:true"`
	CreatedAt   time.Time `gorm:"column:created_at;not null;autoCreateTime"`
	UpdatedAt   time.Time `gorm:"column:updated_at;not null;autoUpdateTime"`
}
func (PolygonFence) TableName() string {
	return "polygon_fences"
}
type Point struct {
	X float64 `json:"x"` 
	Y float64 `json:"y"` 
}
type PolygonFenceCreateReq struct {
	IsIndoor    bool    `json:"is_indoor"` 
	FenceName   string  `json:"fence_name" validate:"required,min=1,max=255"`
	Points      []Point `json:"points" validate:"required,min=3"` 
	Description string  `json:"description,omitempty" validate:"omitempty,max=1000"`
}
type PolygonFenceUpdateReq struct {
	IsIndoor    *bool    `json:"is_indoor,omitempty"` 
	FenceName   *string  `json:"fence_name,omitempty" validate:"omitempty,min=1,max=255"`
	Points      *[]Point `json:"points,omitempty" validate:"omitempty,min=3"`
	Description *string  `json:"description,omitempty" validate:"omitempty,max=1000"`
	IsActive    *bool    `json:"is_active,omitempty"`
}
type PolygonFenceResp struct {
	ID          string    `json:"id"`
	IsIndoor    bool      `json:"is_indoor"` 
	FenceName   string    `json:"fence_name"`
	Points      []Point   `json:"points"` 
	Description string    `json:"description"`
	IsActive    bool      `json:"is_active"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}
type PointCheckReq struct {
	X float64 `json:"x"` 
	Y float64 `json:"y"` 
}
type PointCheckResp struct {
	IsInside   bool     `json:"is_inside"`
	FenceID    string   `json:"fence_id,omitempty"`
	FenceName  string   `json:"fence_name,omitempty"`
	FenceNames []string `json:"fence_names,omitempty"` 
}
package service
import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"gorm.io/gorm"
	"IOT-Manage-System/map-service/errs"
	"IOT-Manage-System/map-service/model"
	"IOT-Manage-System/map-service/repo"
)
type CustomMapService struct {
	customMapRepo *repo.CustomMapRepo
}
func NewCustomMapService(repo *repo.CustomMapRepo) *CustomMapService {
	return &CustomMapService{customMapRepo: repo}
}
func (s *CustomMapService) CreateCustomMap(req *model.CustomMapCreateReq, imagePath string) error {
	if err := s.validateCustomMapData(req); err != nil {
		return err
	}
	scaleRatio := req.ScaleRatio
	if scaleRatio == 0 {
		scaleRatio = 1.0
	}
	customMap := &model.CustomMap{
		MapName:     req.MapName,
		ImagePath:   imagePath,
		XMin:        req.XMin,
		XMax:        req.XMax,
		YMin:        req.YMin,
		YMax:        req.YMax,
		CenterX:     req.CenterX,
		CenterY:     req.CenterY,
		ScaleRatio:  scaleRatio,
		Description: req.Description,
	}
	if err := s.customMapRepo.Create(customMap); err != nil {
		return s.translateRepoErr(err, "CustomMap")
	}
	return nil
}
func (s *CustomMapService) GetCustomMap(id string, baseURL string) (*model.CustomMapResp, error) {
	uid, err := parseUUID(id)
	if err != nil {
		return nil, err
	}
	customMap, err := s.customMapRepo.GetByID(uid)
	if err != nil {
		return nil, s.translateRepoErr(err, "CustomMap")
	}
	return model.CustomMapToCustomMapResp(customMap, baseURL), nil
}
func (s *CustomMapService) GetAllCustomMaps(baseURL string) ([]model.CustomMapResp, error) {
	list, err := s.customMapRepo.ListAll()
	if err != nil {
		return nil, s.translateRepoErr(err, "CustomMap")
	}
	if len(list) == 0 {
		return []model.CustomMapResp{}, nil
	}
	resp := make([]model.CustomMapResp, 0, len(list))
	for i := range list {
		resp = append(resp, *model.CustomMapToCustomMapResp(&list[i], baseURL))
	}
	return resp, nil
}
func (s *CustomMapService) GetLatestCustomMap(baseURL string) (*model.CustomMapResp, error) {
	customMap, err := s.customMapRepo.GetLatest()
	if err != nil {
		return nil, s.translateRepoErr(err, "CustomMap")
	}
	return model.CustomMapToCustomMapResp(customMap, baseURL), nil
}
func (s *CustomMapService) UpdateCustomMap(id string, req *model.CustomMapUpdateReq, newImagePath *string) error {
	uid, err := parseUUID(id)
	if err != nil {
		return err
	}
	data, err := s.customMapRepo.GetByID(uid)
	if err != nil {
		return s.translateRepoErr(err, "CustomMap")
	}
	oldImagePath := data.ImagePath
	mapName := data.MapName
	xMin := data.XMin
	xMax := data.XMax
	yMin := data.YMin
	yMax := data.YMax
	centerX := data.CenterX
	centerY := data.CenterY
	scaleRatio := data.ScaleRatio
	description := data.Description
	if req.MapName != nil {
		mapName = *req.MapName
	}
	if req.XMin != nil {
		xMin = *req.XMin
	}
	if req.XMax != nil {
		xMax = *req.XMax
	}
	if req.YMin != nil {
		yMin = *req.YMin
	}
	if req.YMax != nil {
		yMax = *req.YMax
	}
	if req.CenterX != nil {
		centerX = *req.CenterX
	}
	if req.CenterY != nil {
		centerY = *req.CenterY
	}
	if req.ScaleRatio != nil {
		scaleRatio = *req.ScaleRatio
	}
	if req.Description != nil {
		description = *req.Description
	}
	validateReq := &model.CustomMapCreateReq{
		MapName:     mapName,
		XMin:        xMin,
		XMax:        xMax,
		YMin:        yMin,
		YMax:        yMax,
		CenterX:     centerX,
		CenterY:     centerY,
		ScaleRatio:  scaleRatio,
		Description: description,
	}
	if err := s.validateCustomMapData(validateReq); err != nil {
		return err
	}
	data.MapName = mapName
	data.XMin = xMin
	data.XMax = xMax
	data.YMin = yMin
	data.YMax = yMax
	data.CenterX = centerX
	data.CenterY = centerY
	data.ScaleRatio = scaleRatio
	data.Description = description
	if newImagePath != nil {
		data.ImagePath = *newImagePath
	}
	if err := s.customMapRepo.UpdateByID(uid, data); err != nil {
		return s.translateRepoErr(err, "CustomMap")
	}
	if newImagePath != nil && *newImagePath != oldImagePath {
		_ = os.Remove(filepath.Join(".", oldImagePath))
	}
	return nil
}
func (s *CustomMapService) DeleteCustomMap(id string) error {
	uid, err := parseUUID(id)
	if err != nil {
		return err
	}
	customMap, err := s.customMapRepo.GetByID(uid)
	if err != nil {
		return s.translateRepoErr(err, "CustomMap")
	}
	if err := s.customMapRepo.DeleteByID(uid); err != nil {
		return s.translateRepoErr(err, "CustomMap")
	}
	if customMap.ImagePath != "" {
		_ = os.Remove(filepath.Join(".", customMap.ImagePath))
	}
	return nil
}
func (s *CustomMapService) translateRepoErr(err error, resource string) error {
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return errs.NotFound(resource, fmt.Sprintf("%s 不存在", resource))
	}
	return errs.ErrInternal.WithDetails(err.Error())
}
func (s *CustomMapService) validateCustomMapData(req *model.CustomMapCreateReq) error {
	if len(req.MapName) == 0 {
		return errs.ErrValidationFailed.WithDetails("地图名称不能为空")
	}
	if len(req.MapName) > 255 {
		return errs.ErrValidationFailed.WithDetails("地图名称长度不能超过255个字符")
	}
	if req.XMin >= req.XMax {
		return errs.ErrValidationFailed.WithDetails("X坐标最小值必须小于最大值")
	}
	if req.YMin >= req.YMax {
		return errs.ErrValidationFailed.WithDetails("Y坐标最小值必须小于最大值")
	}
	if req.CenterX < req.XMin || req.CenterX > req.XMax {
		return errs.ErrValidationFailed.WithDetails("地图中心点X坐标必须在X坐标范围内")
	}
	if req.CenterY < req.YMin || req.CenterY > req.YMax {
		return errs.ErrValidationFailed.WithDetails("地图中心点Y坐标必须在Y坐标范围内")
	}
	if len(req.Description) > 1000 {
		return errs.ErrValidationFailed.WithDetails("地图描述长度不能超过1000个字符")
	}
	return nil
}
package repo
import (
	"IOT-Manage-System/map-service/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type StationRepo struct {
	db *gorm.DB
}
func NewStationRepo(db *gorm.DB) *StationRepo {
	return &StationRepo{db: db}
}
func (r *StationRepo) Create(station *model.Station) error {
	return r.db.Create(station).Error
}
func (r *StationRepo) CreateInBatches(stations []model.Station, batchSize int) error {
	return r.db.CreateInBatches(stations, batchSize).Error
}
func (r *StationRepo) GetByID(id uuid.UUID) (*model.Station, error) {
	var s model.Station
	err := r.db.First(&s, "id = ?", id).Error
	return &s, err
}
func (r *StationRepo) GetByName(name string) (*model.Station, error) {
	var s model.Station
	err := r.db.First(&s, "station_name = ?", name).Error
	return &s, err
}
func (r *StationRepo) ListAll() ([]model.Station, error) {
	var list []model.Station
	err := r.db.Find(&list).Error
	return list, err
}
func (r *StationRepo) UpdateByID(id uuid.UUID, station *model.Station) error {
	return r.db.Model(&model.Station{}).Where("id = ?", id).Updates(station).Error
}
func (r *StationRepo) UpdateByIDWithMap(id uuid.UUID, updates map[string]interface{}) error {
	return r.db.Model(&model.Station{}).Where("id = ?", id).Updates(updates).Error
}
func (r *StationRepo) UpdateName(id uuid.UUID, newName string) error {
	return r.db.Model(&model.Station{}).Where("id = ?", id).Update("station_name", newName).Error
}
func (r *StationRepo) DeleteByID(id uuid.UUID) error {
	return r.db.Delete(&model.Station{}, "id = ?", id).Error
}
func (r *StationRepo) DeleteInBatches(ids []uuid.UUID) error {
	return r.db.Delete(&model.Station{}, "id IN ?", ids).Error
}
package repo
import (
	"IOT-Manage-System/map-service/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type PolygonFenceRepo struct {
	db *gorm.DB
}
func NewPolygonFenceRepo(db *gorm.DB) *PolygonFenceRepo {
	return &PolygonFenceRepo{db: db}
}
func (r *PolygonFenceRepo) Create(fence *model.PolygonFence) error {
	return r.db.Exec(`
		INSERT INTO polygon_fences (is_indoor, fence_name, geometry, description, is_active)
		VALUES (?, ?, ST_GeomFromText(?), ?, ?)
	`, fence.IsIndoor, fence.FenceName, fence.Geometry, fence.Description, fence.IsActive).Error
}
func (r *PolygonFenceRepo) GetByID(id uuid.UUID) (*model.PolygonFence, error) {
	var fence model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry, 
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE id = ?
	`, id).Scan(&fence).Error
	if err != nil {
		return nil, err
	}
	return &fence, nil
}
func (r *PolygonFenceRepo) GetByName(name string) (*model.PolygonFence, error) {
	var fence model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry, 
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE fence_name = ?
	`, name).Scan(&fence).Error
	if err != nil {
		return nil, err
	}
	return &fence, nil
}
func (r *PolygonFenceRepo) ListAll() ([]model.PolygonFence, error) {
	var fences []model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry, 
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		ORDER BY created_at DESC
	`).Scan(&fences).Error
	return fences, err
}
func (r *PolygonFenceRepo) ListActive() ([]model.PolygonFence, error) {
	var fences []model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry, 
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE is_active = true
		ORDER BY created_at DESC
	`).Scan(&fences).Error
	return fences, err
}
func (r *PolygonFenceRepo) ListIndoor() ([]model.PolygonFence, error) {
	var fences []model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry,
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE is_indoor = true
		ORDER BY created_at DESC
	`).Scan(&fences).Error
	return fences, err
}
func (r *PolygonFenceRepo) ListOutdoor() ([]model.PolygonFence, error) {
	var fences []model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry,
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE is_indoor = false
		ORDER BY created_at DESC
	`).Scan(&fences).Error
	return fences, err
}
func (r *PolygonFenceRepo) ListActiveIndoor() ([]model.PolygonFence, error) {
	var fences []model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry,
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE is_active = true AND is_indoor = true
		ORDER BY created_at DESC
	`).Scan(&fences).Error
	return fences, err
}
func (r *PolygonFenceRepo) ListActiveOutdoor() ([]model.PolygonFence, error) {
	var fences []model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry,
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE is_active = true AND is_indoor = false
		ORDER BY created_at DESC
	`).Scan(&fences).Error
	return fences, err
}
func (r *PolygonFenceRepo) UpdateByID(id uuid.UUID, fence *model.PolygonFence) error {
	return r.db.Exec(`
		UPDATE polygon_fences
		SET is_indoor = ?,
		    fence_name = ?, 
		    geometry = ST_GeomFromText(?), 
		    description = ?, 
		    is_active = ?,
		    updated_at = CURRENT_TIMESTAMP
		WHERE id = ?
	`, fence.IsIndoor, fence.FenceName, fence.Geometry, fence.Description, fence.IsActive, id).Error
}
func (r *PolygonFenceRepo) DeleteByID(id uuid.UUID) error {
	return r.db.Exec("DELETE FROM polygon_fences WHERE id = ?", id).Error
}
func (r *PolygonFenceRepo) IsPointInFence(fenceID uuid.UUID, x, y float64) (bool, error) {
	var isInside bool
	err := r.db.Raw(`
		SELECT ST_Contains(geometry, ST_Point(?, ?))
		FROM polygon_fences
		WHERE id = ? AND is_active = true
	`, x, y, fenceID).Scan(&isInside).Error
	return isInside, err
}
func (r *PolygonFenceRepo) FindFencesByPoint(x, y float64) ([]model.PolygonFence, error) {
	var fences []model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry, 
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE is_active = true
		AND ST_Contains(geometry, ST_Point(?, ?))
		ORDER BY created_at DESC
	`, x, y).Scan(&fences).Error
	return fences, err
}
func (r *PolygonFenceRepo) IsPointInAnyFence(x, y float64) (bool, error) {
	var count int64
	err := r.db.Raw(`
		SELECT COUNT(*)
		FROM polygon_fences
		WHERE is_active = true
		AND ST_Contains(geometry, ST_Point(?, ?))
	`, x, y).Scan(&count).Error
	if err != nil {
		return false, err
	}
	return count > 0, nil
}
func (r *PolygonFenceRepo) IsPointInIndoorFence(fenceID uuid.UUID, x, y float64) (bool, error) {
	var isInside bool
	err := r.db.Raw(`
		SELECT ST_Contains(geometry, ST_Point(?, ?))
		FROM polygon_fences
		WHERE id = ? AND is_active = true AND is_indoor = true
	`, x, y, fenceID).Scan(&isInside).Error
	return isInside, err
}
func (r *PolygonFenceRepo) IsPointInOutdoorFence(fenceID uuid.UUID, x, y float64) (bool, error) {
	var isInside bool
	err := r.db.Raw(`
		SELECT ST_Contains(geometry, ST_Point(?, ?))
		FROM polygon_fences
		WHERE id = ? AND is_active = true AND is_indoor = false
	`, x, y, fenceID).Scan(&isInside).Error
	return isInside, err
}
func (r *PolygonFenceRepo) FindIndoorFencesByPoint(x, y float64) ([]model.PolygonFence, error) {
	var fences []model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry, 
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE is_active = true AND is_indoor = true
		AND ST_Contains(geometry, ST_Point(?, ?))
		ORDER BY created_at DESC
	`, x, y).Scan(&fences).Error
	return fences, err
}
func (r *PolygonFenceRepo) FindOutdoorFencesByPoint(x, y float64) ([]model.PolygonFence, error) {
	var fences []model.PolygonFence
	err := r.db.Raw(`
		SELECT id, is_indoor, fence_name, ST_AsText(geometry) as geometry, 
		       description, is_active, created_at, updated_at
		FROM polygon_fences
		WHERE is_active = true AND is_indoor = false
		AND ST_Contains(geometry, ST_Point(?, ?))
		ORDER BY created_at DESC
	`, x, y).Scan(&fences).Error
	return fences, err
}
func (r *PolygonFenceRepo) IsPointInAnyIndoorFence(x, y float64) (bool, error) {
	var count int64
	err := r.db.Raw(`
		SELECT COUNT(*)
		FROM polygon_fences
		WHERE is_active = true AND is_indoor = true
		AND ST_Contains(geometry, ST_Point(?, ?))
	`, x, y).Scan(&count).Error
	if err != nil {
		return false, err
	}
	return count > 0, nil
}
func (r *PolygonFenceRepo) IsPointInAnyOutdoorFence(x, y float64) (bool, error) {
	var count int64
	err := r.db.Raw(`
		SELECT COUNT(*)
		FROM polygon_fences
		WHERE is_active = true AND is_indoor = false
		AND ST_Contains(geometry, ST_Point(?, ?))
	`, x, y).Scan(&count).Error
	if err != nil {
		return false, err
	}
	return count > 0, nil
}
func (r *PolygonFenceRepo) GetBoundingBox(id uuid.UUID) (xMin, yMin, xMax, yMax float64, err error) {
	err = r.db.Raw(`
		SELECT 
			ST_XMin(geometry) as x_min,
			ST_YMin(geometry) as y_min,
			ST_XMax(geometry) as x_max,
			ST_YMax(geometry) as y_max
		FROM polygon_fences
		WHERE id = ?
	`, id).Row().Scan(&xMin, &yMin, &xMax, &yMax)
	return
}
package repo
import (
	"IOT-Manage-System/map-service/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type CustomMapRepo struct {
	db *gorm.DB
}
func NewCustomMapRepo(db *gorm.DB) *CustomMapRepo {
	return &CustomMapRepo{db: db}
}
func (r *CustomMapRepo) Create(customMap *model.CustomMap) error {
	return r.db.Create(customMap).Error
}
func (r *CustomMapRepo) GetByID(id uuid.UUID) (*model.CustomMap, error) {
	var cm model.CustomMap
	err := r.db.First(&cm, "id = ?", id).Error
	return &cm, err
}
func (r *CustomMapRepo) GetByName(name string) (*model.CustomMap, error) {
	var cm model.CustomMap
	err := r.db.First(&cm, "map_name = ?", name).Error
	return &cm, err
}
func (r *CustomMapRepo) ListAll() ([]model.CustomMap, error) {
	var list []model.CustomMap
	err := r.db.Order("created_at DESC").Find(&list).Error
	return list, err
}
func (r *CustomMapRepo) GetLatest() (*model.CustomMap, error) {
	var cm model.CustomMap
	err := r.db.Order("created_at DESC").First(&cm).Error
	return &cm, err
}
func (r *CustomMapRepo) UpdateByID(id uuid.UUID, customMap *model.CustomMap) error {
	return r.db.Model(&model.CustomMap{}).Where("id = ?", id).Updates(customMap).Error
}
func (r *CustomMapRepo) DeleteByID(id uuid.UUID) error {
	return r.db.Delete(&model.CustomMap{}, "id = ?", id).Error
}
package handler
import (
	"encoding/base64"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"IOT-Manage-System/map-service/model"
	"IOT-Manage-System/map-service/service"
	"IOT-Manage-System/map-service/utils"
)
type CustomMapHandler struct {
	customMapService *service.CustomMapService
}
func NewCustomMapHandler(svc *service.CustomMapService) *CustomMapHandler {
	return &CustomMapHandler{customMapService: svc}
}
func (h *CustomMapHandler) CreateCustomMap(c *fiber.Ctx) error {
	req := new(model.CustomMapCreateReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "参数解析失败")
	}
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}
	var imagePath string
	if req.ImageBase64 != "" {
		if req.ImageExt == "" {
			return utils.SendErrorResponse(c, fiber.StatusBadRequest, "提供图片时必须指定图片扩展名")
		}
		imageData, err := base64.StdEncoding.DecodeString(req.ImageBase64)
		if err != nil {
			return utils.SendErrorResponse(c, fiber.StatusBadRequest, "图片数据解码失败")
		}
		maxSize := int64(10 * 1024 * 1024)
		if int64(len(imageData)) > maxSize {
			return utils.SendErrorResponse(c, fiber.StatusBadRequest, "图片大小不能超过10MB")
		}
		imagePath, err = saveBase64Image(imageData, req.ImageExt)
		if err != nil {
			return utils.SendErrorResponse(c, fiber.StatusInternalServerError, "保存图片失败")
		}
	}
	if err := h.customMapService.CreateCustomMap(req, imagePath); err != nil {
		if imagePath != "" {
			_ = os.Remove(filepath.Join(".", imagePath))
		}
		return err
	}
	return utils.SendCreatedResponse(c, nil, "自制地图创建成功")
}
func (h *CustomMapHandler) GetCustomMap(c *fiber.Ctx) error {
	id := c.Params("id")
	baseURL := getBaseURL(c)
	resp, err := h.customMapService.GetCustomMap(id, baseURL)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}
func (h *CustomMapHandler) ListCustomMaps(c *fiber.Ctx) error {
	baseURL := getBaseURL(c)
	list, err := h.customMapService.GetAllCustomMaps(baseURL)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, list)
}
func (h *CustomMapHandler) GetLatestCustomMap(c *fiber.Ctx) error {
	baseURL := getBaseURL(c)
	resp, err := h.customMapService.GetLatestCustomMap(baseURL)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}
func (h *CustomMapHandler) UpdateCustomMap(c *fiber.Ctx) error {
	id := c.Params("id")
	req := new(model.CustomMapUpdateReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "参数解析失败")
	}
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}
	var newImagePath *string
	if req.ImageBase64 != nil && *req.ImageBase64 != "" {
		if req.ImageExt == nil || *req.ImageExt == "" {
			return utils.SendErrorResponse(c, fiber.StatusBadRequest, "更新图片时必须提供image_ext")
		}
		imageData, err := base64.StdEncoding.DecodeString(*req.ImageBase64)
		if err != nil {
			return utils.SendErrorResponse(c, fiber.StatusBadRequest, "图片数据解码失败")
		}
		maxSize := int64(10 * 1024 * 1024)
		if int64(len(imageData)) > maxSize {
			return utils.SendErrorResponse(c, fiber.StatusBadRequest, "图片大小不能超过10MB")
		}
		imagePath, err := saveBase64Image(imageData, *req.ImageExt)
		if err != nil {
			return utils.SendErrorResponse(c, fiber.StatusInternalServerError, "保存图片失败")
		}
		newImagePath = &imagePath
	}
	if err := h.customMapService.UpdateCustomMap(id, req, newImagePath); err != nil {
		if newImagePath != nil {
			_ = os.Remove(filepath.Join(".", *newImagePath))
		}
		return err
	}
	return utils.SendSuccessResponse(c, nil, "自制地图更新成功")
}
func (h *CustomMapHandler) DeleteCustomMap(c *fiber.Ctx) error {
	id := c.Params("id")
	if err := h.customMapService.DeleteCustomMap(id); err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, nil, "自制地图删除成功")
}
func saveBase64Image(imageData []byte, ext string) (string, error) {
	uploadDir := "uploads/maps"
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		return "", fmt.Errorf("创建上传目录失败: %w", err)
	}
	filename := fmt.Sprintf("%s_%d%s", uuid.New().String(), time.Now().Unix(), ext)
	relativePath := filepath.Join(uploadDir, filename)
	if err := os.WriteFile(relativePath, imageData, 0644); err != nil {
		return "", fmt.Errorf("写入文件失败: %w", err)
	}
	return "/" + strings.ReplaceAll(relativePath, "\\", "/"), nil
}
func getBaseURL(c *fiber.Ctx) string {
	scheme := "http"
	if c.Protocol() == "https" {
		scheme = "https"
	}
	return fmt.Sprintf("%s://%s", scheme, c.Hostname())
}
package utils
import (
	"fmt"
	"log"
	"os"
	"time"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"IOT-Manage-System/map-service/config"
)
func InitDB() (*gorm.DB, error) {
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		config.C.PSQLConfig.Host, config.C.PSQLConfig.Port, config.C.PSQLConfig.User, config.C.PSQLConfig.Password, config.C.PSQLConfig.Name, config.C.PSQLConfig.SSLMode)
	log.Println("DSN:" + dsn)
	var db *gorm.DB
	var err error
	for i := 0; i <= config.C.PSQLConfig.MaxRetries; i++ {
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
			Logger: logger.New(
				log.New(os.Stdout, "\r\n", log.LstdFlags), 
				logger.Config{
					SlowThreshold:             200 * time.Millisecond, 
					LogLevel:                  logger.Info,           
					IgnoreRecordNotFoundError: true,                   
					Colorful:                  true,                   
				},
			),
		})
		if err == nil {
			log.Println("数据库连接成功")
			break
		}
		log.Printf("数据库连接失败（尝试 %d/%d）: %v", i+1, config.C.PSQLConfig.MaxRetries, err)
		if i == config.C.PSQLConfig.MaxRetries {
			return nil, fmt.Errorf("数据库连接失败，已尝试%d次: %w", config.C.PSQLConfig.MaxRetries, err)
		}
		time.Sleep(config.C.PSQLConfig.RetryInterval)
	}
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("获取底层 sql.DB 失败: %w", err)
	}
	sqlDB.SetMaxOpenConns(config.C.PSQLConfig.MaxOpen)
	sqlDB.SetMaxIdleConns(config.C.PSQLConfig.MaxIdle)
	sqlDB.SetConnMaxLifetime(config.C.PSQLConfig.MaxLifetime)
	return db, nil
}
func CloseDB(db *gorm.DB) error {
	if db == nil {
		return nil
	}
	sqlDB, err := db.DB()
	if err != nil {
		return fmt.Errorf("获取底层 sql.DB 失败: %w", err)
	}
	return sqlDB.Close()
}
package config
import (
	"os"
	"strconv"
	"sync"
	"time"
)
var C *Config
type Config struct {
	PSQLConfig struct {
		Host          string
		Port          string
		User          string
		Password      string
		Name          string
		SSLMode       string
		MaxOpen       int
		MaxIdle       int
		MaxLifetime   time.Duration
		MaxRetries    int
		RetryInterval time.Duration
	}
}
var once sync.Once
func Load() {
	once.Do(func() {
		C = &Config{}
		C.PSQLConfig.Host = getEnvStr("DB_HOST", "localhost")
		C.PSQLConfig.Port = getEnvStr("DB_PORT", "5432")
		C.PSQLConfig.User = getEnvStr("DB_USER", "postgres")
		C.PSQLConfig.Password = getEnvStr("DB_PASSWORD", "password")
		C.PSQLConfig.Name = getEnvStr("DB_NAME", "iot_manager_db")
		C.PSQLConfig.SSLMode = getEnvStr("DB_SSLMODE", "disable")
		C.PSQLConfig.MaxOpen = getEnvInt("DB_MAX_OPEN_CONNS", 100)
		C.PSQLConfig.MaxIdle = getEnvInt("DB_MAX_IDLE_CONNS", 20)
		C.PSQLConfig.MaxLifetime = getEnvDuration("DB_MAX_LIFETIME", time.Hour)
		C.PSQLConfig.MaxRetries = getEnvInt("DB_MAX_RETRY", 5)
		C.PSQLConfig.RetryInterval = getEnvDuration("DB_RETRY_INTERVAL", 2*time.Second)
	})
}
func getEnvStr(key, defaultValue string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultValue
}
func getEnvInt(key string, defaultValue int) int {
	val := os.Getenv(key)
	if val == "" {
		return defaultValue
	}
	i, err := strconv.Atoi(val)
	if err != nil {
		return defaultValue
	}
	return i
}
func getEnvDuration(key string, def time.Duration) time.Duration {
	v := os.Getenv(key)
	if v == "" {
		return def
	}
	d, err := time.ParseDuration(v)
	if err != nil {
		return def
	}
	return d
}
package handler
import (
	"IOT-Manage-System/map-service/errs"
	"IOT-Manage-System/map-service/utils"
	"github.com/gofiber/fiber/v2"
	"time"
)
func CustomErrorHandler(c *fiber.Ctx, err error) error {
	status := fiber.StatusOK
	code := "INTERNAL_ERROR"
	message := err.Error()
	var details any
	if appErr, ok := err.(*errs.AppError); ok {
		code = appErr.Code
		message = appErr.Message
		details = appErr.Details
	}
	if e, ok := err.(*fiber.Error); ok {
		message = e.Message
	}
	resp := utils.Response{
		Success:   false,
		Message:   message,
		Error:     &utils.ErrorObj{Code: code, Message: message, Details: details},
		Timestamp: time.Now(),
	}
	return c.Status(status).JSON(resp)
}
package service
import (
	"errors"
	"fmt"
	"github.com/google/uuid"
	"gorm.io/gorm"
	"IOT-Manage-System/map-service/errs"
	"IOT-Manage-System/map-service/model"
	"IOT-Manage-System/map-service/repo"
)
type StationService struct {
	stationRepo *repo.StationRepo
}
func NewStationService(repo *repo.StationRepo) *StationService {
	return &StationService{stationRepo: repo}
}
func (s *StationService) CreateStation(req *model.StationCreateReq) error {
	if err := s.validateStationData(req.StationName, req.CoordinateX, req.CoordinateY); err != nil {
		return err
	}
	station := model.StationCreateReqToStation(req)
	if err := s.stationRepo.Create(station); err != nil {
		return s.translateRepoErr(err, "Station")
	}
	return nil
}
func (s *StationService) GetStation(id string) (*model.StationResp, error) {
	uid, err := parseUUID(id)
	if err != nil {
		return nil, err
	}
	station, err := s.stationRepo.GetByID(uid)
	if err != nil {
		return nil, s.translateRepoErr(err, "Station")
	}
	return model.StationToStationResp(station), nil
}
func (s *StationService) GetALLStation() ([]model.StationResp, error) {
	list, err := s.stationRepo.ListAll()
	if err != nil {
		return nil, s.translateRepoErr(err, "Station")
	}
	if len(list) == 0 {
		return []model.StationResp{}, nil
	}
	resp := make([]model.StationResp, 0, len(list))
	for i := range list {
		resp = append(resp, *model.StationToStationResp(&list[i]))
	}
	return resp, nil
}
func (s *StationService) UpdateStation(id string, req *model.StationUpdateReq) error {
	uid, err := parseUUID(id)
	if err != nil {
		return err
	}
	data, err := s.stationRepo.GetByID(uid)
	if err != nil {
		return s.translateRepoErr(err, "Station")
	}
	stationName := data.StationName
	coordinateX := data.CoordinateX
	coordinateY := data.CoordinateY
	if req.StationName != nil {
		stationName = *req.StationName
	}
	if req.CoordinateX != nil {
		coordinateX = *req.CoordinateX
	}
	if req.CoordinateY != nil {
		coordinateY = *req.CoordinateY
	}
	if err := s.validateStationData(stationName, coordinateX, coordinateY); err != nil {
		return err
	}
	updates := make(map[string]interface{})
	if req.StationName != nil {
		updates["station_name"] = stationName
	}
	if req.CoordinateX != nil {
		updates["location_x"] = coordinateX
	}
	if req.CoordinateY != nil {
		updates["location_y"] = coordinateY
	}
	if err := s.stationRepo.UpdateByIDWithMap(uid, updates); err != nil {
		return s.translateRepoErr(err, "Station")
	}
	return nil
}
func (s *StationService) DeleteStation(id string) error {
	uid, err := parseUUID(id)
	if err != nil {
		return err
	}
	if err := s.stationRepo.DeleteByID(uid); err != nil {
		return s.translateRepoErr(err, "Station")
	}
	return nil
}
func parseUUID(id string) (uuid.UUID, error) {
	uid, err := uuid.Parse(id)
	if err != nil {
		return uuid.Nil, errs.ErrValidationFailed.WithDetails(fmt.Sprintf("invalid uuid: %s", id))
	}
	return uid, nil
}
func (s *StationService) translateRepoErr(err error, resource string) error {
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return errs.NotFound(resource, fmt.Sprintf("%s 不存在", resource))
	}
	return errs.ErrInternal.WithDetails(err.Error())
}
func (s *StationService) validateStationData(stationName string, coordinateX, coordinateY float64) error {
	if len(stationName) == 0 {
		return errs.ErrValidationFailed.WithDetails("基站名称不能为空")
	}
	if len(stationName) > 255 {
		return errs.ErrValidationFailed.WithDetails("基站名称长度不能超过255个字符")
	}
	return nil
}
package service
import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
)
func (s *markService) CreateMarkTag(mt *model.MarkTagRequest) error {
	if mt.TagName == "" {
		return errs.ErrInvalidInput.WithDetails("TagName 不能为空")
	}
	if exist, err := s.repo.IsTagNameExists(mt.TagName); exist != false || err != nil {
		return errs.AlreadyExists("MARK_TAG", "标签已存在")
	}
	markTag := model.MarkTag{TagName: mt.TagName}
	if err := s.repo.CreateMarkTag(&markTag); err != nil {
		return errs.ErrDatabase.WithDetails(err)
	}
	return nil
}
func (s *markService) GetMarkTagByID(id int) (*model.MarkTagResponse, error) {
	markTag, err := s.repo.GetMarkTagByID(id)
	if err != nil {
		return nil, errs.NotFound("MARK_TAG", "标签不存在", err)
	}
	return &model.MarkTagResponse{
		ID:      markTag.ID,
		TagName: markTag.TagName,
	}, nil
}
func (s *markService) GetMarkTagByName(name string) (*model.MarkTagResponse, error) {
	markTag, err := s.repo.GetMarkTagByName(name)
	if err != nil {
		return nil, errs.NotFound("MARK_TAG", "标签不存在", err)
	}
	return &model.MarkTagResponse{
		ID:      markTag.ID,
		TagName: markTag.TagName,
	}, nil
}
func (s *markService) ListMarkTags(page, limit int) ([]model.MarkTagResponse, int64, error) {
	if page <= 0 || limit <= 0 {
		return nil, 0, errs.ErrInvalidInput.WithDetails("page 和 limit 必须大于 0")
	}
	offset := (page - 1) * limit
	markTags, total, err := s.repo.ListMarkTagsWithCount(offset, limit)
	if err != nil {
		return nil, 0, errs.ErrDatabase.WithDetails(err)
	}
	responses := make([]model.MarkTagResponse, 0, len(markTags))
	for _, mt := range markTags {
		responses = append(responses, model.MarkTagResponse{
			ID:      mt.ID,
			TagName: mt.TagName,
		})
	}
	return responses, total, nil
}
func (s *markService) UpdateMarkTag(id int, mt *model.MarkTagRequest) error {
	if mt.TagName == "" {
		return errs.ErrInvalidInput.WithDetails("TagName 不能为空")
	}
	tag, err := s.repo.GetMarkTagByID(id)
	if err != nil {
		return errs.NotFound("MARK_TAG", "标签不存在", err)
	}
	if tag.TagName == mt.TagName {
		return nil
	}
	if exist, err := s.repo.IsTagNameExists(mt.TagName); exist != false || err != nil {
		return errs.AlreadyExists("MARK_TAG", "标签已存在")
	}
	tag.TagName = mt.TagName
	return s.repo.UpdateMarkTag(tag)
}
func (s *markService) DeleteMarkTag(id int) error {
	if err := s.repo.DeleteMarkTag(id); err != nil {
		return errs.ErrDatabase.WithDetails(err)
	}
	return nil
}
func (s *markService) GetMarksByTagID(tagID int, page, limit int, preload bool) ([]model.MarkResponse, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit <= 0 || limit > 200 {
		limit = 20
	}
	offset := (page - 1) * limit
	marks, total, err := s.repo.GetMarksByTagID(tagID, preload, offset, limit)
	if err != nil {
		return nil, 0, errs.ErrDatabase.WithDetails(err.Error())
	}
	var responses []model.MarkResponse
	for _, mark := range marks {
		responses = append(responses, *s.convertToMarkResponse(&mark))
	}
	if len(responses) == 0 {
		return nil, total, errs.NotFound("Marks", "未找到相关标记")
	}
	return responses, total, nil
}
func (s *markService) GetMarksByTagName(tagName string, page, limit int, preload bool) ([]model.MarkResponse, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit <= 0 || limit > 200 {
		limit = 20
	}
	offset := (page - 1) * limit
	marks, total, err := s.repo.GetMarksByTagName(tagName, preload, offset, limit)
	if err != nil {
		return nil, 0, errs.ErrDatabase.WithDetails(err.Error())
	}
	var responses []model.MarkResponse
	for _, mark := range marks {
		responses = append(responses, *s.convertToMarkResponse(&mark))
	}
	if len(responses) == 0 {
		return nil, total, errs.NotFound("Marks", "未找到相关标记")
	}
	return responses, total, nil
}
func (s *markService) GetAllTagIDToName() (map[int]string, error) {
	m, err := s.repo.GetAllTagIDsAndNames()
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return m, nil
}
package service
import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
)
func (s *markService) convertToMarkTypeResponse(markType *model.MarkType) *model.MarkTypeResponse {
	if markType == nil {
		return nil
	}
	return &model.MarkTypeResponse{
		ID:                 markType.ID,
		TypeName:           markType.TypeName,
		DefaultDangerZoneM: markType.DefaultSafeDistanceM,
	}
}
func (s *markService) CreateMarkType(req *model.MarkTypeCreateRequest) error {
	exist, err := s.repo.IsTypeNameExists(req.TypeName)
	if err == nil && exist != false {
		return errs.AlreadyExists("MARK_TYPE", "标记类型重复")
	}
	markType := model.MarkType{
		TypeName:             req.TypeName,
		DefaultSafeDistanceM: req.DefaultSafeDistanceM,
	}
	return s.repo.CreateMarkType(&markType)
}
func (s *markService) GetMarkTypeByID(id int) (*model.MarkTypeResponse, error) {
	markType, err := s.repo.GetMarkTypeByID(id)
	if err != nil {
		return nil, err
	}
	return s.convertToMarkTypeResponse(markType), nil
}
func (s *markService) GetMarkTypeByName(name string) (*model.MarkTypeResponse, error) {
	markType, err := s.repo.GetMarkTypeByName(name)
	if err != nil {
		return nil, err
	}
	return s.convertToMarkTypeResponse(markType), nil
}
func (s *markService) ListMarkTypes(page, limit int) ([]model.MarkTypeResponse, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit <= 0 || limit > 200 {
		limit = 20
	}
	offset := (page - 1) * limit
	markTypes, total, err := s.repo.ListMarkTypesWithCount(offset, limit)
	if err != nil {
		return nil, 0, err
	}
	responses := make([]model.MarkTypeResponse, 0, len(markTypes))
	for _, mt := range markTypes {
		responses = append(responses, *s.convertToMarkTypeResponse(&mt))
	}
	return responses, total, nil
}
func (s *markService) UpdateMarkType(typeID int, req *model.MarkTypeUpdateRequest) error {
	mt, err := s.repo.GetMarkTypeByID(typeID)
	if err != nil {
		return err
	}
	if mt == nil {
		return errs.ErrResourceNotFound
	}
	if req.TypeName != nil && *req.TypeName != mt.TypeName {
		exist, err := s.repo.IsTypeNameExists(mt.TypeName)
		if err == nil && exist != false {
			return errs.AlreadyExists("MARK_TYPE", "标记类型重复")
		}
	}
	if req.TypeName != nil {
		mt.TypeName = *req.TypeName
	}
	if req.DefaultSafeDistanceM != nil {
		mt.DefaultSafeDistanceM = req.DefaultSafeDistanceM
	}
	return s.repo.UpdateMarkType(mt)
}
func (s *markService) DeleteMarkType(id int) error {
	return s.repo.DeleteMarkType(id)
}
func (s *markService) GetMarksByTypeID(typeID int, page, limit int, preload bool) ([]model.MarkResponse, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit <= 0 || limit > 200 {
		limit = 20
	}
	offset := (page - 1) * limit
	marks, total, err := s.repo.GetMarksByTypeID(typeID, preload, offset, limit)
	if err != nil {
		return nil, 0, errs.ErrDatabase.WithDetails(err.Error())
	}
	var responses []model.MarkResponse
	for _, mark := range marks {
		responses = append(responses, *s.convertToMarkResponse(&mark))
	}
	return responses, total, nil
}
func (s *markService) GetMarksByTypeName(typeName string, page, limit int, preload bool) ([]model.MarkResponse, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit <= 0 || limit > 200 {
		limit = 20
	}
	offset := (page - 1) * limit
	marks, total, err := s.repo.GetMarksByTypeName(typeName, preload, offset, limit)
	if err != nil {
		return nil, 0, errs.ErrDatabase.WithDetails(err.Error())
	}
	var responses []model.MarkResponse
	for _, mark := range marks {
		responses = append(responses, *s.convertToMarkResponse(&mark))
	}
	return responses, total, nil
}
func (s *markService) GetAllTypeIDToName() (map[int]string, error) {
	m, err := s.repo.GetAllTypeIDsAndNames()
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return m, nil
}
package utils
import (
	"net/http"
	"time"
	"github.com/gofiber/fiber/v2"
)
type Response struct {
	Success    bool           `json:"success"`
	Data       any            `json:"data,omitempty"`
	Message    string         `json:"message,omitempty"`
	Error      *ErrorObj      `json:"error,omitempty"`
	Pagination *PaginationObj `json:"pagination,omitempty"`
	Timestamp  time.Time      `json:"timestamp"`
}
type ErrorObj struct {
	Code    string `json:"code"`
	Message string `json:"message"`
	Details any    `json:"details,omitempty"`
}
type PaginationObj struct {
	CurrentPage  int   `json:"currentPage"`
	TotalPages   int   `json:"totalPages"`
	TotalItems   int64 `json:"totalItems"`
	ItemsPerPage int   `json:"itemsPerPage"`
	HasNext      bool  `json:"has_next"`
	HasPrev      bool  `json:"has_prev"`
}
func SendSuccessResponse(c *fiber.Ctx, data any, msg ...string) error {
	message := "请求成功啦😁"
	if len(msg) > 0 {
		message = msg[0]
	}
	return c.Status(http.StatusOK).JSON(Response{
		Success:   true,
		Data:      data,
		Message:   message,
		Timestamp: time.Now(),
	})
}
func SendCreatedResponse(c *fiber.Ctx, data any, msg ...string) error {
	message := "创建成功啦✌️"
	if len(msg) > 0 {
		message = msg[0]
	}
	return c.Status(http.StatusOK).JSON(Response{
		Success:   true,
		Data:      data,
		Message:   message,
		Timestamp: time.Now(),
	})
}
func SendPaginatedResponse(c *fiber.Ctx, data any, total int64, page, perPage int, msg ...string) error {
	message := "请求成功啦😁"
	if len(msg) > 0 {
		message = msg[0]
	}
	pagination := NewPagination(total, page, perPage)
	return c.Status(http.StatusOK).JSON(Response{
		Success:    true,
		Data:       data,
		Message:    message,
		Pagination: pagination,
		Timestamp:  time.Now(),
	})
}
func SendErrorResponse(c *fiber.Ctx, statusCode int, message string) error {
	return c.Status(http.StatusOK).JSON(Response{
		Success:   false,
		Message:   message,
		Timestamp: time.Now(),
	})
}
func SendErrorResponseWithData(c *fiber.Ctx, statusCode int, message string, data any) error {
	return c.Status(http.StatusOK).JSON(Response{
		Success:   false,
		Message:   message,
		Data:      data,
		Timestamp: time.Now(),
	})
}
func NewPagination(total int64, page, perPage int) *PaginationObj {
	if perPage <= 0 {
		perPage = 10
	}
	totalPages := int((total + int64(perPage) - 1) / int64(perPage))
	return &PaginationObj{
		CurrentPage:  page,
		TotalPages:   totalPages,
		TotalItems:   total,
		ItemsPerPage: perPage,
		HasNext:      page < totalPages,
		HasPrev:      page > 1,
	}
}
package utils
package service
import (
	"time"
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
)
func (s *markService) CreateMark(mark *model.MarkRequest) error {
	exist, err := s.repo.IsDeviceIDExists(mark.DeviceID)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	if exist {
		return errs.AlreadyExists("DeviceID", "设备ID已存在")
	}
	exist, err = s.repo.IsMarkNameExists(mark.MarkName)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	if exist {
		return errs.AlreadyExists("MarkName", "标记名称已存在")
	}
	persistMQTT := false
	if mark.PersistMQTT != nil {
		persistMQTT = *mark.PersistMQTT
	}
	markTypeID := 1 
	if mark.MarkTypeID != nil {
		markTypeID = *mark.MarkTypeID
	}
	safeDistance := mark.SafeDistanceM
	if safeDistance == nil || *safeDistance < 0 { 
		typ, err := s.repo.GetMarkTypeByID(markTypeID)
		if err != nil {
			return errs.ErrDatabase.WithDetails("获取MarkType失败: " + err.Error())
		}
		if typ.DefaultSafeDistanceM != nil {
			safeDistance = typ.DefaultSafeDistanceM
		} else {
			safeDistance = new(float64) 
		}
	}
	dbMark := model.Mark{
		DeviceID:      mark.DeviceID,
		MarkName:      mark.MarkName,
		MqttTopic:     mark.MqttTopic,
		PersistMQTT:   persistMQTT,
		SafeDistanceM: safeDistance,
		MarkTypeID:    markTypeID,
	}
	if err := s.repo.CreateMarkAutoTag(&dbMark, mark.Tags); err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	return nil
}
func (s *markService) GetMarkByID(id string, preload bool) (*model.MarkResponse, error) {
	mark, err := s.repo.GetMarkByID(id, preload)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	if mark == nil {
		return nil, errs.NotFound("Mark", "标记未找到")
	}
	return s.convertToMarkResponse(mark), nil
}
func (s *markService) GetMarkByDeviceID(deviceID string, preload bool) (*model.MarkResponse, error) {
	mark, err := s.repo.GetMarkByDeviceID(deviceID, preload)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	if mark == nil {
		return nil, errs.NotFound("Mark", "标记未找到")
	}
	return s.convertToMarkResponse(mark), nil
}
func (s *markService) ListMark(page, limit int, preload bool) ([]model.MarkResponse, int64, error) {
	offset := (page - 1) * limit
	marks, total, err := s.repo.ListMarkWithCount(offset, limit, preload)
	if err != nil {
		return nil, 0, errs.ErrDatabase.WithDetails(err.Error())
	}
	responses := make([]model.MarkResponse, 0, len(marks))
	for _, mark := range marks {
		responses = append(responses, *s.convertToMarkResponse(&mark))
	}
	return responses, total, nil
}
func (s *markService) fallbackSafeDistance(reqSafe *float64, markTypeID int) (*float64, error) {
	if reqSafe != nil && *reqSafe >= 0 { 
		return reqSafe, nil
	}
	typ, err := s.repo.GetMarkTypeByID(markTypeID)
	if err != nil {
		return nil, err
	}
	if typ.DefaultSafeDistanceM != nil {
		return typ.DefaultSafeDistanceM, nil
	}
	zero := 0.0
	return &zero, nil
}
func (s *markService) UpdateMark(ID string, req *model.MarkUpdateRequest) error {
	m, err := s.repo.GetMarkByID(ID, true)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	if m == nil {
		return errs.NotFound("Mark", "标记未找到")
	}
	if req.MarkName != nil {
		if ok, _ := s.repo.IsMarkNameExists(*req.MarkName); ok && *req.MarkName != m.MarkName {
			return errs.AlreadyExists("MarkName", "标记名称已存在")
		}
		m.MarkName = *req.MarkName
	}
	if req.DeviceID != nil {
		if ok, _ := s.repo.IsDeviceIDExists(*req.DeviceID); ok && *req.DeviceID != m.DeviceID {
			return errs.AlreadyExists("DeviceID", "设备ID已存在")
		}
		m.DeviceID = *req.DeviceID
	}
	if req.MqttTopic != nil {
		m.MqttTopic = req.MqttTopic
	}
	if req.PersistMQTT != nil {
		m.PersistMQTT = *req.PersistMQTT
	}
	if req.SafeDistanceM != nil || req.MarkTypeID != nil {
		newTypeID := m.MarkTypeID
		if req.MarkTypeID != nil {
			newTypeID = *req.MarkTypeID
		}
		fallback, err := s.fallbackSafeDistance(req.SafeDistanceM, newTypeID)
		if err != nil {
			return errs.ErrDatabase.WithDetails("获取默认安全距离失败: " + err.Error())
		}
		m.SafeDistanceM = fallback
	}
	if req.MarkTypeID != nil {
		m.MarkTypeID = *req.MarkTypeID
	}
	if err := s.repo.UpdateMark(m, req.Tags); err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	return nil
}
func (s *markService) DeleteMark(id string) error {
	return s.repo.DeleteMark(id)
}
func (s *markService) UpdateMarkLastOnline(deviceID string, t time.Time) error {
	return s.repo.UpdateMarkLastOnline(deviceID, t)
}
func (s *markService) convertToMarkResponse(mark *model.Mark) *model.MarkResponse {
	response := &model.MarkResponse{
		ID:           mark.ID.String(),
		DeviceID:     mark.DeviceID,
		MarkName:     mark.MarkName,
		MqttTopic:    mark.MqttTopic,
		PersistMQTT:  mark.PersistMQTT,
		DangerZoneM:  mark.SafeDistanceM,
		CreatedAt:    mark.CreatedAt,
		UpdatedAt:    mark.UpdatedAt,
		LastOnlineAt: mark.LastOnlineAt,
	}
	if mark.MarkType.ID != 0 {
		response.MarkType = &model.MarkTypeResponse{
			ID:       mark.MarkType.ID,
			TypeName: mark.MarkType.TypeName,
		}
	}
	if len(mark.Tags) > 0 {
		var tagResponses []model.MarkTagResponse
		for _, tag := range mark.Tags {
			tagResponses = append(tagResponses, model.MarkTagResponse{
				ID:      tag.ID,
				TagName: tag.TagName,
			})
		}
		response.Tags = tagResponses
	}
	return response
}
func (s *markService) GetPersistMQTTByDeviceID(deviceID string) (bool, error) {
	persist, err := s.repo.GetPersistMQTTByDeviceID(deviceID)
	if err != nil {
		return false, errs.ErrDatabase.WithDetails(err.Error())
	}
	return persist, nil
}
func (s *markService) GetMarksByPersistMQTT(persist bool, page, limit int, preload bool) ([]model.MarkResponse, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit <= 0 || limit > 200 {
		limit = 20
	}
	offset := (page - 1) * limit
	marks, total, err := s.repo.GetMarksByPersistMQTT(persist, preload, offset, limit)
	if err != nil {
		return nil, 0, errs.ErrDatabase.WithDetails(err.Error())
	}
	if len(marks) == 0 {
		return nil, total, errs.NotFound("Marks", "未找到 PersistMQTT=%v 的标记", persist)
	}
	var responses []model.MarkResponse
	for _, mark := range marks {
		responses = append(responses, *s.convertToMarkResponse(&mark))
	}
	return responses, total, nil
}
func (s *markService) GetDeviceIDsByPersistMQTT(persist bool) ([]string, error) {
	deviceIDs, err := s.repo.GetDeviceIDsByPersistMQTT(persist)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return deviceIDs, nil
}
func (s *markService) GetAllDeviceIDToName() (map[string]string, error) {
	m, err := s.repo.GetAllMarkDeviceIDsAndNames()
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return m, nil
}
func (s *markService) GetAllMarkIDToName() (map[string]string, error) {
	m, err := s.repo.GetAllMarkIDsAndNames()
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return m, nil
}
func (s *markService) GetMarkSafeDistance(markID string) (*float64, error) {
	safeDistance, err := s.repo.GetMarkSafeDistance(markID)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return safeDistance, nil
}
func (s *markService) GetMarkSafeDistanceByDeviceID(deviceID string) (*float64, error) {
	safeDistance, err := s.repo.GetMarkSafeDistanceByDeviceID(deviceID)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return safeDistance, nil
}
package utils
import (
	"fmt"
	"log"
	"time"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)
func InitDB() (*gorm.DB, error) {
	dbHost := GetEnv("DB_HOST", "localhost")
	dbPort := GetEnv("DB_PORT", "5432")
	dbUser := GetEnv("DB_USER", "postgres")
	dbPassword := GetEnv("DB_PASSWORD", "password")
	dbName := GetEnv("DB_NAME", "credit_management")
	dbSSLMode := GetEnv("DB_SSLMODE", "disable")
	maxOpen := GetEnvInt("DB_MAX_OPEN_CONNS", 100)
	maxIdle := GetEnvInt("DB_MAX_IDLE_CONNS", 20)
	maxLifetime := time.Duration(GetEnvInt("DB_MAX_LIFETIME", 1)) * time.Hour
	maxRetries := GetEnvInt("DB_MAX_RETRY", 5)
	retryInterval := time.Duration(GetEnvInt("DB_RETRY_INTERVAL", 2)) * time.Second
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		dbHost, dbPort, dbUser, dbPassword, dbName, dbSSLMode)
	log.Println("DSN:" + dsn)
	var db *gorm.DB
	var err error
	for i := 0; i <= maxRetries; i++ {
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
			Logger: logger.Default.LogMode(logger.Info),
		})
		if err == nil {
			log.Println("数据库连接成功")
			break
		}
		log.Printf("数据库连接失败（尝试 %d/%d）: %v", i+1, maxRetries, err)
		if i == maxRetries {
			return nil, fmt.Errorf("数据库连接失败，已尝试%d次: %w", maxRetries, err)
		}
		time.Sleep(retryInterval)
	}
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("获取底层 sql.DB 失败: %w", err)
	}
	sqlDB.SetMaxOpenConns(maxOpen)
	sqlDB.SetMaxIdleConns(maxIdle)
	sqlDB.SetConnMaxLifetime(maxLifetime)
	return db, nil
}
func CloseDB(db *gorm.DB) error {
	if db == nil {
		return nil
	}
	sqlDB, err := db.DB()
	if err != nil {
		return fmt.Errorf("获取底层 sql.DB 失败: %w", err)
	}
	return sqlDB.Close()
}
package service
import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
	"IOT-Manage-System/mark-service/repo"
	"sort"
)
type MarkPairService interface {
	SetPairDistance(mark1ID, mark2ID string, distance float64) error
	SetCombinations(ids []string, distance float64) error
	SetCartesian(req model.SetDistanceTypedReq, distance float64) error
	GetDistance(mark1ID, mark2ID string) (float64, error)
	DeletePair(mark1ID, mark2ID string) error
	DistanceMapByMark(id string) (map[string]float64, error)
	DistanceMapByDevice(deviceID string) (map[string]float64, error)
	GetDistanceByDeviceIDs(device1ID, device2ID string) (float64, error)
	DistanceMapByDeviceToDeviceIDs(deviceID string) (map[string]float64, error)
	ListMarkPairs(page, limit int) ([]model.MarkPairResponse, int64, error)
}
type markPairService struct {
	markPairRepo repo.MarkPairRepo
	markRepo     repo.MarkRepo
}
func NewMarkPairService(r1 repo.MarkPairRepo, r2 repo.MarkRepo) MarkPairService {
	return &markPairService{markPairRepo: r1, markRepo: r2}
}
func (s *markPairService) SetPairDistance(mark1ID, mark2ID string, distance float64) error {
	if mark1ID == "" || mark2ID == "" {
		return errs.ErrInvalidInput.WithDetails("mark IDs cannot be empty")
	}
	if distance < 0 {
		return errs.ErrInvalidInput.WithDetails("distance cannot be negative")
	}
	err := s.markPairRepo.Upsert(mark1ID, mark2ID, distance)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	return nil
}
func (s *markPairService) SetCombinations(ids []string, distance float64) error {
	if len(ids) < 2 {
		return nil
	}
	if distance < 0 {
		return errs.ErrInvalidInput.WithDetails("distance cannot be negative")
	}
	m := make(map[string]struct{})
	for _, id := range ids {
		if id == "" {
			return errs.ErrInvalidInput.WithDetails("mark ID cannot be empty")
		}
		m[id] = struct{}{}
	}
	uniq := make([]string, 0, len(m))
	for id := range m {
		uniq = append(uniq, id)
	}
	sort.Strings(uniq)
	err := s.markPairRepo.BatchUpsert(uniq, distance)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	return nil
}
func (s *markPairService) SetCartesian(req model.SetDistanceTypedReq, distance float64) error {
	if distance < 0 {
		return errs.ErrInvalidInput.WithDetails("distance cannot be negative")
	}
	var m1IDs, m2IDs []string
	var err error
	switch req.First.Kind {
	case "mark":
		if req.First.MarkID == "" {
			return errs.ErrInvalidInput.WithDetails("mark ID cannot be empty")
		}
		m1IDs = []string{req.First.MarkID}
	case "tag":
		if req.First.TagID <= 0 {
			return errs.ErrInvalidInput.WithDetails("tag ID must be positive")
		}
		m1IDs, err = s.markRepo.GetMarkIDsByTagID(req.First.TagID)
		if err != nil {
			return errs.ErrDatabase.WithDetails(err.Error())
		}
	case "type":
		if req.First.TypeID <= 0 {
			return errs.ErrInvalidInput.WithDetails("type ID must be positive")
		}
		m1IDs, err = s.markRepo.GetMarkIDsByTypeID(req.First.TypeID)
		if err != nil {
			return errs.ErrDatabase.WithDetails(err.Error())
		}
	default:
		return errs.ErrInvalidInput.WithDetails("unknown first condition kind: " + req.First.Kind)
	}
	switch req.Second.Kind {
	case "mark":
		if req.Second.MarkID == "" {
			return errs.ErrInvalidInput.WithDetails("mark ID cannot be empty")
		}
		m2IDs = []string{req.Second.MarkID}
	case "tag":
		if req.Second.TagID <= 0 {
			return errs.ErrInvalidInput.WithDetails("tag ID must be positive")
		}
		m2IDs, err = s.markRepo.GetMarkIDsByTagID(req.Second.TagID)
		if err != nil {
			return errs.ErrDatabase.WithDetails(err.Error())
		}
	case "type":
		if req.Second.TypeID <= 0 {
			return errs.ErrInvalidInput.WithDetails("type ID must be positive")
		}
		m2IDs, err = s.markRepo.GetMarkIDsByTypeID(req.Second.TypeID)
		if err != nil {
			return errs.ErrDatabase.WithDetails(err.Error())
		}
	default:
		return errs.ErrInvalidInput.WithDetails("unknown second condition kind: " + req.Second.Kind)
	}
	if len(m1IDs) == 0 {
		return errs.NotFound("MARK", "no mark IDs found for first condition")
	}
	if len(m2IDs) == 0 {
		return errs.NotFound("MARK", "no mark IDs found for second condition")
	}
	err = s.markPairRepo.CartesianUpsertByMarkIDs(m1IDs, m2IDs, distance)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	return nil
}
func (s *markPairService) GetDistance(mark1ID, mark2ID string) (float64, error) {
	if mark1ID == "" || mark2ID == "" {
		return 0, errs.ErrInvalidInput.WithDetails("mark IDs cannot be empty")
	}
	distance, err := s.markPairRepo.Get(mark1ID, mark2ID)
	if err != nil {
		return 0, errs.ErrDatabase.WithDetails(err.Error())
	}
	return distance, nil
}
func (s *markPairService) DeletePair(mark1ID, mark2ID string) error {
	if mark1ID == "" || mark2ID == "" {
		return errs.ErrInvalidInput.WithDetails("mark IDs cannot be empty")
	}
	err := s.markPairRepo.Delete(mark1ID, mark2ID)
	if err != nil {
		return errs.ErrDatabase.WithDetails(err.Error())
	}
	return nil
}
func (s *markPairService) DistanceMapByMark(id string) (map[string]float64, error) {
	if id == "" {
		return nil, errs.ErrInvalidInput.WithDetails("mark ID cannot be empty")
	}
	result, err := s.markPairRepo.MapByID(id)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return result, nil
}
func (s *markPairService) DistanceMapByDevice(deviceID string) (map[string]float64, error) {
	if deviceID == "" {
		return nil, errs.ErrInvalidInput.WithDetails("device ID cannot be empty")
	}
	result, err := s.markPairRepo.MapByDeviceID(deviceID)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return result, nil
}
func (s *markPairService) GetDistanceByDeviceIDs(device1ID, device2ID string) (float64, error) {
	if device1ID == "" || device2ID == "" {
		return 0, errs.ErrInvalidInput.WithDetails("device IDs cannot be empty")
	}
	if device1ID == device2ID {
		return 0, errs.ErrInvalidInput.WithDetails("device IDs cannot be the same")
	}
	distance, err := s.markPairRepo.GetByDeviceIDs(device1ID, device2ID)
	if err != nil {
		return 0, errs.ErrDatabase.WithDetails(err.Error())
	}
	return distance, nil
}
func (s *markPairService) DistanceMapByDeviceToDeviceIDs(deviceID string) (map[string]float64, error) {
	if deviceID == "" {
		return nil, errs.ErrInvalidInput.WithDetails("device ID cannot be empty")
	}
	result, err := s.markPairRepo.MapByDeviceIDToDeviceIDs(deviceID)
	if err != nil {
		return nil, errs.ErrDatabase.WithDetails(err.Error())
	}
	return result, nil
}
func (s *markPairService) ListMarkPairs(page, limit int) ([]model.MarkPairResponse, int64, error) {
	if page < 1 {
		page = 1
	}
	if limit < 1 {
		limit = 10
	}
	if limit > 100 {
		limit = 100
	}
	offset := (page - 1) * limit
	pairs, total, err := s.markPairRepo.ListMarkPairs(offset, limit)
	if err != nil {
		return nil, 0, errs.ErrDatabase.WithDetails(err.Error())
	}
	responses := make([]model.MarkPairResponse, 0, len(pairs))
	for _, pair := range pairs {
		responses = append(responses, model.MarkPairResponse{
			Mark1ID:   pair.Mark1ID.String(),
			Mark2ID:   pair.Mark2ID.String(),
			DistanceM: pair.DistanceM,
		})
	}
	return responses, total, nil
}
package handler
import (
	"github.com/gofiber/fiber/v2"
	"IOT-Manage-System/map-service/model"
	"IOT-Manage-System/map-service/service"
	"IOT-Manage-System/map-service/utils"
)
type StationHandler struct {
	stationService *service.StationService
}
func NewStationHandler(svc *service.StationService) *StationHandler {
	return &StationHandler{stationService: svc}
}
func (h *StationHandler) CreateStation(c *fiber.Ctx) error {
	req := new(model.StationCreateReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "参数解析失败")
	}
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}
	if err := h.stationService.CreateStation(req); err != nil {
		return err 
	}
	return utils.SendCreatedResponse(c, nil, "基站创建成功")
}
func (h *StationHandler) GetStation(c *fiber.Ctx) error {
	id := c.Params("id")
	resp, err := h.stationService.GetStation(id)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}
func (h *StationHandler) ListStation(c *fiber.Ctx) error { 
	list, err := h.stationService.GetALLStation()
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, list)
}
func (h *StationHandler) UpdateStation(c *fiber.Ctx) error {
	id := c.Params("id")
	req := new(model.StationUpdateReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "参数解析失败")
	}
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}
	if err := h.stationService.UpdateStation(id, req); err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, nil, "基站更新成功")
}
func (h *StationHandler) DeleteStation(c *fiber.Ctx) error {
	id := c.Params("id")
	if err := h.stationService.DeleteStation(id); err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, nil, "基站删除成功")
}
package utils
import (
	"fmt"
	"os"
	"strconv"
	"strings"
)
func GetEnv(key, defaultValue string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultValue
}
func GetEnvInt(key string, defaultValue int) int {
	val := os.Getenv(key)
	if val == "" {
		return defaultValue
	}
	i, err := strconv.Atoi(val)
	if err != nil {
		return defaultValue
	}
	return i
}
func GetDSN() string {
	dbHost := GetEnv("DB_HOST", "postgres")
	dbPort := GetEnv("DB_PORT", "5432")
	dbUser := GetEnv("DB_USER", "postgres")
	dbPasswd := GetEnv("DB_PASSWD", "password")
	dbName := GetEnv("DB_NAME", "iot_manager_db")
	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable TimeZone=Asia/Shanghai",
		dbHost, dbPort, dbUser, dbPasswd, dbName,
	)
}
func ParsePositiveInt(s string) (int, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0, nil
	}
	v, err := strconv.Atoi(s)
	if err != nil || v <= 0 {
		return 0, nil
	}
	return v, err
}
func ParsePositiveInt64(s string) (int64, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0, nil
	}
	v, err := strconv.ParseInt(s, 10, 64)
	if err != nil || v <= 0 {
		return 0, nil
	}
	return v, err
}
package utils
import (
	"fmt"
	"os"
	"strconv"
	"strings"
	"github.com/go-playground/validator/v10"
)
func GetEnv(key, defaultValue string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultValue
}
func GetEnvInt(key string, defaultValue int) int {
	val := os.Getenv(key)
	if val == "" {
		return defaultValue
	}
	i, err := strconv.Atoi(val)
	if err != nil {
		return defaultValue
	}
	return i
}
func GetDSN() string {
	dbHost := GetEnv("DB_HOST", "postgres")
	dbPort := GetEnv("DB_PORT", "5432")
	dbUser := GetEnv("DB_USER", "postgres")
	dbPasswd := GetEnv("DB_PASSWD", "password")
	dbName := GetEnv("DB_NAME", "iot_manager_db")
	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable TimeZone=Asia/Shanghai",
		dbHost, dbPort, dbUser, dbPasswd, dbName,
	)
}
func ParsePositiveInt(s string) (int, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0, fmt.Errorf("字符串为空")
	}
	v, err := strconv.Atoi(s)
	if err != nil {
		return 0, fmt.Errorf("解析失败: %w", err)
	}
	if v <= 0 {
		return 0, fmt.Errorf("值必须为正整数，当前值: %d", v)
	}
	return v, nil
}
func ParsePositiveInt64(s string) (int64, error) {
	s = strings.TrimSpace(s)
	if s == "" {
		return 0, fmt.Errorf("字符串为空")
	}
	v, err := strconv.ParseInt(s, 10, 64)
	if err != nil {
		return 0, fmt.Errorf("解析失败: %w", err)
	}
	if v <= 0 {
		return 0, fmt.Errorf("值必须为正整数，当前值: %d", v)
	}
	return v, nil
}
var Validator = validator.New()
func ValidateStruct(s interface{}) error {
	if err := Validator.Struct(s); err != nil {
		if validationErrors, ok := err.(validator.ValidationErrors); ok {
			errMsgs := make([]string, 0, len(validationErrors))
			for _, e := range validationErrors {
				errMsgs = append(errMsgs, formatValidationError(e))
			}
			return fmt.Errorf("%s", strings.Join(errMsgs, "; "))
		}
		return err
	}
	return nil
}
func formatValidationError(e validator.FieldError) string {
	field := e.Field()
	switch e.Tag() {
	case "required":
		return fmt.Sprintf("%s 是必填项", field)
	case "min":
		return fmt.Sprintf("%s 的最小长度/值为 %s", field, e.Param())
	case "max":
		return fmt.Sprintf("%s 的最大长度/值为 %s", field, e.Param())
	case "email":
		return fmt.Sprintf("%s 必须是有效的邮箱地址", field)
	case "url":
		return fmt.Sprintf("%s 必须是有效的URL", field)
	default:
		return fmt.Sprintf("%s 验证失败: %s", field, e.Tag())
	}
}
package handler
import (
	"IOT-Manage-System/map-service/model"
	"IOT-Manage-System/map-service/service"
	"IOT-Manage-System/map-service/utils"
	"github.com/gofiber/fiber/v2"
)
type PolygonFenceHandler struct {
	polygonFenceService *service.PolygonFenceService
}
func NewPolygonFenceHandler(svc *service.PolygonFenceService) *PolygonFenceHandler {
	return &PolygonFenceHandler{polygonFenceService: svc}
}
func (h *PolygonFenceHandler) CreatePolygonFence(c *fiber.Ctx) error {
	req := new(model.PolygonFenceCreateReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "请求参数解析失败")
	}
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}
	if err := h.polygonFenceService.CreatePolygonFence(req); err != nil {
		return err
	}
	return utils.SendCreatedResponse(c, nil, "多边形围栏创建成功")
}
func (h *PolygonFenceHandler) GetPolygonFence(c *fiber.Ctx) error {
	id := c.Params("id")
	resp, err := h.polygonFenceService.GetPolygonFence(id)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}
func (h *PolygonFenceHandler) ListPolygonFences(c *fiber.Ctx) error {
	activeOnly := c.QueryBool("active_only", false)
	list, err := h.polygonFenceService.ListPolygonFences(activeOnly)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, list)
}
func (h *PolygonFenceHandler) ListIndoorFences(c *fiber.Ctx) error {
	activeOnly := c.QueryBool("active_only", false)
	list, err := h.polygonFenceService.ListIndoorFences(activeOnly)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, list)
}
func (h *PolygonFenceHandler) ListOutdoorFences(c *fiber.Ctx) error {
	activeOnly := c.QueryBool("active_only", false)
	list, err := h.polygonFenceService.ListOutdoorFences(activeOnly)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, list)
}
func (h *PolygonFenceHandler) UpdatePolygonFence(c *fiber.Ctx) error {
	id := c.Params("id")
	req := new(model.PolygonFenceUpdateReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "请求参数解析失败")
	}
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}
	if err := h.polygonFenceService.UpdatePolygonFence(id, req); err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, nil, "多边形围栏更新成功")
}
func (h *PolygonFenceHandler) DeletePolygonFence(c *fiber.Ctx) error {
	id := c.Params("id")
	if err := h.polygonFenceService.DeletePolygonFence(id); err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, nil, "多边形围栏删除成功")
}
func (h *PolygonFenceHandler) CheckPointInFence(c *fiber.Ctx) error {
	fenceID := c.Params("id")
	req := new(model.PointCheckReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "请求参数解析失败")
	}
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}
	resp, err := h.polygonFenceService.CheckPointInFence(fenceID, req.X, req.Y)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}
func (h *PolygonFenceHandler) CheckPointInAllFences(c *fiber.Ctx) error {
	req := new(model.PointCheckReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "请求参数解析失败")
	}
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}
	resp, err := h.polygonFenceService.CheckPointInAllFences(req.X, req.Y)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}
func (h *PolygonFenceHandler) CheckPointInIndoorFence(c *fiber.Ctx) error {
	fenceID := c.Params("id")
	req := new(model.PointCheckReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "请求参数解析失败")
	}
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}
	resp, err := h.polygonFenceService.CheckPointInIndoorFence(fenceID, req.X, req.Y)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}
func (h *PolygonFenceHandler) CheckPointInOutdoorFence(c *fiber.Ctx) error {
	fenceID := c.Params("id")
	req := new(model.PointCheckReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "请求参数解析失败")
	}
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}
	resp, err := h.polygonFenceService.CheckPointInOutdoorFence(fenceID, req.X, req.Y)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}
func (h *PolygonFenceHandler) CheckPointInIndoorFences(c *fiber.Ctx) error {
	req := new(model.PointCheckReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "请求参数解析失败")
	}
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}
	resp, err := h.polygonFenceService.CheckPointInIndoorFences(req.X, req.Y)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}
func (h *PolygonFenceHandler) CheckPointInOutdoorFences(c *fiber.Ctx) error {
	req := new(model.PointCheckReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "请求参数解析失败")
	}
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}
	resp, err := h.polygonFenceService.CheckPointInOutdoorFences(req.X, req.Y)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}
func (h *PolygonFenceHandler) IsPointInAnyIndoorFence(c *fiber.Ctx) error {
	req := new(model.PointCheckReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "请求参数解析失败")
	}
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}
	isInside, err := h.polygonFenceService.IsPointInAnyIndoorFence(req.X, req.Y)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, map[string]bool{"is_inside": isInside})
}
func (h *PolygonFenceHandler) IsPointInAnyOutdoorFence(c *fiber.Ctx) error {
	req := new(model.PointCheckReq)
	if err := c.BodyParser(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, "请求参数解析失败")
	}
	if err := utils.ValidateStruct(req); err != nil {
		return utils.SendErrorResponse(c, fiber.StatusBadRequest, err.Error())
	}
	isInside, err := h.polygonFenceService.IsPointInAnyOutdoorFence(req.X, req.Y)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, map[string]bool{"is_inside": isInside})
}
package utils
import (
	"net/http"
	"time"
	"github.com/gofiber/fiber/v2"
)
type Response struct {
	Success    bool           `json:"success"`
	Data       any            `json:"data,omitempty"`
	Message    string         `json:"message,omitempty"`
	Error      *ErrorObj      `json:"error,omitempty"`
	Pagination *PaginationObj `json:"pagination,omitempty"`
	Timestamp  time.Time      `json:"timestamp"`
}
type ErrorObj struct {
	Code    string `json:"code"`
	Message string `json:"message"`
	Details any    `json:"details,omitempty"`
}
type PaginationObj struct {
	CurrentPage  int   `json:"currentPage"`
	TotalPages   int   `json:"totalPages"`
	TotalItems   int64 `json:"totalItems"`
	ItemsPerPage int   `json:"itemsPerPage"`
	HasNext      bool  `json:"has_next"`
	HasPrev      bool  `json:"has_prev"`
}
func SendSuccessResponse(c *fiber.Ctx, data any, msg ...string) error {
	message := "请求成功啦😁"
	if len(msg) > 0 {
		message = msg[0]
	}
	return c.Status(http.StatusOK).JSON(Response{
		Success:   true,
		Data:      data,
		Message:   message,
		Timestamp: time.Now(),
	})
}
func SendCreatedResponse(c *fiber.Ctx, data any, msg ...string) error {
	message := "创建成功啦✌️"
	if len(msg) > 0 {
		message = msg[0]
	}
	return c.Status(http.StatusOK).JSON(Response{
		Success:   true,
		Data:      data,
		Message:   message,
		Timestamp: time.Now(),
	})
}
func SendPaginatedResponse(c *fiber.Ctx, data any, total int64, page, perPage int, msg ...string) error {
	message := "请求成功啦😁"
	if len(msg) > 0 {
		message = msg[0]
	}
	pagination := NewPagination(total, page, perPage)
	return c.Status(http.StatusOK).JSON(Response{
		Success:    true,
		Data:       data,
		Message:    message,
		Pagination: pagination,
		Timestamp:  time.Now(),
	})
}
func SendErrorResponse(c *fiber.Ctx, statusCode int, message string) error {
	return c.Status(http.StatusOK).JSON(Response{
		Success:   false,
		Message:   message,
		Timestamp: time.Now(),
	})
}
func SendErrorResponseWithData(c *fiber.Ctx, statusCode int, message string, data any) error {
	return c.Status(http.StatusOK).JSON(Response{
		Success: false,
		Message: message,
		Data:    data,
	})
}
func NewPagination(total int64, page, perPage int) *PaginationObj {
	if perPage <= 0 {
		perPage = 10
	}
	totalPages := int((total + int64(perPage) - 1) / int64(perPage))
	return &PaginationObj{
		CurrentPage:  page,
		TotalPages:   totalPages,
		TotalItems:   total,
		ItemsPerPage: perPage,
		HasNext:      page < totalPages,
		HasPrev:      page > 1,
	}
}
package service
import (
	"IOT-Manage-System/mark-service/model"
	"IOT-Manage-System/mark-service/repo"
	"time"
)
type MarkService interface {
	CreateMark(mark *model.MarkRequest) error
	GetMarkByID(id string, preload bool) (*model.MarkResponse, error)
	GetMarkByDeviceID(deviceID string, preload bool) (*model.MarkResponse, error)
	ListMark(page, limit int, preload bool) ([]model.MarkResponse, int64, error)
	UpdateMark(ID string, req *model.MarkUpdateRequest) error
	DeleteMark(id string) error
	UpdateMarkLastOnline(deviceID string, t time.Time) error
	GetPersistMQTTByDeviceID(deviceID string) (bool, error)
	GetMarksByPersistMQTT(persist bool, page, limit int, preload bool) ([]model.MarkResponse, int64, error)
	GetDeviceIDsByPersistMQTT(persist bool) ([]string, error)
	GetAllDeviceIDToName() (map[string]string, error)
	GetAllMarkIDToName() (map[string]string, error)
	GetMarkSafeDistance(markID string) (*float64, error)
	GetMarkSafeDistanceByDeviceID(deviceID string) (*float64, error)
	CreateMarkTag(mt *model.MarkTagRequest) error
	GetMarkTagByID(id int) (*model.MarkTagResponse, error)
	GetMarkTagByName(name string) (*model.MarkTagResponse, error)
	ListMarkTags(page, limit int) ([]model.MarkTagResponse, int64, error)
	UpdateMarkTag(id int, mt *model.MarkTagRequest) error
	DeleteMarkTag(id int) error
	GetMarksByTagID(tagID int, page, limit int, preload bool) ([]model.MarkResponse, int64, error)
	GetMarksByTagName(tagName string, page, limit int, preload bool) ([]model.MarkResponse, int64, error)
	GetAllTagIDToName() (map[int]string, error)
	CreateMarkType(mt *model.MarkTypeCreateRequest) error
	GetMarkTypeByID(id int) (*model.MarkTypeResponse, error)
	GetMarkTypeByName(name string) (*model.MarkTypeResponse, error)
	ListMarkTypes(page, limit int) ([]model.MarkTypeResponse, int64, error)
	UpdateMarkType(typeID int, mt *model.MarkTypeUpdateRequest) error
	DeleteMarkType(id int) error
	GetMarksByTypeID(typeID int, page, limit int, preload bool) ([]model.MarkResponse, int64, error)
	GetMarksByTypeName(typeName string, page, limit int, preload bool) ([]model.MarkResponse, int64, error)
	GetAllTypeIDToName() (map[int]string, error)
}
type markService struct {
	repo repo.MarkRepo
}
func NewMarkService(repo repo.MarkRepo) MarkService {
	return &markService{repo: repo}
}
package service
import (
	"errors"
	"fmt"
	"regexp"
	"strings"
	"IOT-Manage-System/map-service/errs"
	"IOT-Manage-System/map-service/model"
	"IOT-Manage-System/map-service/repo"
	"github.com/google/uuid"
	"gorm.io/gorm"
)
type PolygonFenceService struct {
	polygonFenceRepo *repo.PolygonFenceRepo
}
func NewPolygonFenceService(repo *repo.PolygonFenceRepo) *PolygonFenceService {
	return &PolygonFenceService{polygonFenceRepo: repo}
}
func (s *PolygonFenceService) CreatePolygonFence(req *model.PolygonFenceCreateReq) error {
	if err := s.validatePolygon(req.Points); err != nil {
		return err
	}
	wkt := s.pointsToWKT(req.Points)
	fence := &model.PolygonFence{
		IsIndoor:    req.IsIndoor,
		FenceName:   req.FenceName,
		Geometry:    wkt,
		Description: req.Description,
		IsActive:    true,
	}
	if err := s.polygonFenceRepo.Create(fence); err != nil {
		return s.translateRepoErr(err, "PolygonFence")
	}
	return nil
}
func (s *PolygonFenceService) GetPolygonFence(id string) (*model.PolygonFenceResp, error) {
	uid, err := uuid.Parse(id)
	if err != nil {
		return nil, errs.ErrInvalidID.WithDetails("无效的围栏ID")
	}
	fence, err := s.polygonFenceRepo.GetByID(uid)
	if err != nil {
		return nil, s.translateRepoErr(err, "PolygonFence")
	}
	return s.fenceToResp(fence), nil
}
func (s *PolygonFenceService) ListPolygonFences(activeOnly bool) ([]model.PolygonFenceResp, error) {
	var fences []model.PolygonFence
	var err error
	if activeOnly {
		fences, err = s.polygonFenceRepo.ListActive()
	} else {
		fences, err = s.polygonFenceRepo.ListAll()
	}
	if err != nil {
		return nil, s.translateRepoErr(err, "PolygonFence")
	}
	if len(fences) == 0 {
		return []model.PolygonFenceResp{}, nil
	}
	resp := make([]model.PolygonFenceResp, 0, len(fences))
	for i := range fences {
		resp = append(resp, *s.fenceToResp(&fences[i]))
	}
	return resp, nil
}
func (s *PolygonFenceService) ListIndoorFences(activeOnly bool) ([]model.PolygonFenceResp, error) {
	var fences []model.PolygonFence
	var err error
	if activeOnly {
		fences, err = s.polygonFenceRepo.ListActiveIndoor()
	} else {
		fences, err = s.polygonFenceRepo.ListIndoor()
	}
	if err != nil {
		return nil, s.translateRepoErr(err, "PolygonFence")
	}
	if len(fences) == 0 {
		return []model.PolygonFenceResp{}, nil
	}
	resp := make([]model.PolygonFenceResp, 0, len(fences))
	for i := range fences {
		resp = append(resp, *s.fenceToResp(&fences[i]))
	}
	return resp, nil
}
func (s *PolygonFenceService) ListOutdoorFences(activeOnly bool) ([]model.PolygonFenceResp, error) {
	var fences []model.PolygonFence
	var err error
	if activeOnly {
		fences, err = s.polygonFenceRepo.ListActiveOutdoor()
	} else {
		fences, err = s.polygonFenceRepo.ListOutdoor()
	}
	if err != nil {
		return nil, s.translateRepoErr(err, "PolygonFence")
	}
	if len(fences) == 0 {
		return []model.PolygonFenceResp{}, nil
	}
	resp := make([]model.PolygonFenceResp, 0, len(fences))
	for i := range fences {
		resp = append(resp, *s.fenceToResp(&fences[i]))
	}
	return resp, nil
}
func (s *PolygonFenceService) UpdatePolygonFence(id string, req *model.PolygonFenceUpdateReq) error {
	uid, err := uuid.Parse(id)
	if err != nil {
		return errs.ErrInvalidID.WithDetails("无效的围栏ID")
	}
	fence, err := s.polygonFenceRepo.GetByID(uid)
	if err != nil {
		return s.translateRepoErr(err, "PolygonFence")
	}
	if req.IsIndoor != nil {
		fence.IsIndoor = *req.IsIndoor
	}
	if req.FenceName != nil {
		fence.FenceName = *req.FenceName
	}
	if req.Points != nil {
		if err := s.validatePolygon(*req.Points); err != nil {
			return err
		}
		fence.Geometry = s.pointsToWKT(*req.Points)
	}
	if req.Description != nil {
		fence.Description = *req.Description
	}
	if req.IsActive != nil {
		fence.IsActive = *req.IsActive
	}
	if err := s.polygonFenceRepo.UpdateByID(uid, fence); err != nil {
		return s.translateRepoErr(err, "PolygonFence")
	}
	return nil
}
func (s *PolygonFenceService) DeletePolygonFence(id string) error {
	uid, err := uuid.Parse(id)
	if err != nil {
		return errs.ErrInvalidID.WithDetails("无效的围栏ID")
	}
	if _, err := s.polygonFenceRepo.GetByID(uid); err != nil {
		return s.translateRepoErr(err, "PolygonFence")
	}
	if err := s.polygonFenceRepo.DeleteByID(uid); err != nil {
		return s.translateRepoErr(err, "PolygonFence")
	}
	return nil
}
func (s *PolygonFenceService) CheckPointInFence(fenceID string, x, y float64) (*model.PointCheckResp, error) {
	uid, err := uuid.Parse(fenceID)
	if err != nil {
		return nil, errs.ErrInvalidID.WithDetails("无效的围栏ID")
	}
	fence, err := s.polygonFenceRepo.GetByID(uid)
	if err != nil {
		return nil, s.translateRepoErr(err, "PolygonFence")
	}
	isInside, err := s.polygonFenceRepo.IsPointInFence(uid, x, y)
	if err != nil {
		return nil, errs.ErrInternal.WithDetails(err.Error())
	}
	resp := &model.PointCheckResp{
		IsInside: isInside,
	}
	if isInside {
		resp.FenceID = fence.ID.String()
		resp.FenceName = fence.FenceName
	}
	return resp, nil
}
func (s *PolygonFenceService) CheckPointInAllFences(x, y float64) (*model.PointCheckResp, error) {
	fences, err := s.polygonFenceRepo.FindFencesByPoint(x, y)
	if err != nil {
		return nil, errs.ErrInternal.WithDetails(err.Error())
	}
	resp := &model.PointCheckResp{
		IsInside: len(fences) > 0,
	}
	if len(fences) > 0 {
		resp.FenceID = fences[0].ID.String()
		resp.FenceName = fences[0].FenceName
		resp.FenceNames = make([]string, len(fences))
		for i, f := range fences {
			resp.FenceNames[i] = f.FenceName
		}
	}
	return resp, nil
}
func (s *PolygonFenceService) CheckPointInIndoorFence(fenceID string, x, y float64) (*model.PointCheckResp, error) {
	uid, err := uuid.Parse(fenceID)
	if err != nil {
		return nil, errs.ErrInvalidID.WithDetails("无效的围栏ID")
	}
	fence, err := s.polygonFenceRepo.GetByID(uid)
	if err != nil {
		return nil, s.translateRepoErr(err, "PolygonFence")
	}
	isInside, err := s.polygonFenceRepo.IsPointInIndoorFence(uid, x, y)
	if err != nil {
		return nil, errs.ErrInternal.WithDetails(err.Error())
	}
	resp := &model.PointCheckResp{
		IsInside: isInside,
	}
	if isInside {
		resp.FenceID = fence.ID.String()
		resp.FenceName = fence.FenceName
	}
	return resp, nil
}
func (s *PolygonFenceService) CheckPointInOutdoorFence(fenceID string, x, y float64) (*model.PointCheckResp, error) {
	uid, err := uuid.Parse(fenceID)
	if err != nil {
		return nil, errs.ErrInvalidID.WithDetails("无效的围栏ID")
	}
	fence, err := s.polygonFenceRepo.GetByID(uid)
	if err != nil {
		return nil, s.translateRepoErr(err, "PolygonFence")
	}
	isInside, err := s.polygonFenceRepo.IsPointInOutdoorFence(uid, x, y)
	if err != nil {
		return nil, errs.ErrInternal.WithDetails(err.Error())
	}
	resp := &model.PointCheckResp{
		IsInside: isInside,
	}
	if isInside {
		resp.FenceID = fence.ID.String()
		resp.FenceName = fence.FenceName
	}
	return resp, nil
}
func (s *PolygonFenceService) CheckPointInIndoorFences(x, y float64) (*model.PointCheckResp, error) {
	fences, err := s.polygonFenceRepo.FindIndoorFencesByPoint(x, y)
	if err != nil {
		return nil, errs.ErrInternal.WithDetails(err.Error())
	}
	resp := &model.PointCheckResp{
		IsInside: len(fences) > 0,
	}
	if len(fences) > 0 {
		resp.FenceID = fences[0].ID.String()
		resp.FenceName = fences[0].FenceName
		resp.FenceNames = make([]string, len(fences))
		for i, f := range fences {
			resp.FenceNames[i] = f.FenceName
		}
	}
	return resp, nil
}
func (s *PolygonFenceService) CheckPointInOutdoorFences(x, y float64) (*model.PointCheckResp, error) {
	fences, err := s.polygonFenceRepo.FindOutdoorFencesByPoint(x, y)
	if err != nil {
		return nil, errs.ErrInternal.WithDetails(err.Error())
	}
	resp := &model.PointCheckResp{
		IsInside: len(fences) > 0,
	}
	if len(fences) > 0 {
		resp.FenceID = fences[0].ID.String()
		resp.FenceName = fences[0].FenceName
		resp.FenceNames = make([]string, len(fences))
		for i, f := range fences {
			resp.FenceNames[i] = f.FenceName
		}
	}
	return resp, nil
}
func (s *PolygonFenceService) IsPointInAnyIndoorFence(x, y float64) (bool, error) {
	return s.polygonFenceRepo.IsPointInAnyIndoorFence(x, y)
}
func (s *PolygonFenceService) IsPointInAnyOutdoorFence(x, y float64) (bool, error) {
	return s.polygonFenceRepo.IsPointInAnyOutdoorFence(x, y)
}
func (s *PolygonFenceService) validatePolygon(points []model.Point) error {
	if len(points) < 3 {
		return errs.ErrValidationFailed.WithDetails("多边形至少需要3个顶点")
	}
	if len(points) > 10000 {
		return errs.ErrValidationFailed.WithDetails("多边形顶点数量不能超过10000")
	}
	for i := 0; i < len(points)-1; i++ {
		if points[i].X == points[i+1].X && points[i].Y == points[i+1].Y {
			return errs.ErrValidationFailed.WithDetails(fmt.Sprintf("存在重复的连续顶点: (%f, %f)", points[i].X, points[i].Y))
		}
	}
	return nil
}
func (s *PolygonFenceService) pointsToWKT(points []model.Point) string {
	coords := make([]string, len(points)+1) 
	for i, p := range points {
		coords[i] = fmt.Sprintf("%f %f", p.X, p.Y)
	}
	coords[len(points)] = fmt.Sprintf("%f %f", points[0].X, points[0].Y)
	return fmt.Sprintf("POLYGON((%s))", strings.Join(coords, ","))
}
func (s *PolygonFenceService) wktToPoints(wkt string) []model.Point {
	re := regexp.MustCompile(`POLYGON\(\((.*?)\)\)`)
	matches := re.FindStringSubmatch(wkt)
	if len(matches) < 2 {
		return []model.Point{}
	}
	coordsStr := matches[1]
	coordPairs := strings.Split(coordsStr, ",")
	points := make([]model.Point, 0, len(coordPairs)-1)
	for i := 0; i < len(coordPairs)-1; i++ {
		coords := strings.Fields(strings.TrimSpace(coordPairs[i]))
		if len(coords) == 2 {
			var x, y float64
			fmt.Sscanf(coords[0], "%f", &x)
			fmt.Sscanf(coords[1], "%f", &y)
			points = append(points, model.Point{X: x, Y: y})
		}
	}
	return points
}
func (s *PolygonFenceService) fenceToResp(fence *model.PolygonFence) *model.PolygonFenceResp {
	return &model.PolygonFenceResp{
		ID:          fence.ID.String(),
		IsIndoor:    fence.IsIndoor,
		FenceName:   fence.FenceName,
		Points:      s.wktToPoints(fence.Geometry),
		Description: fence.Description,
		IsActive:    fence.IsActive,
		CreatedAt:   fence.CreatedAt,
		UpdatedAt:   fence.UpdatedAt,
	}
}
func (s *PolygonFenceService) translateRepoErr(err error, resource string) error {
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return errs.NotFound(resource, fmt.Sprintf("%s 不存在", resource))
	}
	if strings.Contains(err.Error(), "duplicate key") {
		return errs.ErrDuplicateEntry.WithDetails("围栏名称已存在")
	}
	return errs.ErrInternal.WithDetails(err.Error())
}
package main
import (
	"log"
	"github.com/goccy/go-json"
	"github.com/gofiber/fiber/v2"
	"IOT-Manage-System/mark-service/handler"
	"IOT-Manage-System/mark-service/repo"
	"IOT-Manage-System/mark-service/service"
	"IOT-Manage-System/mark-service/utils"
)
func main() {
	app := fiber.New(fiber.Config{
		Prefork: false,
		StrictRouting: true,
		AppName:            "电子标记服务 v0.0.3",
		CaseSensitive:      true,
		DisableDefaultDate: true,
		JSONEncoder:        json.Marshal,
		JSONDecoder:        json.Unmarshal,
		ErrorHandler:       handler.CustomErrorHandler,
	})
	db, err := utils.InitDB()
	if err != nil {
		log.Fatalf("初始化数据库失败: %v", err)
	}
	defer func() {
		if err := utils.CloseDB(db); err != nil {
			log.Printf("关闭数据库失败: %v", err)
		} else {
			log.Println("数据库已正常关闭")
		}
	}()
	r1 := repo.NewMarkRepo(db)
	r2 := repo.NewMarkPairRepo(db)
	s1 := service.NewMarkService(r1)
	s2 := service.NewMarkPairService(r2, r1)
	h1 := handler.NewMarkHandler(s1)
	h2 := handler.NewMarkPairHandler(s2)
	app.Get("/health", func(c *fiber.Ctx) error {
		c.Append("status", "ok")
		return c.SendString("服务运行正常")
	})
	api := app.Group("/api") 
	v1 := api.Group("/v1")   
	mark := v1.Group("/marks")
	mark.Get("/id-to-name", h1.GetAllMarkIDToName)                                 
	mark.Get("/device/id-to-name", h1.GetAllDeviceIDToName)                        
	mark.Get("/persist/list", h1.GetMarksByPersistMQTT)                            
	mark.Get("/persist/device-ids", h1.GetDeviceIDsByPersistMQTT)                  
	mark.Get("/persist/device/:device_id", h1.GetPersistMQTTByDeviceID)            
	mark.Put("/device/:device_id/last-online", h1.UpdateMarkLastOnline)            
	mark.Get("/device/:device_id/safe-distance", h1.GetMarkSafeDistanceByDeviceID) 
	mark.Get("/device/:device_id", h1.GetMarkByDeviceID)                           
	mark.Get("/:id/safe-distance", h1.GetMarkSafeDistance)                         
	mark.Put("/:id", h1.UpdateMark)                                                
	mark.Delete("/:id", h1.DeleteMark)                                             
	mark.Get("/:id", h1.GetMarkByID)                                               
	mark.Post("/", h1.CreateMark) 
	mark.Get("/", h1.ListMark)    
	markTag := v1.Group("/tags")
	markTag.Get("/id-to-name", h1.GetAllTagIDToName)           
	markTag.Get("/name/:tag_name/marks", h1.GetMarksByTagName) 
	markTag.Get("/name/:tag_name", h1.GetMarkTagByName)        
	markTag.Get("/:tag_id/marks", h1.GetMarksByTagID)          
	markTag.Put("/:tag_id", h1.UpdateMarkTag)                  
	markTag.Delete("/:tag_id", h1.DeleteMarkTag)               
	markTag.Get("/:tag_id", h1.GetMarkTagByID)                 
	markTag.Post("/", h1.CreateMarkTag) 
	markTag.Get("/", h1.ListMarkTags)   
	markType := v1.Group("/types")
	markType.Get("/id-to-name", h1.GetAllTypeIDToName)            
	markType.Get("/name/:type_name/marks", h1.GetMarksByTypeName) 
	markType.Get("/name/:type_name", h1.GetMarkTypeByName)        
	markType.Get("/:type_id/marks", h1.GetMarksByTypeID)          
	markType.Put("/:type_id", h1.UpdateMarkType)                  
	markType.Delete("/:type_id", h1.DeleteMarkType)               
	markType.Get("/:type_id", h1.GetMarkTypeByID)                 
	markType.Post("/", h1.CreateMarkType) 
	markType.Get("/", h1.ListMarkTypes)   
	markPair := v1.Group("/pairs")
	markPair.Post("/distance", h2.SetPairDistance)                                      
	markPair.Post("/combinations", h2.SetCombinations)                                  
	markPair.Post("/cartesian", h2.SetCartesian)                                        
	markPair.Get("/distance/map/mark/device/:id", h2.DistanceMapByDeviceToDeviceIDs)    
	markPair.Get("/distance/map/device/:device_id", h2.DistanceMapByDevice)             
	markPair.Get("/distance/map/mark/:id", h2.DistanceMapByMark)                        
	markPair.Get("/distance/device/:device1_id/:device2_id", h2.GetDistanceByDeviceIDs) 
	markPair.Get("/distance/:mark1_id/:mark2_id", h2.GetDistance)                       
	markPair.Delete("/distance/:mark1_id/:mark2_id", h2.DeletePair)                     
	markPair.Get("/", h2.ListMarkPairs) 
	port := utils.GetEnv("PORT", "8004")
	if err := app.Listen(":" + port); err != nil {
		log.Fatalf("启动 HTTP 服务失败: %v", err)
	}
}
package repo
import (
	"errors"
	"fmt"
	"github.com/google/uuid"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
	"IOT-Manage-System/mark-service/model"
)
type MarkPairRepo interface {
	Upsert(mark1ID, mark2ID string, safeDistanceM float64) error
	BatchUpsert(ids []string, safeDistanceM float64) error
	CartesianUpsertByMarkIDs(m1IDs, m2IDs []string, safeDistanceM float64) error
	Get(mark1ID, mark2ID string) (float64, error)
	Delete(mark1ID, mark2ID string) error
	MapByID(id string) (map[string]float64, error)
	MapByDeviceID(deviceID string) (map[string]float64, error)
	GetByDeviceIDs(device1ID, device2ID string) (float64, error)
	MapByDeviceIDToDeviceIDs(deviceID string) (map[string]float64, error)
	ListMarkPairs(offset, limit int) ([]model.MarkPairSafeDistance, int64, error)
}
type markPairRepo struct {
	db *gorm.DB
}
func NewMarkPairRepo(db *gorm.DB) MarkPairRepo {
	return &markPairRepo{db: db}
}
func (r *markPairRepo) Upsert(mark1ID, mark2ID string, safeDistanceM float64) error {
	pair, err := normalizePair(mark1ID, mark2ID, safeDistanceM)
	if err != nil {
		return err
	}
	return r.db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "mark1_id"}, {Name: "mark2_id"}},
		UpdateAll: true,
	}).Create(&pair).Error
}
func (r *markPairRepo) BatchUpsert(ids []string, safeDistanceM float64) error {
	n := len(ids)
	if n < 2 {
		return nil 
	}
	batch := make([]model.MarkPairSafeDistance, 0, n*(n-1)/2)
	for i := 0; i < n; i++ {
		for j := i + 1; j < n; j++ { 
			pair, err := normalizePair(ids[i], ids[j], safeDistanceM)
			if err != nil {
				return err
			}
			batch = append(batch, pair)
		}
	}
	return r.db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "mark1_id"}, {Name: "mark2_id"}},
		UpdateAll: true,
	}).CreateInBatches(&batch, 200).Error
}
func (r *markPairRepo) CartesianUpsertByMarkIDs(m1IDs, m2IDs []string, safeDistanceM float64) error {
	pairMap := make(map[string]model.MarkPairSafeDistance)
	for _, id1 := range m1IDs {
		for _, id2 := range m2IDs {
			if id1 == id2 {
				continue
			}
			pair, err := normalizePair(id1, id2, safeDistanceM)
			if err != nil {
				return err
			}
			key := pair.Mark1ID.String() + ":" + pair.Mark2ID.String()
			pairMap[key] = pair
		}
	}
	pairs := make([]model.MarkPairSafeDistance, 0, len(pairMap))
	for _, pair := range pairMap {
		pairs = append(pairs, pair)
	}
	return r.db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "mark1_id"}, {Name: "mark2_id"}},
		UpdateAll: true,
	}).CreateInBatches(&pairs, 200).Error
}
func (r *markPairRepo) Get(mark1ID, mark2ID string) (float64, error) {
	id1, id2, err := mustUUIDPair(mark1ID, mark2ID)
	if err != nil {
		return 0, err
	}
	var pair model.MarkPairSafeDistance
	if err := r.db.Where("mark1_id = ? AND mark2_id = ?", id1, id2).First(&pair).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return 0, nil 
		}
		return 0, err
	}
	return pair.DistanceM, nil
}
func (r *markPairRepo) Delete(mark1ID, mark2ID string) error {
	id1, id2, err := mustUUIDPair(mark1ID, mark2ID)
	if err != nil {
		return err
	}
	return r.db.Where("mark1_id = ? AND mark2_id = ?", id1, id2).Delete(&model.MarkPairSafeDistance{}).Error
}
func (r *markPairRepo) MapByID(id string) (map[string]float64, error) {
	uid, err := uuid.Parse(id)
	if err != nil {
		return nil, fmt.Errorf("invalid mark id: %w", err)
	}
	var list []struct {
		OtherID   uuid.UUID
		DistanceM float64
	}
	if err := r.db.Raw(`
		SELECT mark2_id AS other_id, distance_m FROM mark_pair_safe_distance WHERE mark1_id = ?
		UNION ALL
		SELECT mark1_id AS other_id, distance_m FROM mark_pair_safe_distance WHERE mark2_id = ?
	`, uid, uid).Scan(&list).Error; err != nil {
		return nil, err
	}
	m := make(map[string]float64, len(list))
	for _, v := range list {
		m[v.OtherID.String()] = v.DistanceM
	}
	return m, nil
}
func (r *markPairRepo) MapByDeviceID(deviceID string) (map[string]float64, error) {
	var id string
	if err := r.db.Model(&model.Mark{}).Where("device_id = ?", deviceID).Select("id").Scan(&id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return map[string]float64{}, nil
		}
		return nil, err
	}
	return r.MapByID(id)
}
func (r *markPairRepo) GetByDeviceIDs(device1ID, device2ID string) (float64, error) {
	var mark1ID, mark2ID string
	if err := r.db.Model(&model.Mark{}).Where("device_id = ?", device1ID).Select("id").Scan(&mark1ID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return 0, nil 
		}
		return 0, err
	}
	if err := r.db.Model(&model.Mark{}).Where("device_id = ?", device2ID).Select("id").Scan(&mark2ID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return 0, nil 
		}
		return 0, err
	}
	return r.Get(mark1ID, mark2ID)
}
func (r *markPairRepo) MapByDeviceIDToDeviceIDs(deviceID string) (map[string]float64, error) {
	var markID string
	if err := r.db.Model(&model.Mark{}).Where("device_id = ?", deviceID).Select("id").Scan(&markID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return map[string]float64{}, nil
		}
		return nil, err
	}
	markDistanceMap, err := r.MapByID(markID)
	if err != nil {
		return nil, err
	}
	deviceDistanceMap := make(map[string]float64)
	for markID, distance := range markDistanceMap {
		var otherDeviceID string
		if err := r.db.Model(&model.Mark{}).Where("id = ?", markID).Select("device_id").Scan(&otherDeviceID).Error; err != nil {
			continue 
		}
		deviceDistanceMap[otherDeviceID] = distance
	}
	return deviceDistanceMap, nil
}
func (r *markPairRepo) ListMarkPairs(offset, limit int) ([]model.MarkPairSafeDistance, int64, error) {
	var pairs []model.MarkPairSafeDistance
	var total int64
	if err := r.db.Model(&model.MarkPairSafeDistance{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}
	err := r.db.Offset(offset).Limit(limit).Find(&pairs).Error
	return pairs, total, err
}
func normalizePair(id1, id2 string, distance float64) (model.MarkPairSafeDistance, error) {
	uid1, err := uuid.Parse(id1)
	if err != nil {
		return model.MarkPairSafeDistance{}, fmt.Errorf("invalid mark1ID: %w", err)
	}
	uid2, err := uuid.Parse(id2)
	if err != nil {
		return model.MarkPairSafeDistance{}, fmt.Errorf("invalid mark2ID: %w", err)
	}
	if uid1.String() > uid2.String() {
		uid1, uid2 = uid2, uid1
	}
	return model.MarkPairSafeDistance{Mark1ID: uid1, Mark2ID: uid2, DistanceM: distance}, nil
}
func mustUUIDPair(id1, id2 string) (uuid.UUID, uuid.UUID, error) {
	uid1, err := uuid.Parse(id1)
	if err != nil {
		return uuid.UUID{}, uuid.UUID{}, fmt.Errorf("invalid mark1ID: %w", err)
	}
	uid2, err := uuid.Parse(id2)
	if err != nil {
		return uuid.UUID{}, uuid.UUID{}, fmt.Errorf("invalid mark2ID: %w", err)
	}
	if uid1.String() > uid2.String() {
		uid1, uid2 = uid2, uid1
	}
	return uid1, uid2, nil
}
package repo
import (
	"errors"
	"time"
	"IOT-Manage-System/mark-service/model"
	"gorm.io/gorm"
)
func (r *markRepo) CreateMark(mark *model.Mark) error {
	return r.db.Create(mark).Error
}
func (r *markRepo) CreateMarkAutoTag(mark *model.Mark, tagNames []string) error {
	if len(tagNames) > 0 {
		tags, err := r.getOrCreateTags(tagNames)
		if err != nil {
			return err
		}
		mark.Tags = tags
	}
	return r.db.Create(mark).Error
}
func (r *markRepo) GetMarkByID(id string, preload bool) (*model.Mark, error) {
	q := r.db
	if preload {
		q = q.Preload("MarkType").Preload("Tags")
	}
	var mark model.Mark
	err := q.First(&mark, "id = ?", id).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &mark, err
}
func (r *markRepo) GetMarkByDeviceID(deviceID string, preload bool) (*model.Mark, error) {
	q := r.db
	if preload {
		q = q.Preload("MarkType").Preload("Tags")
	}
	var mark model.Mark
	err := q.Where("device_id = ?", deviceID).First(&mark).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	return &mark, err
}
func (r *markRepo) ListMark(offset, limit int, preload bool) ([]model.Mark, error) {
	q := r.db
	if preload {
		q = q.Preload("MarkType").Preload("Tags")
	}
	q = q.Offset(offset).Limit(limit)
	var marks []model.Mark
	err := q.Find(&marks).Error
	return marks, err
}
func (r *markRepo) ListMarkWithCount(offset, limit int, preload bool) ([]model.Mark, int64, error) {
	q := r.db
	if preload {
		q = q.Preload("MarkType").Preload("Tags")
	}
	var marks []model.Mark
	var total int64
	if err := q.Model(&model.Mark{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}
	q = q.Offset(offset).Limit(limit).Order("created_at DESC")
	err := q.Find(&marks).Error
	return marks, total, err
}
func (r *markRepo) UpdateMark(mark *model.Mark, tagNames []string) error {
	if err := r.db.Model(&model.Mark{}).
		Where("id = ?", mark.ID).
		Updates(map[string]interface{}{
			"mark_name":       mark.MarkName,
			"device_id":       mark.DeviceID,
			"mqtt_topic":      mark.MqttTopic,
			"persist_mqtt":    mark.PersistMQTT,
			"safe_distance_m": mark.SafeDistanceM,
			"mark_type_id":    mark.MarkTypeID,
		}).Error; err != nil {
		return err
	}
	if tagNames != nil {
		tags, err := r.getOrCreateTags(tagNames)
		if err != nil {
			return err
		}
		var fresh model.Mark
		if err := r.db.First(&fresh, mark.ID).Error; err != nil {
			return err
		}
		return r.db.Model(&fresh).Association("Tags").Replace(tags)
	}
	return nil
}
func (r *markRepo) DeleteMark(id string) error {
	return r.db.Delete(&model.Mark{}, "id = ?", id).Error
}
func (r *markRepo) UpdateMarkLastOnline(deviceID string, t time.Time) error {
	return r.db.Model(&model.Mark{}).
		Where("device_id = ?", deviceID).
		Update("last_online_at", t).Error
}
func (r *markRepo) getOrCreateTags(names []string) ([]model.MarkTag, error) {
	var tags []model.MarkTag
	for _, name := range names {
		if name == "" {
			continue 
		}
		var tag model.MarkTag
		err := r.db.Where("tag_name = ?", name).Assign(model.MarkTag{TagName: name}).FirstOrCreate(&tag).Error
		if err != nil {
			return nil, err
		}
		tags = append(tags, tag)
	}
	return tags, nil
}
func (r *markRepo) GetMarksByTagID(tagID int, preload bool, offset, limit int) ([]model.Mark, int64, error) {
	var tag model.MarkTag
	if err := r.db.First(&tag, tagID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, 0, nil
		}
		return nil, 0, err
	}
	query := r.db.Model(&model.Mark{}).
		Joins("JOIN mark_tag_relation ON marks.id = mark_tag_relation.mark_id").
		Where("mark_tag_relation.tag_id = ?", tagID)
	if preload {
		query = query.Preload("MarkType").Preload("Tags")
	}
	var total int64
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}
	var marks []model.Mark
	if err := query.Offset(offset).Limit(limit).Find(&marks).Error; err != nil {
		return nil, 0, err
	}
	return marks, total, nil
}
func (r *markRepo) GetMarksByTagName(tagName string, preload bool, offset, limit int) ([]model.Mark, int64, error) {
	var tag model.MarkTag
	if err := r.db.Where("tag_name = ?", tagName).First(&tag).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, 0, nil 
		}
		return nil, 0, err
	}
	return r.GetMarksByTagID(int(tag.ID), preload, offset, limit)
}
func (r *markRepo) GetMarksByTypeID(typeID int, preload bool, offset, limit int) ([]model.Mark, int64, error) {
	var markType model.MarkType
	if err := r.db.First(&markType, typeID).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, 0, nil
		}
		return nil, 0, err
	}
	query := r.db.Model(&model.Mark{}).Where("mark_type_id = ?", typeID)
	if preload {
		query = query.Preload("MarkType").Preload("Tags")
	}
	var total int64
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}
	var marks []model.Mark
	if err := query.Offset(offset).Limit(limit).Find(&marks).Error; err != nil {
		return nil, 0, err
	}
	return marks, total, nil
}
func (r *markRepo) GetMarksByTypeName(typeName string, preload bool, offset, limit int) ([]model.Mark, int64, error) {
	var markType model.MarkType
	if err := r.db.Where("type_name = ?", typeName).First(&markType).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, 0, nil 
		}
		return nil, 0, err
	}
	return r.GetMarksByTypeID(int(markType.ID), preload, offset, limit)
}
func (r *markRepo) GetMarksByPersistMQTT(persist bool, preload bool, offset, limit int) ([]model.Mark, int64, error) {
	var marks []model.Mark
	var total int64
	db := r.db
	if preload {
		db = db.Preload("MarkType").Preload("Tags")
	}
	if err := db.Model(&model.Mark{}).Where("persist_mqtt = ?", persist).Count(&total).Error; err != nil {
		return nil, 0, err
	}
	result := db.Where("persist_mqtt = ?", persist).
		Offset(offset).
		Limit(limit).
		Order("created_at DESC"). 
		Find(&marks)
	if result.Error != nil {
		return nil, 0, result.Error
	}
	return marks, total, nil
}
func (r *markRepo) GetPersistMQTTByDeviceID(deviceID string) (bool, error) {
	var persist bool
	result := r.db.Model(&model.Mark{}).
		Select("persist_mqtt").
		Where("device_id = ?", deviceID).
		First(&persist)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return false, nil
		}
		return false, result.Error
	}
	return persist, nil
}
func (r *markRepo) GetDeviceIDsByPersistMQTT(persist bool) ([]string, error) {
	var deviceIDs []string
	result := r.db.Model(&model.Mark{}).
		Select("device_id").
		Where("persist_mqtt = ?", persist).
		Pluck("device_id", &deviceIDs)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, result.Error
	}
	return deviceIDs, nil
}
func (r *markRepo) GetAllMarkDeviceIDsAndNames() (map[string]string, error) {
	rows := make([]struct {
		DeviceID string
		Name     string
	}, 0)
	if err := r.db.Model(&model.Mark{}).
		Select("device_id", "mark_name as name").
		Scan(&rows).Error; err != nil {
		return nil, err
	}
	out := make(map[string]string, len(rows))
	for _, v := range rows {
		out[v.DeviceID] = v.Name
	}
	return out, nil
}
func (r *markRepo) GetAllMarkIDsAndNames() (map[string]string, error) {
	rows := make([]struct {
		ID   string
		Name string
	}, 0)
	if err := r.db.Model(&model.Mark{}).
		Select("id", "mark_name as name").
		Scan(&rows).Error; err != nil {
		return nil, err
	}
	out := make(map[string]string, len(rows))
	for _, v := range rows {
		out[v.ID] = v.Name
	}
	return out, nil
}
func (r *markRepo) GetMarkSafeDistance(markID string) (*float64, error) {
	var safeDistance *float64
	err := r.db.Model(&model.Mark{}).
		Select("safe_distance_m").
		Where("id = ?", markID).
		Scan(&safeDistance).Error
	if err != nil {
		return nil, err
	}
	return safeDistance, nil
}
func (r *markRepo) GetMarkSafeDistanceByDeviceID(deviceID string) (*float64, error) {
	var safeDistance *float64
	err := r.db.Model(&model.Mark{}).
		Select("safe_distance_m").
		Where("device_id = ?", deviceID).
		Scan(&safeDistance).Error
	if err != nil {
		return nil, err
	}
	return safeDistance, nil
}
package handler
import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/utils"
	"github.com/gofiber/fiber/v2"
	"time"
)
func CustomErrorHandler(c *fiber.Ctx, err error) error {
	code := "INTERNAL_ERROR"
	message := err.Error()
	var details any
	if appErr, ok := err.(*errs.AppError); ok {
		code = appErr.Code
		message = appErr.Message
		details = appErr.Details
	}
	if e, ok := err.(*fiber.Error); ok {
		message = e.Message
	}
	resp := utils.Response{
		Success:   false,
		Message:   message,
		Error:     &utils.ErrorObj{Code: code, Message: message, Details: details},
		Timestamp: time.Now(),
	}
	return c.Status(200).JSON(resp)
}
package repo
import (
	"errors"
	"IOT-Manage-System/mark-service/model"
	"gorm.io/gorm"
)
func (r *markRepo) CreateMarkTag(mt *model.MarkTag) error {
	return r.db.Create(mt).Error
}
func (r *markRepo) GetMarkTagByID(id int) (*model.MarkTag, error) {
	var tag model.MarkTag
	err := r.db.First(&tag, id).Error
	if err != nil {
		return nil, err
	}
	return &tag, nil
}
func (r *markRepo) GetMarkTagByName(name string) (*model.MarkTag, error) {
	var tag model.MarkTag
	err := r.db.Where("tag_name = ?", name).First(&tag).Error
	if err != nil {
		return nil, err
	}
	return &tag, nil
}
func (r *markRepo) ListMarkTags(offset, limit int) ([]model.MarkTag, error) {
	var tags []model.MarkTag
	err := r.db.Offset(offset).Limit(limit).Find(&tags).Error
	return tags, err
}
func (r *markRepo) UpdateMarkTag(tag *model.MarkTag) error {
	return r.db.Save(tag).Error
}
func (r *markRepo) DeleteMarkTag(id int) error {
	return r.db.Delete(&model.MarkTag{}, id).Error
}
func (r *markRepo) FindTagsByNames(names []string) ([]model.MarkTag, []string, error) {
	if len(names) == 0 {
		return nil, nil, nil
	}
	var existingTags []model.MarkTag
	err := r.db.Where("tag_name IN ?", names).Find(&existingTags).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, names, nil
		}
		return nil, nil, err
	}
	foundNamesMap := make(map[string]bool)
	for _, tag := range existingTags {
		foundNamesMap[tag.TagName] = true
	}
	var notFound []string
	for _, name := range names {
		if !foundNamesMap[name] {
			notFound = append(notFound, name)
		}
	}
	return existingTags, notFound, nil
}
func (r *markRepo) GetOrCreateTags(names []string) ([]model.MarkTag, error) {
	var tags []model.MarkTag
	for _, name := range names {
		if name == "" {
			continue 
		}
		var tag model.MarkTag
		err := r.db.Where("tag_name = ?", name).Assign(model.MarkTag{TagName: name}).FirstOrCreate(&tag).Error
		if err != nil {
			return nil, err
		}
		tags = append(tags, tag)
	}
	return tags, nil
}
func (r *markRepo) ListMarkTagsWithCount(offset, limit int) ([]model.MarkTag, int64, error) {
	var tags []model.MarkTag
	var total int64
	if err := r.db.Model(&model.MarkTag{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}
	err := r.db.Offset(offset).Limit(limit).Find(&tags).Error
	return tags, total, err
}
func (r *markRepo) GetMarkIDsByTagID(tagID int) ([]string, error) {
	var markIDs []string
	err := r.db.Table("mark_tag_relation").
		Where("tag_id = ?", tagID).
		Pluck("mark_id", &markIDs).Error
	if err != nil {
		return nil, err
	}
	return markIDs, nil
}
func (r *markRepo) GetAllTagIDsAndNames() (map[int]string, error) {
	rows := make([]struct {
		ID   int
		Name string
	}, 0)
	if err := r.db.Model(&model.MarkTag{}).
		Select("id", "tag_name as name").
		Scan(&rows).Error; err != nil {
		return nil, err
	}
	out := make(map[int]string, len(rows))
	for _, v := range rows {
		out[v.ID] = v.Name
	}
	return out, nil
}
package handler
import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
	"IOT-Manage-System/mark-service/service"
	"IOT-Manage-System/mark-service/utils"
	"github.com/gofiber/fiber/v2"
	"time"
)
type MarkHandler struct {
	markService service.MarkService
}
func NewMarkHandler(markService service.MarkService) *MarkHandler {
	return &MarkHandler{markService: markService}
}
func (h *MarkHandler) CreateMark(c *fiber.Ctx) error {
	var req model.MarkRequest
	if err := c.BodyParser(&req); err != nil {
		return errs.ErrInvalidInput
	}
	if appErr := h.markService.CreateMark(&req); appErr != nil {
		return appErr
	}
	return utils.SendCreatedResponse(c, nil, "标记创建成功")
}
func (h *MarkHandler) GetMarkByID(c *fiber.Ctx) error {
	id := c.Params("id")
	preload := c.Query("preload", "false") == "true"
	mark, appErr := h.markService.GetMarkByID(id, preload)
	if appErr != nil {
		return appErr
	}
	return utils.SendSuccessResponse(c, mark)
}
func (h *MarkHandler) GetMarkByDeviceID(c *fiber.Ctx) error {
	deviceID := c.Params("device_id")
	preload := c.Query("preload", "false") == "true"
	mark, appErr := h.markService.GetMarkByDeviceID(deviceID, preload)
	if appErr != nil {
		return appErr
	}
	return utils.SendSuccessResponse(c, mark)
}
func (h *MarkHandler) ListMark(c *fiber.Ctx) error {
	page := c.QueryInt("page", 1)
	if page < 1 {
		page = 1
	}
	limit := c.QueryInt("limit", 10)
	if limit < 1 {
		limit = 10
	}
	if limit > 100 {
		limit = 100 
	}
	preload := c.Query("preload", "false") == "true"
	marks, total, appErr := h.markService.ListMark(page, limit, preload)
	if appErr != nil {
		return appErr
	}
	return utils.SendPaginatedResponse(c, marks, total, page, limit)
}
func (h *MarkHandler) UpdateMark(c *fiber.Ctx) error {
	id := c.Params("id")
	var req model.MarkUpdateRequest
	if err := c.BodyParser(&req); err != nil {
		return errs.ErrInvalidInput
	}
	if appErr := h.markService.UpdateMark(id, &req); appErr != nil {
		return appErr
	}
	return utils.SendSuccessResponse(c, nil, "标记更新成功")
}
func (h *MarkHandler) DeleteMark(c *fiber.Ctx) error {
	id := c.Params("id")
	if appErr := h.markService.DeleteMark(id); appErr != nil {
		return appErr
	}
	return utils.SendSuccessResponse(c, nil, "标记删除成功")
}
func (h *MarkHandler) UpdateMarkLastOnline(c *fiber.Ctx) error {
	deviceID := c.Params("device_id")
	if deviceID == "" {
		return errs.ErrInvalidInput.WithDetails("device_id 不能为空")
	}
	if err := h.markService.UpdateMarkLastOnline(deviceID, time.Now()); err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, nil, "标记最后在线时间更新成功")
}
func (h *MarkHandler) GetPersistMQTTByDeviceID(c *fiber.Ctx) error {
	deviceID := c.Params("device_id")
	if deviceID == "" {
		return errs.ErrInvalidInput.WithDetails("device_id 参数不能为空")
	}
	persist, err := h.markService.GetPersistMQTTByDeviceID(deviceID)
	if err != nil {
		return err 
	}
	return utils.SendSuccessResponse(c, persist)
}
func (h *MarkHandler) GetMarksByPersistMQTT(c *fiber.Ctx) error {
	persistStr := c.Query("persist")
	if persistStr == "" {
		return errs.ErrInvalidInput.WithDetails("缺少查询参数 'persist' (true/false)")
	}
	persist := persistStr == "true"
	page := c.QueryInt("page", 1)
	if page < 1 {
		page = 1
	}
	limit := c.QueryInt("limit", 10)
	if limit < 1 {
		limit = 10
	}
	if limit > 100 {
		limit = 100 
	}
	preload := c.Query("preload", "false") == "true"
	marks, total, err := h.markService.GetMarksByPersistMQTT(persist, page, limit, preload)
	if err != nil {
		return err
	}
	return utils.SendPaginatedResponse(c, marks, total, page, limit)
}
func (h *MarkHandler) GetDeviceIDsByPersistMQTT(c *fiber.Ctx) error {
	persistStr := c.Query("persist")
	if persistStr == "" {
		return errs.ErrInvalidInput.WithDetails("缺少查询参数 'persist' (true/false)")
	}
	persist := persistStr == "true"
	deviceIDs, err := h.markService.GetDeviceIDsByPersistMQTT(persist)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, deviceIDs)
}
func (h *MarkHandler) GetAllDeviceIDToName(c *fiber.Ctx) error {
	resp, err := h.markService.GetAllDeviceIDToName()
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}
func (h *MarkHandler) GetAllMarkIDToName(c *fiber.Ctx) error {
	resp, err := h.markService.GetAllMarkIDToName()
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}
func (h *MarkHandler) GetMarkSafeDistance(c *fiber.Ctx) error {
	markID := c.Params("id")
	safeDistance, err := h.markService.GetMarkSafeDistance(markID)
	if err != nil {
		return err
	}
	response := map[string]interface{}{
		"mark_id":       markID,
		"danger_zone_m": safeDistance,
	}
	return utils.SendSuccessResponse(c, response)
}
func (h *MarkHandler) GetMarkSafeDistanceByDeviceID(c *fiber.Ctx) error {
	deviceID := c.Params("device_id")
	safeDistance, err := h.markService.GetMarkSafeDistanceByDeviceID(deviceID)
	if err != nil {
		return err
	}
	response := map[string]interface{}{
		"device_id":     deviceID,
		"danger_zone_m": safeDistance,
	}
	return utils.SendSuccessResponse(c, response)
}
package model
import (
	"time"
)
type MarkTypeResponse struct {
	ID                 int      `json:"id"`
	TypeName           string   `json:"type_name"`
	DefaultDangerZoneM *float64 `json:"default_danger_zone_m,omitempty"`
}
type MarkTagResponse struct {
	ID      int    `json:"id"`
	TagName string `json:"tag_name"`
}
type MarkResponse struct {
	ID           string            `json:"id"`
	DeviceID     string            `json:"device_id"`
	MarkName     string            `json:"mark_name"`
	MqttTopic    []string          `json:"mqtt_topic"`
	PersistMQTT  bool              `json:"persist_mqtt"`
	DangerZoneM  *float64          `json:"danger_zone_m"`
	MarkType     *MarkTypeResponse `json:"mark_type"` 
	Tags         []MarkTagResponse `json:"tags"`      
	CreatedAt    time.Time         `json:"created_at"`
	UpdatedAt    time.Time         `json:"updated_at"`
	LastOnlineAt *time.Time        `json:"last_online_at"`
}
type MarkPairResponse struct {
	Mark1ID   string  `json:"mark1_id"`
	Mark2ID   string  `json:"mark2_id"`
	DistanceM float64 `json:"distance_m"`
}
package model
type MarkTypeCreateRequest struct {
	TypeName             string   `json:"type_name" validate:"required,max=255"`
	DefaultSafeDistanceM *float64 `json:"default_danger_zone_m"`
}
type MarkTypeUpdateRequest struct {
	TypeName             *string  `json:"type_name" validate:"omitempty,max=255"`
	DefaultSafeDistanceM *float64 `json:"default_danger_zone_m"`
}
type MarkTagRequest struct {
	TagName string `json:"tag_name" validate:"required,max=255"`
}
type MarkRequest struct {
	DeviceID      string   `json:"device_id" validate:"required,max=255"`
	MarkName      string   `json:"mark_name" validate:"required,max=255"`
	MqttTopic     []string `json:"mqtt_topic" validate:"max=65535"`
	PersistMQTT   *bool    `json:"persist_mqtt,omitempty"`
	SafeDistanceM *float64 `json:"danger_zone_m,omitempty"`
	MarkTypeID    *int     `json:"mark_type_id,omitempty"`
	Tags          []string `json:"tags,omitempty"`
}
type MarkUpdateRequest struct {
	DeviceID      *string  `json:"device_id,omitempty" validate:"omitempty,max=255"`
	MarkName      *string  `json:"mark_name,omitempty" validate:"omitempty,max=255"`
	MqttTopic     []string `json:"mqtt_topic,omitempty" validate:"omitempty,max=65535"`
	PersistMQTT   *bool    `json:"persist_mqtt,omitempty"`
	SafeDistanceM *float64 `json:"danger_zone_m,omitempty"`
	MarkTypeID    *int     `json:"mark_type_id,omitempty"`
	Tags          []string `json:"tags,omitempty"`
}
type TypedID struct {
	Kind   string `json:"kind" validate:"required,oneof=mark tag type"`
	MarkID string `json:"mark_id,omitempty" validate:"omitempty,max=36,len=36"`
	TagID  int    `json:"tag_id,omitempty" validate:"omitempty,min=1"`
	TypeID int    `json:"type_id,omitempty" validate:"omitempty,min=1"`
}
type SetDistanceTypedReq struct {
	First    TypedID `json:"first" validate:"required"`
	Second   TypedID `json:"second" validate:"required"`
	Distance float64 `json:"distance" validate:"required,min=0"`
}
type SetDistanceMarkReq struct {
	Mark1ID  string  `json:"mark1_id" validate:"required,uuid"`
	Mark2ID  string  `json:"mark2_id" validate:"required,uuid"`
	Distance float64 `json:"distance" validate:"required,min=0"`
}
package model
import (
	"time"
	"github.com/google/uuid"
	"github.com/lib/pq"
	"gorm.io/gorm"
)
type MarkType struct {
	ID                   int      `gorm:"primaryKey;autoIncrement;column:id"`        
	TypeName             string   `gorm:"unique;size:255;not null;column:type_name"` 
	DefaultSafeDistanceM *float64 `gorm:"column:default_safe_distance_m;default:-1"` 
	Marks []Mark `gorm:"foreignKey:MarkTypeID;references:ID"`
}
func (MarkType) TableName() string { return "mark_types" }
type MarkTag struct {
	ID      int    `gorm:"primaryKey;autoIncrement;column:id"`       
	TagName string `gorm:"unique;size:255;not null;column:tag_name"` 
	Marks []Mark `gorm:"many2many:mark_tag_relation;foreignKey:ID;joinForeignKey:TagID;references:ID;joinReferences:MarkID"`
}
func (MarkTag) TableName() string { return "mark_tags" }
type Mark struct {
	ID            uuid.UUID      `gorm:"primaryKey;type:uuid;default:gen_random_uuid();column:id"` 
	DeviceID      string         `gorm:"unique;size:255;not null;column:device_id"`                
	MarkName      string         `gorm:"size:255;not null;column:mark_name"`                       
	MqttTopic     pq.StringArray `gorm:"type:text[];not null;default:'{}';column:mqtt_topic"`      
	PersistMQTT   bool           `gorm:"not null;default:false;column:persist_mqtt"`               
	SafeDistanceM *float64       `gorm:"column:safe_distance_m"`                                   
	MarkTypeID    int            `gorm:"not null;column:mark_type_id"`                             
	CreatedAt     time.Time      `gorm:"not null;default:now();column:created_at"`                 
	UpdatedAt     time.Time      `gorm:"not null;default:now();column:updated_at"`                 
	LastOnlineAt  *time.Time     `gorm:"column:last_online_at"`                                    
	MarkType MarkType `gorm:"foreignKey:MarkTypeID;references:ID;constraint:OnDelete:RESTRICT"`
	Tags []MarkTag `gorm:"many2many:mark_tag_relation;foreignKey:ID;joinForeignKey:MarkID;references:ID;joinReferences:TagID;constraint:OnDelete:CASCADE"`
}
func (Mark) TableName() string { return "marks" }
type MarkPairSafeDistance struct {
	Mark1ID   uuid.UUID `gorm:"primaryKey"` 
	Mark2ID   uuid.UUID `gorm:"primaryKey"` 
	DistanceM float64   
}
func (MarkPairSafeDistance) TableName() string { return "mark_pair_safe_distance" }
func (m *MarkPairSafeDistance) BeforeCreate(tx *gorm.DB) error {
	if m.Mark1ID.String() > m.Mark2ID.String() {
		m.Mark1ID, m.Mark2ID = m.Mark2ID, m.Mark1ID
	}
	return nil
}
package repo
import (
	"IOT-Manage-System/mark-service/model"
)
func (r *markRepo) IsDeviceIDExists(deviceID string) (bool, error) {
	var count int64
	err := r.db.Model(&model.Mark{}).Where("device_id = ?", deviceID).Count(&count).Error
	return count > 0, err
}
func (r *markRepo) IsMarkNameExists(markName string) (bool, error) {
	var count int64
	err := r.db.Model(&model.Mark{}).Where("mark_name = ?", markName).Count(&count).Error
	return count > 0, err
}
func (r *markRepo) IsTagNameExists(tagName string) (bool, error) {
	var count int64
	err := r.db.Model(&model.MarkTag{}).Where("tag_name = ?", tagName).Count(&count).Error
	return count > 0, err
}
func (r *markRepo) IsTypeNameExists(typeName string) (bool, error) {
	var count int64
	err := r.db.Model(&model.MarkType{}).Where("type_name = ?", typeName).Count(&count).Error
	return count > 0, err
}
package repo
import (
	"IOT-Manage-System/mark-service/model"
)
func (r *markRepo) CreateMarkType(mt *model.MarkType) error {
	return r.db.Create(mt).Error
}
func (r *markRepo) GetMarkTypeByID(id int) (*model.MarkType, error) {
	var mt model.MarkType
	err := r.db.First(&mt, id).Error
	if err != nil {
		return nil, err
	}
	return &mt, nil
}
func (r *markRepo) GetMarkTypeByName(name string) (*model.MarkType, error) {
	var mt model.MarkType
	err := r.db.Where("type_name = ?", name).First(&mt).Error
	if err != nil {
		return nil, err
	}
	return &mt, nil
}
func (r *markRepo) ListMarkTypes(offset, limit int) ([]model.MarkType, error) {
	var types []model.MarkType
	err := r.db.Offset(offset).Limit(limit).Find(&types).Error
	return types, err
}
func (r *markRepo) ListMarkTypesWithCount(offset, limit int) ([]model.MarkType, int64, error) {
	var types []model.MarkType
	var total int64
	if err := r.db.Model(&model.MarkType{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}
	err := r.db.Offset(offset).Limit(limit).Find(&types).Error
	return types, total, err
}
func (r *markRepo) UpdateMarkType(mt *model.MarkType) error {
	return r.db.Save(mt).Error
}
func (r *markRepo) DeleteMarkType(id int) error {
	return r.db.Delete(&model.MarkType{}, id).Error
}
func (r *markRepo) GetMarkIDsByTypeID(typeID int) ([]string, error) {
	var markIDs []string
	err := r.db.Model(&model.Mark{}).
		Where("mark_type_id = ?", typeID).
		Pluck("id", &markIDs).Error
	if err != nil {
		return nil, err
	}
	return markIDs, nil
}
func (r *markRepo) GetAllTypeIDsAndNames() (map[int]string, error) {
	rows := make([]struct {
		ID   int
		Name string
	}, 0)
	if err := r.db.Model(&model.MarkType{}).
		Select("id", "type_name as name").
		Scan(&rows).Error; err != nil {
		return nil, err
	}
	out := make(map[int]string, len(rows))
	for _, v := range rows {
		out[v.ID] = v.Name
	}
	return out, nil
}
package repo
import (
	"IOT-Manage-System/mark-service/model"
	"time"
	"gorm.io/gorm"
)
type MarkRepo interface {
	CreateMark(mark *model.Mark) error
	CreateMarkAutoTag(mark *model.Mark, tagNames []string) error
	GetMarkByID(id string, preload bool) (*model.Mark, error)
	GetMarkByDeviceID(deviceID string, preload bool) (*model.Mark, error)
	ListMark(offset, limit int, preload bool) ([]model.Mark, error)
	ListMarkWithCount(offset, limit int, preload bool) ([]model.Mark, int64, error)
	UpdateMark(mark *model.Mark, tagNames []string) error
	DeleteMark(id string) error
	UpdateMarkLastOnline(deviceID string, t time.Time) error
	GetMarksByPersistMQTT(persist bool, preload bool, offset, limit int) ([]model.Mark, int64, error)
	GetPersistMQTTByDeviceID(deviceID string) (bool, error)
	GetDeviceIDsByPersistMQTT(persist bool) ([]string, error)
	GetAllMarkDeviceIDsAndNames() (map[string]string, error)
	GetAllMarkIDsAndNames() (map[string]string, error)
	GetMarkSafeDistance(markID string) (*float64, error)
	GetMarkSafeDistanceByDeviceID(deviceID string) (*float64, error)
	CreateMarkTag(mt *model.MarkTag) error
	GetMarkTagByID(id int) (*model.MarkTag, error)
	GetMarkTagByName(name string) (*model.MarkTag, error)
	ListMarkTags(offset, limit int) ([]model.MarkTag, error)
	ListMarkTagsWithCount(offset, limit int) ([]model.MarkTag, int64, error)
	UpdateMarkTag(tag *model.MarkTag) error
	DeleteMarkTag(id int) error
	FindTagsByNames(names []string) ([]model.MarkTag, []string, error)
	GetOrCreateTags(names []string) ([]model.MarkTag, error)
	GetMarksByTagID(tagID int, preload bool, offset, limit int) ([]model.Mark, int64, error)
	GetMarksByTagName(tagName string, preload bool, offset, limit int) ([]model.Mark, int64, error)
	GetMarkIDsByTagID(tagID int) ([]string, error)
	GetAllTagIDsAndNames() (map[int]string, error)
	CreateMarkType(mt *model.MarkType) error
	GetMarkTypeByID(id int) (*model.MarkType, error)
	GetMarkTypeByName(name string) (*model.MarkType, error)
	ListMarkTypes(offset, limit int) ([]model.MarkType, error)
	ListMarkTypesWithCount(offset, limit int) ([]model.MarkType, int64, error)
	UpdateMarkType(mt *model.MarkType) error
	DeleteMarkType(id int) error
	GetMarksByTypeID(typeID int, preload bool, offset, limit int) ([]model.Mark, int64, error)
	GetMarksByTypeName(typeName string, preload bool, offset, limit int) ([]model.Mark, int64, error)
	GetMarkIDsByTypeID(typeID int) ([]string, error)
	GetAllTypeIDsAndNames() (map[int]string, error)
	IsDeviceIDExists(deviceID string) (bool, error)
	IsMarkNameExists(markName string) (bool, error)
	IsTagNameExists(tagName string) (bool, error)
	IsTypeNameExists(typeName string) (bool, error)
}
type markRepo struct {
	db *gorm.DB
}
func NewMarkRepo(db *gorm.DB) MarkRepo {
	return &markRepo{db: db}
}
package handler
import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
	"IOT-Manage-System/mark-service/utils"
	"github.com/gofiber/fiber/v2"
)
func (h *MarkHandler) CreateMarkTag(c *fiber.Ctx) error {
	req := new(model.MarkTagRequest)
	if err := c.BodyParser(req); err != nil {
		return errs.ErrInvalidInput.WithDetails(err)
	}
	appErr := h.markService.CreateMarkTag(req)
	if appErr != nil {
		return appErr
	}
	return utils.SendCreatedResponse(c, nil, "标签创建成功")
}
func (h *MarkHandler) GetMarkTagByID(c *fiber.Ctx) error {
	tagID := c.Params("tag_id")
	if tagID == "" {
		return errs.ErrInvalidInput.WithDetails("tag_id 不能为空")
	}
	tagIDInt, err := utils.ParsePositiveInt(tagID)
	if err != nil {
		return errs.ErrInvalidInput.WithDetails("tag_id 必须是正整数")
	}
	tag, err := h.markService.GetMarkTagByID(tagIDInt)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, tag)
}
func (h *MarkHandler) ListMarkTags(c *fiber.Ctx) error {
	page := c.QueryInt("page", 1)
	if page < 1 {
		page = 1
	}
	limit := c.QueryInt("limit", 10)
	if limit < 1 {
		limit = 10
	}
	if limit > 100 {
		limit = 100 
	}
	if page <= 0 || limit <= 0 {
		return errs.ErrInvalidInput.WithDetails("page 和 limit 必须大于 0")
	}
	tags, total, appErr := h.markService.ListMarkTags(page, limit)
	if appErr != nil {
		return appErr
	}
	return utils.SendPaginatedResponse(c, tags, total, page, limit)
}
func (h *MarkHandler) GetMarkTagByName(c *fiber.Ctx) error {
	name := c.Params("tag_name")
	if name == "" {
		return errs.ErrInvalidInput.WithDetails("tag_name 不能为空")
	}
	tag, appErr := h.markService.GetMarkTagByName(name)
	if appErr != nil {
		return appErr
	}
	return utils.SendSuccessResponse(c, tag)
}
func (h *MarkHandler) UpdateMarkTag(c *fiber.Ctx) error {
	tagID := c.Params("tag_id")
	if tagID == "" {
		return errs.ErrInvalidInput.WithDetails("tag_id 不能为空")
	}
	tagIDInt, err := utils.ParsePositiveInt(tagID)
	if err != nil {
		return errs.ErrInvalidInput.WithDetails("tag_id 必须是正整数")
	}
	req := new(model.MarkTagRequest)
	if err := c.BodyParser(req); err != nil {
		return errs.ErrInvalidInput.WithDetails(err)
	}
	if req.TagName == "" {
		return errs.ErrInvalidInput.WithDetails("TagName 不能为空")
	}
	appErr := h.markService.UpdateMarkTag(tagIDInt, req)
	if appErr != nil {
		return appErr
	}
	return utils.SendSuccessResponse(c, nil, "标签更新成功")
}
func (h *MarkHandler) DeleteMarkTag(c *fiber.Ctx) error {
	tagID := c.Params("tag_id")
	if tagID == "" {
		return errs.ErrInvalidInput.WithDetails("tag_id 不能为空")
	}
	tagIDInt, err := utils.ParsePositiveInt(tagID)
	if err != nil {
		return errs.ErrInvalidInput.WithDetails("tag_id 必须是正整数")
	}
	appErr := h.markService.DeleteMarkTag(tagIDInt)
	if appErr != nil {
		return appErr
	}
	return utils.SendSuccessResponse(c, nil, "标签删除成功")
}
func (h *MarkHandler) GetMarksByTagID(c *fiber.Ctx) error {
	tagID := c.Params("tag_id")
	if tagID == "" {
		return errs.ErrInvalidInput.WithDetails("tag_id 不能为空")
	}
	tagIDInt, err := utils.ParsePositiveInt(tagID)
	if err != nil {
		return errs.ErrInvalidInput.WithDetails("tag_id 必须是正整数")
	}
	page := c.QueryInt("page", 1)
	if page < 1 {
		page = 1
	}
	limit := c.QueryInt("limit", 10)
	if limit < 1 {
		limit = 10
	}
	if limit > 100 {
		limit = 100 
	}
	preload := c.Query("preload", "false") == "true"
	marks, total, appErr := h.markService.GetMarksByTagID(tagIDInt, page, limit, preload)
	if appErr != nil {
		return appErr
	}
	return utils.SendPaginatedResponse(c, marks, total, page, limit)
}
func (h *MarkHandler) GetMarksByTagName(c *fiber.Ctx) error {
	name := c.Params("tag_name")
	if name == "" {
		return errs.ErrInvalidInput.WithDetails("tag_name 不能为空")
	}
	page := c.QueryInt("page", 1)
	if page < 1 {
		page = 1
	}
	limit := c.QueryInt("limit", 10)
	if limit < 1 {
		limit = 10
	}
	if limit > 100 {
		limit = 100 
	}
	preload := c.Query("preload", "false") == "true"
	marks, total, appErr := h.markService.GetMarksByTagName(name, page, limit, preload)
	if appErr != nil {
		return appErr
	}
	return utils.SendPaginatedResponse(c, marks, total, page, limit)
}
func (h *MarkHandler) GetAllTagIDToName(c *fiber.Ctx) error {
	resp, err := h.markService.GetAllTagIDToName()
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}
package handler
import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
	"IOT-Manage-System/mark-service/service"
	"IOT-Manage-System/mark-service/utils"
	"github.com/gofiber/fiber/v2"
)
type MarkPairHandler struct {
	markPairService service.MarkPairService
}
func NewMarkPairHandler(markPairService service.MarkPairService) *MarkPairHandler {
	return &MarkPairHandler{markPairService: markPairService}
}
func (h *MarkPairHandler) SetPairDistance(c *fiber.Ctx) error {
	var req model.SetDistanceMarkReq
	if err := c.BodyParser(&req); err != nil {
		return errs.ErrInvalidInput.WithDetails("参数解析失败")
	}
	if err := h.markPairService.SetPairDistance(req.Mark1ID, req.Mark2ID, req.Distance); err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, nil, "标记对距离设置成功")
}
func (h *MarkPairHandler) SetCombinations(c *fiber.Ctx) error {
	var req struct {
		MarkIDs  []string `json:"mark_ids" validate:"required,min=2"`
		Distance float64  `json:"distance" validate:"required,min=0"`
	}
	if err := c.BodyParser(&req); err != nil {
		return errs.ErrInvalidInput.WithDetails("参数解析失败")
	}
	if err := h.markPairService.SetCombinations(req.MarkIDs, req.Distance); err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, nil, "标记组合距离批量设置成功")
}
func (h *MarkPairHandler) SetCartesian(c *fiber.Ctx) error {
	var req model.SetDistanceTypedReq
	if err := c.BodyParser(&req); err != nil {
		return errs.ErrInvalidInput.WithDetails("参数解析失败")
	}
	if err := h.markPairService.SetCartesian(req, req.Distance); err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, nil, "标记对笛卡尔积距离设置成功")
}
func (h *MarkPairHandler) GetDistance(c *fiber.Ctx) error {
	mark1ID := c.Params("mark1_id")
	mark2ID := c.Params("mark2_id")
	if mark1ID == "" || mark2ID == "" {
		return errs.ErrInvalidInput.WithDetails("标记ID不能为空")
	}
	if mark1ID > mark2ID {
		t := mark1ID
		mark1ID = mark2ID
		mark2ID = t
	}
	distance, err := h.markPairService.GetDistance(mark1ID, mark2ID)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, map[string]interface{}{
		"mark1_id": mark1ID,
		"mark2_id": mark2ID,
		"distance": distance,
	})
}
func (h *MarkPairHandler) DeletePair(c *fiber.Ctx) error {
	mark1ID := c.Params("mark1_id")
	mark2ID := c.Params("mark2_id")
	if mark1ID == "" || mark2ID == "" {
		return errs.ErrInvalidInput.WithDetails("标记ID不能为空")
	}
	if mark1ID > mark2ID {
		t := mark1ID
		mark1ID = mark2ID
		mark2ID = t
	}
	if err := h.markPairService.DeletePair(mark1ID, mark2ID); err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, nil, "标记对距离删除成功")
}
func (h *MarkPairHandler) DistanceMapByMark(c *fiber.Ctx) error {
	markID := c.Params("id")
	if markID == "" {
		return errs.ErrInvalidInput.WithDetails("标记ID不能为空")
	}
	distanceMap, err := h.markPairService.DistanceMapByMark(markID)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, distanceMap)
}
func (h *MarkPairHandler) DistanceMapByDevice(c *fiber.Ctx) error {
	deviceID := c.Params("device_id")
	if deviceID == "" {
		return errs.ErrInvalidInput.WithDetails("设备ID不能为空")
	}
	distanceMap, err := h.markPairService.DistanceMapByDevice(deviceID)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, distanceMap)
}
func (h *MarkPairHandler) GetDistanceByDeviceIDs(c *fiber.Ctx) error {
	device1ID := c.Params("device1_id")
	device2ID := c.Params("device2_id")
	if device1ID == "" || device2ID == "" {
		return errs.ErrInvalidInput.WithDetails("设备ID不能为空")
	}
	distance, err := h.markPairService.GetDistanceByDeviceIDs(device1ID, device2ID)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, map[string]interface{}{
		"device1_id": device1ID,
		"device2_id": device2ID,
		"distance":   distance,
	})
}
func (h *MarkPairHandler) DistanceMapByDeviceToDeviceIDs(c *fiber.Ctx) error {
	deviceID := c.Params("id")
	if deviceID == "" {
		return errs.ErrInvalidInput.WithDetails("设备ID不能为空")
	}
	distanceMap, err := h.markPairService.DistanceMapByDeviceToDeviceIDs(deviceID)
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, distanceMap)
}
func (h *MarkPairHandler) ListMarkPairs(c *fiber.Ctx) error {
	page := c.QueryInt("page", 1)
	if page < 1 {
		page = 1
	}
	limit := c.QueryInt("limit", 10)
	if limit < 1 {
		limit = 10
	}
	if limit > 100 {
		limit = 100
	}
	pairs, total, err := h.markPairService.ListMarkPairs(page, limit)
	if err != nil {
		return err
	}
	return utils.SendPaginatedResponse(c, pairs, total, page, limit)
}
package handler
import (
	"IOT-Manage-System/mark-service/errs"
	"IOT-Manage-System/mark-service/model"
	"IOT-Manage-System/mark-service/utils"
	"github.com/gofiber/fiber/v2"
)
func (h *MarkHandler) CreateMarkType(c *fiber.Ctx) error {
	req := new(model.MarkTypeCreateRequest)
	if err := c.BodyParser(req); err != nil {
		return errs.ErrInvalidInput.WithDetails(err)
	}
	appErr := h.markService.CreateMarkType(req)
	if appErr != nil {
		return appErr
	}
	return utils.SendCreatedResponse(c, nil, "标记类型创建成功")
}
func (h *MarkHandler) GetMarkTypeByID(c *fiber.Ctx) error {
	typeID := c.Params("type_id")
	if typeID == "" {
		return errs.ErrInvalidInput.WithDetails("type_id 不能为空")
	}
	typeIDInt, err := utils.ParsePositiveInt(typeID)
	if err != nil {
		return errs.ErrInvalidInput.WithDetails("type_id 必须是正整数")
	}
	typ, appErr := h.markService.GetMarkTypeByID(typeIDInt)
	if appErr != nil {
		return appErr
	}
	return utils.SendSuccessResponse(c, typ)
}
func (h *MarkHandler) ListMarkTypes(c *fiber.Ctx) error {
	page := c.QueryInt("page", 1)
	if page < 1 {
		page = 1
	}
	limit := c.QueryInt("limit", 10)
	if limit < 1 {
		limit = 10
	}
	if limit > 100 {
		limit = 100 
	}
	if page <= 0 || limit <= 0 {
		return errs.ErrInvalidInput.WithDetails("page 和 limit 必须大于 0")
	}
	types, total, appErr := h.markService.ListMarkTypes(page, limit)
	if appErr != nil {
		return appErr
	}
	return utils.SendPaginatedResponse(c, types, total, page, limit)
}
func (h *MarkHandler) GetMarkTypeByName(c *fiber.Ctx) error {
	name := c.Params("type_name")
	if name == "" {
		return errs.ErrInvalidInput.WithDetails("type_name 不能为空")
	}
	typ, appErr := h.markService.GetMarkTypeByName(name)
	if appErr != nil {
		return appErr
	}
	return utils.SendSuccessResponse(c, typ)
}
func (h *MarkHandler) UpdateMarkType(c *fiber.Ctx) error {
	typeID := c.Params("type_id")
	if typeID == "" {
		return errs.ErrInvalidInput.WithDetails("type_id 不能为空")
	}
	typeIDInt, err := utils.ParsePositiveInt(typeID)
	if err != nil {
		return errs.ErrInvalidInput.WithDetails("type_id 必须是正整数")
	}
	req := new(model.MarkTypeUpdateRequest)
	if err := c.BodyParser(req); err != nil {
		return errs.ErrInvalidInput.WithDetails(err.Error())
	}
	if appErr := h.markService.UpdateMarkType(typeIDInt, req); appErr != nil {
		return appErr
	}
	return utils.SendSuccessResponse(c, nil, "标记类型更新成功")
}
func (h *MarkHandler) DeleteMarkType(c *fiber.Ctx) error {
	typeID := c.Params("type_id")
	if typeID == "" {
		return errs.ErrInvalidInput.WithDetails("type_id 不能为空")
	}
	typeIDInt, err := utils.ParsePositiveInt(typeID)
	if err != nil {
		return errs.ErrInvalidInput.WithDetails("type_id 必须是正整数")
	}
	appErr := h.markService.DeleteMarkType(typeIDInt)
	if appErr != nil {
		return appErr
	}
	return utils.SendSuccessResponse(c, nil, "标记类型删除成功")
}
func (h *MarkHandler) GetMarksByTypeID(c *fiber.Ctx) error {
	typeID := c.Params("type_id")
	if typeID == "" {
		return errs.ErrInvalidInput.WithDetails("type_id 不能为空")
	}
	typeIDInt, err := utils.ParsePositiveInt(typeID)
	if err != nil {
		return errs.ErrInvalidInput.WithDetails("type_id 必须是正整数")
	}
	page := c.QueryInt("page", 1)
	if page < 1 {
		page = 1
	}
	limit := c.QueryInt("limit", 10)
	if limit < 1 {
		limit = 10
	}
	if limit > 100 {
		limit = 100 
	}
	preload := c.Query("preload", "false") == "true"
	marks, total, appErr := h.markService.GetMarksByTypeID(typeIDInt, page, limit, preload)
	if appErr != nil {
		return appErr
	}
	return utils.SendPaginatedResponse(c, marks, total, page, limit)
}
func (h *MarkHandler) GetMarksByTypeName(c *fiber.Ctx) error {
	name := c.Params("type_name")
	if name == "" {
		return errs.ErrInvalidInput.WithDetails("type_name 不能为空")
	}
	page := c.QueryInt("page", 1)
	if page < 1 {
		page = 1
	}
	limit := c.QueryInt("limit", 10)
	if limit < 1 {
		limit = 10
	}
	if limit > 100 {
		limit = 100 
	}
	preload := c.Query("preload", "false") == "true"
	marks, total, appErr := h.markService.GetMarksByTypeName(name, page, limit, preload)
	if appErr != nil {
		return appErr
	}
	return utils.SendPaginatedResponse(c, marks, total, page, limit)
}
func (h *MarkHandler) GetAllTypeIDToName(c *fiber.Ctx) error {
	resp, err := h.markService.GetAllTypeIDToName()
	if err != nil {
		return err
	}
	return utils.SendSuccessResponse(c, resp)
}
package client
import (
	"log"
	mqtt "github.com/eclipse/paho.mqtt.golang"
)
func (mc *MqttCallback) MustSubscribe() {
	token := mc.cli.Subscribe("online/#", 1, MultiHandler(EchoMsg))
	if token.Wait() && token.Error() != nil {
		log.Fatalf("[FATAL] 订阅 online/# 失败: %v", token.Error())
	}
	token = mc.cli.Subscribe("location/#", 1, MultiHandler(mc.saveLocation))
	if token.Wait() && token.Error() != nil {
		log.Fatalf("[FATAL] 订阅 location/# 失败: %v", token.Error())
	}
	log.Println("[INFO] MQTT 订阅已完成")
}
func MustSubscribe(c mqtt.Client) {
	token := c.Subscribe("online/#", 1, MultiHandler(EchoMsg))
	if token.Wait() && token.Error() != nil {
		log.Fatalf("[FATAL] 订阅 online/# 失败: %v", token.Error())
	}
	token = c.Subscribe("location/#", 1, MultiHandler())
	if token.Wait() && token.Error() != nil {
		log.Fatalf("[FATAL] 订阅 location/# 失败: %v", token.Error())
	}
	log.Println("[INFO] MQTT 订阅已完成")
}
func MultiHandler(handlers ...mqtt.MessageHandler) mqtt.MessageHandler {
	return func(c mqtt.Client, m mqtt.Message) {
		for _, h := range handlers {
			h(c, m)
		}
	}
}
package client
import (
	"log"
	"time"
	mqtt "github.com/eclipse/paho.mqtt.golang"
	"github.com/goccy/go-json"
	"IOT-Manage-System/mqtt-watch/model"
	"IOT-Manage-System/mqtt-watch/service"
	"IOT-Manage-System/mqtt-watch/utils"
)
type MqttCallback struct {
	cli             mqtt.Client
	markService     service.MarkService
	markPairService service.MarkPairService
	mongoService    service.MongoService 
}
func NewMqttCallback(cli mqtt.Client,
	markService service.MarkService,
	markPairService service.MarkPairService,
	mongoService service.MongoService, 
) *MqttCallback {
	return &MqttCallback{
		cli:             cli,
		markService:     markService,
		markPairService: markPairService,
		mongoService:    mongoService, 
	}
}
func (m *MqttCallback) defaultMsgHandler(c mqtt.Client, msg mqtt.Message) {
	log.Printf("[INFO] 收到: topic=%s payload=%s\n", msg.Topic(), string(msg.Payload()))
}
func (m *MqttCallback) echoMsg(c mqtt.Client, msg mqtt.Message) {
	deviceID := utils.ParseOnlineId(msg.Topic(), msg.Payload())
	tok := c.Publish("echo/"+deviceID, 0, false, "1")
	tok.Wait()
	if err := tok.Error(); err != nil {
		log.Printf("[ERROR] 发布失败: %v", err)
	}
}
func (m *MqttCallback) SendWarningStart(deviceID string) {
	tok := m.cli.Publish("warning/"+deviceID, 1, false, "1")
	tok.Wait()
	if err := tok.Error(); err != nil {
		log.Printf("[ERROR] 发布失败: %v", err)
	} else {
		log.Printf("[DEBUG] 警报已发送  deviceID=%s  targetTopic=warning/%s", deviceID, deviceID)
	}
}
func (m *MqttCallback) SendWarningEnd(deviceID string) {
	tok := m.cli.Publish("warning/"+deviceID, 1, false, "0")
	tok.Wait()
	if err := tok.Error(); err != nil {
		log.Printf("[ERROR] 发布失败: %v", err)
	} else {
		log.Printf("[DEBUG] 解除警报已发送  deviceID=%s  targetTopic=warning/%s", deviceID, deviceID)
	}
}
func (m *MqttCallback) saveLocation(c mqtt.Client, msg mqtt.Message) {
	deviceID := utils.ParseOnlineId(msg.Topic(), msg.Payload())
	var locMsg model.LocMsg
	if err := json.Unmarshal(msg.Payload(), &locMsg); err != nil {
		log.Println("[ERROR] json 解析失败:", err)
		return
	}
	if len(locMsg.Sens) == 0 {
		return
	}
	is_save, err := m.markService.GetPersistMQTTByDeviceID(deviceID)
	if err != nil {
		log.Printf("[ERROR] 获取 persist 失败: %v", err)
		return
	}
	if !is_save {
		return
	}
	var rtk, uwb *model.Sens
	for i := range locMsg.Sens {
		switch locMsg.Sens[i].N {
		case "RTK":
			rtk = &locMsg.Sens[i]
		case "UWB":
			uwb = &locMsg.Sens[i]
		}
	}
	indoor := uwb != nil && len(uwb.V) >= 2
	recTime := time.Now()
	data := &model.DeviceLoc{
		DeviceID:   deviceID,
		Indoor:     indoor,
		RecordTime: recTime,
		CreatedAt:  time.Now(), 
	}
	data.SetID()
	if rtk != nil && len(rtk.V) >= 2 {
		data.Latitude = &rtk.V[0]
		data.Longitude = &rtk.V[1]
	}
	if uwb != nil && len(uwb.V) >= 2 {
		data.UWBX = &uwb.V[0]
		data.UWBY = &uwb.V[1]
	}
	m.mongoService.SaveDeviceLoc(*data) 
	log.Printf("[INFO] 保存位置信息成功  deviceID=%s  indoor=%t  lat=%f  lon=%f  uwb_x=%f  uwb_y=%f", deviceID, indoor, *data.Latitude, *data.Longitude, *data.UWBX, *data.UWBY)
}
type DistanceMsg struct {
	X float64
	Y float64
}
func DefaultMsgHandler(c mqtt.Client, m mqtt.Message) {
	log.Printf("[INFO] 收到: topic=%s payload=%s\n", m.Topic(), string(m.Payload()))
}
func logMsg(c mqtt.Client, m mqtt.Message) {
	log.Printf("[INFO] 收到消息  topic=%s  payload=%s", m.Topic(), string(m.Payload()))
}
func EchoMsg(c mqtt.Client, m mqtt.Message) {
	deviceID := utils.ParseOnlineId(m.Topic(), m.Payload())
	token := c.Publish("echo/"+deviceID, 0, false, "1")
	token.Wait()
	if err := token.Error(); err != nil {
		log.Printf("[ERROR] 发布失败: %v", err)
	} else {
	}
}
func SendWaringStart(c mqtt.Client, deviceID string) {
	token := c.Publish("warning/"+deviceID, 1, false, "1")
	token.Wait()
	if err := token.Error(); err != nil {
		log.Printf("[ERROR] 发布失败: %v", err)
	} else {
		log.Printf("[DEBUG] 警报已发送  deviceID=%s  targetTopic=waring/%s", deviceID, deviceID)
	}
}
func SendWarningEnd(c mqtt.Client, deviceID string) {
	token := c.Publish("warning/"+deviceID, 1, false, "0")
	token.Wait()
	if err := token.Error(); err != nil {
		log.Printf("[ERROR] 发布失败: %v", err)
	} else {
		log.Printf("[DEBUG] 解除警报已发送  deviceID=%s  targetTopic=waring/%s", deviceID, deviceID)
	}
}
package errs
import (
	"fmt"
)
type AppError struct {
	Code    string 
	Message string 
	Status  int    
	Details any    
}
func (e *AppError) Error() string { return e.Message }
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
var (
	ErrResourceNotFound  = &AppError{"RESOURCE_NOT_FOUND", "资源不存在", 404, nil}
	ErrResourceConflict  = &AppError{"RESOURCE_CONFLICT", "资源冲突", 409, nil}
	ErrResourceExhausted = &AppError{"RESOURCE_EXHAUSTED", "资源耗尽", 429, nil}
	ErrUploadFailed      = &AppError{"UPLOAD_FAILED", "文件上传失败", 500, nil}
	ErrFileTooLarge      = &AppError{"FILE_TOO_LARGE", "文件过大", 413, nil}
	ErrUnsupportedFormat = &AppError{"UNSUPPORTED_FORMAT", "不支持的文件格式", 415, nil}
)
var (
	ErrStatusConflict   = &AppError{"STATUS_CONFLICT", "状态冲突", 409, nil}
	ErrDuplicateAction  = &AppError{"DUPLICATE_ACTION", "重复操作", 409, nil}
	ErrQuotaExceeded    = &AppError{"QUOTA_EXCEEDED", "配额超限", 429, nil}
	ErrOperationTimeout = &AppError{"OPERATION_TIMEOUT", "操作超时", 408, nil}
	ErrInvalidToken     = &AppError{"INVALID_TOKEN", "错误Token", 401, nil}
)
var (
	ErrInternal   = &AppError{"INTERNAL_ERROR", "内部错误", 500, nil}
	ErrDatabase   = &AppError{"DATABASE_ERROR", "数据库异常", 500, nil}
	ErrCache      = &AppError{"CACHE_ERROR", "缓存异常", 500, nil}
	ErrNetwork    = &AppError{"NETWORK_ERROR", "网络异常", 503, nil}
	ErrThirdParty = &AppError{"THIRD_PARTY_ERROR", "第三方服务异常", 502, nil}
	ErrConfig     = &AppError{"CONFIG_ERROR", "配置错误", 500, nil}
)
var (
	ErrValidationFailed = &AppError{"VALIDATION_FAILED", "数据校验失败", 400, nil}
	ErrCaptchaFailed    = &AppError{"CAPTCHA_FAILED", "验证码错误", 400, nil}
	ErrTooManyRequests  = &AppError{"TOO_MANY_REQUESTS", "请求过于频繁", 429, nil}
)
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
func (e *AppError) WithDetails(details any) *AppError {
	return &AppError{
		Code:    e.Code,
		Message: e.Message,
		Status:  e.Status,
		Details: details,
	}
}
package main
import (
	"IOT-Manage-System/api-gateway/middleware"
	"IOT-Manage-System/api-gateway/utils"
	"log"
	"net/http/httputil"
	"net/url"
	"strings"
	"github.com/gin-gonic/gin"
)
func main() {
	r := gin.Default()
	r.RedirectTrailingSlash = false 
	r.Use(middleware.Cors())
	r.Use(middleware.JWTMiddleware())
	userServiceURL := utils.GetEnv("USER_SERVICE_URL", "user-service:8001")
	mapServiceUrl := utils.GetEnv("MAP_SERVICE_URL", "map-service:8002")
	mqttServiceUrl := utils.GetEnv("MQTT_SERVICE_URL", "mqtt-service:8003")
	markServiceUrl := utils.GetEnv("MARK_SERVICE_URL", "mark-service:8004")
	log.Printf("用户 服务地址: %s", userServiceURL)
	log.Printf("标记 服务地址: %s", markServiceUrl)
	r.Any("/api/v1/users/*proxyPath", createProxyHandler(userServiceURL))
	r.Any("/api/v1/marks/*proxyPath", createProxyHandler(markServiceUrl))
	r.Any("/api/v1/tags/*proxyPath", createProxyHandler(markServiceUrl))
	r.Any("/api/v1/types/*proxyPath", createProxyHandler(markServiceUrl))
	r.Any("/api/v1/pairs/*proxyPath", createProxyHandler(markServiceUrl))
	r.Any("/api/v1/mqtt/*proxyPath", createProxyHandler(mqttServiceUrl))
	r.Any("/api/v1/station/*proxyPath", createProxyHandler(mapServiceUrl))
	r.Any("/api/v1/custom-map/*proxyPath", createProxyHandler(mapServiceUrl))
	r.Any("/api/v1/polygon-fence/*proxyPath", createProxyHandler(mapServiceUrl))
	r.Any("/uploads/*proxyPath", createProxyHandler(mapServiceUrl))
	port := utils.GetEnv("PORT", "8000")
	log.Printf("服务即将启动，监听端口: %s\n", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("启动服务失败: %v", err)
	}
}
func createProxyHandler(raw string) gin.HandlerFunc {
	if !strings.HasPrefix(raw, "http://") && !strings.HasPrefix(raw, "https://") {
		raw = "http://" + raw
	}
	target, err := url.Parse(raw)
	if err != nil {
		panic(err) 
	}
	proxy := httputil.NewSingleHostReverseProxy(target)
	return func(c *gin.Context) {
		if uid := c.GetHeader("X-UserID"); uid != "" {
			c.Request.Header.Set("X-UserID", uid)
			c.Request.Header.Set("X-UserName", c.GetHeader("X-UserName"))
			c.Request.Header.Set("X-UserType", c.GetHeader("X-UserType"))
		}
		proxy.ServeHTTP(c.Writer, c.Request)
	}
}
package utils
import (
	"fmt"
	"os"
	"strconv"
)
func GetEnv(key, defaultValue string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return defaultValue
}
func GetEnvInt(key string, defaultValue int) int {
	val := os.Getenv(key)
	if val == "" {
		return defaultValue
	}
	i, err := strconv.Atoi(val)
	if err != nil {
		return defaultValue
	}
	return i
}
func GetDSN() string {
	dbHost := GetEnv("DB_HOST", "postgres")
	dbPort := GetEnv("DB_PORT", "5432")
	dbUser := GetEnv("DB_USER", "postgres")
	dbPasswd := GetEnv("DB_PASSWD", "password")
	dbName := GetEnv("DB_NAME", "iot_manager_db")
	return fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable TimeZone=Asia/Shanghai",
		dbHost, dbPort, dbUser, dbPasswd, dbName,
	)
}
package middleware
import (
	"net/http"
	"github.com/gin-gonic/gin"
)
func Cors() gin.HandlerFunc {
	return func(c *gin.Context) {
		origin := c.GetHeader("Origin")
		if origin != "" {
			c.Header("Access-Control-Allow-Origin", origin)
			c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
			c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Accept, Authorization, X-Requested-With")
			c.Header("Access-Control-Expose-Headers", "Content-Length, Access-Control-Allow-Origin, Access-Control-Allow-Headers")
			c.Header("Access-Control-Allow-Credentials", "true")
		}
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		c.Next()
	}
}
package utils
import (
	"net/http"
	"time"
	"github.com/gin-gonic/gin"
)
type Response struct {
	Success    bool           `json:"success"`
	Data       any            `json:"data,omitempty"`
	Message    string         `json:"message,omitempty"`
	Error      *ErrorObj      `json:"error,omitempty"`
	Pagination *PaginationObj `json:"pagination,omitempty"`
	Timestamp  time.Time      `json:"timestamp"`
}
type ErrorObj struct {
	Code    string `json:"code"`
	Message string `json:"message"`
	Details any    `json:"details,omitempty"`
}
type PaginationObj struct {
	CurrentPage  int   `json:"currentPage"`  
	TotalPages   int   `json:"totalPages"`   
	TotalItems   int64 `json:"totalItems"`   
	ItemsPerPage int   `json:"itemsPerPage"` 
	HasNext      bool  `json:"has_next"`     
	HasPrev      bool  `json:"has_prev"`     
}
func SendSuccessResponse(c *gin.Context, data any, msg ...string) {
	message := "请求成功啦😁"
	if len(msg) > 0 {
		message = msg[0] 
	}
	c.JSON(http.StatusOK, Response{
		Success:   true,
		Data:      data,
		Message:   message, 
		Timestamp: time.Now(),
	})
}
func SendCreatedResponse(c *gin.Context, data any, message string) {
	c.JSON(http.StatusCreated, Response{
		Success:   true,
		Data:      data,
		Message:   message,
		Timestamp: time.Now(),
	})
}
func SendPaginatedResponse(c *gin.Context, data any, total int64, page, perPage int) {
	pagination := NewPagination(total, page, perPage)
	c.JSON(http.StatusOK, Response{
		Success:    true,
		Data:       data,
		Message:    "请求成功啦😁",
		Pagination: pagination,
		Timestamp:  time.Now(),
	})
}
func NewPagination(total int64, page, perPage int) *PaginationObj {
	if perPage <= 0 {
		perPage = 10
	}
	totalPages := int((total + int64(perPage) - 1) / int64(perPage))
	return &PaginationObj{
		CurrentPage:  page,
		TotalPages:   totalPages,
		TotalItems:   total,
		ItemsPerPage: perPage,
		HasNext:      page < totalPages,
		HasPrev:      page > 1,
	}
}
func SendErrorResponse(c *gin.Context, statusCode int, message string) {
	c.JSON(statusCode, Response{
		Success:   false,
		Message:   message,
		Timestamp: time.Now(),
	})
}
func SendErrorResponseWithData(c *gin.Context, statusCode int, message string, data any) {
	c.JSON(statusCode, Response{
		Success: false,
		Message: message,
		Data:    data,
	})
}
func newErrorObj(code, msg string, details ...any) *ErrorObj {
	e := &ErrorObj{Code: code, Message: msg}
	if len(details) > 0 {
		e.Details = details[0]
	}
	return e
}
func SendUnauthorized(c *gin.Context, msg ...any) {
	message := "请先登录哦🤨"
	if len(msg) > 0 {
		message, _ = msg[0].(string)
	}
	c.JSON(http.StatusUnauthorized, Response{
		Success:   false,
		Message:   message,
		Error:     newErrorObj("UNAUTHORIZED", "未认证"),
		Timestamp: time.Now(),
	})
}
func SendForbidden(c *gin.Context, msg ...any) {
	message := "权限不足🙅"
	if len(msg) > 0 {
		message, _ = msg[0].(string)
	}
	c.JSON(http.StatusForbidden, Response{
		Success:   false,
		Message:   message,
		Error:     newErrorObj("FORBIDDEN", "权限不足"),
		Timestamp: time.Now(),
	})
}
func SendNotFound(c *gin.Context, msg ...any) {
	message := "资源没有找到😕"
	if len(msg) > 0 {
		message, _ = msg[0].(string)
	}
	c.JSON(http.StatusNotFound, Response{
		Success:   false,
		Message:   message,
		Error:     newErrorObj("NOT_FOUND", "资源不存在"),
		Timestamp: time.Now(),
	})
}
func SendBadRequest(c *gin.Context, msg ...any) {
	message := "请求参数有误🙅"
	if len(msg) > 0 {
		message, _ = msg[0].(string)
	}
	c.JSON(http.StatusBadRequest, Response{
		Success:   false,
		Message:   message,
		Error:     newErrorObj("BAD_REQUEST", "请求参数有误"),
		Timestamp: time.Now(),
	})
}
func SendBadRequestWithData(c *gin.Context, msg string, data any) {
	c.JSON(http.StatusBadRequest, Response{
		Success:   false,
		Message:   msg,
		Data:      data,
		Error:     newErrorObj("BAD_REQUEST", "请求参数有误"),
		Timestamp: time.Now(),
	})
}
func SendConflict(c *gin.Context, msg ...any) {
	message := "数据冲突，请稍后再试😔"
	if len(msg) > 0 {
		message, _ = msg[0].(string)
	}
	c.JSON(http.StatusConflict, Response{
		Success:   false,
		Message:   message,
		Error:     newErrorObj("CONFLICT", "数据冲突"),
		Timestamp: time.Now(),
	})
}
func SendInternalServerError(c *gin.Context, err error) {
	c.JSON(http.StatusInternalServerError, Response{
		Success:   false,
		Message:   "服务器内部错误🥺",
		Error:     newErrorObj("INTERNAL_SERVER_ERROR", err.Error()),
		Timestamp: time.Now(),
	})
}
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
func GenerateToken(u *models.User) (string, error) {
	return generateToken(u, AccessTokenExpire, AccessTokenIssuer)
}
func GenerateRefreshToken(u *models.User) (string, error) {
	return generateToken(u, RefreshTokenExpire, RefreshTokenIssuer)
}
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
func RefreshAccessToken(refreshToken string) (string, error) {
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
	user := &models.User{
		ID:       claims.UserID,
		Username: claims.Username,
		UserType: claims.UserType,
	}
	return GenerateToken(user)
}
package models
import (
	"time"
	"gorm.io/gorm"
)
type UserType string
const (
	UserTypeRoot  UserType = "root"
	UserTypeUser  UserType = "user"
	UserTypeAdmin UserType = "admin"
)
func (UserType) GormDataType() string { return "user_type_enum" }
type User struct {
	ID        string    `gorm:"type:uuid;primaryKey;default:gen_random_uuid()"`
	Username  string    `gorm:"type:varchar(255);not null"`
	PwdHash   string    `gorm:"type:varchar(255);not null"`
	UserType  UserType  `gorm:"type:user_type_enum;not null;default:'user'"`
	CreatedAt time.Time `gorm:"type:timestamptz;not null;default:now()"`
	UpdatedAt time.Time `gorm:"type:timestamptz;not null;default:now()"`
}
func (User) TableName() string {
	return "users"
}
func (u *User) BeforeSave(tx *gorm.DB) error {
	u.UpdatedAt = time.Now()
	return nil
}
package middleware
import (
	"IOT-Manage-System/api-gateway/utils"
	"net/http"
	"strings"
	"log"
	"github.com/gin-gonic/gin"
)
func JWTMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.Next()
			return
		}
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || parts[0] != "Bearer" {
			c.Next() 
			return
		}
		claims, err := utils.ParseAccessToken(parts[1])
		if err != nil {
			log.Printf("token=%s, err=%v", parts[1], err) 
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"code":    401,
				"message": "认证失败",
				"data":    nil,
			})
			return
		}
		c.Request.Header.Set("X-UserID", claims.UserID)
		c.Request.Header.Set("X-UserName", claims.Username)
		c.Request.Header.Set("X-UserType", string(claims.UserType))
		c.Next()
	}
}
```

```sql
-- 插入默认标记类型
INSERT INTO mark_types (type_name, default_safe_distance_m)
VALUES ('默认', -1),
       ('吊车', 20)
ON CONFLICT (type_name) DO NOTHING;
CREATE TABLE IF NOT EXISTS mark_types
(
    id                      SERIAL           NOT NULL,
    type_name               VARCHAR(255)     NOT NULL UNIQUE,
    default_safe_distance_m DOUBLE PRECISION NOT NULL DEFAULT -1,
    PRIMARY KEY (id)
);
CREATE TABLE IF NOT EXISTS mark_tags
(
    id       SERIAL       NOT NULL,
    tag_name VARCHAR(255) NOT NULL UNIQUE,
    PRIMARY KEY (id)
);
CREATE TABLE IF NOT EXISTS marks
(
    id              UUID             NOT NULL DEFAULT gen_random_uuid(),
    device_id       VARCHAR(255)     NOT NULL UNIQUE,
    mark_name       VARCHAR(255)     NOT NULL,
    mqtt_topic      TEXT[]           NOT NULL DEFAULT '{}',
    persist_mqtt    BOOLEAN          NOT NULL DEFAULT false,
    safe_distance_m DOUBLE PRECISION NOT NULL DEFAULT -1,
    mark_type_id    INTEGER          NOT NULL DEFAULT 1,
    created_at      TIMESTAMPTZ      NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ      NOT NULL DEFAULT now(),
    last_online_at  TIMESTAMPTZ,
    PRIMARY KEY (id),
    -- 添加外键约束
    CONSTRAINT fk_mark_type FOREIGN KEY (mark_type_id) REFERENCES mark_types (id) ON DELETE RESTRICT
);
CREATE TABLE IF NOT EXISTS mark_tag_relation
(
    mark_id UUID NOT NULL,
    tag_id  INT  NOT NULL,
    PRIMARY KEY (mark_id, tag_id),
    FOREIGN KEY (mark_id) REFERENCES marks (id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES mark_tags (id) ON DELETE CASCADE
);
-- 2. 创建 mark_pair_safe_distance 表
CREATE TABLE IF NOT EXISTS mark_pair_safe_distance
(
    mark1_id   UUID             NOT NULL,
    mark2_id   UUID             NOT NULL,
    distance_m DOUBLE PRECISION NOT NULL,
    PRIMARY KEY (mark1_id, mark2_id),
    -- 保证 (mark1, mark2) 与 (mark2, mark1) 不会同时存在
    CHECK (mark1_id < mark2_id),
    -- 外键约束
    FOREIGN KEY (mark1_id) REFERENCES marks (id) ON DELETE CASCADE,
    FOREIGN KEY (mark2_id) REFERENCES marks (id) ON DELETE CASCADE
);
CREATE TYPE user_type_enum AS ENUM ('user', 'admin', 'root');
CREATE TABLE IF NOT EXISTS users
(
    id         UUID           NOT NULL DEFAULT gen_random_uuid(),
    username   VARCHAR(255)   NOT NULL UNIQUE,
    pwd_hash   VARCHAR(255)   NOT NULL,
    user_type  user_type_enum NOT NULL DEFAULT 'user',
    created_at TIMESTAMPTZ    NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ    NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);
CREATE TABLE IF NOT EXISTS base_stations
(
    id           UUID             NOT NULL DEFAULT gen_random_uuid(),
    station_name VARCHAR(255)     NOT NULL,
    location_x   DOUBLE PRECISION NOT NULL,
    location_y   DOUBLE PRECISION NOT NULL,
    created_at   TIMESTAMPTZ      NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ      NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);
-- 添加索引以提高查询性能
-- marks 表索引
CREATE INDEX IF NOT EXISTS idx_marks_type_id ON marks (mark_type_id);
CREATE INDEX IF NOT EXISTS idx_marks_created_at_desc ON marks (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_marks_last_online_desc ON marks (last_online_at DESC) WHERE last_online_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_marks_persist_mqtt ON marks (persist_mqtt) WHERE persist_mqtt = true;
-- 复合索引：用于同时筛选类型和时间的查询
CREATE INDEX IF NOT EXISTS idx_marks_type_created ON marks (mark_type_id, created_at DESC);
-- mark_tag_relation 表索引
CREATE INDEX IF NOT EXISTS idx_mark_tag_relation_tag_id ON mark_tag_relation (tag_id);
-- base_stations 表索引
CREATE INDEX IF NOT EXISTS idx_base_stations_name ON base_stations (station_name);
CREATE INDEX IF NOT EXISTS idx_base_stations_created_at_desc ON base_stations (created_at DESC);
-- 空间查询索引（如果需要按位置范围查询）
CREATE INDEX IF NOT EXISTS idx_base_stations_location ON base_stations (location_x, location_y);
-- 创建自制地图表
CREATE TABLE IF NOT EXISTS custom_maps
(
    id          UUID             NOT NULL DEFAULT gen_random_uuid(),
    map_name    VARCHAR(255)     NOT NULL,
    image_path  VARCHAR(500),
    x_min       DOUBLE PRECISION NOT NULL,
    x_max       DOUBLE PRECISION NOT NULL,
    y_min       DOUBLE PRECISION NOT NULL,
    y_max       DOUBLE PRECISION NOT NULL,
    center_x    DOUBLE PRECISION NOT NULL,
    center_y    DOUBLE PRECISION NOT NULL,
    scale_ratio DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    description TEXT,
    created_at  TIMESTAMPTZ      NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ      NOT NULL DEFAULT now(),
    PRIMARY KEY (id)
);
-- custom_maps 表索引
CREATE INDEX IF NOT EXISTS idx_custom_maps_map_name ON custom_maps (map_name);
CREATE INDEX IF NOT EXISTS idx_custom_maps_created_at_desc ON custom_maps (created_at DESC);
-- 添加注释
COMMENT ON TABLE custom_maps IS '自制地图底图表';
COMMENT ON COLUMN custom_maps.id IS '主键ID';
COMMENT ON COLUMN custom_maps.map_name IS '地图名称';
COMMENT ON COLUMN custom_maps.image_path IS '图片存储路径';
COMMENT ON COLUMN custom_maps.x_min IS 'X坐标系最小值';
COMMENT ON COLUMN custom_maps.x_max IS 'X坐标系最大值';
COMMENT ON COLUMN custom_maps.y_min IS 'Y坐标系最小值';
COMMENT ON COLUMN custom_maps.y_max IS 'Y坐标系最大值';
COMMENT ON COLUMN custom_maps.center_x IS '地图中心点X坐标';
COMMENT ON COLUMN custom_maps.center_y IS '地图中心点Y坐标';
COMMENT ON COLUMN custom_maps.scale_ratio IS '底图缩放比例（默认1.0表示原始大小）';
COMMENT ON COLUMN custom_maps.description IS '地图描述（可选）';
COMMENT ON COLUMN custom_maps.created_at IS '创建时间';
COMMENT ON COLUMN custom_maps.updated_at IS '更新时间';
-- 启用 PostGIS 扩展（如果还没有）
CREATE EXTENSION IF NOT EXISTS postgis;
-- 创建多边形围栏表
CREATE TABLE polygon_fences
(
    id          UUID PRIMARY KEY              DEFAULT gen_random_uuid(),
    is_indoor   BOOLEAN              NOT NULL DEFAULT TRUE, -- FALSE=室外，TRUE=室内
    fence_name  VARCHAR(255)         NOT NULL UNIQUE,
    geometry    GEOMETRY(POLYGON, 0) NOT NULL, -- 只存储多边形
    description TEXT,
    is_active   BOOLEAN                       DEFAULT true,
    created_at  TIMESTAMP            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP            NOT NULL DEFAULT CURRENT_TIMESTAMP
);
-- 创建空间索引，提高查询性能
CREATE INDEX idx_polygon_fences_geometry ON polygon_fences USING GIST (geometry);
-- 创建索引加速名称查询
CREATE INDEX idx_polygon_fences_name ON polygon_fences (fence_name);
CREATE INDEX idx_polygon_fences_active ON polygon_fences (is_active);
CREATE INDEX idx_polygon_fences_indoor_active ON polygon_fences (is_indoor, is_active);
-- 创建多边形围栏与标记的多对多关系表
CREATE TABLE IF NOT EXISTS polygon_fence_mark_relation
(
    fence_id UUID NOT NULL,
    mark_id  UUID NOT NULL,
    PRIMARY KEY (fence_id, mark_id),
    FOREIGN KEY (fence_id) REFERENCES polygon_fences (id) ON DELETE CASCADE,
    FOREIGN KEY (mark_id) REFERENCES marks (id) ON DELETE CASCADE
);
-- 为关系表创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_polygon_fence_mark_relation_fence_id ON polygon_fence_mark_relation (fence_id);
CREATE INDEX IF NOT EXISTS idx_polygon_fence_mark_relation_mark_id ON polygon_fence_mark_relation (mark_id);
-- 添加注释
COMMENT ON TABLE polygon_fence_mark_relation IS '多边形围栏与标记的多对多关系表';
COMMENT ON COLUMN polygon_fence_mark_relation.fence_id IS '围栏ID，外键关联polygon_fences表';
COMMENT ON COLUMN polygon_fence_mark_relation.mark_id IS '标记ID，外键关联marks表';
```
