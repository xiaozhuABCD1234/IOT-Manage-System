# schemas/trajectory_point.py
from pydantic import BaseModel, ConfigDict, model_validator
from datetime import datetime


class Position(BaseModel):
    longitude: float
    latitude: float
    model_config = ConfigDict(
        from_attributes=True,
    )

    @model_validator(mode="after")
    def validate_latitude_longitude(self):
        if not ((-90 <= self.latitude <= 90) and (-180 <= self.longitude <= 180)):
            raise ValueError("无效的经纬度值")
        return self


class Path(BaseModel):
    id: int
    path: list[Position]


class Path_mini(BaseModel):
    id: int
    path: list[list[float]]


class PositionData(Position):
    device_id: int
    timestamp: datetime


class TrajectoryPointOut(PositionData):
    pass


class TrajectoryPointIn(PositionData):
    pass


class PointReadArgs(BaseModel):
    id: int
    start_time: datetime
    end_time: datetime

    @model_validator(mode="after")
    def validate_time_range(self):
        if self.end_time < self.start_time:
            raise ValueError("结束时间必须晚于或等于开始时间")
        return self
