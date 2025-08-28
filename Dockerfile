# 构建前端
FROM node:24.0.1-alpine3.21 AS frontend-builder

WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend .
RUN npm run build

# 构建后端
FROM python:3.13.3-slim-bookworm

# The installer requires curl (and certificates) to download the release archive
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates

# Download the latest installer
ADD https://astral.sh/uv/install.sh /uv-installer.sh

# Run the installer then remove it
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Ensure the installed binary is on the `PATH`
ENV PATH="/root/.local/bin/:$PATH"

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends gcc python3-dev \
    && rm -rf /var/lib/apt/lists/*

# 拷贝后端依赖
COPY backend/. /app

# 安装Python依赖
RUN uv add requests

# 拷贝应用程序
#COPY backend .
COPY --from=frontend-builder /app/frontend/dist ./dist

EXPOSE 8000

# 启动命令

CMD ["uv","run","fastapi","run", "main.py", "--host", "0.0.0.0", "--port", "8000"]