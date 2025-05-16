from datetime import datetime
from models.trajectory_point import TrajectoryPoint
from schemas.trajectory_point import (
    TrajectoryPointIn,
    TrajectoryPointOut,
    PointReadArgs,
)


async def create_trajectory_point(
    trajectory_point_data: TrajectoryPointIn,
) -> TrajectoryPointOut:
    """
    创建新的轨迹点。
    1. 创建轨迹点并保存到数据库。
    """
    trajectory_point = await TrajectoryPoint.create(
        device_id=trajectory_point_data.device_id,
        latitude=trajectory_point_data.latitude,
        longitude=trajectory_point_data.longitude,
        timestamp=datetime.now(),
    )
    return TrajectoryPointOut.model_validate(trajectory_point)


async def get_trajectory_points(data: PointReadArgs) -> list[TrajectoryPointOut]:
    """
    获取设备在指定时间范围内的轨迹点。
    1. 验证时间参数。
    2. 构建查询以过滤指定设备和时间范围的轨迹点。
    4. 返回按时间戳排序的轨迹点列表。
    """

    # 2. 构建基础查询
    points = (
        await TrajectoryPoint.filter(
            device_id=data.id,
            timestamp__gte=data.start_time,
            timestamp__lte=data.end_time,
        )
        .order_by("timestamp")
        .all()
    )

    # 5. 转换为输出模型
    return [TrajectoryPointOut.model_validate(point) for point in points]
