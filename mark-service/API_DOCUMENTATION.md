# 电子标记服务 API 文档

## 基本信息

- **服务名称**: 电子标记服务 (mark-service)
- **版本**: v0.0.2
- **基础路径**: `/api/v1`
- **默认端口**: `8004`

## 目录

- [健康检查](#健康检查)
- [标记管理 (Marks)](#标记管理-marks)
- [标签管理 (Tags)](#标签管理-tags)
- [类型管理 (Types)](#类型管理-types)
- [标记对距离管理 (Pairs)](#标记对距离管理-pairs)
- [数据模型](#数据模型)
- [错误响应](#错误响应)

---

## 健康检查

### 健康检查

检查服务运行状态。

**接口**

```
GET /health
```

**响应示例**

```
服务运行正常
```

---

## 标记管理 (Marks)

### 1. 创建标记

创建一个新的标记。

**接口**

```
POST /api/v1/marks
```

**请求体**

```json
{
	"device_id": "device-001",
	"mark_name": "标记A",
	"mqtt_topic": ["topic/device/001"],
	"persist_mqtt": true,
	"danger_zone_m": 10.5,
	"mark_type_id": 1,
	"tags": ["tag1", "tag2"]
}
```

**字段说明**

- `device_id` (string, 必填): 设备 ID，最大 255 字符
- `mark_name` (string, 必填): 标记名称，最大 255 字符
- `mqtt_topic` (array, 可选): MQTT 主题列表
- `persist_mqtt` (boolean, 可选): 是否持久化 MQTT 消息
- `danger_zone_m` (float, 可选): 安全距离（米）
- `mark_type_id` (int, 可选): 标记类型 ID
- `tags` (array, 可选): 标签名称列表

**响应示例 (201 Created)**

```json
{
	"code": 201,
	"msg": "标记创建成功",
	"data": null
}
```

---

### 2. 获取标记列表

分页获取标记列表。

**接口**

```
GET /api/v1/marks
```

**查询参数**

- `page` (int, 可选, 默认: 1): 页码
- `limit` (int, 可选, 默认: 10, 最大: 100): 每页数量
- `preload` (boolean, 可选, 默认: false): 是否预加载关联数据（类型和标签）

**示例**

```
GET /api/v1/marks?page=1&limit=10&preload=true
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"items": [
			{
				"id": "550e8400-e29b-41d4-a716-446655440000",
				"device_id": "device-001",
				"mark_name": "标记A",
				"mqtt_topic": ["topic/device/001"],
				"persist_mqtt": true,
				"danger_zone_m": 10.5,
				"mark_type": {
					"id": 1,
					"type_name": "类型A",
					"default_danger_zone_m": 5.0
				},
				"tags": [
					{
						"id": 1,
						"tag_name": "tag1"
					}
				],
				"created_at": "2025-01-01T12:00:00Z",
				"updated_at": "2025-01-01T12:00:00Z",
				"last_online_at": "2025-01-01T15:30:00Z"
			}
		],
		"total": 100,
		"page": 1,
		"limit": 10
	}
}
```

---

### 3. 根据 ID 获取标记

根据标记 ID 获取单个标记详情。

**接口**

```
GET /api/v1/marks/:id
```

**路径参数**

- `id` (string, 必填): 标记 UUID

**查询参数**

- `preload` (boolean, 可选, 默认: false): 是否预加载关联数据

**示例**

```
GET /api/v1/marks/550e8400-e29b-41d4-a716-446655440000?preload=true
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"id": "550e8400-e29b-41d4-a716-446655440000",
		"device_id": "device-001",
		"mark_name": "标记A",
		"mqtt_topic": ["topic/device/001"],
		"persist_mqtt": true,
		"danger_zone_m": 10.5,
		"mark_type": {
			"id": 1,
			"type_name": "类型A",
			"default_danger_zone_m": 5.0
		},
		"tags": [
			{
				"id": 1,
				"tag_name": "tag1"
			}
		],
		"created_at": "2025-01-01T12:00:00Z",
		"updated_at": "2025-01-01T12:00:00Z",
		"last_online_at": "2025-01-01T15:30:00Z"
	}
}
```

---

### 4. 根据设备 ID 获取标记

根据设备 ID 获取标记详情。

**接口**

```
GET /api/v1/marks/device/:device_id
```

**路径参数**

- `device_id` (string, 必填): 设备 ID

**查询参数**

- `preload` (boolean, 可选, 默认: false): 是否预加载关联数据

**示例**

```
GET /api/v1/marks/device/device-001?preload=true
```

**响应示例 (200 OK)**

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "device_id": "device-001",
    "mark_name": "标记A",
    ...
  }
}
```

---

### 5. 更新标记

更新标记信息（支持部分更新）。

**接口**

```
PUT /api/v1/marks/:id
```

**路径参数**

- `id` (string, 必填): 标记 UUID

**请求体** (所有字段均为可选)

```json
{
	"device_id": "device-001-updated",
	"mark_name": "标记A（更新）",
	"mqtt_topic": ["topic/device/001", "topic/device/002"],
	"persist_mqtt": false,
	"danger_zone_m": 15.0,
	"mark_type_id": 2,
	"tags": ["tag1", "tag3"]
}
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "标记更新成功",
	"data": null
}
```

---

### 6. 删除标记

根据标记 ID 删除标记。

**接口**

```
DELETE /api/v1/marks/:id
```

**路径参数**

- `id` (string, 必填): 标记 UUID

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "标记删除成功",
	"data": null
}
```

---

### 7. 获取所有标记 ID 到名称的映射

获取全部 markID → markName 的映射关系。

**接口**

```
GET /api/v1/marks/id-to-name
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"550e8400-e29b-41d4-a716-446655440000": "标记A",
		"6ba7b810-9dad-11d1-80b4-00c04fd430c8": "标记B",
		"f47ac10b-58cc-4372-a567-0e02b2c3d479": "标记C"
	}
}
```

---

### 8. 获取所有设备 ID 到名称的映射

获取全部 deviceID → markName 的映射关系。

**接口**

```
GET /api/v1/marks/device/id-to-name
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"device-001": "标记A",
		"device-002": "标记B",
		"device-003": "标记C"
	}
}
```

---

### 9. 更新最后在线时间

更新标记的最后在线时间。

**接口**

```
PUT /api/v1/marks/device/:device_id/last-online
```

**路径参数**

- `device_id` (string, 必填): 设备 ID

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "标记最后在线时间更新成功",
	"data": null
}
```

---

### 10. 根据设备 ID 查询 PersistMQTT 值

根据设备 ID 查询 PersistMQTT 配置值。

**接口**

```
GET /api/v1/marks/persist/device/:device_id
```

**路径参数**

- `device_id` (string, 必填): 设备 ID

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": true
}
```

---

### 11. 根据 PersistMQTT 值查询标记列表

根据 PersistMQTT 值筛选标记列表（分页）。

**接口**

```
GET /api/v1/marks/persist/list
```

**查询参数**

- `persist` (boolean, 必填): persist 值（true/false）
- `page` (int, 可选, 默认: 1): 页码
- `limit` (int, 可选, 默认: 10, 最大: 100): 每页数量
- `preload` (boolean, 可选, 默认: false): 是否预加载关联数据

**示例**

```
GET /api/v1/marks/persist/list?persist=true&page=1&limit=10
```

**响应示例 (200 OK)**

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "items": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "device_id": "device-001",
        "persist_mqtt": true,
        ...
      }
    ],
    "total": 50,
    "page": 1,
    "limit": 10
  }
}
```

---

### 12. 根据 PersistMQTT 值查询设备 ID 列表

根据 PersistMQTT 值获取所有设备 ID 列表。

**接口**

```
GET /api/v1/marks/persist/device-ids
```

**查询参数**

- `persist` (boolean, 必填): persist 值（true/false）

**示例**

```
GET /api/v1/marks/persist/device-ids?persist=true
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": ["device-001", "device-002", "device-003"]
}
```

---

## 标签管理 (Tags)

### 1. 创建标签

创建一个新的标签。

**接口**

```
POST /api/v1/tags
```

**请求体**

```json
{
	"tag_name": "重要设备"
}
```

**字段说明**

- `tag_name` (string, 必填): 标签名称，最大 255 字符，全局唯一

**响应示例 (201 Created)**

```json
{
	"code": 201,
	"msg": "标签创建成功",
	"data": null
}
```

---

### 2. 获取标签列表

分页获取标签列表。

**接口**

```
GET /api/v1/tags
```

**查询参数**

- `page` (int, 可选, 默认: 1): 页码
- `limit` (int, 可选, 默认: 10, 最大: 100): 每页数量

**示例**

```
GET /api/v1/tags?page=1&limit=10
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"items": [
			{
				"id": 1,
				"tag_name": "重要设备"
			},
			{
				"id": 2,
				"tag_name": "室外设备"
			}
		],
		"total": 20,
		"page": 1,
		"limit": 10
	}
}
```

---

### 3. 根据 ID 获取标签

根据标签 ID 获取标签详情。

**接口**

```
GET /api/v1/tags/:tag_id
```

**路径参数**

- `tag_id` (int, 必填): 标签 ID

**示例**

```
GET /api/v1/tags/1
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"id": 1,
		"tag_name": "重要设备"
	}
}
```

---

### 4. 根据名称获取标签

根据标签名称获取标签详情。

**接口**

```
GET /api/v1/tags/name/:tag_name
```

**路径参数**

- `tag_name` (string, 必填): 标签名称

**示例**

```
GET /api/v1/tags/name/重要设备
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"id": 1,
		"tag_name": "重要设备"
	}
}
```

---

### 5. 更新标签

更新标签信息。

**接口**

```
PUT /api/v1/tags/:tag_id
```

**路径参数**

- `tag_id` (int, 必填): 标签 ID

**请求体**

```json
{
	"tag_name": "重要设备（已更新）"
}
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "标签更新成功",
	"data": null
}
```

---

### 6. 删除标签

删除标签。

**接口**

```
DELETE /api/v1/tags/:tag_id
```

**路径参数**

- `tag_id` (int, 必填): 标签 ID

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "标签删除成功",
	"data": null
}
```

