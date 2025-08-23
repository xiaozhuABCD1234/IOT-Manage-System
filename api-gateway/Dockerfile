FROM docker.io/library/golang:1.24.6-alpine AS builder

# 设置国内 Go 代理
ENV GOPROXY=https://goproxy.cn,direct
ENV GO111MODULE=on

# 设置工作目录
WORKDIR /app

# 安装必要的构建工具
RUN  sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories &&\
    apk add --no-cache git ca-certificates tzdata

# 复制 go mod 文件
COPY go.mod go.sum ./

# 下载依赖（使用国内代理，避免超时）
RUN go mod download -x

# 复制源代码
COPY . .

# 构建应用（优化二进制，Gin使用go_json序列化）
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -tags="go_json" \
    -ldflags="-w -s" \
    -a -installsuffix cgo \
    -o main .
# 运行阶段
FROM docker.io/library/alpine:latest

ENV GIN_MODE=release

# 安装运行时依赖
RUN  sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories &&\
    apk --no-cache add ca-certificates tzdata

# 创建非 root 用户
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# 设置工作目录
WORKDIR /app

# 复制二进制
COPY --from=builder /app/main .

# 设置权限
RUN chown -R appuser:appgroup /app

# 切换用户（安全）
USER appuser

# 暴露端口
EXPOSE 8000

# 健康检查
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health ||

ENV GIN_MODE=release PORT=8000
ENV HTTP_PROXY=""
ENV http_proxy=""
ENV HTTPS_PROXY=""
ENV https_proxy=""
ENV NO_PROXY=*
ENV no_proxy=*

# 运行应用
CMD ["./main"] 