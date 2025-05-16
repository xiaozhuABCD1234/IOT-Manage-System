# schemas/trajectory_point.py
from pydantic import BaseModel, ConfigDict, model_validator
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


class PointReadArgs(BaseModel):
    id: int
    start_time: datetime
    end_time: datetime

    @model_validator(mode="after")
    def validate_time_range(self):
        if self.end_time < self.start_time:
            raise ValueError("结束时间必须晚于或等于开始时间")
        return self
