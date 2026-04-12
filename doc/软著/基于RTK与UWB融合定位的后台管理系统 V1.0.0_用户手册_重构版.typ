// ============================================================
// 基于RTK与UWB融合定位的后台管理系统 V1.0.0
// 用户手册（重构版）
// ============================================================

// ---------- 可调参数 ----------
#let soft-name = "基于RTK与UWB融合定位的后台管理系统"
#let soft-ver = "V1.0.0"
#let doc-type = "用户手册"

#set heading(numbering: "1.1.1")

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
    #place(center + horizon, text(size: 20pt, doc-type))
  ]
  pagebreak()
}

// ---------- 全局设置 ----------
#set page(
  margin: (top: 2.8cm, bottom: 2.5cm, x: 2cm),
  header: soft-header(),
  numbering: none,
)
#set par(justify: true)
#cover()

// ---------- 正文 ----------
#outline(title: "目录")
#pagebreak()
#counter(page).update(1)
#set page(
  margin: (top: 2.8cm, bottom: 2.5cm, x: 2cm),
  header: soft-header(),
  numbering: none,
)

#set text(lang: "zh", region: "cn")
#set figure(numbering: "1")

// ============================================================
// 第一部分：详细操作手册
// ============================================================

= 第一部分：详细操作手册

// ============================================================
// 第1章 登录与系统访问
// ============================================================
= 登录与系统访问

== 访问系统登录页

本章节详细介绍用户如何访问后台管理系统的登录页面，包含完整的操作流程。

+ 打开浏览器

  在您的计算机上打开常用的Web浏览器。

  #table(
    columns: (1fr, 2fr),
    [浏览器], [推荐版本],
    [Google Chrome], [最新版本],
    [Microsoft Edge], [最新版本],
    [Firefox], [最新版本],
    [Safari], [最新版本],
  )

+ 输入系统地址

  *地址格式：*
  - 如果通过 Nginx 访问：`http://服务器IP/`
  - 如果直接访问前端：`http://服务器IP:3000/`
  - 默认管理员访问地址：`http://localhost:80/`

+ 进入登录页面

  #figure(image("assets/登录界面.png", width: 80%), caption: [系统登录界面])

  *页面元素说明：*

  #table(
    columns: (1fr, 2fr, 1fr),
    [元素名称], [说明], [位置],
    [用户名输入框], [用于输入用户名], [页面左侧/中部],
    [密码输入框], [用于输入密码], [用户名下方],
    [登录按钮], [提交登录信息], [密码输入框下方],
  )

+ 输入用户名

  *输入内容：*
  #table(
    columns: (1fr, 2fr),
    [字段], [输入值],
    [用户名], [admin],
  )

+ 输入密码

  *输入内容：*
  #table(
    columns: (1fr, 2fr),
    [字段], [输入值],
    [密码], [admin（显示为\*\*\*\*）],
  )

+ 点击登录按钮

  *预期结果：*
  - 按钮文字变为"登录中..."
  - 等待时间约1-3秒

+ 进入主界面

  #figure(image("assets/主页.png", width: 80%), caption: [步骤6：登录成功进入主界面，标注各功能区])

  *主界面布局说明：*

  #table(
    columns: (1fr, 2fr),
    [功能区域], [说明],
    [顶部导航栏], [显示系统名称、当前用户、退出按钮],
    [左侧菜单], [系统功能导航菜单],
    [内容区域], [显示当前功能模块的内容],
    [状态栏], [显示当前时间、在线设备数],
  )

== 默认账户说明

#table(
  columns: (1fr, 1fr, 1fr, 2fr),
  [角色], [用户名], [密码], [权限说明],
  [管理员], [admin], [admin], [拥有全部功能权限，可管理系统用户、设备、地图、围栏等],
  [普通用户], [user], [user], [仅可查看数据，无法进行修改操作],
)

== 退出登录

1. 点击页面右上角的用户名区域
2. 在下拉菜单中选择"退出登录"选项
3. 系统确认退出，清除登录状态
4. 页面跳转回登录页面

== 修改密码

1. 点击顶部导航栏的用户名
2. 选择"个人信息"选项
3. 点击"修改密码"按钮
4. 输入当前密码和新密码
5. 确认新密码
6. 点击"保存"按钮

#figure(image("assets/用户密码修改界面.png", width: 80%), caption: [个人信息页面 - 修改密码])

*密码修改规则：*
#table(
  columns: (1fr, 2fr),
  [规则], [说明],
  [最小长度], [6个字符],
  [最大长度], [64个字符],
  [字符类型], [不限（建议包含字母和数字）],
  [不能与当前密码相同], [是],
)

== 用户权限说明

#table(
  columns: (1fr, 2fr),
  [角色], [权限说明],
  [root], [超级管理员，拥有所有权限，可管理系统用户、分配角色],
  [admin], [管理员，可管理设备、地图、围栏、标签、类型等业务数据],
  [user], [普通用户，只能查看系统数据，无法进行任何修改操作],
)

// ============================================================
// 第2章 主界面导航详解
// ============================================================
= 主界面导航详解

== 主界面布局概述

*界面分区说明：*

#table(
  columns: (1fr, 2fr),
  [区域], [功能说明],
  [A - 顶部导航栏], [系统名称、当前用户信息、快捷操作入口],
  [B - 左侧菜单], [功能模块导航，支持折叠展开],
  [C - 内容区域], [当前功能模块的详细内容和操作界面],
  [D - 状态栏], [显示系统运行状态、在线设备数、时间信息],
)

== 顶部导航栏功能

#table(
  columns: (1fr, 2fr, 1fr),
  [元素], [功能], [位置],
  [系统Logo/名称], [显示系统标识，点击返回首页], [左侧],
  [当前用户名], [显示已登录用户，点击打开用户菜单], [右侧],
  [用户菜单按钮], [包含个人信息、修改密码、退出登录], [用户名右侧],
)

== 左侧菜单树说明

*菜单结构：*

#table(
  columns: (1fr, 2fr),
  [一级菜单], [二级菜单],
  [电子标记], [标记管理、类型管理、标签管理],
  [地图], [UWB基站管理、地图设置],
  [电子围栏], [围栏管理],
  [距离设置], [设备距离配置],
  [系统监控], [设备状态、告警管理],
)

// ============================================================
// 第3章 设备管理完整操作流程
// ============================================================
= 设备管理完整操作流程

== 设备管理概述

设备（标记）是系统中管理的物联网终端设备。设备管理功能位于"电子标记 → 标记管理"菜单下。

#figure(image("assets/设备标记管理.png", width: 80%), caption: [进入设备管理页面])

== 设备列表说明

*访问路径：* 电子标记 → 标记管理

*显示信息：*

#table(
  columns: (1fr, 2fr, 1fr),
  [字段], [说明], [示例值],
  [设备ID], [设备的唯一标识符], [device-001],
  [设备名称], [显示名称，可自定义], [移动设备1],
  [设备类型], [设备所属分类], [吊车],
  [标签], [设备的多维度标记], [重要, 高风险],
  [在线状态], [当前是否在线], [在线/离线],
  [最后在线时间], [最近一次通信时间], [2026-04-12 10:30:00],
  [操作], [编辑、删除等操作], [编辑 / 删除],
)

