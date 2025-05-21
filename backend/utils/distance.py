# utils/distance.py
"""
包含距离计算和辅助函数
"""

import math
from schemas.trajectory import Position


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
