# app/models/models.py
from tortoise.models import Model
from tortoise import fields
from enum import Enum
from datetime import datetime


# 权限枚举类，定义用户权限类型（考虑Python版本，使用StrEnum需3.11+，此处保持兼容性）
class Permissions(str, Enum):
    USER = "user"
    ADMIN = "admin"
    EDITOR = "editor"


# 用户模型
class User(Model):
    id = fields.IntField(primary_key=True, description="用户ID")
    name = fields.CharField(max_length=50, unique=True, description="用户名，唯一")
    password = fields.CharField(
        max_length=60, description="用户密码的BCrypt哈希值，固定60字符"
    )
    email = fields.CharField(max_length=255, unique=True, description="用户邮箱，唯一")
    permissions = fields.CharEnumField(
        Permissions, default=Permissions.USER, description="用户权限"
    )

    # 关系字段

    def __str__(self):
        return self.id+self.name+self.email+self.permissions

    class Meta:
        table = "users"