== 创建设备（7步详细操作）

+ 进入设备管理页面

  1. 点击左侧菜单"电子标记"
  2. 点击展开的子菜单"标记管理"
  3. 系统加载并显示设备列表页面

+ 打开创建设备对话框

  1. 在设备列表页面右上角找到"新建标记"按钮
  2. 点击该按钮
  3. 系统弹出创建设备对话框

  #figure(image("assets/创建设备的类型.png", width: 80%), caption: [步骤2：新增标记类型对话框])

+ 选择或输入设备ID

  *输入规则：*
  #table(
    columns: (1fr, 2fr, 1fr),
    [字段], [规则], [必填],
    [设备ID], [最大255字符，支持字母、数字、连字符], [是],
  )

+ 输入设备名称

  #table(
    columns: (1fr, 2fr, 1fr),
    [字段], [规则], [必填],
    [设备名称], [最大255字符], [是],
  )

+ 选择设备类型

  *可选类型：*
  #table(
    columns: (1fr, 2fr),
    [类型名称], [说明],
    [默认], [默认类型，适合一般设备],
    [吊车], [适用于起重设备，默认危险半径20米],
  )

+ 设置危险半径（可选）

  #table(
    columns: (1fr, 2fr, 1fr),
    [字段], [规则], [必填],
    [危险半径], [数值，单位米，留空则使用类型默认值], [否],
  )

+ 添加标签（可选）

+ 保存设备

  *表单字段验证规则汇总：*

  #table(
    columns: (1fr, 2fr, 1fr, 2fr),
    [字段名], [类型], [必填], [验证规则与错误提示],
    [设备ID], [text], [是], [不能为空；最大255字符；唯一性检查],
    [设备名称], [text], [是], [不能为空；最大255字符],
    [设备类型], [select], [是], [默认选中第一项],
    [危险半径], [number], [否], [必须为非负数值],
    [标签], [tags-input], [否], [无限制],
  )

== 编辑设备（4步操作）

+ 定位要编辑的设备

  在设备列表中找到需要编辑的设备，可以通过搜索、筛选加速定位。

+ 打开编辑对话框

  #figure(image("assets/修改标记.png", width: 80%), caption: [步骤2：修改标记对话框])

+ 修改设备信息

  *可修改字段：*
  #table(
    columns: (1fr, 2fr),
    [字段], [说明],
    [设备名称], [可修改],
    [设备类型], [可修改],
    [危险半径], [可修改],
    [标签], [可添加/删除],
  )

+ 保存修改

== 删除设备（3步操作）

+ 选择要删除的设备

  在设备列表中找到需要删除的设备，确认设备信息，避免误删。

+ 点击删除按钮

  *确认对话框内容：*
  #table(
    columns: (1fr, 2fr),
    [内容], [说明],
    [标题], ["确认删除"],
    [消息], ["确定要删除该设备吗？此操作不可撤销。"],
    [按钮], ["取消"、"确定删除"],
  )

+ 确认删除

  点击"确定删除"按钮，系统执行删除操作。

== 设备类型管理

*访问路径：* 电子标记 → 标记管理 → 类型管理

*功能说明：*
#table(
  columns: (1fr, 2fr),
  [功能], [说明],
  [查看类型列表], [显示所有已创建的类型],
  [创建类型], [添加新的设备类型],
  [编辑类型], [修改类型名称和默认危险半径],
  [删除类型], [删除未使用的类型],
)

== 设备标签管理

*访问路径：* 电子标记 → 标记管理 → 标签管理

#figure(image("assets/按标签筛选的设备列表.png", width: 80%), caption: [设备标签管理页面])

// ============================================================
// 第4章 基站管理操作
// ============================================================
= 基站管理操作

== 基站管理概述

基站是UWB定位系统的参考点设备。基站管理功能位于"地图 → UWB基站管理"菜单下。

== 基站列表说明

*访问路径：* 地图 → UWB基站管理

*显示信息：*

#table(
  columns: (1fr, 2fr, 1fr),
  [字段], [说明], [示例值],
  [基站名称], [基站的显示名称], [基站A],
  [坐标X], [在地图坐标系中的X坐标], [100.5],
  [坐标Y], [在地图坐标系中的Y坐标], [200.3],
  [创建时间], [基站注册时间], [2026-04-10 09:00:00],
  [操作], [编辑、删除操作], [编辑 / 删除],
)

== 创建基站（4步操作）

+ 进入基站管理页面

  #figure(image("assets/UWB基站配置界面.png", width: 80%), caption: [步骤1：基站管理页面 - 新建基站对话框])

+ 打开创建基站对话框

+ 填写基站信息

  *表单字段：*
  #table(
    columns: (1fr, 2fr, 1fr, 2fr),
    [字段], [类型], [必填], [说明],
    [基站名称], [text], [是], [最大255字符],
    [坐标X], [number], [是], [地图坐标系X值],
    [坐标Y], [number], [是], [地图坐标系Y值],
  )

+ 保存基站

== 编辑基站

1. 在基站列表中找到要编辑的基站
2. 点击该基站行的"编辑"按钮
3. 在弹出的对话框中修改信息
4. 点击"保存"按钮提交

== 删除基站

1. 在基站列表中找到要删除的基站
2. 点击"删除"按钮
3. 在确认对话框中点击"确定删除"

// ============================================================
// 第5章 地图设置操作
// ============================================================
= 地图设置操作

== 地图设置概述

地图设置功能用于管理自定义地图图片和坐标系配置。地图管理功能位于"地图 → 地图设置"菜单下。

== 地图列表说明

*访问路径：* 地图 → 地图设置

*显示信息：*

#table(
  columns: (1fr, 2fr, 1fr),
  [字段], [说明], [示例值],
  [地图名称], [地图的显示名称], [工厂一楼平面图],
  [坐标系范围], [X和Y的最小/最大值], [X: 0-500, Y: 0-300],
  [中心点], [地图中心坐标], [250, 150],
  [比例尺], [地图比例], [1:100],
  [描述], [地图用途说明], [生产车间A区],
)

== 创建地图（6步操作）

+ 进入地图设置页面

  #figure(image("assets/室内UWB地图.png", width: 80%), caption: [室内UWB地图 - 电子围栏绘制界面])

+ 打开创建地图对话框

+ 输入地图名称

  #table(
    columns: (1fr, 2fr, 1fr),
    [字段], [规则], [必填],
    [地图名称], [最大255字符], [是],
  )

+ 上传地图图片（可选）

  *图片要求：*
  #table(
    columns: (1fr, 2fr),
    [参数], [要求],
    [格式], [JPG、JPEG、PNG、GIF、WebP],
    [大小], [最大10MB],
  )

+ 设置坐标系

  *坐标系说明：*
  #table(
    columns: (1fr, 2fr, 1fr),
    [参数], [说明], [示例值],
    [X最小值], [地图左下角的X坐标], [0],
    [X最大值], [地图右上角的X坐标], [500],
    [Y最小值], [地图左下角的Y坐标], [0],
    [Y最大值], [地图右上角的Y坐标], [300],
    [中心X], [地图中心点的X坐标], [250],
    [中心Y], [地图中心点的Y坐标], [150],
  )

