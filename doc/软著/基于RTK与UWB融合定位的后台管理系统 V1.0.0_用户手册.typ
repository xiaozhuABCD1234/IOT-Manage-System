// ---------- 可调参数 ----------
#let soft-name = "基于RTK与UWB融合定位的后台管理系统"
#let soft-ver = "V1.0.0"
#let doc-type = "用户手册"

#set heading(numbering: "1.1.1") //设置标题格式

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()

#codly(languages: codly-languages,zebra-fill: none)

// ---------- 页眉函数 ----------
#let soft-header() = context {
  set text(size: 10.5pt, font: ("SimSun", "Songti SC", "serif"))
  smallcaps(soft-name) + h(1fr) + str(counter(page).at(here()).first())
  v(2pt, weak: true)
  line(length: 100%, stroke: 0.25pt)
}

// ---------- 封面 ----------
#let cover() = {
  align(center)[
    #text(size: 20pt, weight: "bold", soft-name + " " + soft-ver) \
    #v(3em)
    // 关键：把下面这句包进 place 里，让它在页面垂直居中
    #place(center + horizon, text(size: 20pt, doc-type))
  ]
  pagebreak()
}

// ---------- 全局设置 ----------
#set page(
  margin: (top: 2.8cm, bottom: 2.5cm, x: 2cm),
  header: soft-header(),
  numbering: none, // 已在页眉自定义
)
#set par(justify: true)     // 两端对齐
#cover()                // 先排封面


// ---------- 正文 ----------
// #counter(page).update(0)     // 封面不占页码，正文从 1 开始

#outline(title: "目录")
#pagebreak()
#counter(page).update(1)
#set page(
  margin: (top: 2.8cm, bottom: 2.5cm, x: 2cm),
  header: soft-header(),
  numbering: none, // 已在页眉自定义
)

#set text(lang: "zh", region: "cn")
#set figure(numbering: "1")

= 软件简介
== 开发背景

随着物联网技术的快速发展，各类智能设备在工业、安防、物流等领域的应用日益广泛。传统单一定位技术已无法满足复杂场景下的高精度定位需求，特别是在室内外混合环境中，需要结合多种定位技术实现无缝覆盖。RTK（实时动态定位）技术提供室外厘米级GPS定位精度，而UWB（超宽带）技术则在室内环境下实现厘米级精确定位。本系统通过融合RTK与UWB两种定位技术，构建了一个功能完善的物联网设备管理平台，满足用户对设备位置实时监控、安全预警和数据分析的全方位需求。

== 软件介绍

本系统是一个基于Go语言开发的微服务架构后台管理系统，专门用于管理RTK与UWB融合定位系
统。系统采用分布式架构设计，通过多个独立的服务模块协同工作，实现对定位设备、电子标记、地
图数据、围栏区域、告警机制等的统一管理。

系统采用前后端分离架构，后端基于Go语言开发，包含API网关、用户服务、标记服务、地图服务、MQTT监控、警报服务等六个微服务

== 面向用户

本系统主要面向以下三类用户群体：

+ 设备管理人员
  - 负责设备信息的录入、分类和标签管理
  - 监控设备在线状态和位置信息
  - 配置设备安全距离和电子围栏规则

+ 安防监控人员
  - 实时查看设备位置和移动轨迹
  - 接收和处理系统发出的安全警报
  - 分析设备行为模式和异常情况

+ 系统管理员
  - 管理用户账户和权限分配
  - 配置系统参数和服务设置
  - 监控系统运行状态和性能指标

== 主要功能

系统提供以下核心功能模块：

+ 地图与定位功能
  - 多地图支持：高德地图（RTK定位）、自定义平面图、UWB坐标系
  - 基站管理：可视化基站分布和坐标配置
  - 实时定位显示：设备位置实时刷新、轨迹绘制

+ 设备管理功能
  - 设备标记管理：设备信息CRUD操作、分类标签管理
  - 在线状态监控：最后在线时间追踪、设备上线/下线通知
  - MQTT通信配置：自定义订阅主题、持久化消息配置

+ 安全预警功能
  - 电子围栏：多边形围栏创建、实时围栏检查、进出警报
  - 距离监控：设备间实时距离计算、安全距离配置、距离超限警报
  - 智能限流：防止警报风暴、状态缓存机制

+ 用户与权限功能
  - 三级权限体系：Root（超级管理员）、Admin（管理员）、User（普通用户）
  - JWT认证：Token过期自动刷新、7天登录有效期
  - 用户管理：用户信息管理、密码修改、用户列表查询

