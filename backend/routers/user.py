from fastapi import APIRouter, Depends, HTTPException, status
from models.models import User
from schemas.user import (
    UserCreate,
    UserRead,
    UserUpdate,
    UserPasswordUpdate,
    UserPermissionUpdate,
)
from crud.user import CRUDUser
from core.security import Security

router = APIRouter()


# 创建新用户（管理员操作）
@router.post(
    "/",
    response_model=UserRead,
    status_code=status.HTTP_201_CREATED,
    summary="创建新用户（管理员操作）",
    description="接收用户的基本信息，创建一个新的用户记录，并返回用户详情。此操作需要管理员权限。",
)
async def create_user(user_data: UserCreate):
    # current_user: User = Depends(Security.get_current_user),
    # await Security.check_user_permissions(current_user, required_permission="admin")
    return await CRUDUser.create_user(user_data)


# 获取所有用户（管理员操作）
@router.get(
    "/",
    response_model=list[UserRead],
    summary="获取所有用户（管理员操作）",
    description="返回系统中所有用户的列表，包括用户的基本信息。此操作需要管理员权限。",
)
async def get_all_users():
    # current_user: User = Depends(Security.get_current_user),
    # await Security.check_user_permissions(current_user, required_permission="admin")
    return await CRUDUser.read_user_all()


# 根据用户ID获取用户详情
@router.get(
    "/{user_id}",
    response_model=UserRead,
    summary="根据用户ID获取用户详情",
    description="通过指定的用户ID，返回该用户的具体信息。任何用户都可以查询自己的信息，管理员可以查询任何用户的信息。",
)
async def get_user_by_id(user_id: int):
    # current_user: User = Depends(Security.get_current_user),
    # await Security.check_user_permissions(current_user, user_id)
    return await CRUDUser.read_user_id(user_id)


# 根据用户ID更新用户信息
@router.put(
    "/{user_id}",
    response_model=UserRead,
    summary="根据用户ID更新用户信息",
    description="更新指定用户的基本信息（如用户名、邮箱等）。需要验证当前用户是否有权限更新指定用户的信息。",
)
async def update_user_info(
    user_id: int,
    user_data: UserUpdate,
):
    # current_user: User = Depends(Security.get_current_user),
    # await Security.check_user_permissions(current_user, user_id)
    return await CRUDUser.update_user_name_or_email(user_id, user_data)


# 根据用户ID更新用户密码
@router.put(
    "/password/{user_id}",
    response_model=UserRead,
    summary="根据用户ID更新用户密码",
    description="更新指定用户的密码。需要验证当前用户是否有权限更新指定用户的信息。",
)
async def update_user_password(
    user_id: int,
    user_data: UserPasswordUpdate,
):
    # current_user: User = Depends(Security.get_current_user),
    # await Security.check_user_permissions(current_user, user_id)
    return await CRUDUser.update_user_password(user_id, user_data)


# 根据用户ID更新用户权限
@router.put(
    "/permissions/{user_id}",
    response_model=UserRead,
    summary="根据用户ID更新用户权限",
    description="更新指定用户的权限。此操作需要管理员权限。",
)
async def update_user_permissions(
    user_id: int,
    user_data: UserPermissionUpdate,
):
    # current_user: User = Depends(Security.get_current_user),
    # await Security.check_user_permissions(current_user, required_permission="admin")
    return await CRUDUser.update_user_permissions(user_id, user_data)


# 根据用户ID删除用户
@router.delete(
    "/{user_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="根据用户ID删除用户",
    description="删除指定用户。需要验证当前用户是否有权限删除指定用户。",
)
async def delete_user_by_id(
    user_id: int,
):
    # current_user: User = Depends(Security.get_current_user),
    # await Security.check_user_permissions(current_user, user_id)
    return await CRUDUser.delete_user(user_id)
