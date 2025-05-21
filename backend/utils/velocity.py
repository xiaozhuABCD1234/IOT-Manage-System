# utils/velocity.py
"""
包含速度计算逻辑（依赖距离计算）
"""

from schemas.trajectory import Position
from .distance import calculate_distance_m, simple_calculate_distance_m


def calculate_velocity(p1: Position, p2: Position, second: float) -> float:
    """
    计算两点间的速度（米/秒）。

    参数:
        p1 (Position): 第一个位置点
        p2 (Position): 第二个位置点
        second (float): 两点间的时间差（秒）

    返回:
        float: 两点间的速度（米/秒）
    """
    return calculate_distance_m(p1, p2) / second


def simple_calculate_velocity(p1: Position, p2: Position, second: float) -> float:
    """
    计算两点间的速度（米/秒），使用平面几何公式估算距离。

    参数:
        p1 (Position): 第一个位置点
        p2 (Position): 第二个位置点
        second (float): 两点间的时间差（秒）

    返回:
        float: 两点间的估算速度（米/秒）
    """
    return simple_calculate_distance_m(p1, p2) / second
