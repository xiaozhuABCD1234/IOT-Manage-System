# models/models.py
from tortoise.models import Model
from tortoise import fields
from schemas.user import Permissions


class User(Model):
    id = fields.IntField(primary_key=True, description="用户ID")
    name = fields.CharField(
        max_length=50, unique=True, index=True, description="用户名，唯一"
    )
    password = fields.CharField(
        max_length=60, index=True, description="用户密码的BCrypt哈希值，固定60字符"
    )
    email = fields.CharField(
        max_length=255, unique=True, null=True, index=True, description="用户邮箱，唯一"
    )
    phone_number = fields.CharField(
        max_length=20,
        unique=True,
        null=True,
        index=True,
        description="用户手机号，唯一",
    )
    created_at = fields.DatetimeField(auto_now_add=True, description="用户创建时间")
    updated_at = fields.DatetimeField(auto_now=True, description="用户更新时间")
    permissions = fields.CharEnumField(
        Permissions, default=Permissions.USER, index=True, description="用户权限"
    )

    class Meta:  # type: ignore
        table = "users"  # 如果需要指定表名，可以在这里设置