+ 数据存储与分析功能
  - 双数据库存储：PostgreSQL存储结构化数据、MongoDB存储时序数据
  - 历史轨迹查询：设备位置历史记录、轨迹回放功能
  - 统计分析：设备在线时长统计、警报事件分析

== 优势创新

- 微服务架构：采用Go语言开发的微服务架构，具有高并发、高可用性
- RTK与UWB融合：结合两种定位技术的优势，实现室内外无缝定位
- 实时告警机制：基于距离和区域的实时告警，保障安全运营
- 灵活的围栏管理：支持多边形围栏定义，满足复杂场景需求
- 统一API管理：通过API网关统一管理各服务接口

= 运行环境
== 硬件环境
- 服务器：至少4核CPU，8GB内存，100GB硬盘空间
- 网络：稳定的局域网或互联网连接
- 定位设备：支持RTK和UWB的定位基站和标签设备
- 存储设备：用于存储定位数据和地图文件
== 软件环境
- 操作系统：Linux、Windows或macOS
- 数据库：PostgreSQL（用于持久化数据存储）
- 消息队列：MQTT Broker（如Mosquitto，用于设备通信）
- 缓存数据库：MongoDB（用于存储实时位置数据）
- 运行时：Go 1.24+（各服务模块运行环境）
- 容器化：Docker（可选，用于部署）

= 技术栈
== 软件技术
- 后端语言：Go语言（Golang 1.24+）
- Web框架：Gin框架（API网关）、Fiber框架（其他服务）
- 数据库驱动：GORM（ORM框架）
- 消息协议：MQTT（设备通信协议）
- 认证机制：JWT（JSON Web Token）
- 序列化：JSON（数据交换格式）
- 验证库：Validator（数据验证）
== 架构设计
系统采用微服务架构，包含以下核心服务：
+ API 网关服务（api-gateway）：
  - 端口：8000
  - 功能：统一API入口、JWT认证、请求路由
  - 技术：Gin框架、JWT认证中间件
+ 用户服务（user-service）：
  - 端口：8001
  - 功能：用户管理、认证授权、权限控制
  - 技术：Gin框架、GORM、PostgreSQL
+ 地图服务（map-service）：
  - 端口：8002
  - 功能：地图管理、基站管理、围栏管理
  - 技术：Fiber框架、GORM、PostgreSQL、PostGIS
+ MQTT服务（mqtt-watch）：
  - 端口：8003
  - 功能：MQTT消息处理、位置数据接收、历史位置存储
  - 技术：Fiber框架、Eclipse Paho MQTT、MongoDB
+ 标记服务（mark-service）：
  - 端口：8004
  - 功能：设备标记、标签管理、距离管理、设备在线状态更新
  - 技术：Fiber框架、GORM、PostgreSQL
+ 告警服务（warning-service）：
  - 端口：后台服务（无特定端口）
  - 功能：距离告警、区域告警、安全距离检查、智能限流
  - 技术：MQTT、GORM、内存缓存

#figure(image("assets/image-10.png"), caption: [总体架构设计])

#figure(image("assets/image-11.png"), caption: [数据流图])


== 数据模型

系统采用PostgreSQL数据库存储持久化数据，主要数据表结构如下：

#figure(image("assets/image-12.png"), caption: [数据库实体关系图])


= 软件功能
== 用户认证与管理功能
+ 用户登录认证：通过API网关提供统一的JWT认证服务，支持7天登录有效期和Token自动刷新，如@登录界面 所示
+ 权限控制：基于用户类型（Root、Admin、User）的角色权限管理如@权限管理 所示
+ 用户信息管理：支持用户信息的增删改查操作@权限管理
+ 多级权限管理：Root（超级管理员）、Admin（管理员）、User（普通用户）
#grid(
  columns: (1fr, 1fr),
  gutter: 2em,

  [
    #figure(
      image("assets/7a03ad4f50bc580707c076a7a9fcab44.png", height: 10cm),
      caption: [登录界面],
    ) <登录界面>
  ],

  [
    #figure(
      image("assets/image-13.png", height: 10cm),
      caption: [用户管理],
    ) <权限管理>
  ],
)

== 登录安全
- JWT令牌认证，有效期7天
- 自动令牌刷新机制
- 路由守卫保护未授权访问
- 密码加密传输与存储

