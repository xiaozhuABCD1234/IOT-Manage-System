# models/trajectory_point.py
from tortoise.models import Model
from tortoise import fields


class PositionData(Model):
    id = fields.BigIntField(primary_key=True, description="轨迹点ID")
    device_id = fields.IntField(index=True, description="设备ID")
    longitude = fields.FloatField(description="经度")
    latitude = fields.FloatField(description="纬度")
    timestamp = fields.DatetimeField(index=True, description="时间戳")

    class Meta:  # type: ignore
        table = "position_data"  # 如果需要指定表名，可以在这里设置
