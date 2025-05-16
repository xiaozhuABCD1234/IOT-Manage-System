# schemas/user.py
from enum import Enum
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field, ConfigDict, model_validator


class Permissions(str, Enum):
    """可用的用户权限类型"""

    ADMIN = "admin"
    EDITOR = "editor"
    USER = "user"


class UserBase(BaseModel):
    """基础用户数据模型"""

    name: str = Field(..., max_length=50, description="用户名")
    email: EmailStr | None = Field(default=None, description="用户邮箱")
    phone_number: str | None = Field(default=None, description="用户手机号")

    @model_validator(mode="before")
    @classmethod
    def check_empty_strings(cls, data: dict) -> dict:
        """将空字符串转换为None"""
        if isinstance(data, dict):
            if "email" in data and data["email"] == "":
                data["email"] = None
            if "phone_number" in data and data["phone_number"] == "":
                data["phone_number"] = None
        return data

class UserRegister(UserBase):
    """
    用户注册数据模型

    验证用户注册时的必要信息，包括密码强度和联系方式完整性
    """

    password: str = Field(..., min_length=6, description="用户密码，至少6位")

    @model_validator(mode="after")
    def check_contact_info(self):
        """验证联系方式完整性"""
        if self.email is None and self.phone_number is None:
            raise ValueError("必须提供邮箱或手机号")
        return self


class UserCreate(UserRegister, UserBase):
    """用户创建模型（合并注册和基础信息验证）"""

    permissions: Permissions | None = Field(
        default=Permissions.USER,
        description="用户权限，默认为普通用户",
    )


class UserRead(UserBase):
    """
    用户读取模型

    用于API响应，包含数据库用户ID
    """

    id: int = Field(..., description="用户ID")
    created_at: datetime | None = None
    updated_at: datetime | None = None
    permissions: Permissions = Field(...,
        description="用户权限，默认为普通用户",
    )
    model_config = ConfigDict(from_attributes=True)


class UserUpdate(BaseModel):
    """用户更新模型"""

    name: str | None = Field(None, max_length=50)
    email: EmailStr | None = None
    phone_number: str | None = None
    permissions: Permissions | None = None


class UserPermissionUpdate(BaseModel):
    """权限更新模型"""

    permissions: Permissions = Field(..., description="新权限")


class UserPasswordUpdate(BaseModel):
    """密码更新模型"""

    password: str = Field(..., min_length=6, description="新密码，至少6位")


class PaginatedUsers(BaseModel):
    total: int = Field(..., description="总记录数")
    page: int = Field(..., description="当前页码")
    page_size: int = Field(..., description="每页数量")
    items: list[UserRead] = Field(..., description="用户列表")