---

### 7. 根据标签 ID 获取标记列表

根据标签 ID 获取关联的标记列表（分页）。

**接口**

```
GET /api/v1/tags/:tag_id/marks
```

**路径参数**

- `tag_id` (int, 必填): 标签 ID

**查询参数**

- `page` (int, 可选, 默认: 1): 页码
- `limit` (int, 可选, 默认: 10, 最大: 100): 每页数量
- `preload` (boolean, 可选, 默认: false): 是否预加载关联数据

**示例**

```
GET /api/v1/tags/1/marks?page=1&limit=10&preload=true
```

**响应示例 (200 OK)**

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "items": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "device_id": "device-001",
        "mark_name": "标记A",
        ...
      }
    ],
    "total": 15,
    "page": 1,
    "limit": 10
  }
}
```

---

### 8. 根据标签名称获取标记列表

根据标签名称获取关联的标记列表（分页）。

**接口**

```
GET /api/v1/tags/name/:tag_name/marks
```

**路径参数**

- `tag_name` (string, 必填): 标签名称

**查询参数**

- `page` (int, 可选, 默认: 1): 页码
- `limit` (int, 可选, 默认: 10, 最大: 100): 每页数量
- `preload` (boolean, 可选, 默认: false): 是否预加载关联数据

**示例**

```
GET /api/v1/tags/name/重要设备/marks?page=1&limit=10
```

**响应示例 (200 OK)**

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "items": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "device_id": "device-001",
        "mark_name": "标记A",
        ...
      }
    ],
    "total": 15,
    "page": 1,
    "limit": 10
  }
}
```