== 设备标记管理功能
+ 标记创建：如@录入电子标记 所示支持录入带有设备ID的电子标记，包括标记名称、类型、标签等信息
+ 标签分类：通过标签对设备进行分类管理，支持标签的增删改查，如@修改电子标记 所示
+ 类型定义：通过类型定义设备的属性和行为，支持类型的增删改查，如@新增电子标记类型 所示
+ 距离管理：管理设备间的安全距离和告警距离，支持全局/类型/设备对三级距离配置
+ 设备在线状态：实时更新设备最后在线时间，监控设备在线状态如@标记列表
#grid(
  columns: (1fr, 1fr),
  gutter: 2em,

  [
    #figure(
      image("assets/764f88444e406165df014ca03e3d83c2.png", height: 8cm),
      caption: [录入电子标记],
    ) <录入电子标记>
  ],

  [
    #figure(
      image("assets/1533a0022c72c24351c0eda6bf4b2884.png", height: 8cm),
      caption: [修改电子标记],
    ) <修改电子标记>
  ],

  [
    #figure(
      image("assets/506882daeaa4a7945dda3be2a96903cb.png", height: 8cm),
      caption: [新增电子标记类型],
    ) <新增电子标记类型>
  ],
  [
    #figure(
      image("assets/af29357c5374bccf53ad2026ee96c9b4.png", height: 8cm),
      caption: [标记列表],
    ) <标记列表>
  ],
)
== 地图与基站管理功能
+ 自定义地图：支持上传和管理自定义地图图片（PNG/JPG/GIF/WEBP格式）
+ 基站配置：管理定位基站的位置和状态，支持基站的增删改查
+ 围栏设置：创建和管理多边形围栏区域，基于PostGIS实现空间查询
+ 室内外区分：支持室内和室外围栏的分类管理，支持高德地图、自定义地图、UWB平面坐标系
== 位置监控与告警功能
+ 实时位置：通过MQTT接收设备实时位置数据，支持UWB和RTK定位数据
+ 距离告警：监控设备间距离，超过安全距离时触发告警
+ 区域告警：监控设备是否进入/离开围栏区域，支持多边形围栏检查
+ 在线状态：监控设备的在线/离线状态
+ 智能限流：防止告警风暴，每秒最多发布2次告警，避免重复告警
== 数据处理与存储功能
+ 位置数据存储：将实时位置数据存储到MongoDB，支持历史轨迹查询
+ 历史数据管理：管理设备的历史位置数据，支持轨迹回放
+ 配置数据持久化：将系统配置、用户信息、设备信息等存储到PostgreSQL
+ 数据备份与恢复：支持关键数据的备份和恢复

= 部署与配置指南
== 系统部署
=== 前置要求
- Docker >= 20.10
- Docker Compose >= 2.0
- Git

=== 一键部署步骤
1. 克隆项目代码：
```bash
git clone https://github.com/your-username/IOT-Manage-System.git
cd IOT-Manage-System
```

2. 配置环境变量（可选）：
创建 `.env` 文件用于前端构建：
```bash
# 高德地图配置（可选）
VITE_AMAP_KEY=your-amap-key
VITE_AMAP_SECURITY_CODE=your-security-code

# MQTT WebSocket地址
VITE_MQTT_URL=ws://localhost:8083
```

3. 启动所有服务：
```bash
docker-compose up -d
```

4. 访问系统：
- 前端界面：http://localhost (或 http://localhost:3000)
- API 网关：http://localhost:8000
- 默认账户：用户名 `admin`，密码 `admin`

=== 服务端口说明
#table(
  align: center,
  columns: (1fr, 1fr, 2fr),
  [服务], [端口], [说明],
  [Frontend], [80, 3000], [Web 界面],
  [API Gateway], [8000], [统一网关],
  [User Service], [8001], [用户服务（内部）],
  [Map Service], [8002], [地图服务],
  [MQTT Watch], [8003], [MQTT 监控（内部）],
  [Mark Service], [8004], [标记服务（内部）],
  [PostgreSQL], [5433], [数据库],
  [MongoDB], [27018], [NoSQL 数据库],
  [Mosquitto MQTT], [1883], [MQTT TCP],
  [Mosquitto WebSocket], [8083], [MQTT WebSocket],
)

== 环境配置
=== 数据库配置
PostgreSQL配置：
```yaml
POSTGRES_DB: iot_manager_db
POSTGRES_USER: postgres
POSTGRES_PASSWORD: password
TZ: Asia/Shanghai
```

MongoDB配置：
```yaml
MONGO_INITDB_ROOT_USERNAME: admin
MONGO_INITDB_ROOT_PASSWORD: admin
```

=== MQTT配置
Mosquitto MQTT配置：
- 配置文件：`config/mosquitto.conf`
- 密码文件：`config/mosquitto.passwd`
- 默认用户：`admin` / `admin`

