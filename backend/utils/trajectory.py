# utils/trajectory.py
"""
包含轨迹分段、路径转换和简化逻辑
"""

from schemas.trajectory_point import TrajectoryPointOut, Path, Position, Path_mini
from .velocity import simple_calculate_velocity, calculate_velocity


def split_trajectory(
    points: list[TrajectoryPointOut],
    time_threshold: int = 30,
    velocity_threshold: int = 340,
    use_simple_calculation: bool = True,
) -> list[list[TrajectoryPointOut]]:
    """
    综合时间和速度条件的轨迹分割函数，满足任一条件即创建新段落

    参数:
        points (list[TrajectoryPointOut]):
            按时间排序的轨迹点列表（必须正确排序）
        time_threshold (int):
            时间分割阈值（秒），相邻点间隔超过此值则分割（默认：30）
        velocity_threshold (int):
            速度分割阈值（米/秒），相邻点速度超过此值则分割（默认：340）
        use_simple_calculation (bool):
            是否使用简化版距离计算（默认使用精确计算）

    返回:
        list[list[TrajectoryPointOut]]: 分割后的轨迹段落列表

    异常:
        ValueError: 当时间差 <= 0 时抛出

    算法逻辑:
        1. 同时检查时间差和速度两个条件
        2. 满足任一条件即进行分割
        3. 时间条件优先级高于速度条件（先检查时间）

    示例:
        >>> points = [...]  # 按时间排序的轨迹点
        >>> # 同时使用30秒和50米/秒阈值
        >>> segments = split_trajectory(points, 30, 50)
    """
    if not points:
        return []

    segments = []
    current_segment = [points[0]]

    for current_point in points[1:]:
        last_point = current_segment[-1]

        # 计算时间差
        time_diff = (current_point.timestamp - last_point.timestamp).total_seconds()
        if time_diff <= 0:
            raise ValueError(
                f"时间戳异常：{last_point.timestamp} → {current_point.timestamp}"
            )

        # 先检查时间条件
        time_condition = time_diff >= time_threshold

        # 检查速度条件（仅当时间条件不满足时）
        velocity_condition = False
        if not time_condition:
            # 选择距离计算方法
            calc_velocity = (
                simple_calculate_velocity
                if use_simple_calculation
                else calculate_velocity
            )
            current_velocity = calc_velocity(last_point, current_point, time_diff)
            velocity_condition = current_velocity > velocity_threshold

        # 任一条件满足则分割
        if time_condition or velocity_condition:
            segments.append(current_segment)
            current_segment = [current_point]
        else:
            current_segment.append(current_point)

    # 添加最后段落
    if current_segment:
        segments.append(current_segment)

    return segments


# 保留原有单一条件接口
def split_trajectory_by_time(
    points: list[TrajectoryPointOut], time_threshold_seconds: int = 30
) -> list[list[TrajectoryPointOut]]:
    """仅按时间分割的快捷方式"""
    return split_trajectory(
        points, time_threshold=time_threshold_seconds, velocity_threshold=0
    )


def split_trajectory_by_velocity(
    points: list[TrajectoryPointOut],
    velocity: int = 340,
    use_simple_distance: bool = False,
) -> list[list[TrajectoryPointOut]]:
    """仅按速度分割的快捷方式"""
    return split_trajectory(
        points,
        time_threshold=0,
        velocity_threshold=velocity,
        use_simple_calculation=use_simple_distance,
    )


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
