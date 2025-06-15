# routers/user_search.py
from fastapi import APIRouter, Query
from fastapi import HTTPException
from schemas.user import UserRead
from crud.user import CRUDUser, Permissions

router = APIRouter()


@router.get(
    "/username",
    response_model=UserRead,
)
async def get_user_by_username(
    username: str | None = Query(None, title="用户名", description="用户用户名"),
):
    """根据用户名获取用户"""
    if not username:
        raise HTTPException(status_code=400, detail="Bad Request - Missing username")
    user = await CRUDUser.get_user_by_name(username)
    return user


@router.get(
    "/email",
    response_model=UserRead,
)
async def get_user_by_email(
    email: str | None = Query(None, title="邮箱", description="用户邮箱"),
):
    """根据邮箱获取用户"""
    if not email:
        raise HTTPException(status_code=400, detail="Bad Request - Missing email")
    user = await CRUDUser.get_user_by_email(email)
    return user


@router.get(
    "/phone_number",
    response_model=UserRead,
)
async def get_user_by_phone_number(
    phone_number: str | None = Query(None, title="手机号", description="用户手机号"),
):
    """根据手机号获取用户"""
    if not phone_number:
        raise HTTPException(
            status_code=400, detail="Bad Request - Missing phone number"
        )
    user = await CRUDUser.get_user_by_phone_number(phone_number)
    return user


@router.get(
    "/permissions",
    response_model=list[UserRead],
)
async def get_user_by_permissions(
    permissions: Permissions | None = Query(None, title="权限", description="用户权限"),
):
    """根据权限获取用户"""
    if not permissions:
        raise HTTPException(status_code=400, detail="Bad Request - Missing permissions")
    users = await CRUDUser.get_user_by_permissions(permissions)
    return users