+ 保存地图

  #figure(image("assets/室外RTK地图.png", width: 80%), caption: [室外RTK地图 - 显示围栏"施工"])

== 坐标系说明

#table(
  columns: (1fr, 2fr, 2fr),
  [参数], [含义], [计算公式],
  [scale_ratio], [比例尺], [1:scale_ratio],
  [center_x], [地图中心X坐标], [(x_max + x_min) / 2],
  [center_y], [地图中心Y坐标], [(y_max + y_min) / 2],
)

== 编辑地图

1. 在地图列表中找到要编辑的地图
2. 点击该地图行的"编辑"按钮
3. 在弹出的对话框中修改信息
4. 点击"更新"按钮提交

== 删除地图

1. 在地图列表中找到要删除的地图
2. 点击"删除"按钮
3. 在确认对话框中点击"确定删除"

// ============================================================
// 第6章 电子围栏管理操作
// ============================================================
= 电子围栏管理操作

== 电子围栏概述

电子围栏是系统提供的安全区域管理功能。围栏管理功能位于"电子围栏 → 围栏管理"菜单下。

*围栏类型：*
#table(
  columns: (1fr, 2fr, 1fr),
  [类型], [说明], [应用场景],
  [室内围栏], [is_indoor = true，用于室内定位], [工厂车间、仓库内部],
  [室外围栏], [is_indoor = false，用于室外定位], [园区、码头、露天场地],
)

== 围栏列表说明

*访问路径：* 电子围栏 → 围栏管理

*显示信息：*
#table(
  columns: (1fr, 2fr, 1fr),
  [字段], [说明], [示例值],
  [围栏名称], [围栏的显示名称], [危险区域A],
  [类型], [室内/室外], [室内],
  [顶点数量], [围栏多边形的顶点数], [5],
  [状态], [启用/禁用], [启用中],
  [描述], [围栏用途说明], [化学物品存放区],
)

== 创建电子围栏（6步操作）

+ 进入围栏管理页面

  #figure(image("assets/电子围栏创建界面.png", width: 80%), caption: [步骤1：进入围栏管理页面])

+ 打开创建围栏对话框

+ 选择围栏类型

  #figure(image("assets/围栏属性设置界面.png", width: 80%), caption: [步骤3：围栏属性设置（新增室外围栏）])

  *选择说明：*
  #table(
    columns: (1fr, 2fr),
    [类型], [使用场景],
    [室内], [适用于室内UWB定位系统],
    [室外], [适用于室外RTK定位系统],
  )

+ 输入围栏名称和描述

  #table(
    columns: (1fr, 2fr, 1fr),
    [字段], [规则], [必填],
    [围栏名称], [最大255字符，唯一], [是],
    [描述], [最大1000字符], [否],
  )

+ 绘制围栏边界

  *绘制操作说明：*
  #table(
    columns: (1fr, 2fr),
    [操作], [说明],
    [点击地图], [添加一个顶点],
    [双击], [完成绘制（闭合多边形）],
    [右键点击顶点], [删除该顶点],
    [拖拽顶点], [移动顶点位置],
  )

  *绘制规则：*
  #table(
    columns: (1fr, 2fr),
    [规则], [说明],
    [最少顶点数], [3个（三角形）],
    [最多顶点数], [10000个],
    [重复顶点], [不允许连续重复点],
  )

+ 保存围栏

== 围栏绘制操作细节

=== 顶点编辑

#table(
  columns: (1fr, 2fr),
  [操作], [说明],
  [添加顶点], [在边上点击可插入新顶点],
  [删除顶点], [右键点击顶点删除],
  [移动顶点], [拖拽顶点到新位置],
  [撤销], [Ctrl+Z 撤销上一次操作],
)

=== 围栏闭合验证

#table(
  columns: (1fr, 2fr),
  [状态], [说明],
  [已闭合], [首尾顶点连接，形成封闭多边形],
  [未闭合], [需要添加更多顶点或手动闭合],
)

== 编辑围栏

1. 在围栏列表中找到要编辑的围栏
2. 点击该围栏行的"编辑"按钮
3. 系统打开编辑对话框，显示围栏多边形
4. 修改围栏信息或调整顶点
5. 点击"更新"按钮提交

== 删除围栏

1. 在围栏列表中找到要删除的围栏
2. 点击"删除"按钮
3. 在确认对话框中点击"确定删除"

== 围栏警报规则

#table(
  columns: (1fr, 2fr),
  [规则], [说明],
  [进入检测], [设备从围栏外进入围栏内时触发告警],
  [离开检测], [设备从围栏内离开时触发告警解除],
  [持续报警], [设备持续在围栏内时，告警保持激活状态],
  [限流控制], [每设备每秒最多1次告警推送],
)

// ============================================================
// 第7章 距离设置操作
// ============================================================
= 距离设置操作

== 距离设置概述

距离设置用于配置设备之间的安全距离阈值。距离设置功能位于"距离设置"菜单下。

*配置模式：*
#table(
  columns: (1fr, 2fr),
  [模式], [说明],
  [点对点距离], [设置两个特定设备间的距离],
  [组合距离], [为一组设备设置统一距离],
  [笛卡尔积距离], [为两组设备集合设置距离矩阵],
)

== 点对点距离设置

=== 操作步骤

+ 进入距离设置页面

  #figure(image("assets/批量距离设置界面.png", width: 80%), caption: [步骤1：进入距离设置页面])

+ 选择第一个设备

  在"设备1"下拉选择框中选择第一个设备。

+ 选择第二个设备

  在"设备2"下拉选择框中选择第二个设备。

+ 输入安全距离

  #table(
    columns: (1fr, 2fr, 1fr),
    [字段], [规则], [必填],
    [距离], [非负数值，单位米], [是],
  )

+ 保存配置

== 批量组合设置

+ 进入组合设置模式

+ 选择设备组合

  在左侧设备列表中勾选多个设备。

+ 设置统一距离

  输入统一的距离值，点击"批量设置"按钮。

== 笛卡尔积设置

+ 进入笛卡尔积模式

+ 选择第一组设备

  在左侧选择第一个设备集合，支持按类型或标签筛选选择。

+ 选择第二组设备

  在右侧选择第二个设备集合。

+ 设置距离

  输入距离值，点击"设置距离"按钮。

== 距离配置优先级

当同一设备对存在多个距离配置时，按以下优先级生效：

#table(
  columns: (1fr, 2fr, 1fr),
  [优先级], [配置类型], [说明],
  [最高], [点对点距离], [直接设置的两设备间距离],
  [中等], [组合距离], [批量设置的设备组内配对],
  [最低], [笛卡尔积距离], [两组设备间的距离矩阵],
)

// ============================================================
// 第8章 系统监控与运维
// ============================================================
= 系统监控与运维

== Docker部署操作

=== 环境要求

#table(
  columns: (1fr, 2fr),
  [组件], [版本要求],
  [Docker], [20.10+],
  [Docker Compose], [2.0+],
  [内存], [最小4GB，推荐8GB+],
  [CPU], [最小2核，推荐4核+],
)

