# routers/monitor_position.py
from datetime import datetime
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from schemas.trajectory_point import (
    TrajectoryPointIn,
)
from crud.position import Position

router = APIRouter()


@router.websocket("/monitor/position")
async def monitor_position(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            ws_message = await websocket.receive_json()
            if not all(
                key in ws_message
                for key in ["id", "latitude", "longitude", "timestamp"]
            ):
                raise ValueError("消息格式不完整")
            timestamp = datetime.fromtimestamp(ws_message["timestamp"] / 1000)
            data = TrajectoryPointIn(
                device_id=ws_message["id"],
                longitude=ws_message["longitude"],
                latitude=ws_message["latitude"],
                timestamp=timestamp,
            )
            await Position.create_position_point(data)

    except WebSocketDisconnect:
        # 客户端主动断开时优雅退出
        pass

    finally:
        # 确保连接关闭（忽略已关闭的情况）
        try:
            await websocket.close()
        except RuntimeError:
            pass
