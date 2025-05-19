# routers/position.py
from fastapi import APIRouter, Depends

from schemas.trajectory_point import PointReadArgs, Path
from utils import position_utils
from crud.position import Position

router = APIRouter()


@router.get("/")
async def get_trajectory(
    query: PointReadArgs = Depends(),
) -> list[Path]:
    points = await Position.get_position_points(query)
    return position_utils.change_to_path(
        position_utils.split_trajectory_by_time(points=points)
    )


@router.get("/ids")
async def get_unique_device_ids() -> dict:
    device_ids = await Position.get_unique_device_ids()
    return {"data": device_ids, "count": len(device_ids)}
