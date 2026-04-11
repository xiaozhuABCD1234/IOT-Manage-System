// ---------- 可调参数 ----------
#let soft-name = "基于RTK与UWB融合定位的后台管理系统"
#let soft-ver = "V1.0.0"
#let doc-type = "用户手册"

#set heading(numbering: "1.1.1") //设置标题格式

#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()

#codly(languages: codly-languages, zebra-fill: none)

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

= 系统概述

== 管理系统简介

管理系统是 IOT 管理系统的配置管理端，面向负责系统配置、设备管理、围栏设置的运维人员和管理员。

本系统是一个基于Go语言开发的微服务架构后台管理系统，专门用于管理RTK与UWB融合定位系统。系统采用分布式架构设计，通过多个独立的服务模块协同工作，实现对定位设备、电子标记、地图数据、围栏区域、告警机制等的统一管理。

系统采用前后端分离架构，后端基于Go语言开发，包含API网关、用户服务、标记服务、地图服务、MQTT监控、警报服务等六个微服务。

== 主要功能

#table(
  columns: (1fr, 2fr),
  [功能], [说明],
  [*用户管理*], [用户登录、密码修改、权限管理],
  [*设备管理*], [设备的增删改查，类型和标签管理],
  [*基站管理*], [UWB 基站配置与管理],
  [*地图设置*], [自定义地图上传、坐标系配置],
  [*电子围栏*], [围栏创建、编辑、删除，警报规则配置],
  [*距离设置*], [设备间安全距离配置],
  [*运维管理*], [服务部署、数据备份、日志查看],
)

== 系统架构

#figure(image("assets/image-10.png"), caption: [总体架构设计])

#figure(image("/assets/image-2.png"), caption: [微服务交互图])

== 服务端口

#table(
  align: center,
  columns: (1fr, 1fr, 2fr),
  [服务], [端口], [说明],
  [前端界面], [80, 3000], [Web 访问入口],
  [API 网关], [8000], [统一 API 入口],
  [用户服务], [8001], [用户认证管理],
  [地图服务], [8002], [地图、围栏管理],
  [MQTT 监控], [8003], [消息订阅处理],
  [标记服务], [8004], [设备标记管理],
  [PostgreSQL], [5432], [主数据库],
  [MongoDB], [27017], [位置历史存储],
  [MQTT Broker], [1883/8083], [消息代理],
)

== 技术架构
=== 软件技术栈
- 后端语言：Go语言（Golang 1.24+）
- Web框架：Gin框架（API网关）、Fiber框架（其他服务）
- 数据库驱动：GORM（ORM框架）
- 消息协议：MQTT（设备通信协议）
- 认证机制：JWT（JSON Web Token）
- 序列化：JSON（数据交换格式）
- 验证库：Validator（数据验证）

=== 微服务架构
系统采用微服务架构，包含以下核心服务：

+ *API 网关服务（api-gateway）*：
  - 端口：8000
  - 功能：统一API入口、JWT认证、请求路由
  - 技术：Gin框架、JWT认证中间件

+ *用户服务（user-service）*：
  - 端口：8001
  - 功能：用户管理、认证授权、权限控制
  - 技术：Gin框架、GORM、PostgreSQL

+ *地图服务（map-service）*：
  - 端口：8002
  - 功能：地图管理、基站管理、围栏管理
  - 技术：Fiber框架、GORM、PostgreSQL、PostGIS

+ *MQTT服务（mqtt-watch）*：
  - 端口：8003
  - 功能：MQTT消息处理、位置数据接收、历史位置存储
  - 技术：Fiber框架、Eclipse Paho MQTT、MongoDB

+ *标记服务（mark-service）*：
  - 端口：8004
  - 功能：设备标记、标签管理、距离管理、设备在线状态更新
  - 技术：Fiber框架、GORM、PostgreSQL

+ *告警服务（warning-service）*：
  - 端口：后台服务（无特定端口）
  - 功能：距离告警、区域告警、安全距离检查、智能限流
  - 技术：MQTT、GORM、内存缓存

#figure(image("assets/image-10.png"), caption: [总体架构设计])

#figure(image("assets/image-11.png"), caption: [数据流图])

=== 数据模型
系统采用PostgreSQL数据库存储持久化数据，主要数据表结构如下：

#figure(image("assets/image-12.png"), caption: [数据库实体关系图])

= 用户认证

== 登录

1. 访问系统登录页面
2. 输入用户名和密码
3. 点击"登录"按钮
4. 登录成功后显示系统主界面

*页面截图：*
#figure(image("assets/登录界面.png"), caption: [管理系统登录页面])

== 默认账户

#table(
  columns: (1fr, 1fr, 1fr, 2fr),
  [角色], [用户名], [密码], [权限],
  [管理员], [admin], [admin], [全部功能],
)

== 退出登录

1. 点击页面右上角用户名
2. 选择"退出登录"选项
3. 系统清除登录状态，跳转到登录页面

