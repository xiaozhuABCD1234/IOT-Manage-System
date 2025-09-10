<template>
  <div class="h-full w-full">
    <div ref="chartRef" class="h-full w-full"></div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted, onBeforeUnmount } from "vue";
import * as echarts from "echarts/core";
import { ScatterChart } from "echarts/charts";
import { GridComponent, DataZoomComponent, GraphicComponent } from "echarts/components";
import { CanvasRenderer } from "echarts/renderers";
import type { ECBasicOption } from "echarts/types/dist/shared";

// 按需注册模块
echarts.use([ScatterChart, GridComponent, DataZoomComponent, GraphicComponent, CanvasRenderer]);

// 数据类型定义
interface UWBFix {
  id: string;
  x: number;
  y: number;
}

// Props
const props = defineProps<{ points: UWBFix[] }>();

// DOM 引用
const chartRef = ref<HTMLDivElement | null>(null);
let chart: echarts.ECharts | null = null;
let bgEl: any = null;
const bgImg = new Image();
bgImg.src = new URL("@/assets/imgs/map.png", import.meta.url).href;

// 计算背景图在像素坐标系下的矩形区域
function calcBgPixelRect(): { x: number; y: number; width: number; height: number } | null {
  if (!chart) return null;

  const xAxisModel = (chart as any).getModel().getComponent("xAxis", 0);
  const yAxisModel = (chart as any).getModel().getComponent("yAxis", 0);
  const [xMin, xMax] = xAxisModel.axis.scale.getExtent();
  const [yMin, yMax] = yAxisModel.axis.scale.getExtent();

  const lt = chart.convertToPixel("grid", [xMin, yMax]);
  const rb = chart.convertToPixel("grid", [xMax, yMin]);

  return {
    x: lt[0],
    y: lt[1],
    width: rb[0] - lt[0],
    height: rb[1] - lt[1],
  };
}

// 更新背景图位置和尺寸
function updateBackground() {
  const rect = calcBgPixelRect();
  if (!rect) return;

  if (!bgEl) {
    bgEl = new (echarts as any).graphic.Image({
      z: -1,
      style: {
        image: bgImg,
        x: rect.x,
        y: rect.y,
        width: rect.width,
        height: rect.height,
      },
      silent: true,
    });
    chart!.getZr().add(bgEl);
  } else {
    bgEl.setStyle({
      image: bgImg, // 必须保留，否则可能丢失图片
      x: rect.x,
      y: rect.y,
      width: rect.width,
      height: rect.height,
    });
  }
}

// 初始化并渲染图表
function renderChart() {
  if (!chartRef.value) return;
  if (!chart) {
    chart = echarts.init(chartRef.value);

    const option: ECBasicOption = {
      grid: {
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
      },
      xAxis: {
        type: "value",
        min: -1000,
        max: 1000,
        splitLine: { lineStyle: { type: "dashed" } },
      },
      yAxis: {
        type: "value",
        min: -1000,
        max: 1000,
        splitLine: { lineStyle: { type: "dashed" } },
      },
      series: [
        {
          type: "scatter",
          data: [],
          symbolSize: 10,
          itemStyle: {
            borderColor: "#fff",
            borderWidth: 1,
            shadowBlur: 8,
            shadowColor: "rgba(0,0,0,0.2)",
            color: new (echarts as any).graphic.RadialGradient(0.4, 0.3, 1, [
              { offset: 0, color: "rgb(251, 118, 123)" },
              { offset: 1, color: "rgb(204, 46, 72)" },
            ]),
          },
          emphasis: {
            scale: 2,
            itemStyle: { shadowBlur: 20 },
          },
          label: {
            show: true,
            fontSize: 10,
            color: "#666",
            distance: 5,
            position: "top",
            formatter: (p: any) =>
              `ID:${p.value[2]} (${p.value[0].toFixed(2)},${p.value[1].toFixed(2)})`,
          },
        },
      ],
      dataZoom: [
        { type: "inside", xAxisIndex: 0, zoomOnMouseWheel: true, moveOnMouseMove: true },
        { type: "inside", yAxisIndex: 0, zoomOnMouseWheel: true, moveOnMouseMove: true },
        { type: "slider", xAxisIndex: 0, bottom: 10, height: 14 },
        { type: "slider", yAxisIndex: 0, right: 10, width: 14 },
      ],
    };

    chart.setOption(option);
  }

  const data = props.points.map((p) => [p.x, p.y, p.id]);
  chart.setOption({ series: [{ data }] } as any);

  updateBackground();
}

// 监听数据变化
watch(() => props.points, renderChart, { deep: true });

// 生命周期钩子
let ro: ResizeObserver | null = null;
onMounted(() => {
  renderChart();

  ro = new ResizeObserver(() => {
    chart?.resize();
    requestAnimationFrame(updateBackground);
  });
  chartRef.value && ro.observe(chartRef.value);

  // 缩放、拖动事件监听
  chart!.on("dataZoom", () => {
    requestAnimationFrame(() => {
      requestAnimationFrame(updateBackground); // 确保坐标已更新
    });
  });

  chart!.on("finished", updateBackground);
});

onBeforeUnmount(() => {
  ro?.disconnect();
  bgEl && chart?.getZr().remove(bgEl);
  chart?.dispose();
});
</script>
