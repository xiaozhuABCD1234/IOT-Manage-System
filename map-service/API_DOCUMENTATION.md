# IOT 地图数据服务 API 文档

## 📝 概述

**服务名称**: 地图数据服务 (Map Service)  
**版本**: v0.0.2  
**默认端口**: 8002  
**基础路径**: `http://localhost:8002`

本服务提供基站管理、自制地图管理和多边形围栏管理功能。

---

## 📋 目录

- [通用说明](#通用说明)
- [健康检查](#健康检查)
- [基站管理 API](#基站管理-api)
- [自制地图 API](#自制地图-api)
- [多边形围栏 API](#多边形围栏-api)
- [错误码说明](#错误码说明)

---

## 通用说明

### 响应格式

所有接口返回统一的 JSON 格式：

**成功响应:**

```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

**错误响应:**

```json
{
	"code": 400,
	"message": "参数错误",
	"details": "具体错误信息"
}
```

### HTTP 状态码

- `200` - 请求成功
- `201` - 创建成功
- `400` - 请求参数错误
- `404` - 资源不存在
- `409` - 资源冲突
- `500` - 服务器内部错误

---

## 健康检查

### GET /health

检查服务运行状态。

**请求示例:**

```bash
curl http://localhost:8002/health
```

**响应示例:**

```json
{
	"status": "ok",
	"service": "地图数据服务 v0.0.2"
}
```

---

## 基站管理 API

基站用于在平面坐标系中标记固定位置点。

### 1. 创建基站

**POST** `/api/v1/station`

创建一个新的基站。

**请求体:**

```json
{
	"station_name": "基站A",
	"coordinate_x": 123.45,
	"coordinate_y": 67.89
}
```

**参数说明:**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| station_name | string | 是 | 基站名称，1-255 个字符 |
| coordinate_x | float64 | 是 | X 坐标 |
| coordinate_y | float64 | 是 | Y 坐标 |

**curl 示例:**

```bash
curl -X POST http://localhost:8002/api/v1/station \
  -H "Content-Type: application/json" \
  -d '{
    "station_name": "基站A",
    "coordinate_x": 123.45,
    "coordinate_y": 67.89
  }'
```

**响应示例:**

```json
{
	"code": 201,
	"message": "基站创建成功",
	"data": null
}
```

---

### 2. 获取基站列表

**GET** `/api/v1/station`

获取所有基站列表。

**curl 示例:**

```bash
curl http://localhost:8002/api/v1/station
```

**响应示例:**

```json
{
	"code": 200,
	"message": "success",
	"data": [
		{
			"id": "123e4567-e89b-12d3-a456-426614174000",
			"station_name": "基站A",
			"coordinate_x": 123.45,
			"coordinate_y": 67.89,
			"created_at": "2025-01-15T10:30:00Z",
			"updated_at": "2025-01-15T10:30:00Z"
		}
	]
}
```

---

### 3. 获取单个基站

**GET** `/api/v1/station/:id`

根据 ID 获取基站详情。

**路径参数:**

- `id` (UUID): 基站 ID

**curl 示例:**

```bash
curl http://localhost:8002/api/v1/station/123e4567-e89b-12d3-a456-426614174000
```

**响应示例:**

```json
{
	"code": 200,
	"message": "success",
	"data": {
		"id": "123e4567-e89b-12d3-a456-426614174000",
		"station_name": "基站A",
		"coordinate_x": 123.45,
		"coordinate_y": 67.89,
		"created_at": "2025-01-15T10:30:00Z",
		"updated_at": "2025-01-15T10:30:00Z"
	}
}
```

---

### 4. 更新基站

**PUT** `/api/v1/station/:id`

更新指定基站的信息。

**路径参数:**

- `id` (UUID): 基站 ID

**请求体（所有字段可选）:**

```json
{
	"station_name": "基站A-更新",
	"coordinate_x": 150.0,
	"coordinate_y": 80.0
}
```

**curl 示例:**

```bash
curl -X PUT http://localhost:8002/api/v1/station/123e4567-e89b-12d3-a456-426614174000 \
  -H "Content-Type: application/json" \
  -d '{
    "station_name": "基站A-更新",
    "coordinate_x": 150.00
  }'
```

**响应示例:**

```json
{
	"code": 200,
	"message": "基站更新成功",
	"data": null
}
```

---

### 5. 删除基站

**DELETE** `/api/v1/station/:id`

删除指定的基站。

**路径参数:**

- `id` (UUID): 基站 ID

**curl 示例:**

```bash
curl -X DELETE http://localhost:8002/api/v1/station/123e4567-e89b-12d3-a456-426614174000
```

**响应示例:**

```json
{
	"code": 200,
	"message": "基站删除成功",
	"data": null
}
```

---

## 自制地图 API

自制地图支持上传图片并配置坐标系统，也可以只配置坐标信息不上传图片。

### 1. 创建自制地图

**POST** `/api/v1/custom-map`

创建地图并配置坐标信息，图片上传为可选。

**请求体（带图片）:**

```json
{
	"map_name": "仓库平面图",
	"image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
	"image_ext": ".png",
	"x_min": 0,
	"x_max": 1000,
	"y_min": 0,
	"y_max": 500,
	"center_x": 500,
	"center_y": 250,
	"description": "这是仓库的平面图"
}
```

**请求体（不带图片）:**

```json
{
	"map_name": "虚拟坐标系统",
	"x_min": 0,
	"x_max": 1000,
	"y_min": 0,
	"y_max": 500,
	"center_x": 500,
	"center_y": 250,
	"description": "纯坐标系统，不需要地图图片"
}
```

**参数说明:**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| map_name | string | 是 | 地图名称，1-255 个字符 |
| image_base64 | string | 否 | Base64 编码的图片数据（最大 10MB），可选 |
| image_ext | string | 否\* | 图片扩展名，可选值：.jpg, .jpeg, .png, .gif, .webp<br/>**如果提供 image_base64 则必填** |
| x_min | float64 | 是 | X 坐标最小值 |
| x_max | float64 | 是 | X 坐标最大值 |
| y_min | float64 | 是 | Y 坐标最小值 |
| y_max | float64 | 是 | Y 坐标最大值 |
| center_x | float64 | 是 | 地图中心点 X 坐标 |
| center_y | float64 | 是 | 地图中心点 Y 坐标 |
| description | string | 否 | 地图描述，最多 1000 个字符 |

**curl 示例:**

```bash
# 创建带图片的地图
# 注意：实际使用时，image_base64 应该是完整的 Base64 编码字符串
curl -X POST http://localhost:8002/api/v1/custom-map \
  -H "Content-Type: application/json" \
  -d '{
    "map_name": "仓库平面图",
    "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAY...",
    "image_ext": ".png",
    "x_min": 0,
    "x_max": 1000,
    "y_min": 0,
    "y_max": 500,
    "center_x": 500,
    "center_y": 250,
    "description": "这是仓库的平面图"
  }'

# 创建不带图片的地图（仅坐标系统）
curl -X POST http://localhost:8002/api/v1/custom-map \
  -H "Content-Type: application/json" \
  -d '{
    "map_name": "虚拟坐标系统",
    "x_min": 0,
    "x_max": 1000,
    "y_min": 0,
    "y_max": 500,
    "center_x": 500,
    "center_y": 250,
    "description": "纯坐标系统"
  }'
```

**响应示例:**

```json
{
	"code": 201,
	"message": "自制地图创建成功",
	"data": null
}
```

---

### 2. 获取地图列表

**GET** `/api/v1/custom-map`

获取所有自制地图列表。

**curl 示例:**

```bash
curl http://localhost:8002/api/v1/custom-map
```

**响应示例:**

```json
{
	"code": 200,
	"message": "success",
	"data": [
		{
			"id": "123e4567-e89b-12d3-a456-426614174000",
			"map_name": "仓库平面图",
			"image_path": "/uploads/maps/abc123_1234567890.png",
			"image_url": "http://localhost:8002/uploads/maps/abc123_1234567890.png",
			"x_min": 0,
			"x_max": 1000,
			"y_min": 0,
			"y_max": 500,
			"center_x": 500,
			"center_y": 250,
			"description": "这是仓库的平面图",
			"created_at": "2025-01-15T10:30:00Z",
			"updated_at": "2025-01-15T10:30:00Z"
		},
		{
			"id": "223e4567-e89b-12d3-a456-426614174001",
			"map_name": "虚拟坐标系统",
			"image_path": "",
			"image_url": "",
			"x_min": 0,
			"x_max": 1000,
			"y_min": 0,
			"y_max": 500,
			"center_x": 500,
			"center_y": 250,
			"description": "纯坐标系统，无图片",
			"created_at": "2025-01-15T11:00:00Z",
			"updated_at": "2025-01-15T11:00:00Z"
		}
	]
}
```

**说明:** 如果地图创建时未上传图片，`image_path` 和 `image_url` 字段将为空字符串。

---

### 3. 获取最新地图

**GET** `/api/v1/custom-map/latest`

获取最新创建的地图。

**curl 示例:**

```bash
curl http://localhost:8002/api/v1/custom-map/latest
```

**响应示例:**

```json
{
	"code": 200,
	"message": "success",
	"data": {
		"id": "123e4567-e89b-12d3-a456-426614174000",
		"map_name": "仓库平面图",
		"image_path": "/uploads/maps/abc123_1234567890.png",
		"image_url": "http://localhost:8002/uploads/maps/abc123_1234567890.png",
		"x_min": 0,
		"x_max": 1000,
		"y_min": 0,
		"y_max": 500,
		"center_x": 500,
		"center_y": 250,
		"description": "这是仓库的平面图",
		"created_at": "2025-01-15T10:30:00Z",
		"updated_at": "2025-01-15T10:30:00Z"
	}
}
```

---

### 4. 获取单个地图

**GET** `/api/v1/custom-map/:id`

根据 ID 获取地图详情。

**路径参数:**

- `id` (UUID): 地图 ID

**curl 示例:**

```bash
curl http://localhost:8002/api/v1/custom-map/123e4567-e89b-12d3-a456-426614174000
```

**响应示例:**（同上）

---

### 5. 更新自制地图

**PUT** `/api/v1/custom-map/:id`

更新地图信息，可选择性上传新图片。

**路径参数:**

- `id` (UUID): 地图 ID

**请求体（所有字段可选）:**

```json
{
	"map_name": "仓库平面图-更新版",
	"description": "更新后的描述",
	"x_max": 1200
}
```

或者同时更新图片:

```json
{
	"map_name": "仓库平面图-更新版",
	"image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAY...",
	"image_ext": ".png",
	"x_max": 1200
}
```

**参数说明:**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| map_name | string | 否 | 地图名称，1-255 个字符 |
| image_base64 | string | 否 | Base64 编码的新图片数据 |
| image_ext | string | 否\* | 图片扩展名（如果提供 image_base64 则必填） |
| x_min | float64 | 否 | X 坐标最小值 |
| x_max | float64 | 否 | X 坐标最大值 |
| y_min | float64 | 否 | Y 坐标最小值 |
| y_max | float64 | 否 | Y 坐标最大值 |
| center_x | float64 | 否 | 地图中心点 X 坐标 |
| center_y | float64 | 否 | 地图中心点 Y 坐标 |
| description | string | 否 | 地图描述 |

**curl 示例:**

```bash
# 只更新名称和描述
curl -X PUT http://localhost:8002/api/v1/custom-map/123e4567-e89b-12d3-a456-426614174000 \
  -H "Content-Type: application/json" \
  -d '{
    "map_name": "仓库平面图-更新版",
    "description": "更新后的描述"
  }'

# 更新图片和坐标
curl -X PUT http://localhost:8002/api/v1/custom-map/123e4567-e89b-12d3-a456-426614174000 \
  -H "Content-Type: application/json" \
  -d '{
    "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAY...",
    "image_ext": ".png",
    "x_max": 1200
  }'
