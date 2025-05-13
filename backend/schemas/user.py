# app/schemas/user.py
from pydantic import BaseModel, EmailStr, Field, ConfigDict
from enum import Enum


# 权限枚举类（保持原样）
class Permissions(str, Enum):
    USER = "user"
    ADMIN = "admin"
    EDITOR = "editor"


# 用户注册模型
class UserRegister(BaseModel):
    name: str = Field(..., max_length=50, description="用户名，必须唯一")
    password: str = Field(..., min_length=6, description="用户密码，至少6位")
    email: EmailStr = Field(..., description="用户邮箱，必须唯一")


# 用户创建模型
class UserCreate(UserRegister):
    permissions: Permissions | None = Field(
        default=Permissions.USER,  # 注意这里的参数名变更
        description="用户权限，默认为普通用户",
    )

    model_config = ConfigDict(
        use_enum_values=True,  # 替代原来的Config.use_enum_values
        populate_by_name=True,  # 允许别名优先（可选）
    )


# 用户查询模型
class UserRead(BaseModel):
    id: int = Field(..., description="用户ID")
    name: str = Field(..., max_length=50, description="用户名")
    email: EmailStr = Field(..., description="用户邮箱")
    permissions: Permissions

    model_config = ConfigDict(
        from_attributes=True, use_enum_values=True  # 替代原来的orm_mode
    )


# 用户更新模型
class UserUpdate(BaseModel):
    name: str | None = Field(
        default=None, max_length=50, description="用户名，可选"  # 参数名变更
    )
    email: EmailStr | None = Field(default=None, description="用户邮箱，可选")

    model_config = ConfigDict(use_enum_values=True)


# 用户密码更新模型
class UserPasswordUpdate(BaseModel):
    password: str = Field(..., min_length=5, description="新密码，至少5位")

    # V2 默认不需要额外配置
    # model_config = ConfigDict(extra="forbid")  # 可选：禁止额外字段


# 用户权限更新模型
class UserPermissionUpdate(BaseModel):
    permissions: Permissions

    model_config = ConfigDict(
        use_enum_values=True,
        json_schema_extra={  # 可选：增强OpenAPI文档
            "examples": [{"permissions": "admin"}]
        },
    )
