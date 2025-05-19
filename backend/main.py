# main.py
from fastapi import FastAPI, Request
from fastapi.responses import FileResponse, Response
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware

from tortoise.contrib.fastapi import register_tortoise
from core.config import TORTOISE_ORM
from routers import (
    monitor_position,
    monitor_server_status,
    user,
    auth,
    user_search,
    position,
    utils,
)


app = FastAPI()

# 添加 CORS 中间件以支持跨域请求
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(user.router, prefix="/api/users", tags=["user"])
app.include_router(user_search.router, prefix="/api/user_search", tags=["user_search"])
app.include_router(auth.router, prefix="/api/user/auth", tags=["auth"])
app.include_router(position.router, prefix="/api/position", tags=["position"])
app.include_router(utils.router, prefix="/api/utils", tags=["utils"])

app.include_router(monitor_server_status.router, prefix="/ws", tags=["devops"])
app.include_router(monitor_position.router, prefix="/ws", tags=["monitor"])

register_tortoise(
    app,
    config=TORTOISE_ORM,
    generate_schemas=True,  # 自动生成表结构，仅在开发环境中使用
    add_exception_handlers=True,
)

app.mount("/", StaticFiles(directory="dist", html=True), name="static")


# 中间件处理前端路由
@app.middleware("http")
async def spa_middleware(request: Request, call_next):
    response = await call_next(request)
    if response.status_code == 404:
        # 检查路径是否以API或WebSocket开头
        if not request.url.path.startswith(("/api", "/ws")):
            try:
                return FileResponse("./dist/index.html")
            except FileNotFoundError:
                return Response(status_code=404, content="Not Found")
    return response


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
