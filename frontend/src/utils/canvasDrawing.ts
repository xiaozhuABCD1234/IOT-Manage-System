import type { StationResp } from "@/types/station";
import type { PolygonFenceResp, Point } from "@/types/polygonFence";

/**
 * 像素坐标转换器
 */
export class PixelScaler {
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
 * 绘制底图
 */
export function drawBackgroundImage(
  ctx: CanvasRenderingContext2D,
  imageUrl: string,
  width: number,
  height: number,
): Promise<void> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.crossOrigin = "anonymous";
    img.src = imageUrl;
    img.onload = () => {
      ctx.drawImage(img, 0, 0, width, height);
      resolve();
    };
    img.onerror = () => {
      console.error("Failed to load background image:", imageUrl);
      reject(new Error("Failed to load image"));
    };
  });
}

/**
 * 生成"好看"的刻度值
 * @param min 最小值
 * @param max 最大值
 * @param maxTicks 期望的最大刻度数量
 * @returns 刻度值数组
 */
export function generateNiceTicks(min: number, max: number, maxTicks: number = 10): number[] {
  const range = max - min;
  if (range === 0) return [min];

  // 计算初步步长
  const roughStep = range / (maxTicks - 1);

  // 找到最接近的"好看"的步长（1, 2, 5 的倍数）
  const magnitude = Math.pow(10, Math.floor(Math.log10(roughStep)));
  const normalized = roughStep / magnitude; // 归一化到 1-10 范围

  let niceStep;
  if (normalized < 1.5) {
    niceStep = 1 * magnitude;
  } else if (normalized < 3) {
    niceStep = 2 * magnitude;
  } else if (normalized < 7) {
    niceStep = 5 * magnitude;
  } else {
    niceStep = 10 * magnitude;
  }

  // 计算刻度起始和结束值（向外扩展到"好看"的值）
  const niceMin = Math.floor(min / niceStep) * niceStep;
  const niceMax = Math.ceil(max / niceStep) * niceStep;

  // 生成刻度数组
  const ticks: number[] = [];
  for (let tick = niceMin; tick <= niceMax; tick += niceStep) {
    // 避免浮点数精度问题
    ticks.push(Math.round(tick / niceStep) * niceStep);
  }

  return ticks;
}

/**
 * 格式化刻度标签
 */
export function formatTickLabel(value: number): string {
  const absValue = Math.abs(value);

  if (absValue >= 1000000) {
    return (value / 1000000).toFixed(1).replace(/\.0$/, "") + "M";
  } else if (absValue >= 1000) {
    return (value / 1000).toFixed(1).replace(/\.0$/, "") + "k";
  } else if (absValue < 1 && absValue > 0) {
    return value.toFixed(2).replace(/\.?0+$/, "");
  } else {
    return value.toFixed(0);
  }
}

/**
 * 绘制网格
 */
export function drawGrid(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  gridSpacing: number = 1,
  options: {
    color?: string;
    lineWidth?: number;
  } = {},
) {
  const { color = "#e0e0e0", lineWidth = 0.5 } = options;

  ctx.save();
  ctx.strokeStyle = color;
  ctx.lineWidth = lineWidth;

  // 垂直网格线
  for (let x = Math.ceil(scaler.x_min); x <= scaler.x_max; x += gridSpacing) {
    const { px } = scaler.toPixel(x, 0);
    ctx.beginPath();
    ctx.moveTo(px, 0);
    ctx.lineTo(px, scaler.pixelHeight);
    ctx.stroke();
  }

  // 水平网格线
  for (let y = Math.ceil(scaler.y_min); y <= scaler.y_max; y += gridSpacing) {
    const { py } = scaler.toPixel(0, y);
    ctx.beginPath();
    ctx.moveTo(0, py);
    ctx.lineTo(scaler.pixelWidth, py);
    ctx.stroke();
  }

  ctx.restore();
}

/**
 * 绘制 X 轴
 */