```

**响应示例:**

```json
{
	"code": 200,
	"message": "自制地图更新成功",
	"data": null
}
```

---

### 6. 删除自制地图

**DELETE** `/api/v1/custom-map/:id`

删除指定的地图（同时删除关联的图片文件）。

**路径参数:**

- `id` (UUID): 地图 ID

**curl 示例:**

```bash
curl -X DELETE http://localhost:8002/api/v1/custom-map/123e4567-e89b-12d3-a456-426614174000
```

**响应示例:**

```json
{
	"code": 200,
	"message": "自制地图删除成功",
	"data": null
}
```

---

## 多边形围栏 API

多边形围栏使用 PostGIS 进行空间数据存储和查询。

### 1. 创建多边形围栏

**POST** `/api/v1/polygon-fence`

创建一个新的多边形围栏。

**请求体:**

```json
{
	"fence_name": "仓库A区",
	"points": [
		{ "x": 0, "y": 0 },
		{ "x": 100, "y": 0 },
		{ "x": 100, "y": 50 },
		{ "x": 0, "y": 50 }
	],
	"description": "仓库A区的电子围栏"
}
```

**参数说明:**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| fence_name | string | 是 | 围栏名称，1-255 个字符，必须唯一 |
| points | array | 是 | 多边形顶点数组，至少 3 个点 |
| points[].x | float64 | 是 | 顶点 X 坐标 |
| points[].y | float64 | 是 | 顶点 Y 坐标 |
| description | string | 否 | 围栏描述，最多 1000 个字符 |

**curl 示例:**

```bash
curl -X POST http://localhost:8002/api/v1/polygon-fence \
  -H "Content-Type: application/json" \
  -d '{
    "fence_name": "仓库A区",
    "points": [
      {"x": 0, "y": 0},
      {"x": 100, "y": 0},
      {"x": 100, "y": 50},
      {"x": 0, "y": 50}
    ],
    "description": "仓库A区的电子围栏"
  }'