== 修改密码

1. 点击顶部导航栏用户名
2. 进入"个人信息"页面
3. 点击"修改密码"
4. 输入当前密码和新密码
5. 确认修改

*页面截图：*
#figure(image("assets/用户密码修改界面.png"), caption: [个人信息页面])

== 用户权限

#table(
  columns: (1fr, 2fr),
  [角色], [权限说明],
  [root], [超级管理员，拥有所有权限，可管理系统用户],
  [admin], [管理员，可管理设备、地图、围栏等业务数据],
  [user], [普通用户，只能查看展示界面],
)

= 设备管理

设备（标记）是系统中管理的物联网终端设备，可以是定位标签、传感器等。

== 设备列表

*访问路径：* 电子标记 → 标记管理

*显示信息：*

#table(
  columns: (1fr, 2fr),
  [字段], [说明],
  [设备 ID], [设备唯一标识],
  [设备名称], [显示名称],
  [设备类型], [设备分类],
  [标签], [设备标签],
  [在线状态], [在线/离线],
  [最后在线时间], [最近一次收到数据的时间],
  [操作], [编辑/删除],
)

*页面截图：*
#figure(image("assets/设备标记管理.png"), caption: [设备列表页面])

== 添加设备

1. 进入设备管理页面
2. 点击"添加设备"按钮
3. 填写设备信息：

#table(
  columns: (1fr, 2fr, 1fr),
  [字段], [说明], [必填],
  [设备 ID], [设备唯一标识], [是],
  [设备名称], [显示名称], [是],
  [设备类型], [设备分类], [是],
  [标签], [设备标签（可多选）], [否],
  [MQTT 持久化], [是否持久化消息到 MongoDB], [否],
)

4. 点击"保存"

*页面截图：*
#figure(image("assets/创建标记.png", height: 9cm), caption: [新建标记界面])

== 编辑设备

1. 在设备列表中找到要编辑的设备
2. 点击"编辑"按钮
3. 修改设备信息
4. 点击"保存"

== 删除设备

1. 在设备列表中找到要删除的设备
2. 点击"删除"按钮
3. 确认删除操作

== 设备类型管理

设备类型用于对设备进行分类管理。

*访问路径：* 电子标记 → 标记管理 → 类型管理

*操作：*
- 查看类型列表
- 添加新类型（类型名称）
- 编辑类型名称
- 删除类型

*页面截图：*
#figure(image("assets/创建设备的类型.png"), caption: [设备类型管理页面])

== 设备标签管理

标签用于对设备进行多维度标记。

*访问路径：* 电子标记 → 标记管理 → 标签管理

*操作：*
- 查看标签列表
- 添加新标签（标签名称）
- 编辑标签
- 删除标签

*页面截图：*
#figure(image("assets/按标签筛选的设备列表.png"), caption: [设备标签管理页面])

= 基站管理

基站是 UWB 定位系统的参考点设备，用于确定移动设备的精确位置。

== 基站列表

*访问路径：* 地图 → UWB 基站管理

*显示信息：*

#table(
  columns: (1fr, 2fr),
  [字段], [说明],
  [基站 ID], [基站唯一标识],
  [基站名称], [显示名称],
  [基站类型], [基站分类],
  [X 坐标], [水平位置],
  [Y 坐标], [垂直位置],
  [操作], [编辑/删除],
)

*页面截图：*
#figure(image("assets/UWB基站配置界面.png"), caption: [基站管理页面])

== 添加基站

1. 进入基站管理页面
2. 点击"添加基站"按钮
3. 填写基站信息：
  - 基站名称
  - 基站类型
  - X 坐标
  - Y 坐标
4. 点击"保存"

== 编辑基站

1. 在基站列表中找到要编辑的基站
2. 点击"编辑"按钮
3. 修改基站信息
4. 点击"保存"

== 删除基站

1. 在基站列表中找到要删除的基站
2. 点击"删除"按钮
3. 确认删除操作

== 基站布局建议

- 基站应均匀分布在定位区域内
- 建议在区域角落和边缘布置
- 避免基站之间距离过近或过远
- 室外 RTK 定位不需要基站

= 地图设置

地图设置用于配置 UWB 室内定位使用的自定义地图（平面图）。

== 地图列表

*访问路径：* 地图 → 地图设置

*显示信息：*

#table(
  columns: (1fr, 2fr),
  [字段], [说明],
  [地图 ID], [唯一标识],
  [地图名称], [显示名称],
  [地图类型], [地图分类],
  [图片], [缩略图],
  [操作], [编辑/删除],
)

#pagebreak()
*页面截图：*
#figure(image("/assets/image-1.png"), caption: [地图设置页面])

== 创建地图

1. 进入地图设置页面
2. 点击"创建地图"按钮
3. 填写地图信息：

