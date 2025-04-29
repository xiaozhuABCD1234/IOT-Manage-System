from fastapi import Depends, HTTPException, status
from passlib.context import CryptContext
from jose import jwt, JWTError
from datetime import datetime, timedelta, timezone
from typing import Optional
from fastapi.security import OAuth2PasswordBearer

from models.models import User
from core.config import settings


class Security:
    """
    安全工具类，用于处理密码加密、JWT 令牌生成与验证、用户认证与权限检查等安全相关功能。
    """

    # 密码加密工具，使用 bcrypt 算法
    pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

    # JWT 配置
    SECRET_KEY = (
        settings.SECRET_KEY
    )  # 从配置文件中获取密钥，建议使用 openssl rand -hex 32 生成
    ALGORITHM = settings.ALGORITHM  # 使用的加密算法
    ACCESS_TOKEN_EXPIRE_MINUTES = (
        settings.ACCESS_TOKEN_EXPIRE_MINUTES
    )  # 令牌过期时间（分钟）

    @staticmethod
    def get_password_hash(password: str) -> str:
        """
        生成密码的哈希值。

        :param password: 明文密码
        :return: 加密后的密码哈希值
        """
        return Security.pwd_context.hash(password)

    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        """
        验证明文密码与哈希密码是否匹配。

        :param plain_password: 明文密码
        :param hashed_password: 加密后的密码哈希值
        :return: 如果密码匹配返回 True，否则返回 False
        """
        return Security.pwd_context.verify(plain_password, hashed_password)

    @staticmethod
    def create_access_token(
        data: dict, expires_delta: Optional[timedelta] = None
    ) -> str:
        """
        创建 JWT 令牌。

        :param data: 要编码到令牌中的数据
        :param expires_delta: 令牌过期时间（可选）
        :return: 生成的 JWT 令牌
        """
        to_encode = data.copy()
        if expires_delta:
            expire = datetime.now(timezone.utc) + expires_delta
        else:
            expire = datetime.now(timezone.utc) + timedelta(
                minutes=Security.ACCESS_TOKEN_EXPIRE_MINUTES
            )
        to_encode.update({"exp": expire})
        encoded_jwt = jwt.encode(
            to_encode, Security.SECRET_KEY, algorithm=Security.ALGORITHM
        )
        return encoded_jwt

    @staticmethod
    def decode_token(token: str) -> Optional[dict]:
        """
        解码 JWT 令牌。

        :param token: JWT 令牌
        :return: 解码后的令牌数据，如果解码失败返回 None
        """
        try:
            payload = jwt.decode(
                token, Security.SECRET_KEY, algorithms=[Security.ALGORITHM]
            )
            return payload
        except JWTError:
            return None

    @staticmethod
    async def authenticate_user(username: str, password: str) -> Optional[User]:
        """
        验证用户身份。

        :param username: 用户名
        :param password: 明文密码
        :return: 如果验证成功返回用户对象，否则返回 None
        """
        user = await User.get_or_none(name=username)
        if not user:
            return None
        if not Security.verify_password(password, user.password):
            return None
        return user

    @staticmethod
    async def get_current_user(
        token: str = Depends(OAuth2PasswordBearer(tokenUrl="token")),
    ) -> User:
        """
        获取当前认证用户。

        :param token: JWT 令牌
        :return: 当前用户对象
        :raises HTTPException: 如果令牌无效或用户不存在
        """
        payload = Security.decode_token(token)
        if not payload:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token",
            )
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token",
            )
        user = await User.get_or_none(id=user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found",
            )
        # 验证时间
        exp = payload.get("exp")
        if exp and datetime.now(timezone.utc) > datetime.fromtimestamp(
            exp, timezone.utc
        ):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token has expired",
            )
        return user

    @staticmethod
    async def check_user_permissions(current_user: User, target_user_id: int) -> None:
        """
        检查当前用户是否有权限操作目标用户。

        :param current_user: 当前用户对象
        :param target_user_id: 目标用户ID
        :raises HTTPException: 如果当前用户没有权限
        """
        if current_user.id != target_user_id and current_user.permissions != "admin":
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to perform this action",
            )

    @staticmethod
    async def get_user_permissions(
        token: str = Depends(OAuth2PasswordBearer(tokenUrl="token")),
    ) -> str:
        """
        获取用户的权限级别。

        :param token: JWT 令牌
        :return: 用户的权限级别（"admin"、"user" 或 "visitor"）
        """
        payload = Security.decode_token(token)
        if not payload:
            return "visitor"
        user_id = payload.get("sub")
        if not user_id:
            return "visitor"
        exp = payload.get("exp")
        if exp and datetime.now(timezone.utc) > datetime.fromtimestamp(
            exp, timezone.utc
        ):
            return "visitor"
        user = await User.get_or_none(id=user_id)
        if not user:
            return "visitor"
        if user_id == 1 or user.permissions == "admin":
            return "admin"
        elif user.permissions == "editor":
            return "editor"
        return "user"
