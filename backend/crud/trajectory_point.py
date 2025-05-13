from fastapi import HTTPException
from datetime import datetime, timedelta
from models.trajectory_point import TrajectoryPoint
from schemas.trajectory_point import TrajectoryPointIn, TrajectoryPointOut


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


async def get_trajectory_points(
    device_id: int,
    start_time: str,
    end_time: str,
    limit: int = 100,
    time_step: int | None = None,
) -> list[TrajectoryPointOut]:
    """
    获取设备在指定时间范围内的轨迹点。
    1. 验证时间参数。
    2. 构建查询以过滤指定设备和时间范围的轨迹点。
    3. 如果提供了 time_step，则对结果进行时间步长采样。
    4. 返回按时间戳排序的轨迹点列表。
    """
    # 1. 验证时间参数
    try:
        start_dt = datetime.fromisoformat(start_time)
        end_dt = datetime.fromisoformat(end_time)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail="Invalid datetime format") from exc

    if start_dt >= end_dt:
        raise HTTPException(
            status_code=400, detail="Start time must be before end time"
        )

    # 2. 构建基础查询
    query = TrajectoryPoint.filter(
        device_id=device_id, timestamp__gte=start_dt, timestamp__lte=end_dt
    ).order_by("timestamp")

    if limit > 0:
        query = query.limit(limit)

    # 3. 执行查询
    trajectory_points = await query

    # 4. 处理 time_step 逻辑
    if time_step is not None:
        if time_step <= 0:
            raise HTTPException(status_code=400, detail="Time step must be positive")

        # 应用时间步长采样
        sampled_points = []
        current_time = start_dt
        index = 0

        while current_time <= end_dt and index < len(trajectory_points):
            # 查找当前时间步长内的第一个点
            while (
                index < len(trajectory_points)
                and trajectory_points[index].timestamp < current_time
            ):
                index += 1

            if index < len(trajectory_points) and trajectory_points[
                index
            ].timestamp <= current_time + timedelta(seconds=time_step):
                sampled_points.append(trajectory_points[index])
                index += 1

            current_time += timedelta(seconds=time_step)

        trajectory_points = sampled_points

    # 5. 转换为输出模型
    return [TrajectoryPointOut.model_validate(point) for point in trajectory_points]
