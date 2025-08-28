package utils

import (
	"golang.org/x/crypto/bcrypt"
)

// GetPwd 将明文密码生成 bcrypt 哈希并返回字符串
func GetPwd(pwd string) (string, error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(pwd), bcrypt.DefaultCost)
	return string(hash), err
}

// ComparePwd 比较明文密码 plain 与已哈希值 hashed，返回是否匹配
func ComparePwd(plain, hashed string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hashed), []byte(plain))
	return err == nil
}