=== 启动所有服务

```bash
cd /path/to/IOT-Manage-System
docker-compose up -d
docker-compose ps
```

=== 停止所有服务

```bash
docker-compose down
docker-compose down -v
```

=== 重启单个服务

```bash
docker-compose restart api-gateway
docker-compose logs -f api-gateway
```

=== 服务端口映射

#table(
  columns: (1fr, 1fr, 2fr),
  [服务], [端口], [说明],
  [frontend], [80, 3000], [Web访问入口],
  [api-gateway], [8000], [API统一入口],
  [user-service], [8001], [用户服务],
  [map-service], [8002], [地图服务],
  [mqtt-watch], [8003], [MQTT监控],
  [mark-service], [8004], [标记服务],
  [PostgreSQL], [5432], [主数据库],
  [MongoDB], [27017], [位置历史存储],
  [Mosquitto], [1883, 8083], [MQTT代理],
)

== 日志查看

=== 查看所有服务日志

```bash
docker-compose logs -f
docker-compose logs --tail 100
```

=== 查看特定服务日志

```bash
docker-compose logs api-gateway
docker-compose logs -f api-gateway
```

=== 日志级别说明

#table(
  columns: (1fr, 2fr, 1fr),
  [级别], [含义], [颜色标识],
  [DEBUG], [调试信息，详细执行流程], [灰色],
  [INFO], [一般信息，正常运行状态], [白色],
  [WARN], [警告信息，潜在问题], [黄色],
  [ERROR], [错误信息，功能异常], [红色],
)

== 数据库备份

=== PostgreSQL备份

```bash
docker-compose exec postgres pg_dump -U postgres iot_db > backup_$(date +%Y%m%d_%H%M%S).sql
```

=== MongoDB备份

```bash
docker-compose exec mongodb mongodump --archive=backup_$(date +%Y%m%d) --gzip
```

=== 数据恢复

```bash
docker-compose exec -T postgres psql -U postgres iot_db < backup_file.sql
```

== 服务重启流程

=== 常规重启

1. 停止服务：`docker-compose stop <service-name>`
2. 重新启动：`docker-compose start <service-name>`
3. 检查状态：`docker-compose ps <service-name>`

=== 重启后验证

#table(
  columns: (1fr, 2fr),
  [检查项], [验证方法],
  [服务状态], [docker-compose ps 显示"Up"状态],
  [端口响应], [curl http://localhost:8000/health],
  [日志检查], [docker-compose logs 无ERROR],
)

// ============================================================
// 第二部分：详细设计说明
// ============================================================

= 第二部分：详细设计说明

// ============================================================
// 第9章 软件总体设计
// ============================================================
= 软件总体设计

== 系统架构概述

本系统采用前后端分离的微服务架构设计，后端由6个独立的Go语言微服务组成。

*架构特点：*
#table(
  columns: (1fr, 2fr),
  [特点], [说明],
  [微服务架构], [各服务独立部署，降低耦合度],
  [前后端分离], [前端Vue3，后端Go，通过REST API通信],
  [统一入口], [API网关处理认证和路由],
  [数据分离], [PostgreSQL存储业务数据，MongoDB存储时序数据],
)

== 功能模块结构图

#image("/assets/未命名绘图.png")

== 微服务交互图

#image("/assets/image-16.png")

== 技术选型说明

=== 后端技术栈

#table(
  columns: (1fr, 2fr, 1fr),
  [技术], [用途], [版本],
  [Go语言], [后端开发语言], [1.24+],
  [Gin框架], [API网关HTTP框架], [最新],
  [Fiber框架], [微服务HTTP框架], [最新],
  [GORM], [PostgreSQL ORM], [最新],
  [Eclipse Paho MQTT], [MQTT客户端库], [最新],
  [PostGIS], [空间数据库扩展], [3.x],
)

=== 前端技术栈

#table(
  columns: (1fr, 2fr, 1fr),
  [技术], [用途], [版本],
  [Vue3], [前端框架], [3.x],
  [TypeScript], [类型系统], [5.x],
  [Vite], [构建工具], [5.x],
  [Pinia], [状态管理], [2.x],
  [Vue Router], [路由管理], [4.x],
  [ECharts], [图表展示], [5.x],
)

// ============================================================
// 第10章 模块与函数详细说明
// ============================================================
= 模块与函数详细说明

== API网关模块（api-gateway）

*源码位置：* `api-gateway/`

*核心功能：*
#table(
  columns: (1fr, 2fr),
  [功能], [说明],
  [路由分发], [将请求转发到对应的微服务],
  [JWT认证], [验证访问令牌的有效性],
  [用户信息注入], [将解析出的用户信息注入到请求头],
)

