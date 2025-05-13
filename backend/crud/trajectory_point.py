# crud/trajectory_point.py
from fastapi import HTTPException

from datetime import datetime
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
    )
    return TrajectoryPointOut.model_validate(trajectory_point)


async def get_trajectory_points(
    device_id: int,
    start_time: str,
    end_time: str,
    limit: int = 100,
    time_step: int | None = None,
) -> list[TrajectoryPointOut]:
    start_dt: datetime = datetime.fromisoformat(start_time)
    end_dt: datetime = datetime.fromisoformat(end_time)
    total_seconds = (end_dt - start_dt).total_seconds()
    if total_seconds <= 0:
        raise HTTPException(
            status_code=400, detail="Start time must be before end time"
        )

    if time_step is None:
        if limit <= 0:
            raise HTTPException(status_code=400, detail="Limit must be positive")
        time_step = time_step or max(1, int((end_dt - start_dt).total_seconds() / limit))