export function drawAxisX(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  ticks: number = 10,
  options: {
    color?: string;
    lineWidth?: number;
    tickLength?: number;
    font?: string;
    textColor?: string;
    arrowSize?: number;
  } = {},
) {
  const {
    color = "#333",
    lineWidth = 2,
    tickLength = 8,
    font = "12px Arial",
    textColor = "#333",
    arrowSize = 10,
  } = options;

  // X轴画在 y=0 的位置（如果0在范围内），否则画在底部
  const yPos = scaler.y_min <= 0 && scaler.y_max >= 0 ? 0 : scaler.y_min;
  const { py: yAxisPx } = scaler.toPixel(0, yPos);

  ctx.save();
  ctx.strokeStyle = color;
  ctx.fillStyle = color;
  ctx.lineWidth = lineWidth;

  // 主轴线
  ctx.beginPath();
  ctx.moveTo(0, yAxisPx);
  ctx.lineTo(scaler.pixelWidth, yAxisPx);
  ctx.stroke();

  // 箭头
  ctx.beginPath();
  ctx.moveTo(scaler.pixelWidth, yAxisPx);
  ctx.lineTo(scaler.pixelWidth - arrowSize, yAxisPx - arrowSize / 2);
  ctx.lineTo(scaler.pixelWidth - arrowSize, yAxisPx + arrowSize / 2);
  ctx.closePath();
  ctx.fill();

  // 刻度和标签
  ctx.font = font;
  ctx.fillStyle = textColor;
  ctx.textAlign = "center";
  ctx.textBaseline = "top";

  // 生成"好看"的刻度值
  const tickValues = generateNiceTicks(scaler.x_min, scaler.x_max, ticks);

  for (const x of tickValues) {
    // 只绘制在可见范围内的刻度
    if (x < scaler.x_min || x > scaler.x_max) continue;

    const { px } = scaler.toPixel(x, 0);

    // 刻度线
    ctx.strokeStyle = color;
    ctx.lineWidth = lineWidth;
    ctx.beginPath();
    ctx.moveTo(px, yAxisPx);
    ctx.lineTo(px, yAxisPx + tickLength);
    ctx.stroke();

    // 标签 - 使用智能格式化，添加白色描边增强可读性
    const label = formatTickLabel(x);
    // 白色描边
    ctx.strokeStyle = "rgba(255, 255, 255, 0.8)";
    ctx.lineWidth = 3;
    ctx.strokeText(label, px, yAxisPx + tickLength + 4);
    // 文字本身
    ctx.fillStyle = textColor;
    ctx.fillText(label, px, yAxisPx + tickLength + 4);
  }

  // X 轴标签
  ctx.font = "bold 14px Arial";
  // 白色描边
  ctx.strokeStyle = "rgba(255, 255, 255, 0.8)";
  ctx.lineWidth = 3;
  ctx.strokeText("X", scaler.pixelWidth - 25, yAxisPx - 20);
  // 文字本身
  ctx.fillText("X", scaler.pixelWidth - 25, yAxisPx - 20);

  ctx.restore();
}

/**
 * 绘制 Y 轴
 */
export function drawAxisY(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  ticks: number = 10,
  options: {
    color?: string;
    lineWidth?: number;
    tickLength?: number;
    font?: string;
    textColor?: string;
    arrowSize?: number;
  } = {},
) {
  const {
    color = "#333",
    lineWidth = 2,
    tickLength = 8,
    font = "12px Arial",
    textColor = "#333",
    arrowSize = 10,
  } = options;

  // Y轴画在 x=0 的位置（如果0在范围内），否则画在左边
  const xPos = scaler.x_min <= 0 && scaler.x_max >= 0 ? 0 : scaler.x_min;
  const { px: xAxisPx } = scaler.toPixel(xPos, 0);

  ctx.save();
  ctx.strokeStyle = color;
  ctx.fillStyle = color;
  ctx.lineWidth = lineWidth;

  // 主轴线
  ctx.beginPath();
  ctx.moveTo(xAxisPx, scaler.pixelHeight);
  ctx.lineTo(xAxisPx, 0);
  ctx.stroke();

  // 箭头
  ctx.beginPath();
  ctx.moveTo(xAxisPx, 0);
  ctx.lineTo(xAxisPx - arrowSize / 2, arrowSize);
  ctx.lineTo(xAxisPx + arrowSize / 2, arrowSize);
  ctx.closePath();
  ctx.fill();

  // 刻度和标签
  ctx.font = font;
  ctx.fillStyle = textColor;
  ctx.textAlign = "right";
  ctx.textBaseline = "middle";

  // 生成"好看"的刻度值
  const tickValues = generateNiceTicks(scaler.y_min, scaler.y_max, ticks);

  for (const y of tickValues) {
    // 只绘制在可见范围内的刻度
    if (y < scaler.y_min || y > scaler.y_max) continue;

    const { py } = scaler.toPixel(0, y);

    // 刻度线
    ctx.strokeStyle = color;
    ctx.lineWidth = lineWidth;
    ctx.beginPath();
    ctx.moveTo(xAxisPx - tickLength, py);
    ctx.lineTo(xAxisPx, py);
    ctx.stroke();

    // 标签 - 使用智能格式化，添加白色描边增强可读性
    const label = formatTickLabel(y);
    // 白色描边
    ctx.strokeStyle = "rgba(255, 255, 255, 0.8)";
    ctx.lineWidth = 3;
    ctx.strokeText(label, xAxisPx - tickLength - 4, py);
    // 文字本身
    ctx.fillStyle = textColor;
    ctx.fillText(label, xAxisPx - tickLength - 4, py);
  }

  // Y 轴标签
  ctx.font = "bold 14px Arial";
  ctx.textAlign = "center";
  // 白色描边
  ctx.strokeStyle = "rgba(255, 255, 255, 0.8)";
  ctx.lineWidth = 3;
  ctx.strokeText("Y", xAxisPx + 20, 15);
  // 文字本身
  ctx.fillText("Y", xAxisPx + 20, 15);

  ctx.restore();
}

/**
 * 绘制基站（蓝色等边三角形）
 */
