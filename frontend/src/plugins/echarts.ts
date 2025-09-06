// plugins/echarts.ts
import * as echarts from "echarts/core";

// 只引入散点图
import { ScatterChart } from "echarts/charts";

// 只引入用到的组件
import {
  GridComponent,
  TooltipComponent,
  DataZoomComponent, // ← 新增
} from "echarts/components";

import type { ECharts } from "echarts/core"; // 把官方类型导出来

import { CanvasRenderer } from "echarts/renderers";

echarts.use([ScatterChart, GridComponent, TooltipComponent, CanvasRenderer, DataZoomComponent]);

export default echarts
export type { ECharts }
export * from 'echarts/core'   // 如果还想用其它工具函数
