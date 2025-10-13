<script setup lang="ts">
import { onMounted } from "vue";
import uwbmap from "@/assets/imgs/uwbmap.png"; // 返回构建后的 URL

function drawImage(
  ctx: CanvasRenderingContext2D,
  left: number,
  top: number,
  right: number,
  bottom: number,
) {
  const bg = new Image();
  bg.crossOrigin = "anonymous";
  bg.src = uwbmap;
  bg.onload = () => {
    ctx.drawImage(bg, left, top, right, bottom);
  };
}

class PixelScaler {
  readonly pixelWidth: number;
  readonly pixelHeight: number;
  readonly x_min: number;
  readonly x_max: number;
  readonly y_min: number;
  readonly y_max: number;

  constructor(
    pixelWidth: number,
    pixelHeight: number,
    x_min: number,
    x_max: number,
    y_min: number,
    y_max: number,
  ) {
    this.pixelWidth = pixelWidth;
    this.pixelHeight = pixelHeight;
    this.x_min = x_min;
    this.x_max = x_max;
    this.y_min = y_min;
    this.y_max = y_max;
  }

  /** 逻辑坐标 → 像素坐标 */
  toPixel(x: number, y: number): { px: number; py: number } {
    const px = ((x - this.x_min) / (this.x_max - this.x_min)) * this.pixelWidth;
    const py = (1 - (y - this.y_min) / (this.y_max - this.y_min)) * this.pixelHeight;
    return { px, py };
  }

  /** 像素坐标 → 逻辑坐标 */
  toXY(px: number, py: number): { x: number; y: number } {
    const x = this.x_min + (px / this.pixelWidth) * (this.x_max - this.x_min);
    const y = this.y_min + (1 - py / this.pixelHeight) * (this.y_max - this.y_min);
    return { x, y };
  }
}

/**
 * 绘制可带方向箭头的 X 轴（水平轴）
 * @param ctx            canvas 2d 上下文
 * @param x              轴起点 canvas x 坐标（像素）
 * @param y              轴起点 canvas y 坐标（像素）
 * @param length         轴长度（像素）
 * @param width          轴主线线宽（像素）
 * @param min            轴最小数据值
 * @param max            轴最大数据值
 * @param ticks          刻度个数（包含首尾）
 * @param arrowDirection 箭头朝向：1 朝右（正方向），-1 朝左（负方向）
 * @param options        可选样式配置（新增 arrowSize 控制箭头大小）
 */
function drawAxisX(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  length: number,
  width: number,
  min: number,
  max: number,
  ticks: number,
  arrowDirection: 1 | -1 = 1,
  options: {
    color?: string;
    tickLength?: number;
    font?: string;
    textColor?: string;
    textOffsetY?: number;
    decimals?: number;
    arrowSize?: number; // 箭头两翼长度（像素）
  } = {},
) {
  const {
    color = "#000",
    tickLength = 6,
    font = "12px sans-serif",
    textColor = color,
    textOffsetY = 4,
    decimals,
    arrowSize = 10,
  } = options;

  const autoDecimals = decimals ?? Math.max(0, -Math.floor(Math.log10((max - min) / (ticks - 1))));

  ctx.save();
  ctx.strokeStyle = color;
  ctx.fillStyle = color;
  ctx.lineWidth = width;

  // 1. 主线
  ctx.beginPath();
  ctx.moveTo(x, y);
  ctx.lineTo(x + length, y);
  ctx.stroke();

  // 2. 箭头
  const arrowX = x + length;
  const dir = arrowDirection; // 1 或 -1
  ctx.beginPath();
  ctx.moveTo(arrowX, y);
  ctx.lineTo(arrowX - dir * arrowSize, y - arrowSize / 2);
  ctx.lineTo(arrowX - dir * arrowSize, y + arrowSize / 2);
  ctx.closePath();
  ctx.fill();

  // 3. 刻度与文字
  ctx.font = font;
  ctx.fillStyle = textColor;
  ctx.textAlign = "center";
  ctx.textBaseline = "top";

  const step = length / (ticks - 1);
  for (let i = 0; i < ticks; i++) {
    const px = x + i * step;
    const value = min + (i * (max - min)) / (ticks - 1);

    // 刻度线
    ctx.beginPath();
    ctx.moveTo(px, y);
    ctx.lineTo(px, y + tickLength);
    ctx.stroke();

    // 标签
    const label = value.toFixed(autoDecimals);
    ctx.fillText(label, px, y + tickLength + textOffsetY);
  }

  ctx.restore();
}

onMounted(() => {
  const canvas = document.getElementById("rtk-map-canvas") as HTMLCanvasElement;
  if (!canvas) return;

  const rect = canvas.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;

  // 1. 物理像素
  canvas.width = Math.round(rect.width * dpr);
  canvas.height = Math.round(rect.height * dpr);
  // 2. 坐标系缩回 CSS 像素
  const ctx = canvas.getContext("2d")!;
  ctx.scale(dpr, dpr);
  // drawImage(ctx, 0, 0, canvas.width / 2, canvas.height);
  drawAxisX(ctx, 0, canvas.height / 2, canvas.width, 2, 100, 10, canvas.width / 50, -1, {
    color: "#007bff",
    tickLength: 8,
    font: "14px Arial",
    textColor: "#333",
    decimals: 1,
  });
});
</script>

<template>
  <div class="h-full w-full">
    <canvas id="rtk-map-canvas" class="h-full w-full" />
  </div>
</template>
