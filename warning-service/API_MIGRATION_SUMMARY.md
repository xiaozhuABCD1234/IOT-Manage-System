# Warning Service API 迁移总结

## 概述

本次迁移将 warning-service 从直接数据库查询改为通过 mark-service API 获取数据，实现了服务间的解耦。

## 主要更改

### 1. 创建了 MarkAPIClient (repo/sql_repo.go)

- 实现了与 mark-service 的 HTTP 通信
- 支持以下 API 调用：
  - `GetMarkByDeviceID()` - 根据设备 ID 获取标记信息
  - `GetDangerZoneByDeviceID()` - 根据设备 ID 获取危险半径
  - `GetDistanceMapByDeviceID()` - 根据设备 ID 获取距离映射
  - `UpdateLastOnlineTime()` - 更新设备最后在线时间
  - `GetOnlineDevices()` - 获取在线设备列表（暂未实现）

### 2. 更新了 MarkRepo (repo/sql_repo.go)

- 添加了 API 模式支持，默认使用 API 模式
- 保留了数据库模式的兼容性
- 所有方法都支持 API 和数据库两种模式：
  - `SetOnline()` - 更新在线时间
  - `GetOnlineList()` - 获取在线设备列表
  - `GetDangerZoneM()` - 获取危险半径
  - `GetBatchDangerZoneM()` - 批量获取危险半径
  - `GetDistanceMapByDevice()` - 获取距离映射
  - `GetDistanceByDevice()` - 获取设备距离配置

### 3. 更新了配置文件 (config/config.go)

- 添加了 `MarkServiceConfig` 配置项
- 支持环境变量配置：
  - `MARK_SERVICE_HOST` (默认: mark-service)
  - `MARK_SERVICE_PORT` (默认: 8004)

### 4. 更新了 Locator (service/locator.go)

- 统一使用 MarkRepo 的方法获取危险半径
- 确保所有距离检查都通过 API 获取数据

### 5. 更新了 DistancePoller (service/worker.go)

- 添加了 API 模式下的日志说明
- 在 API 模式下，当在线设备列表为空时跳过轮询（正常行为）

### 6. 更新了主程序 (main.go)

- 添加了可选的数据库连接
- 通过环境变量 `USE_DATABASE=true` 控制是否使用数据库模式
- 默认使用 API 模式，无需数据库连接

## API 调用映射

| 原数据库查询             | 新 API 调用                                          |
| ------------------------ | ---------------------------------------------------- |
| 根据设备 ID 查询标记     | `GET /api/v1/marks/device/{device_id}`               |
| 根据设备 ID 获取危险半径 | `GET /api/v1/marks/device/{device_id}/safe-distance` |
| 根据设备 ID 获取距离映射 | `GET /api/v1/pairs/distance/map/device/{device_id}`  |
| 更新最后在线时间         | `PUT /api/v1/marks/device/{device_id}/last-online`   |

## 环境变量配置

```bash
# Mark Service 配置
MARK_SERVICE_HOST=mark-service
MARK_SERVICE_PORT=8004

# 可选：使用数据库模式（默认使用API模式）
USE_DATABASE=false
```

## 部署说明

1. **API 模式（推荐）**：

   - 设置 `USE_DATABASE=false` 或不设置该环境变量
   - 确保 mark-service 服务可用
   - 无需数据库连接

2. **兼容模式**：
   - 设置 `USE_DATABASE=true`
   - 保持原有的数据库配置
   - 同时支持 API 和数据库查询

## 注意事项

1. **在线设备检测**：API 模式下 `GetOnlineDevices()` 返回空列表，这是正常行为，因为距离检查由 Locator 实时处理。

2. **错误处理**：API 调用失败时会记录错误日志，但不会中断服务运行。

3. **性能考虑**：API 调用有 5 秒超时设置，避免长时间阻塞。

4. **向后兼容**：保留了数据库模式的完整支持，可以随时切换。

## 测试建议

1. 验证 API 连接性
2. 测试距离检查功能
3. 验证危险半径获取
4. 测试在线时间更新
5. 验证错误处理机制

## 问题修复

### API 响应格式修正

根据实际 API 响应格式，修正了所有 API 调用的响应结构体：

```go
// 统一的响应格式
type APIResponse struct {
    Success   bool        `json:"success"`
    Data      interface{} `json:"data"`
    Message   string      `json:"message"`
    Timestamp string      `json:"timestamp"`
}
```

### UUID 到设备 ID 映射转换

由于距离映射 API 返回的是标记 UUID 到距离的映射，而系统需要设备 ID 到距离的映射，实现了转换机制：

1. **问题识别**：API 返回 `{"ac0371ed-c9a5-444f-90b6-27ac437b1f1f": 1.8}` 格式
2. **解决方案**：通过调用 `GET /api/v1/marks/{uuid}` 获取标记信息，提取设备 ID
3. **转换逻辑**：`ConvertUUIDMapToDeviceMap()` 方法实现 UUID 到设备 ID 的映射转换

### 调试日志增强

添加了详细的调试日志，包括：

- API 请求 URL
- HTTP 状态码
- 完整响应体
- 映射转换过程

## 后续优化

1. 实现 `GetOnlineDevices()` API 调用
2. 添加 API 调用缓存机制
3. 实现 API 调用重试机制
4. 添加 API 调用监控和指标
5. 优化 UUID 到设备 ID 的映射缓存，避免重复 API 调用
