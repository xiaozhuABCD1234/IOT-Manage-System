from fastapi import FastAPI, Request, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from datetime import datetime, timezone


from models.models import User
from core.config import settings
from core.security import Security

# OAuth2PasswordBearer 实例
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")


# 定义中间件
async def get_user_permissions_middleware(request: Request):
    """
    中间件：获取用户的权限级别，并将其存储在请求的 state 属性中。
    """
    token = await oauth2_scheme(request)  # 从请求中获取 JWT 令牌
    payload = Security.decode_token(token)  # 解码 JWT 令牌
    if not payload:
        request.state.user_permissions = "visitor"
        return

    user_id = payload.get("sub")
    if not user_id:
        request.state.user_permissions = "visitor"
        return

    exp = payload.get("exp")
    if exp and datetime.now(timezone.utc) > datetime.fromtimestamp(exp, timezone.utc):
        request.state.user_permissions = "visitor"
        return

    user = await User.get_or_none(id=user_id)
    if not user:
        request.state.user_permissions = "visitor"
        return

    role = payload.get("role")
    if user_id == 1 or role == "admin":
        request.state.user_permissions = "admin"
    elif role == "editor":
        request.state.user_permissions = "editor"
    else:
        request.state.user_permissions = "user"
