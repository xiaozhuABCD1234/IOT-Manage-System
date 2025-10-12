# 多边形围栏 API 文档

## 概述

多边形围栏功能使用 PostGIS 扩展来存储和查询多边形几何数据，支持创建、查询、更新、删除围栏，以及检查点是否在围栏内等空间查询功能。

## 数据库表结构

```sql
-- 已创建的表
CREATE TABLE polygon_fences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fence_name VARCHAR(255) NOT NULL UNIQUE,
    geometry GEOMETRY(POLYGON, 0) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 索引
CREATE INDEX idx_polygon_fences_geometry ON polygon_fences USING GIST(geometry);
CREATE INDEX idx_polygon_fences_name ON polygon_fences(fence_name);
CREATE INDEX idx_polygon_fences_active ON polygon_fences(is_active);
```

## API 端点

基础路径: `/api/v1/polygon-fence`

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

- `fence_name` (string, 必填): 围栏名称，1-255 个字符，必须唯一
- `points` (array, 必填): 多边形顶点数组，至少 3 个点
  - `x` (float64, 必填): X 坐标
  - `y` (float64, 必填): Y 坐标
- `description` (string, 可选): 围栏描述，最多 1000 个字符

**响应:**

```json
{
	"code": 201,
	"message": "多边形围栏创建成功",
	"data": null
}
```

**示例 (curl):**

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

---

### 2. 获取单个围栏

**GET** `/api/v1/polygon-fence/:id`

根据 ID 获取围栏详情。

**路径参数:**

- `id` (UUID): 围栏 ID

**响应:**

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

**示例 (curl):**

```bash
curl http://localhost:8002/api/v1/polygon-fence/123e4567-e89b-12d3-a456-426614174000
```

---

### 3. 获取围栏列表

**GET** `/api/v1/polygon-fence`

获取所有围栏列表。

**查询参数:**

- `active_only` (boolean, 可选): 是否只返回激活的围栏，默认 false

**响应:**

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

**示例 (curl):**

```bash
# 获取所有围栏
curl http://localhost:8002/api/v1/polygon-fence

# 只获取激活的围栏
curl http://localhost:8002/api/v1/polygon-fence?active_only=true
```

---

### 4. 更新围栏

**PUT** `/api/v1/polygon-fence/:id`

更新指定围栏的信息。

**路径参数:**

- `id` (UUID): 围栏 ID

**请求体:**

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

**参数说明:**
所有参数都是可选的，只需要传递要更新的字段：

- `fence_name` (string, 可选): 新的围栏名称
- `points` (array, 可选): 新的多边形顶点
- `description` (string, 可选): 新的描述
- `is_active` (boolean, 可选): 是否激活

**响应:**

```json
{
	"code": 200,
	"message": "多边形围栏更新成功",
	"data": null
}
```

**示例 (curl):**

```bash
curl -X PUT http://localhost:8002/api/v1/polygon-fence/123e4567-e89b-12d3-a456-426614174000 \
  -H "Content-Type: application/json" \
  -d '{
    "fence_name": "仓库A区-更新",
    "is_active": false
  }'
```

---

### 5. 删除围栏

**DELETE** `/api/v1/polygon-fence/:id`

删除指定的围栏。

**路径参数:**

- `id` (UUID): 围栏 ID

**响应:**

```json
{
	"code": 200,
	"message": "多边形围栏删除成功",
	"data": null
}
```

**示例 (curl):**

```bash
curl -X DELETE http://localhost:8002/api/v1/polygon-fence/123e4567-e89b-12d3-a456-426614174000
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

- `x` (float64, 必填): 点的 X 坐标
- `y` (float64, 必填): 点的 Y 坐标

**响应:**

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

**响应字段说明:**

- `is_inside` (boolean): 点是否在围栏内
- `fence_id` (string): 围栏 ID（仅当点在围栏内时返回）
- `fence_name` (string): 围栏名称（仅当点在围栏内时返回）

**示例 (curl):**

```bash
curl -X POST http://localhost:8002/api/v1/polygon-fence/123e4567-e89b-12d3-a456-426614174000/check \
  -H "Content-Type: application/json" \
  -d '{
    "x": 50,
    "y": 25
  }'
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