```

**响应示例:**

```json
{
	"code": 201,
	"message": "多边形围栏创建成功",
	"data": null
}
```

---

### 2. 获取围栏列表

**GET** `/api/v1/polygon-fence`

获取所有围栏列表。

**查询参数:**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| active_only | boolean | 否 | 是否只返回激活的围栏，默认 false |

**curl 示例:**

```bash
# 获取所有围栏
curl http://localhost:8002/api/v1/polygon-fence

# 只获取激活的围栏
curl http://localhost:8002/api/v1/polygon-fence?active_only=true
```

**响应示例:**

```json
{
	"code": 200,
	"message": "success",
	"data": [
		{
			"id": "123e4567-e89b-12d3-a456-426614174000",
			"fence_name": "仓库A区",
			"points": [
				{ "x": 0, "y": 0 },
				{ "x": 100, "y": 0 },
				{ "x": 100, "y": 50 },
				{ "x": 0, "y": 50 }
			],
			"description": "仓库A区的电子围栏",
			"is_active": true,
			"created_at": "2025-01-15T10:30:00Z",
			"updated_at": "2025-01-15T10:30:00Z"
		}
	]
}
```

---

### 3. 获取单个围栏

**GET** `/api/v1/polygon-fence/:id`

根据 ID 获取围栏详情。

**路径参数:**

- `id` (UUID): 围栏 ID

**curl 示例:**

```bash
curl http://localhost:8002/api/v1/polygon-fence/123e4567-e89b-12d3-a456-426614174000
```

**响应示例:**

```json
{
	"code": 200,
	"message": "success",
	"data": {
		"id": "123e4567-e89b-12d3-a456-426614174000",
		"fence_name": "仓库A区",
		"points": [
			{ "x": 0, "y": 0 },
			{ "x": 100, "y": 0 },
			{ "x": 100, "y": 50 },
			{ "x": 0, "y": 50 }
		],
		"description": "仓库A区的电子围栏",
		"is_active": true,
		"created_at": "2025-01-15T10:30:00Z",
		"updated_at": "2025-01-15T10:30:00Z"
	}
}
```

---

### 4. 更新围栏

**PUT** `/api/v1/polygon-fence/:id`

更新指定围栏的信息。

**路径参数:**

- `id` (UUID): 围栏 ID

**请求体（所有字段可选）:**

```json
{
	"fence_name": "仓库A区-更新",
	"points": [
		{ "x": 0, "y": 0 },
		{ "x": 120, "y": 0 },
		{ "x": 120, "y": 60 },
		{ "x": 0, "y": 60 }
	],
	"description": "更新后的描述",
	"is_active": false
}
```

**curl 示例:**

```bash
# 更新围栏名称和状态
curl -X PUT http://localhost:8002/api/v1/polygon-fence/123e4567-e89b-12d3-a456-426614174000 \
  -H "Content-Type: application/json" \
  -d '{
    "fence_name": "仓库A区-更新",
    "is_active": false
  }'

