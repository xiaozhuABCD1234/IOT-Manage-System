from typing import cast
from models.position_model import PositionData
from schemas.trajectory import (
    TrajectoryPointIn,
    TrajectoryPointOut,
    PointReadArgs,
)


class Position:
    @staticmethod
    async def create_position_point(
        position_data: TrajectoryPointIn,
    ) -> TrajectoryPointOut:
        """
        创建新的轨迹点。
        1. 创建轨迹点并保存到数据库。
        """
        trajectory_point = await PositionData.create(
            device_id=position_data.device_id,
            latitude=position_data.latitude,
            longitude=position_data.longitude,
            timestamp=position_data.timestamp,
        )
        return TrajectoryPointOut.model_validate(trajectory_point)

    @staticmethod
    async def get_position_points(data: PointReadArgs) -> list[TrajectoryPointOut]:
        """
        获取设备在指定时间范围内的轨迹点。
        1. 验证时间参数。
        2. 构建查询以过滤指定设备和时间范围的轨迹点。
        4. 返回按时间戳排序的轨迹点列表。
        """

        # 2. 构建基础查询
        points = (
            await PositionData.filter(
                device_id=data.id,
                timestamp__gte=data.start_time,
                timestamp__lte=data.end_time,
            )
            .order_by("timestamp")
            .all()
        )

        # 5. 转换为输出模型
        return [TrajectoryPointOut.model_validate(point) for point in points]

    @staticmethod
    async def get_unique_device_ids() -> list[int]:
        # 查询所有不同的设备ID
        device_ids = (
            await PositionData.all().distinct().values_list("device_id", flat=True)
        )
        return cast(list[int], device_ids)
