# app/crud/user.py
from fastapi import HTTPException
# from sqlmodel import Session, select
from typing import List, Optional
from pydantic import EmailStr

from models.models import User
from schemas.user import (
    UserCreate,
    UserRead,
    UserUpdate,
    UserRegister,
    UserPermissionUpdate,
    UserPasswordUpdate,
)
from core.security import Security


async def _check_user_name_is_existing(name: str) -> None:
    """
    检查用户名是否已存在。
    如果用户名已存在，抛出 HTTP 400 错误。
    """
    user = await User.get_or_none(name=name)
    if user:
        raise HTTPException(status_code=400, detail="Username already exists")


async def _check_user_email_is_existing(email: EmailStr) -> None:
    """
    检查邮箱是否已存在。
    如果邮箱已存在，抛出 HTTP 400 错误。
    """
    user = await User.get_or_none(email=email)
    if user:
        raise HTTPException(status_code=400, detail="Email already exists")


class CRUDUser:
    """
    用户相关的 CRUD 操作类。
    """

    @staticmethod
    async def create_user(user_data: UserCreate) -> User:
        """
        创建新用户。
        1. 检查邮箱和用户名是否已存在。
        2. 对密码进行哈希处理。
        3. 创建用户并保存到数据库。
        4. 如果用户是第一个用户（id == 1），将其权限设置为管理员。
        """
        await _check_user_email_is_existing(user_data.email)
        await _check_user_name_is_existing(user_data.name)
        user_data.password = Security.get_password_hash(user_data.password)
        new_user = await User.create(
            name=user_data.name,
            email=user_data.email,
            password=user_data.password,
            permissions=user_data.permissions,
        )
        if new_user.id == 1:
            new_user.permissions = "admin"
        await new_user.save()
        return new_user

    @staticmethod
    async def register_user(user_data: UserRegister) -> User:
        """
        注册新用户。
        1. 检查邮箱和用户名是否已存在。
        2. 对密码进行哈希处理。
        3. 创建用户并保存到数据库，权限默认为普通用户。
        """
        await _check_user_email_is_existing(user_data.email)
        await _check_user_name_is_existing(user_data.name)
        user_data.password = Security.get_password_hash(user_data.password)
        new_user = await User.create(
            name=user_data.name,
            email=user_data.email,
            password=user_data.password,
            permissions="user",  # 默认权限为普通用户
        )
        return new_user

    @staticmethod
    async def update_user_name_or_email(user_id: int, user_data: UserUpdate) -> User:
        """
        更新用户的用户名或邮箱。
        1. 检查用户是否存在，如果不存在则抛出 HTTP 404 错误。
        2. 如果提供了新邮箱或新用户名，检查是否已存在。
        3. 更新用户信息并保存到数据库。
        """
        user = await User.get_or_none(id=user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        if user_data.email:
            await _check_user_email_is_existing(user_data.email)
        if user_data.name:
            await _check_user_name_is_existing(user_data.name)
        update_data = user_data.model_dump(exclude_unset=True)  # 仅更新提供的字段
        await user.update_from_dict(update_data)
        await user.save()
        return user

    @staticmethod
    async def update_user_permissions(
        user_id: int, user_data: UserPermissionUpdate
    ) -> User:
        """
        更新用户权限。
        1. 检查用户是否存在，如果不存在则抛出 HTTP 404 错误。
        2. 更新用户权限并保存到数据库。
        """
        user = await User.get_or_none(id=user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        update_data = user_data.model_dump(exclude_unset=True)  # 仅更新提供的字段
        await user.update_from_dict(update_data)
        await user.save()
        return user

    @staticmethod
    async def update_user_password(user_id: int, user_data: UserPasswordUpdate) -> User:
        """
        更新用户密码。
        1. 检查用户是否存在，如果不存在则抛出 HTTP 404 错误。
        2. 对新密码进行哈希处理。
        3. 更新用户密码并保存到数据库。
        """
        user = await User.get_or_none(id=user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        if user_data.password:
            user_data.password = Security.get_password_hash(user_data.password)
        update_data = user_data.model_dump(exclude_unset=True)  # 仅更新提供的字段
        await user.update_from_dict(update_data)
        await user.save()
        return user

    @staticmethod
    async def read_user_all() -> List[UserRead]:
        """
        获取所有用户。
        1. 查询数据库中的所有用户。
        2. 将用户数据转换为 UserRead 模型并返回。
        """
        users = await User.all()
        return [UserRead.model_validate(dict(user)) for user in users]

    @staticmethod
    async def read_user_id(user_id: int) -> UserRead:
        """
        根据用户 ID 获取单个用户。
        1. 检查用户是否存在，如果不存在则抛出 HTTP 404 错误。
        2. 将用户数据转换为 UserRead 模型并返回。
        """
        user = await User.get_or_none(id=user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return UserRead.model_validate(user)

    @staticmethod
    async def delete_user(user_id: int) -> None:
        """
        删除用户。
        1. 检查用户是否存在，如果不存在则抛出 HTTP 404 错误。
        2. 删除用户。
        """
        user = await User.get_or_none(id=user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        await user.delete()