=== 微服务通用配置
```yaml
# 数据库连接
DB_HOST: postgres
DB_PORT: 5432
DB_NAME: iot_manager_db
DB_USER: postgres
DB_PASSWORD: password

# JWT密钥
JWT_SECRET: your-secret-key

# 时区
TZ: Asia/Shanghai
```

=== 特殊配置
Map Service配置：
```yaml
DB_MAX_OPEN_CONNS: 10
DB_MAX_IDLE_CONNS: 20
DB_MAX_LIFETIME: 1h
```

MQTT Watch配置：
```yaml
MQTT_BROKER: ws://mosquitto:8083
MQTT_USERNAME: admin
MQTT_PASSWORD: admin
MONGO_HOST: mongo
MONGO_PORT: 27017
```

Warning Service配置：
```yaml
MAP_SERVICE_HOST: map-service
MAP_SERVICE_PORT: 8002
```

Frontend配置：
```yaml
VITE_AMAP_KEY: ${VITE_AMAP_KEY}
VITE_AMAP_SECURITY_CODE: ${VITE_AMAP_SECURITY_CODE}
VITE_MQTT_URL: ${VITE_MQTT_URL}
```

= API接口文档
== 统一响应格式
成功响应：
```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

错误响应：
```json
{
  "code": 400,
  "message": "参数错误",
  "details": "具体错误信息"
}
```

== 主要API接口

=== 用户服务接口

`POST /api/v1/users/register` - 用户注册

`POST /api/v1/users/login` - 用户登录

`GET /api/v1/users/profile` - 获取当前用户信息

`PUT /api/v1/users/profile` - 更新用户信息

`GET /api/v1/users` - 获取用户列表（管理员）

`DELETE /api/v1/users/:id` - 删除用户（管理员）

=== 标记服务接口

- 标记管理：

  `POST /api/v1/marks` - 创建标记

  `GET /api/v1/marks` - 获取标记列表（分页）

  `GET /api/v1/marks/:id` - 获取单个标记

  `PUT /api/v1/marks/:id` - 更新标记

  `DELETE /api/v1/marks/:id` - 删除标记

  `GET /api/v1/marks/device/:device_id` - 根据设备ID获取

- 标签管理：

  `POST /api/v1/tags` - 创建标签

  `GET /api/v1/tags` - 获取标签列表

  `GET /api/v1/tags/:tag_id` - 获取标签详情

  `PUT /api/v1/tags/:tag_id` - 更新标签

  `DELETE /api/v1/tags/:tag_id` - 删除标签

- 类型管理：

  `POST /api/v1/types` - 创建类型

  `GET /api/v1/types` - 获取类型列表

  `GET /api/v1/types/:type_id` - 获取类型详情

  `PUT /api/v1/types/:type_id` - 更新类型

  `DELETE /api/v1/types/:type_id` - 删除类型

- 距离配置：

  `POST /api/v1/pairs/distance` - 设置设备对距离

  `POST /api/v1/pairs/combinations` - 批量设置距离

  `POST /api/v1/pairs/cartesian` - 笛卡尔积设置

  `GET /api/v1/pairs/distance/:m1/:m2` - 查询距离

  `DELETE /api/v1/pairs/distance/:m1/:m2` - 删除距离配置

=== 地图服务接口

- 基站管理：

  `POST /api/v1/station` - 创建基站

  `GET /api/v1/station` - 获取基站列表

  `GET /api/v1/station/:id` - 获取基站详情

  `PUT /api/v1/station/:id` - 更新基站

  `DELETE /api/v1/station/:id` - 删除基站

- 地图管理：

  `POST /api/v1/custom-map` - 创建地图

  `GET /api/v1/custom-map` - 获取地图列表

  `GET /api/v1/custom-map/latest` - 获取最新地图

  `GET /api/v1/custom-map/:id` - 获取地图详情

  `PUT /api/v1/custom-map/:id` - 更新地图

  `DELETE /api/v1/custom-map/:id` - 删除地图

- 围栏管理：

  `POST /api/v1/polygon-fence` - 创建围栏

  `GET /api/v1/polygon-fence` - 获取围栏列表

  `GET /api/v1/polygon-fence/:id` - 获取围栏详情

  `PUT /api/v1/polygon-fence/:id` - 更新围栏

  `DELETE /api/v1/polygon-fence/:id` - 删除围栏

  `POST /api/v1/polygon-fence/:id/check` - 检查点是否在围栏内

  `POST /api/v1/polygon-fence/check-all` - 检查点在哪些围栏内

=== 常用API调用示例
用户登录示例：
```bash
curl -X POST http://localhost:8000/api/v1/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin"
  }'