*核心函数：*
#table(
  columns: (1fr, 2fr, 2fr, 1fr, 1fr),
  [模块名称], [功能描述], [核心函数], [输入参数], [输出结果],
  [AuthMiddleware], [JWT认证中间件], [AuthMiddleware(c \#gin.Context)], [Context], [401/继续处理],
  [CORSMiddleware], [跨域处理中间件], [CORSMiddleware(c \#gin.Context)], [Context], [设置响应头],
  [ProxyHandler], [请求代理], [ProxyHandler(c \#gin.Context)], [Context], [代理到目标服务],
)

== 用户服务模块（user-service）

*源码位置：* `user-service/`

*核心功能：*
#table(
  columns: (1fr, 2fr),
  [功能], [说明],
  [用户登录], [验证用户名密码，生成JWT令牌],
  [Token刷新], [刷新过期的访问令牌],
  [用户CRUD], [创建、查询、更新、删除用户],
  [权限管理], [用户类型（root/admin/user）权限控制],
)

*核心函数：*
#table(
  columns: (1fr, 2fr, 2fr, 1fr, 1fr),
  [模块名称], [功能描述], [核心函数], [输入参数], [输出结果],
  [AuthHandler], [登录认证], [Login(c \#gin.Context)], [username, password], [access_token, refresh_token],
  [AuthHandler], [Token刷新], [Refresh(c \#gin.Context)], [refresh_token], [access_token],
  [UserHandler], [创建用户], [CreateUser(c \#gin.Context)], [UserRequest], [UserResponse, error],
  [UserHandler], [获取用户列表], [ListUsers(c \#gin.Context)], [page, limit], [[]UserResponse, Pagination],
  [UserHandler], [获取单个用户], [GetUser(c \#gin.Context)], [id], [UserResponse, error],
  [UserHandler], [更新用户], [UpdateUser(c \#gin.Context)], [id, UserRequest], [UserResponse, error],
  [UserHandler], [删除用户], [DeleteUser(c \#gin.Context)], [id], [error],
)

*API端点：*
#table(
  columns: (1fr, 1fr, 2fr, 1fr),
  [方法], [路径], [功能], [认证],
  [POST], [/api/v1/users/token], [用户登录], [否],
  [POST], [/api/v1/users/refresh], [刷新Token], [否],
  [GET], [/api/v1/users/me], [获取当前用户], [是],
  [POST], [/api/v1/users], [创建用户], [是],
  [GET], [/api/v1/users], [获取用户列表], [是],
  [GET], [/api/v1/users/:id], [获取单个用户], [是],
  [PUT], [/api/v1/users/:id], [更新用户], [是],
  [DELETE], [/api/v1/users/:id], [删除用户], [是],
)

== 地图服务模块（map-service）

*源码位置：* `map-service/`

*核心功能：*
#table(
  columns: (1fr, 2fr),
  [功能], [说明],
  [基站管理], [CRUD操作基站设备],
  [地图管理], [CRUD操作自制地图],
  [围栏管理], [CRUD操作多边形围栏],
  [空间查询], [PostGIS ST_Contains 点是否在多边形内],
)

*核心函数：*
#table(
  columns: (1fr, 2fr, 1fr, 1fr),
  [模块名称], [核心函数], [输入参数], [输出结果],
  [创建基站], [CreateStation(c fiber.Ctx)], [StationRequest], [StationResponse, error],
  [获取基站列表], [ListStations(c fiber.Ctx)], [-], [[]StationResponse, error],
  [更新基站], [UpdateStation(c fiber.Ctx)], [id, StationRequest], [error],
  [删除基站], [DeleteStation(c fiber.Ctx)], [id], [error],
  [创建围栏], [CreatePolygonFence(c fiber.Ctx)], [FenceRequest], [error],
  [获取围栏列表], [ListPolygonFences(c fiber.Ctx)], [activeOnly], [[]FenceResponse, error],
  [点是否在围栏内], [CheckPointInFence(c fiber.Ctx)], [fenceID, x, y], [bool, error],
  [检查所有围栏], [CheckPointInAllFences(c fiber.Ctx)], [x, y], [FenceCheckResp, error],
  [空间包含查询], [IsPointInFence(fenceID, x, y)], [uuid, float64, float64], [bool, error],
  [查询点所在围栏], [FindFencesByPoint(x, y)], [float64, float64], [[]Fence, error],
)

// ============================================================
// 第11章 核心算法与流程图
// ============================================================
= 核心算法与流程图

== 电子围栏检测算法（PostGIS ST_Contains）

=== 算法原理

电子围栏检测使用PostGIS的空间包含函数 `ST_Contains` 实现。

*算法步骤：*
```
设备发送位置坐标 (x, y)
系统构造点几何：ST_Point(x, y)
系统查询所有激活的围栏多边形
对每个围栏执行 ST_Contains(geometry, ST_Point(x, y))
如果返回 true，表示点在围栏内
触发相应的进入/离开事件
```

=== 源码实现

#raw(
  lang: "go",
  "
// 文件：map-service/repo/polygon_fence_repo.go
// 位置：第174-183行

// IsPointInFence 检查点是否在指定围栏内
func (r *PolygonFenceRepo) IsPointInFence(fenceID uuid.UUID, x, y float64) (bool, error) {
    var isInside bool
    err := r.db.Raw(`
        SELECT ST_Contains(geometry, ST_Point(?, ?))
        FROM polygon_fences
        WHERE id = ? AND is_active = true
    `, x, y, fenceID).Scan(&isInside).Error
    return isInside, err
}
",
)

=== 围栏状态机

#image("/assets/er-第 1 页.drawio.png")

== 距离计算算法

=== UWB距离计算（欧几里得距离）

*计算公式：*


$d = sqrt((x_2 - x_1)^2 + (y_2 - y_1)^2)$


#raw(
  lang: "go",
  "
// 文件：warning-service/utils/calculate.go
// 位置：第29-35行

// CalculateUWB 计算两个 UWB 坐标之间的距离
func CalculateUWB(l1, l2 model.UWBLoc) float64 {
    dx := (l1.X - l2.X) / 100.0
    dy := (l1.Y - l2.Y) / 100.0
    distance := math.Sqrt(dx*dx + dy*dy)
    return distance
}
",
)

=== RTK距离计算（Haversine公式）

*计算公式：*


$d = 2 R arctan(sqrt(a), sqrt(1-a))$



其中：


$a = sin^2((Delta "lat")/2) + cos("lat"_1) dot cos("lat"_2) dot sin^2((Delta "lon")/2)$


#table(
  columns: (1fr, 2fr),
  [符号], [含义],
  [$R$], [地球平均半径 = 6371393 米],
  [$Delta "lat"$], [$"lat"_2 - "lat"_1$，纬度差（弧度）],
  [$Delta "lon"$], [$"lon"_2 - "lon"_1$，经度差（弧度）],
  [$"lat"_1, "lat"_2$], [两个点的纬度（弧度）],
  [$d$], [两点间的大圆距离（米）],
)

#raw(
  lang: "go",
  "
// 文件：warning-service/utils/calculate.go
// 位置：第10-27行

const earthRadius float64 = 6371393

func toRadians(degree float64) float64 {
    return degree * math.Pi / 180.0
}

// CalculateRTK 使用 Haversine 算法计算两个 RTK 坐标之间的距离
func CalculateRTK(l1, l2 model.RTKLoc) float64 {
    dLat := toRadians(l1.Lat - l2.Lat)
    dLon := toRadians(l1.Lon - l2.Lon)

    a := math.Sin(dLat/2)*math.Sin(dLat/2) +
        math.Cos(toRadians(l1.Lat))*math.Cos(toRadians(l2.Lat))*
            math.Sin(dLon/2)*math.Sin(dLon/2)

    c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))

    return earthRadius * c
}
",
)

== 警报限流算法（滑动窗口）

=== 算法原理

告警限流采用滑动窗口算法，控制每个设备每秒发送告警的次数。

#table(
  columns: (1fr, 2fr),
  [特点], [说明],
  [时间窗口], [滑动窗口大小为1000毫秒（1秒）],
  [最大速率], [每个设备每窗口最多1次告警],
  [独立计数], [每个设备独立计数，互不影响],
  [自动清理], [后台协程定期清理过期记录],
)

=== 源码实现

#raw(
  lang: "go",
  "
// 文件：warning-service/service/warning_gate.go
// 位置：第15-68行

type WarningRateLimiter struct {
    records map[string][]time.Time // deviceID -> 最近发送时间列表
    mu      sync.RWMutex
    maxRate int           // 每秒最大发送次数
    window  time.Duration // 时间窗口
}

func init() {
    rateLimiter = &WarningRateLimiter{
        records: make(map[string][]time.Time),
        maxRate: 1,
        window:  1000 * time.Millisecond,
    }
    go rateLimiter.cleanupLoop()
}

func (r *WarningRateLimiter) Allow(deviceID string, on bool) bool {
    r.mu.Lock()
    defer r.mu.Unlock()
    now := time.Now()
    key := deviceID + \":\" + strconv.FormatBool(on)
    times, exists := r.records[key]
    if !exists {
        r.records[key] = []time.Time{now}
        return true
    }
    validTimes := make([]time.Time, 0, len(times))
    for _, t := range times {
        if now.Sub(t) < r.window {
            validTimes = append(validTimes, t)
        }
    }
    if len(validTimes) >= r.maxRate {
        return false
    }
    validTimes = append(validTimes, now)
    r.records[key] = validTimes
    return true
}
",
)

=== 持续报警模式

#table(
  columns: (1fr, 2fr, 2fr),
  [状态], [行为], [说明],
  [首次进入], [发送 payload=\"1\"], [告警开始],
  [持续在围栏内], [每秒发送 payload=\"1\"], [保持告警激活],
  [离开围栏], [发送 payload=\"0\"], [告警解除],
  [持续在围栏外], [不发送任何消息], [无操作],
)

// ============================================================
// 第12章 接口详细设计
// ============================================================
= 接口详细设计

== 统一响应格式

*成功响应：*
```json
{
  "success": true,
  "data": { ... },
  "message": "操作成功",
  "error": null,
  "pagination": {
    "currentPage": 1,
    "totalPages": 10,
    "totalItems": 100,
    "itemsPerPage": 10
  },
  "timestamp": "2026-04-12T10:00:00Z"
}
```

*错误响应：*
```json
{
  "success": false,
  "message": "错误描述",
  "error": {
    "code": "ERROR_CODE",
    "details": "详细错误信息"
  }
}
```

== API Gateway路由配置

#table(
  columns: (1fr, 1fr, 2fr, 1fr),
  [代理路径], [目标服务], [目标地址], [认证],
  [/api/v1/users/\*proxyPath], [user-service], [user-service:8001], [部分需要],
  [/api/v1/marks/\*proxyPath], [mark-service], [mark-service:8004], [是],
  [/api/v1/station/\*proxyPath], [map-service], [map-service:8002], [是],
  [/api/v1/polygon-fence/\*proxyPath], [map-service], [map-service:8002], [是],
  [/api/v1/custom-map/\*proxyPath], [map-service], [map-service:8002], [是],
  [/api/v1/mqtt/\*proxyPath], [mqtt-service], [mqtt-service:8003], [是],
)

== user-service接口详情

=== 用户登录

*接口：* `POST /api/v1/users/token`

*请求参数：*
#table(
  columns: (1fr, 1fr, 1fr, 2fr, 2fr),
  [字段名], [类型], [必填], [约束], [示例值],
  [username], [string], [是], [3-32字符], ["admin"],
  [password], [string], [是], [6-64字符], ["admin"],
)

*响应参数：*
#table(
  columns: (1fr, 2fr),
  [字段名], [说明],
  [access_token], [JWT访问令牌],
  [refresh_token], [刷新令牌],
)

*curl示例：*
```bash
curl -X POST http://localhost:8000/api/v1/users/token \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin"}'
```

=== 创建设备标记

*接口：* `POST /api/v1/marks`

*请求参数：*
#table(
  columns: (1fr, 1fr, 1fr, 2fr, 2fr),
  [字段名], [类型], [必填], [约束], [示例值],
  [device_id], [string], [是], [最大255字符，唯一], ["device-001"],
  [mark_name], [string], [是], [最大255字符], ["移动设备1"],
  [mark_type_id], [int], [否], [默认1], ["1"],
  [danger_zone_m], [float], [否], [非负数], ["15.5"],
  [tags], [[]string], [否], [标签名称数组], [["重要","高风险"]],
)

*curl示例：*
```bash
curl -X POST http://localhost:8000/api/v1/marks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"device_id": "device-001", "mark_name": "移动设备1", "mark_type_id": 1}'
```

=== 创建电子围栏

*接口：* `POST /api/v1/polygon-fence`

*请求参数：*
#table(
  columns: (1fr, 1fr, 1fr, 2fr, 2fr),
  [字段名], [类型], [必填], [约束], [示例值],
  [fence_name], [string], [是], [最大255字符，唯一], ["危险区域A"],
  [is_indoor], [bool], [是], [true=室内，false=室外], ["true"],
  [points], [array], [是], [至少3个点], [[{"x":0,"y":0},...]],
  [description], [string], [否], [最大1000字符], ["化学物品存放区"],
)

*curl示例：*
```bash
curl -X POST http://localhost:8000/api/v1/polygon-fence \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"fence_name": "危险区域A", "is_indoor": true, "points": [{"x": 0, "y": 0}, {"x": 100, "y": 0}, {"x": 100, "y": 50}, {"x": 0, "y": 50}]}'
```

== 错误码定义

#table(
  columns: (1fr, 1fr, 2fr),
  [错误码], [HTTP状态], [说明],
  [400], [400], [请求参数错误或缺少必填参数],
  [401], [401], [未认证或Token无效],
  [403], [403], [无权限访问该资源],
  [404], [404], [请求的资源不存在],
  [409], [409], [资源冲突（如用户名/围栏名称已存在）],
  [500], [500], [服务器内部错误],
  [503], [503], [第三方服务不可用（如MQTT Broker）],
)

// ============================================================
// 第13章 运行设计
// ============================================================
= 运行设计

== 并发处理

=== MQTT消息并发接收

mqtt-watch服务采用goroutine处理并发MQTT消息。

*并发模型：*
#table(
  columns: (1fr, 2fr),
  [组件], [说明],
  [MQTT Client], [单实例，维护长连接],
  [Message Handler], [每条消息启动一个goroutine处理],
  [Channel], [消息队列，缓冲处理],
)

=== 数据库连接池

```go
sqlDB, _ := db.DB()
sqlDB.SetMaxIdleConns(10)
sqlDB.SetMaxOpenConns(100)
sqlDB.SetConnMaxLifetime(time.Hour)
```

== 缓存策略

=== 围栏状态缓存

warning-service使用内存缓存存储设备围栏状态：

```go
type FenceChecker struct {
    statusCache map[string]bool // deviceID -> 是否在围栏内
    mu          sync.RWMutex
}
```

=== 缓存更新机制

距离缓存通过定时轮询更新：

```go
type DistancePoller struct {
    r    *repo.MarkRepo
    sd   *repo.SafeDist
    dz   *repo.DangerZone
    tick *time.Ticker
}
// 每秒轮询更新缓存
```

== 定时任务

=== 距离轮询任务

*执行频率：* 每秒1次

*功能：*
#table(
  columns: (1fr, 2fr),
  [功能], [说明],
  [获取在线设备], [从MongoDB获取当前在线的设备列表],
  [查询距离配置], [批量查询设备间的安全距离设置],
  [更新缓存], [更新内存中的距离缓存数据],
)