#table(
  columns: (1fr, 2fr),
  [字段], [说明],
  [地图名称], [显示名称],
  [地图类型], [地图分类],
  [地图图片], [上传平面图（支持 PNG/JPG/GIF/WEBP）],
  [左上角坐标], [地图左上角在坐标系中的位置],
  [右下角坐标], [地图右下角在坐标系中的位置],
  [比例尺], [1 像素对应的实际距离],
)

4. 上传地图图片
5. 配置坐标系统
6. 点击"保存"

== 编辑地图

1. 在地图列表中找到要编辑的地图
2. 点击"编辑"按钮
3. 修改地图信息或图片
4. 点击"保存"

== 删除地图

1. 在地图列表中找到要删除的地图
2. 点击"删除"按钮
3. 确认删除操作

== 坐标系说明

UWB 定位使用平面直角坐标系：
#image("assets/test.png")

- X 坐标：从左到右增加
- Y 坐标：从下到上增加
- 单位：与实际距离单位一致（如厘米）

= 电子围栏

电子围栏是在地图上划定的虚拟安全区域，当设备进入或离开围栏时触发警报。

== 围栏类型

#table(
  columns: (1fr, 2fr),
  [类型], [说明],
  [室内围栏], [室内定位系统使用的围栏，配合 UWB 定位],
  [室外围栏], [室外定位系统使用的围栏，配合 RTK 定位],
)

== 围栏列表

*访问路径：* 地图 → 地图设置 → 电子围栏

*显示信息：*

#table(
  columns: (1fr, 2fr),
  [字段], [说明],
  [围栏 ID], [唯一标识],
  [围栏名称], [显示名称],
  [围栏类型], [室内/室外],
  [描述], [说明信息],
  [操作], [编辑/删除],
)

== 创建围栏

1. 进入围栏管理页面
2. 点击"创建围栏"按钮
3. 填写围栏信息：

#table(
  columns: (1fr, 2fr),
  [字段], [说明],
  [围栏名称], [围栏标识名称],
  [围栏类型], [室内或室外],
  [描述], [围栏说明],
)

4. 在地图上绘制围栏边界
5. 点击"保存"
#image("/assets/image.png")

== 绘制围栏

1. 选择地图上的点作为围栏顶点
2. 依次点击形成围栏边界
3. 点击完成绘制
4. 系统自动计算围栏范围


*页面截图：*
#figure(image("assets/电子围栏创建界面.png"), caption: [绘制围栏])


== 编辑围栏

1. 在围栏列表中找到要编辑的围栏
2. 点击"编辑"按钮
3. 修改围栏信息或边界顶点
4. 点击"保存"

== 删除围栏

1. 在围栏列表中找到要删除的围栏
2. 点击"删除"按钮
3. 确认删除操作

== 围栏警报规则

#table(
  columns: (1fr, 2fr),
  [警报类型], [触发条件],
  [进入警报], [设备进入围栏区域时触发],
  [离开警报], [设备离开围栏区域时触发],
  [持续警报], [设备持续在围栏内（可配置）],
)

= 距离设置

距离设置用于配置设备间的安全距离，当设备间距离小于安全距离时触发警报。

== 距离设置页面

*访问路径：* 电子标记 → 距离设置

== 设备对距离配置

为两个特定设备设置安全距离。

*操作步骤：*
1. 选择第一个设备
2. 选择第二个设备
3. 输入安全距离值（单位：米）
4. 点击"保存"

*页面截图：*
#figure(image("assets/批量距离设置界面.png"), caption: [距离设置页面])

== 笛卡尔积配置

为同一类型的设备批量设置安全距离。

*操作步骤：*
1. 选择设备类型
2. 输入默认安全距离
3. 系统自动为该类型下所有设备对设置距离

== 批量组合配置

手动选择多个设备，批量设置它们之间的安全距离。

*操作步骤：*
1. 选择要配置的设备列表
2. 输入安全距离值
3. 确认配置

== 距离配置优先级

#table(
  columns: (1fr, 1fr, 2fr),
  [优先级], [类型], [说明],
  [1], [设备对距离], [针对特定两个设备的自定义距离],
  [2], [类型默认距离], [同一类型设备的默认安全距离],
  [-1], [跳过检查], [设置为 -1 表示不检查该设备对],
)








= 运维指南

== 运行环境
=== 硬件环境
- 服务器：至少4核CPU，8GB内存，100GB硬盘空间
- 网络：稳定的局域网或互联网连接
- 定位设备：支持RTK和UWB的定位基站和标签设备
- 存储设备：用于存储定位数据和地图文件

=== 软件环境
- 操作系统：Linux、Windows或macOS
- 数据库：PostgreSQL（用于持久化数据存储）
- 消息队列：MQTT Broker（如Mosquitto，用于设备通信）
- 缓存数据库：MongoDB（用于存储实时位置数据）
- 运行时：Go 1.24+（各服务模块运行环境）
- 容器化：Docker（可选，用于部署）

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

= API 参考
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

= 故障排查
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
