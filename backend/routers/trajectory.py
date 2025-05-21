# routers/position.py
from fastapi import APIRouter, Depends

from schemas.trajectory import PointReadArgs, Path_mini, Path, TrajectoryPointOut
from utils import trajectory
from crud.position import Position

router = APIRouter()


@router.get("/original")
async def get_original_path(
    query: PointReadArgs = Depends(),
) -> list[list[TrajectoryPointOut]]:
    points = await Position.get_position_points(query)
    return trajectory.split_trajectory_by_time(points=points)


@router.get("/path")
async def get_path(
    query: PointReadArgs = Depends(),
) -> list[Path]:
    points = await Position.get_position_points(query)
    return trajectory.convert_to_paths(
        trajectory.split_trajectory_by_time(points=points)
    )


@router.get("/mini")
async def get_mini_path(
    query: PointReadArgs = Depends(),
) -> list[Path_mini]:
    points = await Position.get_position_points(query)
    return trajectory.simplify_paths(
        trajectory.convert_to_paths(
            trajectory.split_trajectory(
                points=points, time_threshold=10, velocity_threshold=50
            )
        )
    )


@router.get("/ids")
async def get_unique_device_ids() -> dict:
    device_ids = await Position.get_unique_device_ids()
    return {"data": device_ids, "count": len(device_ids)}