=== 告警限流清理任务

*执行频率：* 每5秒1次

*功能：*
#table(
  columns: (1fr, 2fr),
  [功能], [说明],
  [清理过期记录], [删除超过1秒窗口的记录],
  [释放内存], [清理零记录条目避免内存泄漏],
)

// ============================================================
// 第14章 数据库设计
// ============================================================
= 数据库设计

== 数据库概览

#table(
  columns: (1fr, 2fr, 1fr, 2fr),
  [数据库], [类型], [端口], [用途],
  [PostgreSQL], [关系型], [5432], [存储业务数据、空间数据],
  [MongoDB], [文档型], [27017], [存储时序位置数据],
)

== 实体关系图

#image("/assets/er-ER.drawio.png")

== PostgreSQL表结构详解

=== 用户表（users）

#table(
  columns: (1fr, 1fr, 1fr, 2fr),
  [字段名], [类型], [约束], [说明],
  [id], [UUID], [PK, DEFAULT gen_random_uuid()], [用户唯一标识],
  [username], [VARCHAR(255)], [NOT NULL, UNIQUE], [用户名],
  [pwd_hash], [VARCHAR(255)], [NOT NULL], [密码哈希值],
  [user_type], [user_type_enum], [NOT NULL, DEFAULT 'user'], [用户类型：admin/user/root],
  [created_at], [TIMESTAMPTZ], [NOT NULL, DEFAULT now()], [创建时间],
  [updated_at], [TIMESTAMPTZ], [NOT NULL, DEFAULT now()], [更新时间],
)