# 更新围栏形状
curl -X PUT http://localhost:8002/api/v1/polygon-fence/123e4567-e89b-12d3-a456-426614174000 \
  -H "Content-Type: application/json" \
  -d '{
    "points": [
      {"x": 0, "y": 0},
      {"x": 120, "y": 0},
      {"x": 120, "y": 60},
      {"x": 0, "y": 60}
    ]
  }'
```

**响应示例:**

```json
{
	"code": 200,
	"message": "多边形围栏更新成功",
	"data": null
}
```

---

### 5. 删除围栏

**DELETE** `/api/v1/polygon-fence/:id`

删除指定的围栏。

**路径参数:**

- `id` (UUID): 围栏 ID

**curl 示例:**

```bash
curl -X DELETE http://localhost:8002/api/v1/polygon-fence/123e4567-e89b-12d3-a456-426614174000
```

**响应示例:**

```json
{
	"code": 200,
	"message": "多边形围栏删除成功",
	"data": null
}
```

---

### 6. 检查点是否在指定围栏内

**POST** `/api/v1/polygon-fence/:id/check`

检查一个点是否在指定的围栏内。

**路径参数:**

- `id` (UUID): 围栏 ID

**请求体:**

```json
{
	"x": 50,
	"y": 25
}
```

**参数说明:**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| x | float64 | 是 | 点的 X 坐标 |
| y | float64 | 是 | 点的 Y 坐标 |

**curl 示例:**

```bash
curl -X POST http://localhost:8002/api/v1/polygon-fence/123e4567-e89b-12d3-a456-426614174000/check \
  -H "Content-Type: application/json" \
  -d '{
    "x": 50,
    "y": 25
  }'
