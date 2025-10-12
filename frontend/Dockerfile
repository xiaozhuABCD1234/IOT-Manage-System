# 构建阶段
FROM docker.io/library/node:trixie-slim AS builder

ARG VITE_API_BASE
ARG VITE_AMAP_KEY
ARG VITE_AMAP_SECURITY_CODE
ARG VITE_MQTT_URL

# 设置工作目录
WORKDIR /app

ENV VITE_AMAP_KEY=d345dbe66fd01f5c41ce3cf7e063597b \
    VITE_AMAP_SECURITY_CODE=f8444fa686115a25ea60c937cd6a6ab9 \
    VITE_MQTT_URL=ws://8.133.17.175:8083/mqtt 

# 安装pnpm + 设置国内镜像
RUN npm install -g pnpm \
    && pnpm config set registry https://registry.npmmirror.com \
    && pnpm config set store-dir /tmp/.pnpm-store

# 复制package文件
COPY package*.json ./
COPY pnpm-lock.yaml ./

# 安装依赖（添加缓存优化）
RUN pnpm install --frozen-lockfile --prefer-offline

# 复制源代码
COPY . .

# 构建应用（添加构建优化）
RUN pnpm run build


# 运行阶段
FROM docker.io/library/nginx:alpine

COPY nginx.conf /etc/nginx/nginx.conf

# 复制前端构建产物到 nginx 的 html 目录
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

# 6. 直接启动 nginx，跳过 entrypoint
ENTRYPOINT ["nginx", "-g", "daemon off;"]