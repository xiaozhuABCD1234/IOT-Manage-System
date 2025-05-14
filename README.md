# IOT-Management-System

## 启动

### 编译前端代码

```bash
cd ./frontend
npm install
npm run build
```

### 启动后端

```bash
cd ../backend
```

#### 使用 pip

```bash
# 安装依赖
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
# 启动
fastapi run main.py --port 8000 --host 0.0.0.0
```

#### 使用 uv

```bash
# 安装依赖
uv add requests
# 启动
uv run fastapi run main.py --port 8000 --host 0.0.0.0
```

---

## TodoList

- 增加历史位置功能
- 写一个新的距离展示组件
- 让它在docker里运行也能监控服务器
- 增加运维管理的网络监控功能
- 对服务器高负载是报警
- 把数据库从SQLite3迁移到MongoDB
- 增加用户管理界面
- 重构 P5MultiTrail.vue
- 下面开始发癫
- 尝试使用SSR，Wasm看是否提升前端计算性能
- 尝试后端用GO语言重构