```

**响应示例（点在围栏内）:**

```json
{
	"code": 200,
	"message": "success",
	"data": {
		"is_inside": true,
		"fence_id": "123e4567-e89b-12d3-a456-426614174000",
		"fence_name": "仓库A区"
	}
}
```

**响应示例（点不在围栏内）:**

```json
{
	"code": 200,
	"message": "success",
	"data": {
		"is_inside": false
	}
}
```

---

### 7. 检查点在哪些围栏内

**POST** `/api/v1/polygon-fence/check-all`

检查一个点在所有激活的围栏中的位置，返回包含该点的所有围栏。

**请求体:**

```json
{
	"x": 50,
	"y": 25
}
```

**curl 示例:**

```bash
curl -X POST http://localhost:8002/api/v1/polygon-fence/check-all \
  -H "Content-Type: application/json" \
  -d '{
    "x": 50,
    "y": 25
  }'
```

**响应示例（点在多个围栏内）:**

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

**响应示例（点不在任何围栏内）:**

```json
{
	"code": 200,
	"message": "success",
	"data": {
		"is_inside": false
	}
}
```

---

## 错误码说明

### 客户端错误 (4xx)

| 错误码 | 说明         | 常见原因                                   |
| ------ | ------------ | ------------------------------------------ |
| 400    | 请求参数错误 | 参数格式不正确、缺少必填参数、参数验证失败 |
| 404    | 资源不存在   | ID 不存在、资源已被删除                    |
| 409    | 资源冲突     | 名称重复、状态冲突                         |
| 413    | 文件过大     | 上传的图片超过 10MB                        |
| 415    | 不支持的格式 | 上传的文件格式不支持                       |

### 服务器错误 (5xx)

| 错误码 | 说明           | 处理建议                   |
| ------ | -------------- | -------------------------- |
| 500    | 服务器内部错误 | 联系管理员或查看服务器日志 |
| 502    | 网关错误       | 检查后端服务是否正常       |
| 503    | 服务不可用     | 服务可能正在维护           |

---

## 完整使用示例

### 示例 1: 创建完整的仓库监控系统

```bash
# 1. 上传仓库平面图
# 注意：实际使用时需要先将图片转换为 Base64 编码
# 例如: base64 warehouse_map.png | tr -d '\n' > image_base64.txt
curl -X POST http://localhost:8002/api/v1/custom-map \
  -H "Content-Type: application/json" \
  -d '{
    "map_name": "仓库平面图",
    "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAY...",
    "image_ext": ".png",
    "x_min": 0,
    "x_max": 1000,
    "y_min": 0,
    "y_max": 500,
    "center_x": 500,
    "center_y": 250
  }'