=== 标记类型表（mark_types）

#table(
  columns: (1fr, 1fr, 1fr, 2fr),
  [字段名], [类型], [约束], [说明],
  [id], [SERIAL], [PK], [类型ID，自增],
  [type_name], [VARCHAR(255)], [NOT NULL, UNIQUE], [类型名称],
  [default_safe_distance_m], [DOUBLE PRECISION], [NOT NULL, DEFAULT -1], [默认安全距离（米）],
)

=== 标记主表（marks）

#table(
  columns: (1fr, 1fr, 1fr, 2fr),
  [字段名], [类型], [约束], [说明],
  [id], [UUID], [PK, DEFAULT gen_random_uuid()], [标记UUID],
  [device_id], [VARCHAR(255)], [NOT NULL, UNIQUE], [设备唯一标识],
  [mark_name], [VARCHAR(255)], [NOT NULL], [显示名称],
  [mqtt_topic], [TEXT[]], [NOT NULL, DEFAULT '{}'], [MQTT主题数组],
  [persist_mqtt], [BOOLEAN], [NOT NULL, DEFAULT false], [是否持久化MQTT消息],
  [safe_distance_m], [DOUBLE PRECISION], [NOT NULL, DEFAULT -1], [安全距离（米）],
  [mark_type_id], [INTEGER], [NOT NULL, DEFAULT 1, FK], [关联类型ID],
  [created_at], [TIMESTAMPTZ], [NOT NULL, DEFAULT now()], [创建时间],
  [updated_at], [TIMESTAMPTZ], [NOT NULL, DEFAULT now()], [更新时间],
  [last_online_at], [TIMESTAMPTZ], [NULL], [最后在线时间],
)

=== 多边形围栏表（polygon_fences）- PostGIS空间表

#table(
  columns: (1fr, 1fr, 1fr, 2fr),
  [字段名], [类型], [约束], [说明],
  [id], [UUID], [PK, DEFAULT gen_random_uuid()], [围栏UUID],
  [is_indoor], [BOOLEAN], [NOT NULL, DEFAULT true], [是否室内围栏],
  [fence_name], [VARCHAR(255)], [NOT NULL, UNIQUE], [围栏名称],
  [geometry], [GEOMETRY(POLYGON, 0)], [NOT NULL], [PostGIS多边形几何],
  [description], [TEXT], [NULL], [围栏描述],
  [is_active], [BOOLEAN], [DEFAULT true], [是否启用],
  [created_at], [TIMESTAMP], [NOT NULL, DEFAULT CURRENT_TIMESTAMP], [创建时间],
  [updated_at], [TIMESTAMP], [NOT NULL, DEFAULT CURRENT_TIMESTAMP], [更新时间],
)

*PostGIS空间索引：*
```sql
CREATE INDEX idx_polygon_fences_geometry ON polygon_fences USING GIST (geometry);
```

== MongoDB集合说明

=== 设备位置集合（device_loc）

#table(
  columns: (1fr, 1fr, 2fr),
  [字段名], [类型], [说明],
  [id字段], [ObjectID], [文档ID自动生成],
  [device_id], [string], [设备标识],
  [indoor], [bool], [是否室内定位模式],
  [latitude], [float64], [纬度可选],
  [longitude], [float64], [经度可选],
  [uwb_x], [float64], [UWB局部X坐标厘米],
  [uwb_y], [float64], [UWB局部Y坐标厘米],
  [speed], [float64], [移动速度],
  [record_time], [time.Time], [记录时间],
  [created_at], [time.Time], [创建时间],
)

== PostGIS空间查询

=== 常用空间函数

#table(
  columns: (1fr, 1fr, 2fr),
  [函数], [返回值], [说明],
  [ST_GeomFromText(wkt)], [GEOMETRY], [从WKT文本创建几何],
  [ST_Point(x, y)], [GEOMETRY], [创建点几何],
  [ST_Contains(polygon, point)], [BOOLEAN], [判断多边形是否包含点],
  [ST_AsText(geometry)], [TEXT], [将几何转换为WKT文本],
)

=== WKT格式说明

*点（POINT）：*
```
POINT(100 200)
```

*多边形（POLYGON）：*
```
POLYGON((0 0, 100 0, 100 50, 0 50, 0 0))
```

// ============================================================
// 第15章 术语表
// ============================================================
= 术语表

== 定位技术相关术语

#table(
  columns: (1fr, 1fr, 3fr),
  [术语], [全称/解释], [详细说明],
  [RTK],
  [Real-Time Kinematic],
  [实时动态载波相位差分技术，一种高精度GPS定位方法，通过实时处理载波相位观测量，可达到厘米级定位精度。适用于室外开阔环境的精确定位。],

  [UWB],
  [Ultra-Wideband],
  [超宽带无线通信技术，一种使用极宽频带进行短距离高速数据传输的无线技术。UWB定位具有抗多径能力强、定位精度高（可达厘米级）、功耗低等优点，特别适用于室内定位场景。],

  [GPS],
  [Global Positioning System],
  [全球定位系统，美国建设的卫星导航系统，通过接收至少4颗GPS卫星信号确定位置，精度通常在米级。],

  [GNSS],
  [Global Navigation Satellite System],
  [全球导航卫星系统，是对所有卫星导航系统的统称，包括GPS、GLONASS、Galileo、北斗等。],

  [DGPS], [Differential GPS], [差分GPS，通过在已知位置的基准站计算GPS误差修正量，提高移动站的定位精度。],
  [CORS],
  [Continuously Operating Reference Stations],
  [连续运行参考站系统，由多个永久性GPS基准站组成的网络，提供实时差分改正数据。],
)

== 系统功能相关术语

#table(
  columns: (1fr, 1fr, 3fr),
  [术语], [全称/解释], [详细说明],
  [电子围栏], [Virtual Fence], [基于位置技术的虚拟边界，当设备进入或离开预设区域时触发告警。],
  [安全距离], [Safe Distance], [两个设备之间允许的最小距离，低于此距离则触发告警。],
  [设备标记], [Mark/Device Mark], [系统中管理的物联网终端设备标识，可关联位置数据和告警配置。],
  [危险半径], [Danger Zone], [设备周围的警戒区域半径，当其他设备进入此范围时触发告警。],
)

== 技术术语