---

### 9. 获取所有标签 ID 到名称的映射

获取全部 tagID → tagName 的映射关系。

**接口**

```
GET /api/v1/tags/id-to-name
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"1": "重要设备",
		"2": "室外设备",
		"3": "测试设备"
	}
}
```

---

## 类型管理 (Types)

### 1. 创建类型

创建一个新的标记类型。

**接口**

```
POST /api/v1/types
```

**请求体**

```json
{
	"type_name": "移动设备",
	"default_danger_zone_m": 5.0
}
```

**字段说明**

- `type_name` (string, 必填): 类型名称，最大 255 字符，全局唯一
- `default_danger_zone_m` (float, 可选): 该类型的默认安全距离（米）

**响应示例 (201 Created)**

```json
{
	"code": 201,
	"msg": "标记类型创建成功",
	"data": null
}
```

---

### 2. 获取类型列表

分页获取类型列表。

**接口**

```
GET /api/v1/types
```

**查询参数**

- `page` (int, 可选, 默认: 1): 页码
- `limit` (int, 可选, 默认: 10, 最大: 100): 每页数量

**示例**

```
GET /api/v1/types?page=1&limit=10
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"items": [
			{
				"id": 1,
				"type_name": "移动设备",
				"default_danger_zone_m": 5.0
			},
			{
				"id": 2,
				"type_name": "固定设备",
				"default_danger_zone_m": 10.0
			}
		],
		"total": 10,
		"page": 1,
		"limit": 10
	}
}
```

