package service

import (
	"IOT-Manage-System/user-service/model"
	"IOT-Manage-System/user-service/repository"
	"IOT-Manage-System/user-service/utils"
	// "log"
	// "time"
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
	// start := time.Now()

	user, err := a.repo.FindByUsername(req.Username)
	// log.Printf("FindByUsername took %v", time.Since(start))
	if err != nil {
		return nil, ErrUserNotFound
	}
	if !utils.ComparePwd(req.Password, user.PwdHash) {
		return nil, ErrWrongPassword
	}

	accessToken, err := utils.GenerateToken(user)
	// log.Printf("GenerateToken took %v", time.Since(start))
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
