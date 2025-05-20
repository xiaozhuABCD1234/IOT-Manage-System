# utils/positions.py
import math
from schemas.trajectory_point import TrajectoryPointOut, Path, Position, Path_mini


def split_trajectory_by_time(
    points: list[TrajectoryPointOut], time_threshold_seconds: int = 30
) -> list[list[TrajectoryPointOut]]:
    """
    将轨迹点按照时间间隔分割成多个段落。

    参数:
        points (list[TrajectoryPointOut]): 按时间排序的轨迹点列表
        time_threshold_seconds (int): 判断为新段的时间间隔（单位：秒）

    返回:
        list[list[TrajectoryPointOut]]: 分割后的轨迹点段落列表
    """
    if not points:
        return []

    result = []
    current_segment = [points[0]]

    for point in points[1:]:
        last_point = current_segment[-1]
        time_diff = (point.timestamp - last_point.timestamp).total_seconds()

        if time_diff >= time_threshold_seconds:
            result.append(current_segment)
            current_segment = [point]
        else:
            current_segment.append(point)

    # 添加最后一个段
    if current_segment:
        result.append(current_segment)

    return result


def convert_to_paths(trajectory_segments: list[list[TrajectoryPointOut]]) -> list[Path]:
    """
    将轨迹段转换为 Path 对象列表。

    参数:
        trajectory_segments (list[list[TrajectoryPointOut]]): 轨迹段列表

    返回:
        list[Path]: 包含设备 ID 和路径坐标的 Path 对象列表
    """
    if not trajectory_segments:
        return []

    paths = []

    for segment in trajectory_segments:
        if not segment:
            continue

        device_id = segment[0].device_id
        positions = [
            Position(latitude=point.latitude, longitude=point.longitude)
            for point in segment
        ]

        paths.append(Path(id=device_id, path=positions))

    return paths


def simplify_paths(paths: list[Path]) -> list[Path_mini]:
    """
    简化路径数据，将 Position 对象转换为二维数组 [latitude, longitude]。

    参数:
        paths (list[Path]): 原始路径对象列表

    返回:
        list[Path_mini]: 简化的路径对象列表
    """
    if not paths:
        return []

    simplified = []

    for path in paths:
        simplified_path = [
            [position.latitude, position.longitude] for position in path.path
        ]
        simplified.append(Path_mini(id=path.id, path=simplified_path))

    return simplified


def _to_radians(degree: float) -> float:
    """将度数转换为弧度"""
    return degree * (math.pi / 180)


def calculate_distance_m(p1: Position, p2: Position) -> float:
    """
    计算两点间的大圆距离（米）。

    参数:
        P1 (Position): 第一个位置点
        P2 (Position): 第二个位置点

    返回:
        float: 两点间距离（米
    """
    r: float = 6371008.771
    delta_lat = _to_radians(p1.latitude - p2.latitude)
    delta_lon = _to_radians(p1.longitude - p2.longitude)

    a = math.pow(math.sin(delta_lat / 2), 2) + math.cos(
        _to_radians(p1.latitude)
    ) * math.cos(+_to_radians(p2.latitude)) * math.pow(math.sin(delta_lon / 2), 2)

    c = 2 * math.atan2(math.sqrt(a), math.sqrt(a - 1))

    distance = r * c
    return distance


def simple_calculate_distance_m(p1: Position, p2: Position) -> float:
    """
    使用平面几何公式估算两点间的直线距离（米），适用于小范围或粗略估算。

    参数:
        p1 (Position): 第一个位置点
        p2 (Position): 第二个位置点

    返回:
        float: 两点间估算距离（米）
    """
    r: float = 6371008.771

    delta_lat = _to_radians(p1.latitude) - _to_radians(p2.latitude)
    delta_lon = _to_radians(p1.longitude) - _to_radians(p2.longitude)

    # 欧几里得距离估算
    distance = math.hypot(delta_lat, delta_lon) * r
    return distance


def calculate_velocity(p1: Position, p2: Position, second: float) -> float:
    return calculate_distance_m(p1, p2) / second


def simple_calculate_velocity(p1: Position, p2: Position, second: float) -> float:
    return simple_calculate_distance_m(p1, p2) / second


