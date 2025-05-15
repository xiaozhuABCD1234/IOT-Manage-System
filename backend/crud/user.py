# crud/user.py
from fastapi import HTTPException
from tortoise.transactions import in_transaction

from models.models import User
from schemas.user import (
    UserCreate,
    UserRead,
    UserUpdate,
    UserRegister,
    UserPermissionUpdate,
    UserPasswordUpdate,
    Permissions,
    PaginatedUsers,
)
from core.security import Security


async def get_user_or_404(user_id: int) -> User:
    """获取用户或抛出404异常"""
    user = await User.get_or_none(id=user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


async def _check_unique_constraints(
    user_data: UserCreate | UserUpdate | UserRegister, existing_user: User | None = None
) -> None:
    """检查唯一性约束"""
    # 检查用户名
    if user_data.name is not None:
        query = User.filter(name=user_data.name)
        if existing_user:
            query = query.exclude(id=existing_user.id)
        if await query.exists():
            raise HTTPException(status_code=400, detail="Username already exists")

    # 检查邮箱
    if user_data.email is not None:
        query = User.filter(email=user_data.email)
        if existing_user:
            query = query.exclude(id=existing_user.id)
        if await query.exists():
            raise HTTPException(status_code=400, detail="Email already exists")

    # 检查手机号
    if user_data.phone_number is not None:
        query = User.filter(phone_number=user_data.phone_number)
        if existing_user:
            query = query.exclude(id=existing_user.id)
        if await query.exists():
            raise HTTPException(status_code=400, detail="Phone number already exists")


class CRUDUser:
    """优化后的用户CRUD操作"""

    @staticmethod
    async def create_user(user_data: UserCreate) -> User:
        """创建用户（带事务支持）"""
        async with in_transaction():
            await _check_unique_constraints(user_data)
            user_data.password = Security.get_password_hash(user_data.password)
            new_user = await User.create(
                **user_data.model_dump(
                    exclude={"password", "created_at", "updated_at"}, exclude_unset=True
                ),
                password=user_data.password,
            )
            return new_user

    @staticmethod
    async def register_user(user_data: UserRegister) -> User:
        """用户注册（带事务支持）"""
        async with in_transaction():
            await _check_unique_constraints(user_data)
            hashed_password = Security.get_password_hash(user_data.password)
            new_user = await User.create(
                name=user_data.name,
                email=user_data.email,
                phone_number=user_data.phone_number,
                password=hashed_password,
                permissions=Permissions.USER,
            )
            return new_user

    @staticmethod
    async def update_user_info(user_id: int, update_data: UserUpdate) -> User:
        """更新用户基本信息"""
        async with in_transaction():
            user = await get_user_or_404(user_id)
            await _check_unique_constraints(update_data, existing_user=user)
            update_dict = update_data.model_dump(exclude_unset=True)
            await user.update_from_dict(update_dict)
            await user.save()
            return user

    @staticmethod
    async def update_user_password(
        user_id: int, update_data: UserPasswordUpdate
    ) -> User:
        """更新用户密码"""
        async with in_transaction():
            user = await get_user_or_404(user_id)
            hashed_password = Security.get_password_hash(update_data.password)
            user.password = hashed_password
            await user.save()
            return user

    @staticmethod
    async def update_user_permissions(
        user_id: int, update_data: UserPermissionUpdate
    ) -> User:
        """更新用户权限"""
        async with in_transaction():
            user = await get_user_or_404(user_id)
            user.permissions = update_data.permissions
            await user.save()
            return user

    @staticmethod
    async def read_all_users() -> list[UserRead]:
        """获取所有用户（优化查询）"""
        users = await User.all().values()
        return [UserRead.model_validate(user) for user in users]

    @staticmethod
    async def delete_user(user_id: int) -> None:
        """删除用户（优化异常处理）"""
        user = await get_user_or_404(user_id)
        await user.delete()

    @staticmethod
    async def read_users_paginated(
        page: int = 1,
        page_size: int = 10,
        min_page_size: int = 1,
        max_page_size: int = 100,
    ) -> PaginatedUsers:
        """
        分页查询用户
        :param page: 当前页码（从1开始）
        :param page_size: 每页数量
        :param min_page_size: 最小允许的每页数量
        :param max_page_size: 最大允许的每页数量
        """
        # 参数校验
        if page < 1:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid page number: {page}. Page number must be positive",
            )

        page_size = max(min(page_size, max_page_size), min_page_size)

        # 计算偏移量
        offset = (page - 1) * page_size

        # 执行查询
        users_query = User.all().offset(offset).limit(page_size)
        total = await User.all().count()
        users = await users_query.values()

        return PaginatedUsers(
            total=total,
            page=page,
            page_size=page_size,
            items=[UserRead.model_validate(user) for user in users],
        )

    @staticmethod
    async def get_user_by_name(name: str) -> User | None:
        """根据用户名获取用户"""
        user = await User.get_or_none(name=name)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return user

    @staticmethod
    async def get_user_by_id(user_id: int) -> User | None:
        """根据用户ID获取用户"""
        user = await User.get_or_none(id=user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return user

    @staticmethod
    async def get_user_by_email(email: str) -> User | None:
        """根据邮箱获取用户"""
        user = await User.get_or_none(email=email)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return user

    @staticmethod
    async def get_user_by_phone_number(phone_number: str) -> User | None:
        """根据手机号获取用户"""
        user = await User.get_or_none(phone_number=phone_number)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return user

    @staticmethod
    async def get_user_by_permissions(permissions: Permissions) -> User | None:
        """根据权限获取用户"""
        user = await User.get_or_none(permissions=permissions)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return user