#table(
  columns: (1fr, 1fr, 3fr),
  [术语], [全称/解释], [详细说明],
  [PostGIS],
  [PostGIS],
  [PostgreSQL的空间扩展，提供了存储、查询和操作地理空间数据的功能，支持点、线、多边形等几何类型和空间索引。],

  [MQTT], [Message Queuing Telemetry Transport], [轻量级的发布/订阅消息传输协议，常用于物联网设备间的通信。],
  [JWT], [JSON Web Token], [一种用于身份验证的开放标准，通过JSON格式传输声明，实现无状态的令牌认证。],
  [REST API], [Representational State Transfer], [一种软件架构风格，通过HTTP协议进行客户端-服务器通信。],
  [WebSocket], [WebSocket], [一种全双工通信协议，在单个TCP连接上提供持久的双向通信。],
  [Docker], [Docker], [开源的容器化平台，将应用程序及其依赖打包成容器，实现一致的运行环境。],
  [微服务], [Microservice], [一种软件架构风格，将应用程序拆分为多个独立、可部署的服务，每个服务负责特定功能。],
  [API网关], [API Gateway], [系统的统一入口，负责请求路由、认证、限流等功能。],
  [GORM], [Go Object Relational Mapping], [Go语言的ORM库，提供了数据库操作的高级抽象。],
  [Fiber], [Fiber], [Go语言的Web框架，以高性能著称，基于fasthttp实现。],
  [Gin], [Gin], [Go语言的Web框架，以易用性和高性能著称。],
  [Haversine公式], [Haversine Formula], [计算地球表面两点间大圆距离的数学公式，考虑了地球的球形特性。],
  [欧几里得距离], [Euclidean Distance], [平面直角坐标系中两点间的直线距离公式。],
  [滑动窗口], [Sliding Window], [一种限流算法，通过维护一个时间窗口内的请求记录来控制访问频率。],
  [ST_Contains], [ST_Contains], [PostGIS函数，判断一个几何图形是否完全包含另一个几何图形。],
  [WKT], [Well-Known Text], [一种文本格式，用于表示几何对象，如POINT、POLYGON等。],
  [空间索引], [Spatial Index], [一种特殊类型的索引，用于加速空间查询，如R-Tree索引。],
  [GIS], [Geographic Information System], [地理信息系统，用于采集、存储、管理、分析和展示地理空间数据。],
)

== 业务流程相关术语

#table(
  columns: (1fr, 1fr, 3fr),
  [术语], [全称/解释], [详细说明],
  [RBAC], [Role-Based Access Control], [基于角色的访问控制，通过分配角色来管理用户权限的系统方法。],
  [CRUD], [Create, Read, Update, Delete], [数据管理的四种基本操作：创建、读取、更新、删除。],
  [分页], [Pagination], [将大量数据分割成多个页面进行展示的技术，提高系统响应速度。],
  [限流], [Rate Limiting], [控制单位时间内请求数量的技术，防止系统过载。],
  [令牌桶], [Token Bucket], [一种限流算法，通过桶中令牌数量控制请求速率。],
  [持续报警], [Continuous Alerting], [设备在异常状态持续存在时持续发送告警的模式。],
  [笛卡尔积], [Cartesian Product], [数学概念，在本系统中指两组设备所有可能的配对组合。],
)

== 硬件设备相关术语

#table(
  columns: (1fr, 1fr, 3fr),
  [术语], [全称/解释], [详细说明],
  [基站], [Base Station], [UWB定位系统中的固定参考点设备，用于确定移动设备的精确位置。通常部署在已知坐标位置。],
  [定位标签], [Positioning Tag], [携带UWB收发器的移动设备，用于发送定位信号。通常佩戴在人员或设备上。],
  [锚点], [Anchor], [与基站类似，是UWB系统中的固定参考点，用于三角定位计算。],
  [三角定位], [Triangulation], [利用三个或更多已知位置点，通过测量距离来确定目标位置的几何方法。],
)

// ============================================================
// 附录
// ============================================================
= 附录

== 附录A：配置文件参考

=== docker-compose.yml 主要服务配置

```yaml
services:
  api-gateway:
    build: ./api-gateway
    ports:
      - "8000:8000"
    depends_on:
      - user-service
      - map-service
      - mqtt-watch
      - mark-service

  user-service:
    build: ./user-service
    ports:
      - "8001:8001"
    environment:
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_USER=postgres
      - DB_PASSWORD=postgres
      - DB_NAME=iot_db

  map-service:
    build: ./map-service
    ports:
      - "8002:8002"
    environment:
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_USER=postgres
      - DB_PASSWORD=postgres
      - DB_NAME=iot_db

  mqtt-watch:
    build: ./mqtt-watch
    ports:
      - "8003:8003"
    environment:
      - MQTT_BROKER=mosquitto:1883
      - MONGO_URI=mongodb://mongodb:27017

  mark-service:
    build: ./mark-service
    ports:
      - "8004:8004"
    environment:
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_USER=postgres
      - DB_PASSWORD=postgres
      - DB_NAME=iot_db

  postgres:
    image: postgis/postgis:latest
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=iot_db

  mongodb:
    image: mongo:latest
    ports:
      - "27017:27017"

  mosquitto:
    image: eclipse-mosquitto:latest
    ports:
      - "1883:1883"
      - "8083:8083"
```

== 附录B：环境变量参考

=== user-service 环境变量

#table(
  columns: (1fr, 2fr, 1fr),
  [变量名], [说明], [默认值],
  [DB_HOST], [数据库主机地址], [localhost],
  [DB_PORT], [数据库端口], [5432],
  [DB_USER], [数据库用户名], [postgres],
  [DB_PASSWORD], [数据库密码], [postgres],
  [DB_NAME], [数据库名称], [iot_db],
  [JWT_SECRET], [JWT密钥], [your-secret-key],
  [JWT_EXPIRY], [JWT过期时间], [24h],
)

=== mqtt-watch 环境变量

#table(
  columns: (1fr, 2fr, 1fr),
  [变量名], [说明], [默认值],
  [MQTT_BROKER], [MQTT Broker地址], [localhost:1883],
  [MQTT_USERNAME], [MQTT用户名], [无],
  [MQTT_PASSWORD], [MQTT密码], [无],
  [MONGO_URI], [MongoDB连接URI], [mongodb:27017],
  [MONGO_DB], [MongoDB数据库名], [iot_db],
)

== 附录C：快速故障排查

#table(
  columns: (1fr, 2fr, 2fr),
  [问题], [可能原因], [解决方法],
  [服务无法启动], [端口被占用], [检查并释放端口：netstat -tlnp | grep <port>],
  [服务无法启动], [配置文件错误], [检查docker-compose.yml配置],
  [数据库连接失败], [数据库未启动], [检查postgres容器状态],
  [数据库连接失败], [密码错误], [检查环境变量DB_PASSWORD],
  [MQTT连接失败], [Broker未启动], [检查mosquitto容器状态],
  [MQTT连接失败], [端口错误], [检查MQTT_BROKER配置],
  [前端无法访问], [Nginx未启动], [检查nginx容器状态],
  [前端无法访问], [代理配置错误], [检查nginx.conf配置],
  [JWT认证失败], [Token过期], [重新登录获取新Token],
  [JWT认证失败], [Secret不一致], [检查各服务JWT_SECRET配置],
  [围栏检测不准确], [坐标系不匹配], [检查地图坐标系配置],
  [围栏检测不准确], [PostGIS未启用], [确认PostgreSQL已安装PostGIS扩展],
)
