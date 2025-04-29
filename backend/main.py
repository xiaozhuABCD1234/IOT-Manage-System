from fastapi import FastAPI, WebSocket
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
import psutil
import asyncio
import logging
import time


from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from tortoise.contrib.fastapi import register_tortoise
from tortoise import Tortoise
from core.config import TORTOISE_ORM
from routers import user, auth ,server_monitor
from middlewares.permissions import get_user_permissions_middleware

# 配置日志
logging.basicConfig(level=logging.INFO)


class ServerStatus(BaseModel):
    cpu_used: float
    memory_available: float
    memory_total: float
    memory_used: float
    disk_total: float
    disk_used: float
    network_in_rate: float  # 网络接收速率 (bytes/s)
    network_out_rate: float  # 网络发送速率 (bytes/s)


app = FastAPI()

# 添加CORS中间件以支持跨域请求
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.include_router(user.router, prefix="/api/users", tags=["user"])
app.include_router(auth.router, prefix="/api/user/auth", tags=["auth"])
app.include_router(server_monitor.router, prefix="/ws", tags=["devops"])

Tortoise._init_timezone(use_tz=True, timezone="Asia/Shanghai")
register_tortoise(
    app,
    config=TORTOISE_ORM,
    generate_schemas=True,  # 自动生成表结构，仅在开发环境中使用
    add_exception_handlers=True,
)


html_template = """
<!DOCTYPE html>
<html>
<head>
    <title>Server Monitor</title>
    <style>
        .metric { margin: 10px; padding: 10px; border: 1px solid #ddd; border-radius: 5px; }
        .value { color: #2196F3; font-weight: bold; }
    </style>
</head>
<body>
    <h1>Real-time Server Monitoring</h1>
    
    <div class="metric">
        CPU Usage: <span class="value" id="cpuUsage">0</span>%
    </div>
    
    <div class="metric">
        Memory Usage: <span class="value" id="memoryUsed">0</span>GB / 
        <span class="value" id="memoryTotal">0</span>GB
    </div>
    
    <div class="metric">
        Disk Usage: <span class="value" id="diskUsed">0</span>GB / 
        <span class="value" id="diskTotal">0</span>GB
    </div>
    
    <div class="metric">
        Network: ↑ <span class="value" id="networkOut">0</span>MB/s ↓ 
        <span class="value" id="networkIn">0</span>MB/s
    </div>

    <script>
        const ws = new WebSocket('ws://' + window.location.host + '/ws/devops/status');
        
        function formatGB(bytes) {
            return (bytes / 1024 / 1024 / 1024).toFixed(2);
        }
        
        function formatMB(bytes) {
            return (bytes / 1024 / 1024).toFixed(2);
        }
        
        ws.onmessage = function(event) {
            const data = JSON.parse(event.data);
            
            // 更新CPU
            document.getElementById('cpuUsage').textContent = data.cpu_used.toFixed(1);
            
            // 更新内存
            document.getElementById('memoryUsed').textContent = formatGB(data.memory_used);
            document.getElementById('memoryTotal').textContent = formatGB(data.memory_total);
            
            // 更新磁盘
            document.getElementById('diskUsed').textContent = formatGB(data.disk_used);
            document.getElementById('diskTotal').textContent = formatGB(data.disk_total);
            
            // 更新网络
            document.getElementById('networkIn').textContent = formatMB(data.network_in_rate);
            document.getElementById('networkOut').textContent = formatMB(data.network_out_rate);
        };
    </script>
</body>
</html>
"""


@app.get("/", response_class=HTMLResponse)
async def get_dashboard():
    return HTMLResponse(content=html_template)


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
    ),{'bytes_recv': net_io.bytes_recv, 'bytes_sent': net_io.bytes_sent, 'time': time.time()}


# @app.websocket("/ws/devops/status")
# async def websocket_endpoint(websocket: WebSocket):
#     await websocket.accept()
#     last_net = None
#     try:
#         while True:
#             start_time = time.time()
#             # 收集系统状态
#             status, new_net = await collect_system_stats(last_net)
#             last_net = new_net
#             # 发送监控数据
#             await websocket.send_json(status.dict())

#             # 保持稳定的1秒间隔
#             elapsed = time.time() - start_time
#             await asyncio.sleep(max(1.0 - elapsed, 0))

#     except Exception as e:
#         logging.error(f"WebSocket error: {str(e)}", exc_info=True)
#     finally:
#         await websocket.close()
#         logging.info("WebSocket connection closed")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
