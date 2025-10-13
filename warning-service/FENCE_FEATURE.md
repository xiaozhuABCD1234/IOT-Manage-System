# 电子围栏功能文档

## 功能概述

集成了与 `map-service` 的电子围栏检查功能。当设备进入电子围栏时，系统会自动发送警报。

## 配置说明

### 环境变量

需要配置以下环境变量来指定 `map-service` 的地址：

```bash
# Map Service 配置
MAP_SERVICE_HOST=localhost    # map-service 的主机名或 IP
MAP_SERVICE_PORT=8002         # map-service 的端口号
```

### 默认值

- `MAP_SERVICE_HOST`: 默认 `localhost`
- `MAP_SERVICE_PORT`: 默认 `8002`

## 工作原理

### 1. 数据流程

```
UWB 定位数据 → OnLocMsg() → 异步调用 checkFence()
                             ↓
                      调用 map-service API
                             ↓
                      检查是否在围栏内
                             ↓
                     是 → 发送警报 (warning/deviceID payload=1)
                     否 → 取消警报 (warning/deviceID payload=0)
```

### 2. API 调用

系统会向 `map-service` 发送 POST 请求：

```http
POST http://{MAP_SERVICE_HOST}:{MAP_SERVICE_PORT}/api/v1/polygon-fence/check-all
Content-Type: application/json

{
  "x": 50.5,
  "y": 25.3
}
```

### 3. 响应处理

**点在围栏内：**

```json
{
	"code": 200,
	"message": "success",
	"data": {
		"is_inside": true,
		"fence_id": "123e4567-e89b-12d3-a456-426614174000",
		"fence_name": "仓库A区",
		"fence_names": ["仓库A区", "安全区域", "监控区"]
	}
}
```

**点不在围栏内：**

```json
{
	"code": 200,
	"message": "success",
	"data": {
		"is_inside": false
	}
}
```

## 关键特性

### 1. 状态缓存

- 系统会记住每个设备的上一次围栏状态
- 只有当状态发生变化时才会发送警报
- 避免重复警报

### 2. 智能限流

结合警报限流器（`WarningRateLimiter`）：

- 每秒每个设备最多发送 2 次警报
- 防止警报风暴

### 3. 异步检查

- 围栏检查在独立的 goroutine 中执行
- 不阻塞定位数据处理流程
- HTTP 请求超时时间：3 秒

### 4. 错误处理

- 网络错误不会导致服务崩溃
- 错误会记录到日志
- 自动降级（如果 map-service 不可用，围栏检查会被跳过）

## 日志说明

### 初始化日志

```
[INFO] FenceChecker 初始化, baseURL=http://localhost:8002
```

### 围栏状态变化日志

```
[FENCE] 设备 device-001 进入围栏: [仓库A区 安全区域]
[FENCE_ALERT] 设备 device-001 在电子围栏内，发送警报

[FENCE] 设备 device-001 离开围栏
[FENCE_ALERT] 设备 device-001 离开电子围栏，取消警报
```

### 错误日志

```
[WARN] 检查围栏失败 deviceID=device-001 error=请求map-service失败: connection refused
```

## 代码结构

### 新增文件

1. **model/fence_model.go**

   - 围栏检查的数据模型
   - 请求和响应结构体

2. **service/fence_checker.go**
   - 围栏检查器核心逻辑
   - HTTP 客户端封装
   - 状态缓存管理

### 修改文件

1. **config/config.go**

   - 添加 `MapServiceConfig` 配置段

2. **service/locator.go**

   - 集成围栏检查逻辑
   - 添加 `checkFence()` 方法

3. **main.go**
   - 初始化 `FenceChecker`

## 性能考虑

1. **并发性**

   - 每个围栏检查都在独立的 goroutine 中
   - 不影响定位数据处理的主流程

2. **网络延迟**

   - HTTP 请求超时：3 秒
   - 异步调用，不阻塞

3. **内存占用**
   - 每个设备一个状态记录（布尔值）
   - 内存占用极小

## 部署注意事项

### Docker 部署

如果使用 Docker，确保：

1. `map-service` 和 `warning-service` 在同一网络
2. 使用服务名称作为 hostname（如 `MAP_SERVICE_HOST=map-service`）

### Kubernetes 部署

使用 Service 名称：

```bash
MAP_SERVICE_HOST=map-service.default.svc.cluster.local
MAP_SERVICE_PORT=8002
```

### 本地测试

```bash
export MAP_SERVICE_HOST=localhost
export MAP_SERVICE_PORT=8002
./warning-service
```

## 故障排除

### 1. 无法连接 map-service

**症状：** 日志显示 `connection refused`

**解决：**

- 检查 `MAP_SERVICE_HOST` 和 `MAP_SERVICE_PORT` 配置
- 确保 map-service 正在运行
- 检查防火墙/网络策略

### 2. 未收到围栏警报

**检查：**

- 确认设备发送的是 UWB 定位数据（围栏只支持平面坐标）
- 查看日志中是否有 `[FENCE]` 相关信息
- 确认 map-service 中围栏配置正确

### 3. 警报过于频繁

**原因：** 可能是设备在围栏边界附近频繁进出

**解决：** 警报限流器会自动限制为每秒最多 2 次

## 测试示例

### 模拟 UWB 定位消息

```bash
mosquitto_pub -h localhost -p 1883 \
  -t "location/device-001" \
  -u admin -P admin \
  -m '{
    "id": "device-001",
    "sens": [
      {
        "n": "UWB",
        "u": "cm",
        "v": [5000, 2500]
      }
    ]
  }'
```

### 预期日志

```
[DEBUG] 收到 UWB 定位消息  deviceID=device-001  x=5000.000000  y=2500.000000
[FENCE] 设备 device-001 进入围栏: [测试围栏]
[FENCE_ALERT] 设备 device-001 在电子围栏内，发送警报
[PUB] topic=warning/device-001 payload=1
```

## 扩展建议

### 1. 支持 RTK 围栏

如需支持 GPS 坐标的围栏，需要：

- 修改 `checkFence()` 支持经纬度
- 在 map-service 中实现地理围栏

### 2. 自定义警报级别

根据不同围栏类型发送不同级别的警报：

- 危险区域：高优先级警报
- 提醒区域：低优先级警报

### 3. 历史记录

记录设备进出围栏的历史：

- 进入时间
- 停留时长
- 离开时间
