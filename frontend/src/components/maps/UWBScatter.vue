<template>
  <div class="h-full w-full">
    <div ref="chartRef" class="h-full w-full"></div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted, onBeforeUnmount } from "vue";
import echarts from "@/plugins/echarts";
// import type { ECharts, graphic } from "@/plugins/echarts";

import type { ECBasicOption } from "echarts/types/dist/shared";
import type { UWBFix } from "@/utils/mqtt"; // 路径按实际调整

/* ---------- props ---------- */
const props = defineProps<{
  points: UWBFix[];
}>();

/* ---------- 生命周期变量 ---------- */
const chartRef = ref<HTMLDivElement>();
let chart: echarts.ECharts | null = null;

/* ---------- 绘制函数 ---------- */
function renderChart() {
  if (!chartRef.value) return;
  if (!chart) chart = echarts.init(chartRef.value);

  /* 把 UWBFix[] 转成 echarts 需要的 [x,y,id] */
  const echartsData: [number, number, string][] = props.points.map((p) => [p.x, p.y, p.id]);

  const option: ECBasicOption = {
    xAxis: {
      type: "value",
      scale: true,
      splitLine: { lineStyle: { type: "dashed" } },
      min: -1000,
      max: 1000,
    },
    yAxis: {
      type: "value",
      scale: true,
      splitLine: { lineStyle: { type: "dashed" } },
      min: -1000,
      max: 1000,
    },
    series: [
      {
        type: "scatter",
        data: echartsData,
        symbolSize: 10,
        itemStyle: {
          borderColor: "#fff",
          borderWidth: 1,
          shadowBlur: 8,
          shadowColor: "rgba(0,0,0,0.2)",
          color: new echarts.graphic.RadialGradient(0.4, 0.3, 1, [
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
          formatter: (p: { value: [number, number, string] }) =>
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

/* ---------- 监听数据变化 ---------- */
watch(() => props.points, renderChart, { deep: true });

/* ---------- 挂载 & 卸载 ---------- */
let ro: ResizeObserver | null = null;

onMounted(() => {
  renderChart();

  /* ---------- 关键：监听父容器尺寸 ---------- */
  ro = new ResizeObserver(() => chart?.resize());
  if (chartRef.value) ro.observe(chartRef.value);

  /* 如果还想保留窗口resize兜底，可保留下面两行 */
  const winResize = () => chart?.resize();
  window.addEventListener("resize", winResize);
  onBeforeUnmount(() => {
    window.removeEventListener("resize", winResize);
    ro?.disconnect();
    chart?.dispose();
  });
});
</script>
