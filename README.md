# IOT-Management-System

## 启动

### 编译前端代码

```bash
cd ./frontend
npm install
<<<<<<< HEAD
npm run build
```

### 启动后端

#### 使用 pip

```bash
=======
node run build
>>>>>>> 03adc705bda5f856763f5d544e36474b2cf15048
cd ../backend
# 安装依赖
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
# 启动
fastapi run main.py --port 8000 --host 0.0.0.0
```

#### 使用 uv

```bash
cd ../backend
# 安装依赖
uv add requests
# 启动
uv run fastapi run main.py --port 8000 --host 0.0.0.0
```