export function drawStations(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  stations: StationResp[],
  options: {
    color?: string;
    size?: number;
    font?: string;
    textColor?: string;
  } = {},
) {
  const { color = "#3498db", size = 12, font = "12px Arial", textColor = "#333" } = options;

  ctx.save();

  stations.forEach((station) => {
    const { px, py } = scaler.toPixel(station.coordinate_x, station.coordinate_y);

    // 绘制等边三角形（顶点朝上）
    const height = (size * Math.sqrt(3)) / 2; // 等边三角形高度
    const halfBase = size / 2; // 底边的一半

    ctx.fillStyle = color;
    ctx.beginPath();
    // 顶点（上）
    ctx.moveTo(px, py - (height * 2) / 3);
    // 左下顶点
    ctx.lineTo(px - halfBase, py + height / 3);
    // 右下顶点
    ctx.lineTo(px + halfBase, py + height / 3);
    ctx.closePath();
    ctx.fill();

    // 绘制三角形边框
    ctx.strokeStyle = "#fff";
    ctx.lineWidth = 2;
    ctx.stroke();

    // 绘制基站名称（右上角，灰色）
    ctx.fillStyle = "#888";
    ctx.font = font;
    ctx.textAlign = "left";
    ctx.textBaseline = "bottom";
    ctx.fillText(station.station_name, px + halfBase + 4, py - (height * 2) / 3);
  });

  ctx.restore();
}

/**
 * 绘制多边形围栏
 */
export function drawPolygonFences(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  fences: PolygonFenceResp[],
  options: {
    strokeColor?: string;
    fillColor?: string;
    lineWidth?: number;
    font?: string;
    textColor?: string;
  } = {},
) {
  const {
    strokeColor = "#3498db",
    fillColor = "rgba(68, 68, 255, 0.1)",
    lineWidth = 2,
    font = "12px Arial",
    textColor = "#3498db",
  } = options;

  ctx.save();

  fences.forEach((fence) => {
    if (fence.points.length < 3) return;

    // 绘制多边形
    ctx.beginPath();
    const firstPoint = scaler.toPixel(fence.points[0].x, fence.points[0].y);
    ctx.moveTo(firstPoint.px, firstPoint.py);

    for (let i = 1; i < fence.points.length; i++) {
      const { px, py } = scaler.toPixel(fence.points[i].x, fence.points[i].y);
      ctx.lineTo(px, py);
    }
    ctx.closePath();

    // 填充
    ctx.fillStyle = fence.is_active ? fillColor : "rgba(150, 150, 150, 0.1)";
    ctx.fill();

    // 描边
    ctx.strokeStyle = fence.is_active ? strokeColor : "#999";
    ctx.lineWidth = lineWidth;
    ctx.stroke();

    // 绘制顶点
    fence.points.forEach((point) => {
      const { px, py } = scaler.toPixel(point.x, point.y);
      ctx.fillStyle = fence.is_active ? strokeColor : "#999";
      ctx.beginPath();
      ctx.arc(px, py, 4, 0, Math.PI * 2);
      ctx.fill();
    });

    // 绘制围栏名称（在中心位置）
    if (fence.points.length > 0) {
      let centerX = 0,
        centerY = 0;
      fence.points.forEach((p) => {
        centerX += p.x;
        centerY += p.y;
      });
      centerX /= fence.points.length;
      centerY /= fence.points.length;

      const { px, py } = scaler.toPixel(centerX, centerY);
      ctx.fillStyle = textColor;
      ctx.font = font;
      ctx.textAlign = "center";
      ctx.textBaseline = "middle";
      ctx.fillText(`${fence.fence_name}${fence.is_active ? "" : " (未激活)"}`, px, py);
    }
  });

  ctx.restore();
}

/**
 * 绘制正在创建的多边形
 */
export function drawCurrentPolygon(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  points: Point[],
) {
  if (points.length === 0) return;

  ctx.save();

  // 绘制连线
  if (points.length > 1) {
    ctx.beginPath();
    const firstPoint = scaler.toPixel(points[0].x, points[0].y);
    ctx.moveTo(firstPoint.px, firstPoint.py);

    for (let i = 1; i < points.length; i++) {
      const { px, py } = scaler.toPixel(points[i].x, points[i].y);
      ctx.lineTo(px, py);
    }

    ctx.strokeStyle = "#ff6b35";
    ctx.lineWidth = 2;
    ctx.setLineDash([5, 5]);
    ctx.stroke();
    ctx.setLineDash([]);
  }

  // 绘制顶点
  points.forEach((point, index) => {
    const { px, py } = scaler.toPixel(point.x, point.y);

    // 绘制顶点圆圈
    ctx.fillStyle = "#ff6b35";
    ctx.beginPath();
    ctx.arc(px, py, 6, 0, Math.PI * 2);
    ctx.fill();

    ctx.strokeStyle = "#fff";
    ctx.lineWidth = 2;
    ctx.stroke();

    // 绘制顶点序号
    ctx.fillStyle = "#fff";
    ctx.font = "bold 10px Arial";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText((index + 1).toString(), px, py);
  });

  ctx.restore();
}
