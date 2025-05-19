# utils/positions.py
from schemas.trajectory_point import TrajectoryPointOut, Path, Position


def split_trajectory_by_time(
    points: list[TrajectoryPointOut], time_s: int = 30
) -> list[list[TrajectoryPointOut]]:
    # 检查输入的轨迹点是否为空
    if not points:
        return []
    # 初始化结果列表和当前段落
    result = []
    current_segment = [points[0]]
    # 遍历轨迹点（从第二个点开始）
    for point in points[1:]:
        # 计算当前点与前一个点的时间差（以秒为单位）
        time_diff = (point.timestamp - current_segment[-1].timestamp).total_seconds()
        # 如果时间差大于等于给定的时间间隔，则将当前段落添加到结果中，并开始新的段落
        if time_diff >= time_s:
            result.append(current_segment)
            current_segment = [point]
        # 否则，将当前点添加到当前段落
        else:
            current_segment.append(point)
    # 添加最后一个段落（如果有的话）
    if current_segment:
        result.append(current_segment)
    return result


def change_to_path(data: list[list[TrajectoryPointOut]]) -> list[Path]:
    if not data:
        return []

    result = []
    for points in data:
        # 确保每个轨迹段至少有一个点
        if not points:
            continue

        # 提取设备ID（假设同一轨迹段内设备ID相同）
        device_id = points[0].device_id

        # 转换坐标点对象
        positions = [
            Position(latitude=point.latitude, longitude=point.longitude)
            for point in points
        ]

        # 创建Path对象并添加到结果列表
        result.append(Path(id=device_id, path=positions))

    return result
