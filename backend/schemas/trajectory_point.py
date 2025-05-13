# schemas/trajectory_point.py
from pydantic import BaseModel, ConfigDict
from datetime import datetime


class TrajectoryPointOut(BaseModel):
    device_id: int
    latitude: float
    longitude: float
    timestamp: datetime
    model_config = ConfigDict(
        from_attributes=True,
    )


class TrajectoryPointIn(BaseModel):
    device_id: int
    latitude: float
    longitude: float
    model_config = ConfigDict(
        from_attributes=True,
    )