**参数说明:**

- `x` (float64, 必填): 点的 X 坐标
- `y` (float64, 必填): 点的 Y 坐标

**响应:**

```json
{
	"code": 200,
	"message": "success",
	"data": {
		"is_inside": true,
		"fence_id": "123e4567-e89b-12d3-a456-426614174000",
		"fence_name": "仓库A区",
		"fence_names": ["仓库A区", "安全区域"]
	}
}
```

**响应字段说明:**

- `is_inside` (boolean): 点是否在任何围栏内
- `fence_id` (string): 第一个包含该点的围栏 ID
- `fence_name` (string): 第一个包含该点的围栏名称
- `fence_names` (array): 所有包含该点的围栏名称列表

**示例 (curl):**

```bash
curl -X POST http://localhost:8002/api/v1/polygon-fence/check-all \
  -H "Content-Type: application/json" \
  -d '{
    "x": 50,
    "y": 25
  }'
```

---

## 错误响应

所有接口在出错时返回统一的错误格式：

```json
{
	"code": 400,
	"message": "数据校验失败",
	"details": "多边形至少需要3个顶点"
}
```

**常见错误码:**

- `400` - 请求参数错误
- `404` - 资源不存在
- `409` - 数据冲突（如围栏名称重复）
- `500` - 服务器内部错误

---

## 业务规则

1. **围栏名称唯一性**: 每个围栏的名称必须唯一
2. **多边形顶点数量**: 至少需要 3 个顶点，最多 10000 个顶点
3. **顶点去重**: 不允许连续的重复顶点
4. **自动闭合**: 多边形会自动闭合（首尾相连）
5. **空间查询**: 只对激活的围栏（`is_active=true`）进行空间查询
6. **PostGIS 支持**: 使用 PostGIS 的 `ST_Contains` 函数进行高效的点面判断

---

## 使用场景示例

### 场景 1: 创建仓库围栏并检查设备位置

```bash
# 1. 创建仓库围栏
curl -X POST http://localhost:8002/api/v1/polygon-fence \
  -H "Content-Type: application/json" \
  -d '{
    "fence_name": "仓库A区",
    "points": [
      {"x": 0, "y": 0},
      {"x": 100, "y": 0},
      {"x": 100, "y": 50},
      {"x": 0, "y": 50}
    ]
  }'

# 2. 检查设备(x=50, y=25)是否在仓库内
curl -X POST http://localhost:8002/api/v1/polygon-fence/check-all \
  -H "Content-Type: application/json" \
  -d '{"x": 50, "y": 25}'
```

### 场景 2: 管理多个安全区域

```bash
# 1. 获取所有激活的围栏
curl http://localhost:8002/api/v1/polygon-fence?active_only=true

# 2. 暂时禁用某个围栏
curl -X PUT http://localhost:8002/api/v1/polygon-fence/{id} \
  -H "Content-Type: application/json" \
  -d '{"is_active": false}'

# 3. 重新激活围栏
curl -X PUT http://localhost:8002/api/v1/polygon-fence/{id} \
  -H "Content-Type: application/json" \
  -d '{"is_active": true}'
```

---

## 技术栈

- **PostgreSQL + PostGIS**: 空间数据存储和查询
- **Go + Fiber**: Web 框架
- **GORM**: ORM（使用原生 SQL 进行 PostGIS 操作）
- **WKT 格式**: Well-Known Text 用于存储多边形几何数据

---

## 注意事项

1. 确保 PostgreSQL 已安装并启用 PostGIS 扩展
2. 坐标系统与项目中的地图坐标系统保持一致
3. 对于大量围栏和频繁的空间查询，PostGIS 的 GIST 索引能提供优秀的性能
4. 多边形顶点按逆时针或顺时针顺序排列都可以
5. 数据库会自动为多边形添加闭合点，API 层会自动去除闭合点返回原始顶点
