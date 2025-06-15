FROM ghcr.io/astral-sh/uv:python3.13-alpine

WORKDIR /app

# 安装系统依赖
RUN apk add --no-cache gcc python3-dev musl-dev linux-headers

# 先复制依赖声明文件
COPY ./pyproject.toml \
    ./requirements.txt \
    ./uv.lock \
    ./

RUN uv sync --default-index https://pypi.tuna.tsinghua.edu.cn/simple

COPY ./. ./

EXPOSE 8000

CMD ["uv","run","fastapi","run", "main.py", "--host", "0.0.0.0", "--port", "8000"]
