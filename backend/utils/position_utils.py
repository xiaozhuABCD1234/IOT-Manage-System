# utils/positions.py
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
