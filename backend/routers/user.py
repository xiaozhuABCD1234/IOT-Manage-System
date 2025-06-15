# routes/users.py
from fastapi import APIRouter, status, Query
from schemas.user import (
    UserCreate,
    UserRead,
    UserUpdate,
    UserPasswordUpdate,
    UserPermissionUpdate,
    PaginatedUsers,
)
from crud.user import CRUDUser

router = APIRouter()


# 创建新用户
@router.post(
    "/",
    response_model=UserRead,
    status_code=status.HTTP_201_CREATED,
    summary="创建新用户",
)
async def create_user(user_data: UserCreate):
    return await CRUDUser.create_user(user_data)


# 分页获取用户
@router.get("/paginated", response_model=PaginatedUsers, summary="分页获取用户列表")
async def get_paginated_users(
    page: int = Query(1, gt=0),
    page_size: int = Query(10, gt=0, le=100),
):
    return await CRUDUser.read_users_paginated(page, page_size)


# 获取所有用户
@router.get("/", response_model=list[UserRead], summary="获取所有用户")
async def get_all_users():
    return await CRUDUser.read_all_users()


# 根据ID获取用户详情
@router.get("/{user_id}", response_model=UserRead, summary="获取用户详情")
async def get_user(user_id: int):
    return await CRUDUser.get_user_by_id(user_id)


# 更新用户基本信息
@router.put("/{user_id}/info", response_model=UserRead, summary="更新用户基本信息")
async def update_user_info(
    user_id: int,
    update_data: UserUpdate,
):
    return await CRUDUser.update_user_info(user_id, update_data)


# 更新用户密码
@router.put("/{user_id}/password", response_model=UserRead, summary="更新用户密码")
async def update_user_password(
    user_id: int,
    update_data: UserPasswordUpdate,
):
    return await CRUDUser.update_user_password(user_id, update_data)


# 更新用户权限（需要管理员权限）
@router.put("/{user_id}/permissions", response_model=UserRead, summary="更新用户权限")
async def update_user_permissions(
    user_id: int,
    update_data: UserPermissionUpdate,
):
    return await CRUDUser.update_user_permissions(user_id, update_data)


# 删除用户
@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT, summary="删除用户")
async def delete_user(user_id: int):
    await CRUDUser.delete_user(user_id)
