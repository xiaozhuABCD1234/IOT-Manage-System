import type { StationResp } from "@/types/station";
import type { PolygonFenceResp, Point } from "@/types/polygonFence";
import type { UWBFix, MarkOnline } from "@/utils/mqtt";
import type { CustomMapResp } from "@/types/customMap";

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

    // 根据室内/室外设置不同颜色
    const indoorStrokeColor = "#22c55e"; // 绿色 - 室内
    const outdoorStrokeColor = "#f97316"; // 橙色 - 室外
    const indoorFillColor = "rgba(34, 197, 94, 0.1)"; // 浅绿色
    const outdoorFillColor = "rgba(249, 115, 22, 0.1)"; // 浅橙色

    const currentStrokeColor = fence.is_indoor ? indoorStrokeColor : outdoorStrokeColor;
    const currentFillColor = fence.is_indoor ? indoorFillColor : outdoorFillColor;

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
    ctx.fillStyle = fence.is_active ? currentFillColor : "rgba(150, 150, 150, 0.1)";
    ctx.fill();

    // 描边
    ctx.strokeStyle = fence.is_active ? currentStrokeColor : "#999";
    ctx.lineWidth = lineWidth;
    ctx.stroke();

    // 绘制顶点
    fence.points.forEach((point) => {
      const { px, py } = scaler.toPixel(point.x, point.y);
      ctx.fillStyle = fence.is_active ? currentStrokeColor : "#999";
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
      ctx.fillStyle = fence.is_active ? currentStrokeColor : "#999";
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

/**
 * 绘制 UWB 设备坐标
 */
export function drawUWBDevices(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  deviceCoordinates: Map<string, UWBFix>,
  onlineDevices: MarkOnline[],
  deviceNames: Map<string, string>,
  options: {
    onlineColor?: string;
    offlineColor?: string;
    size?: number;
    font?: string;
    textColor?: string;
    showTrail?: boolean;
    trailLength?: number;
  } = {},
) {
  const {
    onlineColor = "#e74c3c",
    offlineColor = "#95a5a6",
    size = 4,
    font = "10px Arial",
    textColor = "#333",
    showTrail = false,
    trailLength = 10,
  } = options;

  ctx.save();

  // 创建设备轨迹存储（如果需要显示轨迹）
  const deviceTrails = new Map<string, Array<{ x: number; y: number; timestamp: number }>>();

  deviceCoordinates.forEach((uwbData, deviceId) => {
    const { px, py } = scaler.toPixel(uwbData.x, uwbData.y);

    // 检查设备是否在线
    const isOnline = onlineDevices.some((device) => device.id === deviceId && device.online);
    const deviceColor = isOnline ? onlineColor : offlineColor;

    // 绘制设备位置圆圈
    ctx.fillStyle = deviceColor;
    ctx.beginPath();
    ctx.arc(px, py, size, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = "#000"; // 加一圈黑边
    ctx.lineWidth = 1;
    ctx.stroke();

    // 绘制白色边框
    // ctx.strokeStyle = "#fff";
    // ctx.lineWidth = 2;
    // ctx.stroke();

    // 如果设备在线，绘制脉冲效果
    // if (isOnline) {
    //   ctx.strokeStyle = deviceColor;
    //   ctx.lineWidth = 1;
    //   ctx.globalAlpha = 0.3;
    //   ctx.beginPath();
    //   ctx.arc(px, py, size * 2, 0, Math.PI * 2);
    //   ctx.stroke();
    //   ctx.globalAlpha = 1;
    // }

    // 绘制设备名称（优先显示名称，如果没有名称则显示ID）
    const deviceName = deviceNames.get(deviceId) || "未知设备";
    const displayText = `${deviceName}(${deviceId})`;

    ctx.fillStyle = textColor;
    ctx.font = font;
    ctx.textAlign = "center";
    ctx.textBaseline = "top";

    // 添加白色描边增强可读性
    ctx.strokeStyle = "rgba(255, 255, 255, 0.8)";
    ctx.lineWidth = 2;
    ctx.strokeText(displayText, px, py + size + 4);
    ctx.fillText(displayText, px, py + size + 4);

    // 绘制坐标信息
    const coordText = `(${uwbData.x.toFixed(1)}, ${uwbData.y.toFixed(1)})`;
    ctx.font = "8px Arial";
    ctx.textBaseline = "top";
    ctx.strokeText(coordText, px, py + size + 16);
    ctx.fillText(coordText, px, py + size + 16);

    // 如果需要显示轨迹，记录当前位置
    if (showTrail) {
      if (!deviceTrails.has(deviceId)) {
        deviceTrails.set(deviceId, []);
      }
      const trail = deviceTrails.get(deviceId)!;
      trail.push({ x: uwbData.x, y: uwbData.y, timestamp: Date.now() });

      // 限制轨迹长度
      if (trail.length > trailLength) {
        trail.shift();
      }

      // 绘制轨迹
      if (trail.length > 1) {
        ctx.strokeStyle = deviceColor;
        ctx.lineWidth = 1;
        ctx.globalAlpha = 0.6;
        ctx.beginPath();

        const firstPoint = scaler.toPixel(trail[0].x, trail[0].y);
        ctx.moveTo(firstPoint.px, firstPoint.py);

        for (let i = 1; i < trail.length; i++) {
          const { px: trailPx, py: trailPy } = scaler.toPixel(trail[i].x, trail[i].y);
          ctx.lineTo(trailPx, trailPy);
        }
        ctx.stroke();
        ctx.globalAlpha = 1;
      }
    }
  });

  ctx.restore();
}

/**
 * 双缓冲 Canvas 管理器
 * 用于解决 Canvas 重绘时的闪动问题
 */
export class DoubleBufferCanvas {
  private displayCanvas: HTMLCanvasElement;
  private offscreenCanvas: HTMLCanvasElement;
  private displayCtx: CanvasRenderingContext2D;
  private offscreenCtx: CanvasRenderingContext2D;
  private dpr: number;

  constructor(displayCanvas: HTMLCanvasElement) {
    this.displayCanvas = displayCanvas;
    this.dpr = window.devicePixelRatio || 1;

    // 创建离屏 Canvas
    this.offscreenCanvas = document.createElement("canvas");
    this.offscreenCanvas.style.display = "none"; // 隐藏离屏 Canvas

    // 获取上下文
    this.displayCtx = this.displayCanvas.getContext("2d")!;
    this.offscreenCtx = this.offscreenCanvas.getContext("2d")!;

    this.resize();

    console.log("🔄 双缓冲Canvas管理器已创建");
    console.log("📱 设备像素比:", this.dpr);
  }

  /**
   * 调整 Canvas 尺寸
   */
  resize(): void {
    const rect = this.displayCanvas.getBoundingClientRect();

    // 设置显示 Canvas 尺寸
    this.displayCanvas.width = Math.round(rect.width * this.dpr);
    this.displayCanvas.height = Math.round(rect.height * this.dpr);

    // 设置离屏 Canvas 尺寸
    this.offscreenCanvas.width = this.displayCanvas.width;
    this.offscreenCanvas.height = this.displayCanvas.height;

    // 缩放上下文
    this.displayCtx.scale(this.dpr, this.dpr);
    this.offscreenCtx.scale(this.dpr, this.dpr);
  }

  /**
   * 获取离屏 Canvas 的上下文，用于绘制
   */
  getOffscreenContext(): CanvasRenderingContext2D {
    return this.offscreenCtx;
  }

  /**
   * 获取显示 Canvas 的尺寸（CSS 像素）
   */
  getSize(): { width: number; height: number } {
    const rect = this.displayCanvas.getBoundingClientRect();
    return { width: rect.width, height: rect.height };
  }

  /**
   * 将离屏 Canvas 的内容复制到显示 Canvas
   * 这是双缓冲的核心：一次性渲染，避免闪动
   */
  swapBuffers(): void {
    // 使用 putImageData 方法进行快速复制
    const imageData = this.offscreenCtx.getImageData(
      0,
      0,
      this.offscreenCanvas.width,
      this.offscreenCanvas.height,
    );
    this.displayCtx.putImageData(imageData, 0, 0);
    console.log("🔄 双缓冲交换完成，避免闪动");
  }

  /**
   * 清空离屏 Canvas
   */
  clearOffscreen(): void {
    const { width, height } = this.getSize();
    this.offscreenCtx.clearRect(0, 0, width, height);
  }

  /**
   * 销毁双缓冲 Canvas
   */
  destroy(): void {
    // 清理资源
    this.offscreenCanvas.remove();
  }
}

/**
 * 使用双缓冲技术绘制整个地图
 * 解决重绘时的闪动问题
 */
export async function drawMapWithDoubleBuffer(
  doubleBufferCanvas: DoubleBufferCanvas,
  mapData: CustomMapResp | null,
  stations: StationResp[],
  fences: PolygonFenceResp[],
  deviceCoordinates: Map<string, UWBFix>,
  onlineDevices: MarkOnline[],
  deviceNames: Map<string, string>,
  currentPolygon: Point[] = [],
  isDrawing: boolean = false,
): Promise<void> {
  const { width: cssWidth, height: cssHeight } = doubleBufferCanvas.getSize();
  const ctx = doubleBufferCanvas.getOffscreenContext();

  // 清空离屏 Canvas
  doubleBufferCanvas.clearOffscreen();

  // 如果没有地图数据，显示提示
  if (!mapData) {
    ctx.fillStyle = "#999";
    ctx.font = "16px Arial";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText("正在加载地图...", cssWidth / 2, cssHeight / 2);
    // 立即交换缓冲区显示提示
    doubleBufferCanvas.swapBuffers();
    return;
  }

  // 创建坐标转换器
  const scaler = new PixelScaler(
    cssWidth,
    cssHeight,
    mapData.x_min,
    mapData.x_max,
    mapData.y_min,
    mapData.y_max,
  );

  try {
    // 1. 绘制底图（作为最底层）
    if (mapData.image_url) {
      try {
        await drawBackgroundImage(ctx, mapData.image_url, cssWidth, cssHeight);
        console.log("✅ 底图加载成功:", mapData.image_url);
      } catch (error) {
        console.warn("⚠️ 底图加载失败，使用白色背景:", error);
        // 底图加载失败时使用白色背景
        ctx.fillStyle = "#ffffff";
        ctx.fillRect(0, 0, cssWidth, cssHeight);
      }
    } else {
      // 没有底图时使用白色背景
      ctx.fillStyle = "#ffffff";
      ctx.fillRect(0, 0, cssWidth, cssHeight);
    }

    // 2. 绘制网格 - 自动计算合适的网格间距
    const range = Math.max(mapData.x_max - mapData.x_min, mapData.y_max - mapData.y_min);
    // 根据范围自动计算网格间距（大约10-20个网格）
    let gridSpacing = Math.pow(10, Math.floor(Math.log10(range / 15)));
    if (range / gridSpacing > 25) gridSpacing *= 2;
    if (range / gridSpacing > 25) gridSpacing *= 2.5;
    console.log("网格间距:", gridSpacing, "坐标范围:", range);

    // 在底图上使用更明显的网格颜色
    drawGrid(ctx, scaler, gridSpacing, {
      color: mapData.image_url ? "rgba(0, 0, 0, 0.15)" : "#e0e0e0",
      lineWidth: 1,
    });

    // 3. 绘制坐标轴 - 在底图上使用更明显的颜色
    const axisFontSize = Math.max(10, Math.min(cssWidth, cssHeight) / 80);
    const axisColor = mapData.image_url ? "#000" : "#333";
    const textColor = mapData.image_url ? "#000" : "#333";

    drawAxisX(ctx, scaler, 10, {
      color: axisColor,
      lineWidth: 3,
      font: `${axisFontSize}px Arial`,
      textColor: textColor,
      arrowSize: 15,
    });
    drawAxisY(ctx, scaler, 10, {
      color: axisColor,
      lineWidth: 3,
      font: `${axisFontSize}px Arial`,
      textColor: textColor,
      arrowSize: 15,
    });
    console.log("🎯 坐标轴绘制在: X轴 y=0, Y轴 x=0 (画布中心)");

    // 4. 绘制电子围栏 - 根据地图范围自动调整
    const fenceLineWidth = Math.max(2, Math.min(cssWidth, cssHeight) / 300);
    const fenceFontSize = Math.max(12, Math.min(cssWidth, cssHeight) / 60);
    drawPolygonFences(ctx, scaler, fences, {
      strokeColor: "#3498db",
      fillColor: "rgba(68, 68, 255, 0.15)",
      lineWidth: fenceLineWidth,
      font: `${fenceFontSize}px Arial`,
    });

    // 5. 绘制基站 - 根据地图范围自动调整大小
    const baseSize = Math.max(16, Math.min(cssWidth, cssHeight) / 50);
    const baseFontSize = Math.max(12, Math.min(cssWidth, cssHeight) / 60);
    drawStations(ctx, scaler, stations, {
      color: "#3498db",
      size: baseSize,
      font: `${baseFontSize}px Arial`,
    });

    // 6. 绘制 UWB 设备坐标
    const deviceSize = Math.max(8, Math.min(cssWidth, cssHeight) / 150);
    const deviceFontSize = Math.max(10, Math.min(cssWidth, cssHeight) / 80);
    drawUWBDevices(ctx, scaler, deviceCoordinates, onlineDevices, deviceNames, {
      onlineColor: "#e74c3c",
      offlineColor: "#95a5a6",
      size: deviceSize,
      font: `${deviceFontSize}px Arial`,
      textColor: "#333",
      showTrail: false, // 可以根据需要开启轨迹显示
      trailLength: 10,
    });

    // 7. 绘制正在创建的多边形
    if (isDrawing && currentPolygon.length > 0) {
      drawCurrentPolygon(ctx, scaler, currentPolygon);
    }

    // 调试信息
    console.log("✅ Map drawn successfully with double buffer");
    console.log("📊 Canvas size:", cssWidth, "x", cssHeight);
    console.log("📍 Coordinate range:", {
      x: [mapData.x_min, mapData.x_max],
      y: [mapData.y_min, mapData.y_max],
    });
    console.log("🏢 Stations:", stations.length, "个");
    stations.forEach((station) => {
      const { px, py } = scaler.toPixel(station.coordinate_x, station.coordinate_y);
      console.log(
        `  - ${station.station_name}: 逻辑坐标(${station.coordinate_x}, ${station.coordinate_y}) → 像素(${px.toFixed(1)}, ${py.toFixed(1)})`,
      );
    });
    console.log("🚧 Fences:", fences.length, "个");
    console.log("📱 UWB Devices:", deviceCoordinates.size, "个");
    deviceCoordinates.forEach((uwbData, deviceId) => {
      const { px, py } = scaler.toPixel(uwbData.x, uwbData.y);
      const isOnline = onlineDevices.some((device) => device.id === deviceId && device.online);
      console.log(
        `  - ${deviceId}: UWB坐标(${uwbData.x}, ${uwbData.y}) → 像素(${px.toFixed(1)}, ${py.toFixed(1)}) [${isOnline ? "在线" : "离线"}]`,
      );
    });

    // 8. 关键步骤：一次性将离屏 Canvas 内容复制到显示 Canvas
    // 这避免了直接清空和重绘导致的闪动
    doubleBufferCanvas.swapBuffers();
  } catch (error) {
    console.error("Error drawing map with double buffer:", error);
  }
}

/**
 * 使用双缓冲技术绘制静态图层
 * 静态图层包含：底图、网格、坐标轴、电子围栏、基站
 */
export async function drawStaticLayerWithDoubleBuffer(
  doubleBufferCanvas: DoubleBufferCanvas,
  mapData: CustomMapResp | null,
  stations: StationResp[],
  fences: PolygonFenceResp[],
): Promise<void> {
  const { width: cssWidth, height: cssHeight } = doubleBufferCanvas.getSize();
  const ctx = doubleBufferCanvas.getOffscreenContext();

  // 清空离屏 Canvas（透明）
  doubleBufferCanvas.clearOffscreen();

  // 如果没有地图数据，显示提示
  if (!mapData) {
    ctx.fillStyle = "#999";
    ctx.font = "16px Arial";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText("正在加载地图...", cssWidth / 2, cssHeight / 2);
    doubleBufferCanvas.swapBuffers();
    return;
  }

  // 创建坐标转换器
  const scaler = new PixelScaler(
    cssWidth,
    cssHeight,
    mapData.x_min,
    mapData.x_max,
    mapData.y_min,
    mapData.y_max,
  );

  try {
    // 1. 绘制底图（作为最底层）
    if (mapData.image_url) {
      try {
        await drawBackgroundImage(ctx, mapData.image_url, cssWidth, cssHeight);
      } catch {
        ctx.fillStyle = "#ffffff";
        ctx.fillRect(0, 0, cssWidth, cssHeight);
      }
    } else {
      ctx.fillStyle = "#ffffff";
      ctx.fillRect(0, 0, cssWidth, cssHeight);
    }

    // 2. 绘制网格
    const range = Math.max(mapData.x_max - mapData.x_min, mapData.y_max - mapData.y_min);
    let gridSpacing = Math.pow(10, Math.floor(Math.log10(range / 15)));
    if (range / gridSpacing > 25) gridSpacing *= 2;
    if (range / gridSpacing > 25) gridSpacing *= 2.5;
    drawGrid(ctx, scaler, gridSpacing, {
      color: mapData.image_url ? "rgba(0, 0, 0, 0.15)" : "#e0e0e0",
      lineWidth: 1,
    });

    // 3. 坐标轴
    const axisFontSize = Math.max(10, Math.min(cssWidth, cssHeight) / 80);
    const axisColor = mapData.image_url ? "#000" : "#333";
    const textColor = mapData.image_url ? "#000" : "#333";
    drawAxisX(ctx, scaler, 10, {
      color: axisColor,
      lineWidth: 3,
      font: `${axisFontSize}px Arial`,
      textColor: textColor,
      arrowSize: 15,
    });
    drawAxisY(ctx, scaler, 10, {
      color: axisColor,
      lineWidth: 3,
      font: `${axisFontSize}px Arial`,
      textColor: textColor,
      arrowSize: 15,
    });

    // 4. 电子围栏
    const fenceLineWidth = Math.max(2, Math.min(cssWidth, cssHeight) / 300);
    const fenceFontSize = Math.max(12, Math.min(cssWidth, cssHeight) / 60);
    drawPolygonFences(ctx, scaler, fences, {
      strokeColor: "#3498db",
      fillColor: "rgba(68, 68, 255, 0.15)",
      lineWidth: fenceLineWidth,
      font: `${fenceFontSize}px Arial`,
    });

    // 5. 基站
    const baseSize = Math.max(16, Math.min(cssWidth, cssHeight) / 50);
    const baseFontSize = Math.max(12, Math.min(cssWidth, cssHeight) / 60);
    drawStations(ctx, scaler, stations, {
      color: "#3498db",
      size: baseSize,
      font: `${baseFontSize}px Arial`,
    });

    // 交换缓冲区
    doubleBufferCanvas.swapBuffers();
  } catch (error) {
    console.error("Error drawing static layer:", error);
  }
}

/**
 * 使用双缓冲技术绘制动态图层
 * 动态图层包含：UWB 设备位置、正在绘制的多边形
 */
export async function drawDynamicLayerWithDoubleBuffer(
  doubleBufferCanvas: DoubleBufferCanvas,
  mapData: CustomMapResp | null,
  deviceCoordinates: Map<string, UWBFix>,
  onlineDevices: MarkOnline[],
  deviceNames: Map<string, string>,
  currentPolygon: Point[] = [],
  isDrawing: boolean = false,
): Promise<void> {
  const { width: cssWidth, height: cssHeight } = doubleBufferCanvas.getSize();
  const ctx = doubleBufferCanvas.getOffscreenContext();

  // 清空离屏 Canvas（透明）
  doubleBufferCanvas.clearOffscreen();

  // 没有地图数据就不绘制（保持透明）
  if (!mapData) {
    doubleBufferCanvas.swapBuffers();
    return;
  }

  // 坐标转换器
  const scaler = new PixelScaler(
    cssWidth,
    cssHeight,
    mapData.x_min,
    mapData.x_max,
    mapData.y_min,
    mapData.y_max,
  );

  try {
    // 设备
    const deviceSize = Math.max(8, Math.min(cssWidth, cssHeight) / 150);
    const deviceFontSize = Math.max(10, Math.min(cssWidth, cssHeight) / 80);
    drawUWBDevices(ctx, scaler, deviceCoordinates, onlineDevices, deviceNames, {
      onlineColor: "#e74c3c",
      offlineColor: "#95a5a6",
      size: deviceSize,
      font: `${deviceFontSize}px Arial`,
      textColor: "#333",
      showTrail: false,
      trailLength: 10,
    });

    // 绘制设备之间的连线和距离
    const connectionFontSize = Math.max(10, Math.min(cssWidth, cssHeight) / 100);
    drawDeviceConnections(ctx, scaler, deviceCoordinates, onlineDevices, deviceNames, {
      lineColor: "#3498db",
      lineWidth: 2,
      textColor: "#2c3e50",
      fontSize: `${connectionFontSize}px Arial`,
      backgroundColor: "rgba(255, 255, 255, 0.8)",
    });

    // 正在创建的多边形
    if (isDrawing && currentPolygon.length > 0) {
      drawCurrentPolygon(ctx, scaler, currentPolygon);
    }

    // 交换缓冲区
    doubleBufferCanvas.swapBuffers();
  } catch (error) {
    console.error("Error drawing dynamic layer:", error);
  }
}

/**
 * 绘制整个地图（保留原函数以兼容性）
 */
export async function drawMap(
  canvas: HTMLCanvasElement,
  mapData: CustomMapResp | null,
  stations: StationResp[],
  fences: PolygonFenceResp[],
  deviceCoordinates: Map<string, UWBFix>,
  onlineDevices: MarkOnline[],
  deviceNames: Map<string, string>,
  currentPolygon: Point[] = [],
  isDrawing: boolean = false,
): Promise<void> {
  if (!canvas) return;

  const rect = canvas.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;

  // 设置画布尺寸
  canvas.width = Math.round(rect.width * dpr);
  canvas.height = Math.round(rect.height * dpr);

  const ctx = canvas.getContext("2d")!;
  ctx.scale(dpr, dpr);

  const cssWidth = rect.width;
  const cssHeight = rect.height;

  // 清空画布
  ctx.clearRect(0, 0, cssWidth, cssHeight);

  // 如果没有地图数据，显示提示
  if (!mapData) {
    ctx.fillStyle = "#999";
    ctx.font = "16px Arial";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText("正在加载地图...", cssWidth / 2, cssHeight / 2);
    return;
  }

  // 创建坐标转换器
  const scaler = new PixelScaler(
    cssWidth,
    cssHeight,
    mapData.x_min,
    mapData.x_max,
    mapData.y_min,
    mapData.y_max,
  );

  try {
    // 1. 绘制底图（作为最底层）
    if (mapData.image_url) {
      try {
        await drawBackgroundImage(ctx, mapData.image_url, cssWidth, cssHeight);
        console.log("✅ 底图加载成功:", mapData.image_url);
      } catch (error) {
        console.warn("⚠️ 底图加载失败，使用白色背景:", error);
        // 底图加载失败时使用白色背景
        ctx.fillStyle = "#ffffff";
        ctx.fillRect(0, 0, cssWidth, cssHeight);
      }
    } else {
      // 没有底图时使用白色背景
      ctx.fillStyle = "#ffffff";
      ctx.fillRect(0, 0, cssWidth, cssHeight);
    }

    // 2. 绘制网格 - 自动计算合适的网格间距
    const range = Math.max(mapData.x_max - mapData.x_min, mapData.y_max - mapData.y_min);
    // 根据范围自动计算网格间距（大约10-20个网格）
    let gridSpacing = Math.pow(10, Math.floor(Math.log10(range / 15)));
    if (range / gridSpacing > 25) gridSpacing *= 2;
    if (range / gridSpacing > 25) gridSpacing *= 2.5;
    console.log("网格间距:", gridSpacing, "坐标范围:", range);

    // 在底图上使用更明显的网格颜色
    drawGrid(ctx, scaler, gridSpacing, {
      color: mapData.image_url ? "rgba(0, 0, 0, 0.15)" : "#e0e0e0",
      lineWidth: 1,
    });

    // 3. 绘制坐标轴 - 在底图上使用更明显的颜色
    const axisFontSize = Math.max(10, Math.min(cssWidth, cssHeight) / 80);
    const axisColor = mapData.image_url ? "#000" : "#333";
    const textColor = mapData.image_url ? "#000" : "#333";

    drawAxisX(ctx, scaler, 10, {
      color: axisColor,
      lineWidth: 3,
      font: `${axisFontSize}px Arial`,
      textColor: textColor,
      arrowSize: 15,
    });
    drawAxisY(ctx, scaler, 10, {
      color: axisColor,
      lineWidth: 3,
      font: `${axisFontSize}px Arial`,
      textColor: textColor,
      arrowSize: 15,
    });
    console.log("🎯 坐标轴绘制在: X轴 y=0, Y轴 x=0 (画布中心)");

    // 4. 绘制电子围栏 - 根据地图范围自动调整
    const fenceLineWidth = Math.max(2, Math.min(cssWidth, cssHeight) / 300);
    const fenceFontSize = Math.max(12, Math.min(cssWidth, cssHeight) / 60);
    drawPolygonFences(ctx, scaler, fences, {
      strokeColor: "#3498db",
      fillColor: "rgba(68, 68, 255, 0.15)",
      lineWidth: fenceLineWidth,
      font: `${fenceFontSize}px Arial`,
    });

    // 5. 绘制基站 - 根据地图范围自动调整大小
    const baseSize = Math.max(16, Math.min(cssWidth, cssHeight) / 50);
    const baseFontSize = Math.max(12, Math.min(cssWidth, cssHeight) / 60);
    drawStations(ctx, scaler, stations, {
      color: "#3498db",
      size: baseSize,
      font: `${baseFontSize}px Arial`,
    });

    // 6. 绘制 UWB 设备坐标
    const deviceSize = Math.max(8, Math.min(cssWidth, cssHeight) / 150);
    const deviceFontSize = Math.max(10, Math.min(cssWidth, cssHeight) / 80);
    drawUWBDevices(ctx, scaler, deviceCoordinates, onlineDevices, deviceNames, {
      onlineColor: "#e74c3c",
      offlineColor: "#95a5a6",
      size: deviceSize,
      font: `${deviceFontSize}px Arial`,
      textColor: "#333",
      showTrail: false, // 可以根据需要开启轨迹显示
      trailLength: 10,
    });

    // 7. 绘制正在创建的多边形
    if (isDrawing && currentPolygon.length > 0) {
      drawCurrentPolygon(ctx, scaler, currentPolygon);
    }

    // 调试信息
    console.log("✅ Map drawn successfully");
    console.log("📊 Canvas size:", cssWidth, "x", cssHeight);
    console.log("📍 Coordinate range:", {
      x: [mapData.x_min, mapData.x_max],
      y: [mapData.y_min, mapData.y_max],
    });
    console.log("🏢 Stations:", stations.length, "个");
    stations.forEach((station) => {
      const { px, py } = scaler.toPixel(station.coordinate_x, station.coordinate_y);
      console.log(
        `  - ${station.station_name}: 逻辑坐标(${station.coordinate_x}, ${station.coordinate_y}) → 像素(${px.toFixed(1)}, ${py.toFixed(1)})`,
      );
    });
    console.log("🚧 Fences:", fences.length, "个");
    console.log("📱 UWB Devices:", deviceCoordinates.size, "个");
    deviceCoordinates.forEach((uwbData, deviceId) => {
      const { px, py } = scaler.toPixel(uwbData.x, uwbData.y);
      const isOnline = onlineDevices.some((device) => device.id === deviceId && device.online);
      console.log(
        `  - ${deviceId}: UWB坐标(${uwbData.x}, ${uwbData.y}) → 像素(${px.toFixed(1)}, ${py.toFixed(1)}) [${isOnline ? "在线" : "离线"}]`,
      );
    });
  } catch (error) {
    console.error("Error drawing map:", error);
  }
}

/**
 * 计算两点间距离（厘米，内部计算单位）
 */
export function calculateDistance(
  point1: { x: number; y: number },
  point2: { x: number; y: number },
): number {
  const dx = point2.x - point1.x;
  const dy = point2.y - point1.y;
  return Math.sqrt(dx * dx + dy * dy);
}

/**
 * 绘制设备之间的连线和距离
 */
export function drawDeviceConnections(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  deviceCoordinates: Map<string, UWBFix>,
  onlineDevices: MarkOnline[],
  deviceNames: Map<string, string>,
  options: {
    lineColor?: string;
    lineWidth?: number;
    textColor?: string;
    fontSize?: string;
    backgroundColor?: string;
  } = {},
) {
  const {
    lineColor = "#3498db",
    lineWidth = 2,
    textColor = "#2c3e50",
    fontSize = "12px Arial",
    backgroundColor = "rgba(255, 255, 255, 0.8)",
  } = options;

  ctx.save();

  // 获取所有在线的设备坐标
  const onlineDeviceCoords: Array<{ id: string; x: number; y: number; name: string }> = [];

  deviceCoordinates.forEach((uwbData, deviceId) => {
    const isOnline = onlineDevices.some((device) => device.id === deviceId && device.online);
    if (isOnline) {
      const deviceName = deviceNames.get(deviceId) || "未知设备";
      onlineDeviceCoords.push({
        id: deviceId,
        x: uwbData.x,
        y: uwbData.y,
        name: deviceName,
      });
    }
  });

  // 如果设备数量少于2个，不需要绘制连线
  if (onlineDeviceCoords.length < 2) {
    ctx.restore();
    return;
  }

  // 绘制所有设备之间的连线
  for (let i = 0; i < onlineDeviceCoords.length; i++) {
    for (let j = i + 1; j < onlineDeviceCoords.length; j++) {
      const device1 = onlineDeviceCoords[i];
      const device2 = onlineDeviceCoords[j];

      // 计算像素坐标
      const { px: px1, py: py1 } = scaler.toPixel(device1.x, device1.y);
      const { px: px2, py: py2 } = scaler.toPixel(device2.x, device2.y);

      // 绘制连线
      ctx.strokeStyle = lineColor;
      ctx.lineWidth = lineWidth;
      ctx.setLineDash([5, 5]); // 虚线样式
      ctx.beginPath();
      ctx.moveTo(px1, py1);
      ctx.lineTo(px2, py2);
      ctx.stroke();
      ctx.setLineDash([]); // 重置为实线

      // 计算距离（米）
      const distance = calculateDistance(device1, device2);
      const distanceText = `${(distance / 100).toFixed(1)}m`;

      // 计算中点位置用于显示距离文本
      const midX = (px1 + px2) / 2;
      const midY = (py1 + py2) / 2;

      // 绘制距离文本背景
      ctx.font = fontSize;
      ctx.textAlign = "center";
      ctx.textBaseline = "middle";

      const textMetrics = ctx.measureText(distanceText);
      const textWidth = textMetrics.width;
      const textHeight = parseInt(fontSize) * 0.8;

      // 绘制背景矩形
      ctx.fillStyle = backgroundColor;
      ctx.fillRect(
        midX - textWidth / 2 - 4,
        midY - textHeight / 2 - 2,
        textWidth + 8,
        textHeight + 4,
      );

      // 绘制距离文本
      ctx.fillStyle = textColor;
      ctx.fillText(distanceText, midX, midY);
    }
  }

  ctx.restore();
}
