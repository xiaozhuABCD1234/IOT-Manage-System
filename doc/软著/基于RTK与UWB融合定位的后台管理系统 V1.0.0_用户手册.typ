// ---------- 可调参数 ----------
#let soft-name = "基于RTK与UWB融合定位的后台管理系统"
#let soft-ver = "V1.0.0"
#let doc-type = "用户手册"

#set heading(numbering: "1.1.1") //设置标题格式

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



= 软件简介
== 开发背景
== 软件介绍
== 面向用户
== 主要功能
== 优势创新

= 运行环境
== 硬件环境
== 软件环境

= 技术栈
== 软件技术
== 架构设计
== 数据模型

= 软件功能(分点叙述、图文并茂)