---

### 3. 根据 ID 获取类型

根据类型 ID 获取类型详情。

**接口**

```
GET /api/v1/types/:type_id
```

**路径参数**

- `type_id` (int, 必填): 类型 ID

**示例**

```
GET /api/v1/types/1
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"id": 1,
		"type_name": "移动设备",
		"default_danger_zone_m": 5.0
	}
}
```

---

### 4. 根据名称获取类型

根据类型名称获取类型详情。

**接口**

```
GET /api/v1/types/name/:type_name
```

**路径参数**

- `type_name` (string, 必填): 类型名称

**示例**

```
GET /api/v1/types/name/移动设备
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"id": 1,
		"type_name": "移动设备",
		"default_danger_zone_m": 5.0
	}
}
```

---

### 5. 更新类型

更新类型信息。

**接口**

```
PUT /api/v1/types/:type_id
```

**路径参数**

- `type_id` (int, 必填): 类型 ID

**请求体** (所有字段均为可选)

```json
{
	"type_name": "移动设备（已更新）",
	"default_danger_zone_m": 8.0
}
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "标记类型更新成功",
	"data": null
}
```

---

### 6. 删除类型

删除类型。

**接口**

```
DELETE /api/v1/types/:type_id
```

**路径参数**

- `type_id` (int, 必填): 类型 ID

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "标记类型删除成功",
	"data": null
}
```

---

### 7. 根据类型 ID 获取标记列表

根据类型 ID 获取关联的标记列表（分页）。

**接口**

```
GET /api/v1/types/:type_id/marks
```

**路径参数**

- `type_id` (int, 必填): 类型 ID

**查询参数**

- `page` (int, 可选, 默认: 1): 页码
- `limit` (int, 可选, 默认: 10, 最大: 100): 每页数量
- `preload` (boolean, 可选, 默认: false): 是否预加载关联数据

**示例**

```
GET /api/v1/types/1/marks?page=1&limit=10&preload=true
```

**响应示例 (200 OK)**

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "items": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "device_id": "device-001",
        "mark_name": "标记A",
        ...
      }
    ],
    "total": 25,
    "page": 1,
    "limit": 10
  }
}
```

---

### 8. 根据类型名称获取标记列表

根据类型名称获取关联的标记列表（分页）。

**接口**

```
GET /api/v1/types/name/:type_name/marks
```

**路径参数**

- `type_name` (string, 必填): 类型名称

**查询参数**

- `page` (int, 可选, 默认: 1): 页码
- `limit` (int, 可选, 默认: 10, 最大: 100): 每页数量
- `preload` (boolean, 可选, 默认: false): 是否预加载关联数据

**示例**

```
GET /api/v1/types/name/移动设备/marks?page=1&limit=10
```

**响应示例 (200 OK)**

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "items": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440000",
        "device_id": "device-001",
        "mark_name": "标记A",
        ...
      }
    ],
    "total": 25,
    "page": 1,
    "limit": 10
  }
}
```

---

### 9. 获取所有类型 ID 到名称的映射

获取全部 typeID → typeName 的映射关系。

**接口**

```
GET /api/v1/types/id-to-name
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"1": "移动设备",
		"2": "固定设备",
		"3": "传感器"
	}
}
```

---

## 标记对距离管理 (Pairs)

### 1. 分页获取标记对列表

分页获取所有标记对的距离配置列表。

**接口**

```
GET /api/v1/pairs
```

**查询参数**

- `page` (int, 可选, 默认: 1): 页码
- `limit` (int, 可选, 默认: 10, 最大: 100): 每页数量

**示例**

```
GET /api/v1/pairs?page=1&limit=10
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"items": [
			{
				"mark1_id": "550e8400-e29b-41d4-a716-446655440000",
				"mark2_id": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
				"distance_m": 15.5
			},
			{
				"mark1_id": "550e8400-e29b-41d4-a716-446655440000",
				"mark2_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
				"distance_m": 20.0
			}
		],
		"total": 50,
		"page": 1,
		"limit": 10
	}
}
```

---

### 2. 设置单对标记距离

设置或更新两个标记之间的安全距离。

**接口**

```
POST /api/v1/pairs/distance
```

**请求体**

```json
{
	"mark1_id": "550e8400-e29b-41d4-a716-446655440000",
	"mark2_id": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
	"distance": 15.5
}
```

**字段说明**

- `mark1_id` (string, 必填): 第一个标记的 UUID
- `mark2_id` (string, 必填): 第二个标记的 UUID
- `distance` (float, 必填): 安全距离（米），必须 >= 0

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "标记对距离设置成功",
	"data": null
}
```