# 2. 创建基站
curl -X POST http://localhost:8002/api/v1/station \
  -H "Content-Type: application/json" \
  -d '{
    "station_name": "入口基站",
    "coordinate_x": 100,
    "coordinate_y": 100
  }'

# 3. 创建安全区域围栏
curl -X POST http://localhost:8002/api/v1/polygon-fence \
  -H "Content-Type: application/json" \
  -d '{
    "fence_name": "安全区域",
    "points": [
      {"x": 200, "y": 200},
      {"x": 800, "y": 200},
      {"x": 800, "y": 400},
      {"x": 200, "y": 400}
    ],
    "description": "核心安全区域"
  }'

# 4. 检查设备位置是否在安全区域内
curl -X POST http://localhost:8002/api/v1/polygon-fence/check-all \
  -H "Content-Type: application/json" \
  -d '{
    "x": 500,
    "y": 300
  }'
```

### 示例 2: 管理和监控围栏

```bash
# 1. 获取所有激活的围栏
curl http://localhost:8002/api/v1/polygon-fence?active_only=true

# 2. 临时禁用围栏（维护）
curl -X PUT http://localhost:8002/api/v1/polygon-fence/{fence_id} \
  -H "Content-Type: application/json" \
  -d '{"is_active": false}'

# 3. 重新激活围栏
curl -X PUT http://localhost:8002/api/v1/polygon-fence/{fence_id} \
  -H "Content-Type: application/json" \
  -d '{"is_active": true}'

# 4. 调整围栏范围
curl -X PUT http://localhost:8002/api/v1/polygon-fence/{fence_id} \
  -H "Content-Type: application/json" \
  -d '{
    "points": [
      {"x": 150, "y": 150},
      {"x": 850, "y": 150},
      {"x": 850, "y": 450},
      {"x": 150, "y": 450}
    ]
  }'
```

---

## 静态文件访问

上传的地图图片可通过以下方式访问：

```
http://localhost:8002/uploads/maps/{filename}
```

示例:

```bash
curl http://localhost:8002/uploads/maps/abc123_1234567890.png -o downloaded_map.png
```

---

## 技术栈

- **后端框架**: Go + Fiber
- **数据库**: PostgreSQL 14+
- **空间扩展**: PostGIS 3.0+
- **ORM**: GORM
- **坐标系统**: 平面坐标系（非经纬度）

---

## 环境变量配置

```bash
# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=iot_manager_db
DB_SSLMODE=disable

# 服务配置
PORT=8002

# 数据库连接池
DB_MAX_OPEN_CONNS=100
DB_MAX_IDLE_CONNS=20
DB_MAX_LIFETIME=1h
DB_MAX_RETRY=5
DB_RETRY_INTERVAL=2s
```

---

## 注意事项

1. **PostGIS 扩展**: 确保数据库已启用 PostGIS 扩展

   ```sql
   CREATE EXTENSION IF NOT EXISTS postgis;
   ```

2. **文件上传限制**:

   - 图片上传为可选，可以创建不带图片的纯坐标系统地图
   - 支持格式: JPG, PNG, GIF, WEBP
   - 最大大小: 10MB
   - 如果提供 `image_base64`，则必须同时提供 `image_ext`

3. **坐标系统**:

   - 使用平面坐标系，不是经纬度坐标
   - 坐标值为 float64 类型

4. **多边形围栏**:

   - 至少需要 3 个顶点
   - 顶点数量上限 10000 个
   - 系统会自动闭合多边形

5. **UUID 格式**:
   - 所有 ID 均为标准 UUID 格式
   - 示例: `123e4567-e89b-12d3-a456-426614174000`

---

## 联系方式

如有问题或建议，请联系开发团队。

**项目地址**: IOT-Manage-System/map-service  
**版本**: v0.0.2  
**最后更新**: 2025-01-15

---

## 更新日志

### v0.0.2 (2025-01-15)

- ✨ 允许创建地图时不上传图片，支持纯坐标系统地图
- 🔧 优化图片上传逻辑，`image_base64` 和 `image_ext` 字段改为可选
- 📝 更新 API 文档，添加不带图片的创建示例
