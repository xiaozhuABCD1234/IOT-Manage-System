# app/schemas/user.py
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from enum import Enum


# 权限枚举类
class Permissions(str, Enum):
    USER = "user"  # 普通用户
    ADMIN = "admin"  # 管理员
    EDITOR = "editor"  # 编辑


# 用户注册模型
class UserRegister(BaseModel):
    name: str = Field(..., max_length=50, description="用户名，必须唯一")
    password: str = Field(..., min_length=6, description="用户密码，至少6位")
    email: EmailStr = Field(..., description="用户邮箱，必须唯一")


# 用户创建模型
class UserCreate(UserRegister):
    permissions: Optional[Permissions] = Field(
        Permissions.USER, description="用户权限，默认为普通用户"
    )

    class Config:
        use_enum_values = True  # 自动将枚举值转换为字符串


# 用户查询模型
class UserRead(BaseModel):
    id: int = Field(..., description="用户ID")
    name: str = Field(..., max_length=50, description="用户名")
    email: EmailStr = Field(..., description="用户邮箱")
    permissions: Permissions  # 添加权限字段

    class Config:
        from_attributes = True  # 启用 from_attributes 模式
        use_enum_values = True  # 自动将枚举值转换为字符串


# 用户更新模型
class UserUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=50, description="用户名，可选")
    email: Optional[EmailStr] = Field(None, description="用户邮箱，可选")

    class Config:
        use_enum_values = True  # 自动将枚举值转换为字符串


# 用户密码更新模型
class UserPasswordUpdate(BaseModel):
    # old_password: str = Field(..., min_length=6, description="旧密码，至少5位")
    password: str = Field(..., min_length=5, description="新密码，至少5位")


# 用户权限更新模型
class UserPermissionUpdate(BaseModel):
    permissions: Permissions  # 使用枚举类直接定义字段类型

    class Config:
        use_enum_values = True  # 自动将枚举值转换为字符串