---

### 3. 批量设置标记组合距离

为一组标记的所有组合设置相同的安全距离（使用组合算法）。

**接口**

```
POST /api/v1/pairs/combinations
```

**请求体**

```json
{
	"mark_ids": [
		"550e8400-e29b-41d4-a716-446655440000",
		"6ba7b810-9dad-11d1-80b4-00c04fd430c8",
		"f47ac10b-58cc-4372-a567-0e02b2c3d479"
	],
	"distance": 10.0
}
```

**字段说明**

- `mark_ids` (array, 必填): 标记 UUID 列表，至少 2 个
- `distance` (float, 必填): 统一的安全距离（米），必须 >= 0

**说明**: 该接口会为 mark_ids 列表中的所有两两组合设置距离。例如，3 个标记会生成 3 对距离设置。

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "标记组合距离批量设置成功",
	"data": null
}
```

---

### 4. 笛卡尔积方式设置标记对距离

使用类型化标识（可以是标记、标签或类型）的笛卡尔积方式批量设置距离。

**接口**

```
POST /api/v1/pairs/cartesian
```

**请求体**

```json
{
	"first": {
		"kind": "type",
		"type_id": 1
	},
	"second": {
		"kind": "tag",
		"tag_id": 2
	},
	"distance": 20.0
}
```

**字段说明**

- `first` (object, 必填): 第一组标识
  - `kind` (string, 必填): 类型，可选值: "mark", "tag", "type"
  - `mark_id` (string, 可选): 当 kind="mark"时使用
  - `tag_id` (int, 可选): 当 kind="tag"时使用
  - `type_id` (int, 可选): 当 kind="type"时使用
- `second` (object, 必填): 第二组标识（结构同 first）
- `distance` (float, 必填): 安全距离（米），必须 >= 0

**说明**: 该接口会为 first 和 second 代表的所有标记进行笛卡尔积计算，批量设置距离。例如，如果 first 是类型 A（包含 3 个标记），second 是标签 B（包含 4 个标记），则会生成 12 对距离设置。

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "标记对笛卡尔积距离设置成功",
	"data": null
}
```

---

### 5. 查询单对标记距离

查询两个标记之间的安全距离。

**接口**

```
GET /api/v1/pairs/distance/:mark1_id/:mark2_id
```

**路径参数**

- `mark1_id` (string, 必填): 第一个标记的 UUID
- `mark2_id` (string, 必填): 第二个标记的 UUID

**示例**

```
GET /api/v1/pairs/distance/550e8400-e29b-41d4-a716-446655440000/6ba7b810-9dad-11d1-80b4-00c04fd430c8
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"mark1_id": "550e8400-e29b-41d4-a716-446655440000",
		"mark2_id": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
		"distance": 15.5
	}
}
```

---

### 6. 删除单对标记距离

删除两个标记之间的安全距离设置。

**接口**

```
DELETE /api/v1/pairs/distance/:mark1_id/:mark2_id
```

**路径参数**

- `mark1_id` (string, 必填): 第一个标记的 UUID
- `mark2_id` (string, 必填): 第二个标记的 UUID

**示例**

```
DELETE /api/v1/pairs/distance/550e8400-e29b-41d4-a716-446655440000/6ba7b810-9dad-11d1-80b4-00c04fd430c8
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "标记对距离删除成功",
	"data": null
}
```

---

### 7. 查询某个标记与所有其他标记的距离映射

根据标记 ID 查询该标记与其他所有标记的距离映射表。

**接口**

```
GET /api/v1/pairs/distance/map/mark/:id
```

