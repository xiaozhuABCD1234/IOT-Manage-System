# routers/position.py
from fastapi import APIRouter, Depends

from schemas.trajectory_point import (
    TrajectoryPointOut,
    PointReadArgs,
)
from utils.positions import split_trajectory_by_time
from crud.position import Position

router = APIRouter()


@router.get("/")
async def get_trajectory(
    query: PointReadArgs = Depends(),
) -> list[list[TrajectoryPointOut]]:
    points = await Position.get_position_points(query)
    return split_trajectory_by_time(points=points)


@router.get("/ids")
async def get_unique_device_ids() -> list[int]:
    return await Position.get_unique_device_ids()