```

创建设备标记示例：
```bash
curl -X POST http://localhost:8000/api/v1/marks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "device_id": "device-001",
    "mark_name": "移动设备1",
    "mark_type_id": 1
  }'
```

创建电子围栏示例：
```bash
curl -X POST http://localhost:8000/api/v1/polygon-fence \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "fence_name": "安全区域",
    "points": [
      {"x": 0, "y": 0},
      {"x": 100, "y": 0},
      {"x": 100, "y": 50},
      {"x": 0, "y": 50}
    ],
    "description": "核心安全区域"
  }'
```

发布设备位置（MQTT）示例：
```bash
# 使用mosquitto_pub工具
mosquitto_pub -h localhost -p 1883 \
  -u admin -P admin \
  -t "location/device-001" \
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

= 故障排查与维护
== 常见问题及解决方案
=== 服务无法启动
检查步骤：
```bash
# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs service-name

# 检查端口占用
netstat -ano | findstr :8000
```

=== 数据库连接失败
解决方案：
- 确认 PostgreSQL 健康检查通过
- 检查数据库连接配置
- 查看数据库日志：
```bash
docker-compose logs postgres
```

=== MQTT 连接失败
检查项目：
- Mosquitto 是否正常运行
- 用户名密码是否正确
- 防火墙/端口是否开放
- 测试MQTT连接：
```bash
mosquitto_pub -h localhost -p 1883 -u admin -P admin -t "test" -m "hello"
```

=== 前端无法访问 API
检查项目：
- API Gateway 是否启动
- CORS 配置是否正确
- JWT Token 是否有效

=== 围栏检查不工作
排查方法：
- 检查 PostGIS 扩展是否安装：
```bash
docker exec iot_postgres psql -U postgres -d iot_manager_db -c "SELECT PostGIS_Version();"
```
- 确认 Map Service 可访问
- 查看 Warning Service 日志

== 系统监控
=== 服务健康检查
```bash
# 检查所有服务
docker-compose ps

# 检查服务健康状态
docker inspect --format='{{.State.Health.Status}}' iot_user-service
```

=== 资源使用监控
```bash
# 查看容器资源使用
docker stats

# 查看磁盘使用
docker system df
```

=== 数据库状态监控
```bash
# PostgreSQL连接数
docker exec iot_postgres psql -U postgres -c "SELECT count(*) FROM pg_stat_activity;"

# MongoDB状态
docker exec iot_mongo mongosh --username admin --password admin --eval "db.serverStatus()"
```

== 日志管理
```bash
# 查看所有服务日志
docker-compose logs

# 查看特定服务日志
docker-compose logs -f api-gateway

# 查看最近100行日志
docker-compose logs --tail=100

# 实时跟踪日志
docker-compose logs -f --tail=50
```

== 数据备份与恢复
=== PostgreSQL 备份
```bash
# 导出数据
docker exec iot_postgres pg_dump -U postgres iot_manager_db > backup.sql

# 恢复数据
docker exec -i iot_postgres psql -U postgres iot_manager_db < backup.sql
```

=== MongoDB 备份
```bash
# 导出数据
docker exec iot_mongo mongodump --username admin --password admin --out /backup

# 恢复数据
docker exec iot_mongo mongorestore --username admin --password admin /backup
```

= 安全建议
== 生产环境配置
+ 修改默认密码：
  - PostgreSQL: `POSTGRES_PASSWORD`
  - MongoDB: `MONGO_INITDB_ROOT_PASSWORD`
  - MQTT: `config/mosquitto.passwd`
  - 管理员账户密码

+ 使用强 JWT 密钥：
  ```bash
  JWT_SECRET=$(openssl rand -hex 32)
  ```

+ 启用 HTTPS：
  - 使用 Nginx 反向代理
  - 配置 SSL 证书
  - 强制 HTTPS 重定向

+ 网络隔离：
  - 内部服务不暴露端口
  - 使用 Docker 网络隔离

+ 日志审计：
  - 启用操作日志
  - 定期备份日志
  - 监控异常访问

= 附录

== 术语解释
- *RTK*：实时动态载波相位差分技术，提供厘米级室外定位精度
- *UWB*：超宽带技术，提供分米级室内定位精度
- *电子围栏*：虚拟的地理边界，用于检测设备进出特定区域
- *MQTT*：消息队列遥测传输协议，轻量级的发布/订阅消息传输协议

== 版本历史
#table(
  columns: (auto, auto, 1fr),
  align: center,
  [*版本*], [*日期*], [*更新内容*],
  [V1.0.0], [2025-12-22], [初始版本发布，包含基本定位展示和设备管理功能],
)
