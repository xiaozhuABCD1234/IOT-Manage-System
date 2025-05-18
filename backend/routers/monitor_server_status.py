# routers/monitor_server_status.py
import time
import asyncio
import psutil
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from pydantic import BaseModel

router = APIRouter()


class ServerStatus(BaseModel):
    cpu_used: float
    memory_available: float
    memory_total: float
    memory_used: float
    disk_total: float
    disk_used: float
    network_in_rate: float  # 网络接收速率 (bytes/s)
    network_out_rate: float  # 网络发送速率 (bytes/s)


async def collect_system_stats(last_net=None):
    """异步收集系统指标"""
    loop = asyncio.get_event_loop()

    # 并行获取各项指标
    cpu_future = loop.run_in_executor(None, psutil.cpu_percent, 0.5)
    mem_future = loop.run_in_executor(None, psutil.virtual_memory)
    disk_future = loop.run_in_executor(None, psutil.disk_usage, "/")
    net_future = loop.run_in_executor(None, psutil.net_io_counters)

    # 等待所有指标完成
    cpu_used, mem, disk, net_io = await asyncio.gather(
        cpu_future, mem_future, disk_future, net_future
    )

    # 计算网络速率
    network_in_rate = 0.0
    network_out_rate = 0.0
    if last_net:
        time_diff = time.time() - last_net["time"]
        network_in_rate = (net_io.bytes_recv - last_net["bytes_recv"]) / time_diff
        network_out_rate = (net_io.bytes_sent - last_net["bytes_sent"]) / time_diff

    return ServerStatus(
        cpu_used=cpu_used,
        memory_available=mem.available,
        memory_total=mem.total,
        memory_used=mem.used,
        disk_total=disk.total,
        disk_used=disk.used,
        network_in_rate=network_in_rate,
        network_out_rate=network_out_rate,
    ), {
        "bytes_recv": net_io.bytes_recv,
        "bytes_sent": net_io.bytes_sent,
        "time": time.time(),
    }


@router.websocket("/devops/status")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    last_net = None

    try:
        while True:
            start_time = time.time()
            # 收集系统状态
            status, new_net = await collect_system_stats(last_net)
            last_net = new_net

            # 检查连接状态后再发送
            if websocket.client_state.CONNECTED:
                await websocket.send_json(status.dict())

            # 等待下一个周期（精确控制间隔）
            await asyncio.sleep(max(1 - (time.time() - start_time), 0))

    except WebSocketDisconnect:
        # 客户端主动断开时优雅退出
        pass

    # except Exception as e:
    #     # 处理其他异常
    #     print(f"Unexpected error: {e}")

    finally:
        # 确保连接关闭（忽略已关闭的情况）
        try:
            await websocket.close()
        except RuntimeError:
            pass