**路径参数**

- `id` (string, 必填): 标记 UUID

**示例**

```
GET /api/v1/pairs/distance/map/mark/550e8400-e29b-41d4-a716-446655440000
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"6ba7b810-9dad-11d1-80b4-00c04fd430c8": 15.5,
		"f47ac10b-58cc-4372-a567-0e02b2c3d479": 20.0,
		"7c9e6679-7425-40de-944b-e07fc1f90ae7": 10.0
	}
}
```

---

### 8. 查询某个设备与所有其他标记的距离映射

根据设备 ID 查询该设备对应的标记与其他所有标记的距离映射表。

**接口**

```
GET /api/v1/pairs/distance/map/device/:device_id
```

**路径参数**

- `device_id` (string, 必填): 设备 ID

**示例**

```
GET /api/v1/pairs/distance/map/device/device-001
```

**响应示例 (200 OK)**

```json
{
	"code": 200,
	"msg": "success",
	"data": {
		"6ba7b810-9dad-11d1-80b4-00c04fd430c8": 15.5,
		"f47ac10b-58cc-4372-a567-0e02b2c3d479": 20.0,
		"7c9e6679-7425-40de-944b-e07fc1f90ae7": 10.0
	}
}
```

---

## 数据模型

### Mark (标记)

```json
{
	"id": "550e8400-e29b-41d4-a716-446655440000",
	"device_id": "device-001",
	"mark_name": "标记名称",
	"mqtt_topic": ["topic1", "topic2"],
	"persist_mqtt": true,
	"danger_zone_m": 10.5,
	"mark_type": {
		"id": 1,
		"type_name": "类型名称",
		"default_danger_zone_m": 5.0
	},
	"tags": [
		{
			"id": 1,
			"tag_name": "标签名称"
		}
	],
	"created_at": "2025-01-01T12:00:00Z",
	"updated_at": "2025-01-01T12:00:00Z",
	"last_online_at": "2025-01-01T15:30:00Z"
}
```

### MarkType (标记类型)

```json
{
	"id": 1,
	"type_name": "类型名称",
	"default_danger_zone_m": 5.0
}
```

### MarkTag (标签)

```json
{
	"id": 1,
	"tag_name": "标签名称"
}
```

### 分页响应结构

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "items": [...],
    "total": 100,
    "page": 1,
    "limit": 10
  }
}
```

---

## 错误响应

所有错误响应都遵循统一的格式：

```json
{
	"code": 400,
	"msg": "错误信息描述",
	"data": null
}
```

### 常见状态码

- `200` - 成功
- `201` - 创建成功
- `400` - 请求参数错误
- `404` - 资源不存在
- `409` - 资源冲突（如唯一性约束）
- `500` - 服务器内部错误

### 错误示例

**参数解析错误 (400)**

```json
{
	"code": 400,
	"msg": "参数解析失败",
	"data": null
}
```

**资源不存在 (404)**

```json
{
	"code": 404,
	"msg": "标记不存在",
	"data": null
}
```

**资源冲突 (409)**

```json
{
	"code": 409,
	"msg": "设备ID已存在",
	"data": null
}
```

---

## 注意事项

1. **UUID 格式**: 所有标记 ID 使用 UUID v4 格式（如：`550e8400-e29b-41d4-a716-446655440000`）
2. **分页限制**: 每页最大返回 100 条记录
3. **时间格式**: 所有时间字段使用 ISO 8601 格式（如：`2025-01-01T12:00:00Z`）
4. **距离单位**: 所有距离相关字段单位为米（m）
5. **布尔值**: 查询参数中的布尔值使用字符串 "true" 或 "false"
6. **预加载**: 使用 `preload=true` 参数可以在查询标记时一次性加载关联的类型和标签信息
7. **唯一性约束**:
   - `device_id` 在 Mark 表中全局唯一
   - `type_name` 在 MarkType 表中全局唯一
   - `tag_name` 在 MarkTag 表中全局唯一

---

## 开发信息

- **框架**: Fiber v2
- **数据库**: PostgreSQL (使用 GORM)
- **JSON 库**: goccy/go-json
- **路由特性**:
  - 严格路由 (StrictRouting)
  - 大小写敏感 (CaseSensitive)
  - 自定义错误处理

---

_文档生成时间: 2025-10-14_
