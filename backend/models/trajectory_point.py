# models/trajectory_point.py
from tortoise.models import Model
from tortoise import fields


class TrajectoryPoint(Model):
    id = fields.IntField(primary_key=True, description="轨迹点ID")
    device_id = fields.IntField(index=True, description="设备ID")
    latitude = fields.FloatField(description="纬度")
    longitude = fields.FloatField(description="经度")
    timestamp = fields.DatetimeField(
        auto_now_add=True, index=True, description="时间戳"
    )

    class Meta:
        table = "trajectory_points"
