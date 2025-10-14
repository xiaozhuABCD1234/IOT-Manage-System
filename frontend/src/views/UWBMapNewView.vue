<script setup lang="ts">
import { onMounted, onUnmounted, ref } from "vue";
import { getLatestCustomMap } from "@/api/customMap";
import { listStations } from "@/api/station";
import { listPolygonFences, createPolygonFence, deletePolygonFence } from "@/api/polygonFence";
import type { CustomMapResp } from "@/types/customMap";
import type { StationResp } from "@/types/station";
import type { PolygonFenceResp, Point } from "@/types/polygonFence";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { toast } from "vue-sonner";
import { Plus, Loader2, Trash2 } from "lucide-vue-next";

// 数据存储
const mapData = ref<CustomMapResp | null>(null);
const stations = ref<StationResp[]>([]);
const fences = ref<PolygonFenceResp[]>([]);

// 绘制多边形的状态
const isDrawing = ref(false);
const currentPolygon = ref<Point[]>([]);
const fenceName = ref("");
const fenceDescription = ref("");
const isSaving = ref(false);

// 删除确认对话框状态
const showDeleteDialog = ref(false);
const fenceToDelete = ref<{ id: string; name: string } | null>(null);
const deletingFenceId = ref<string | null>(null);

/**
 * 像素坐标转换器
 */
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
 * 绘制底图
 */
function drawBackgroundImage(
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
 * 绘制网格
 */
function drawGrid(
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
function drawAxisX(
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

  const step = (scaler.x_max - scaler.x_min) / (ticks - 1);
  for (let i = 0; i < ticks; i++) {
    const x = scaler.x_min + i * step;
    const { px } = scaler.toPixel(x, 0);

    // 刻度线
    ctx.beginPath();
    ctx.moveTo(px, yAxisPx);
    ctx.lineTo(px, yAxisPx + tickLength);
    ctx.stroke();

    // 标签 - 格式化大数字
    const label = Math.abs(x) >= 1000 ? (x / 1000).toFixed(0) + "k" : x.toFixed(0);
    ctx.fillText(label, px, yAxisPx + tickLength + 4);
  }

  // X 轴标签
  ctx.font = "bold 14px Arial";
  ctx.fillText("X", scaler.pixelWidth - 25, yAxisPx - 20);

  ctx.restore();
}

/**
 * 绘制 Y 轴
 */
function drawAxisY(
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

  const step = (scaler.y_max - scaler.y_min) / (ticks - 1);
  for (let i = 0; i < ticks; i++) {
    const y = scaler.y_min + i * step;
    const { py } = scaler.toPixel(0, y);

    // 刻度线
    ctx.beginPath();
    ctx.moveTo(xAxisPx - tickLength, py);
    ctx.lineTo(xAxisPx, py);
    ctx.stroke();

    // 标签 - 格式化大数字
    const label = Math.abs(y) >= 1000 ? (y / 1000).toFixed(0) + "k" : y.toFixed(0);
    ctx.fillText(label, xAxisPx - tickLength - 4, py);
  }

  // Y 轴标签
  ctx.font = "bold 14px Arial";
  ctx.textAlign = "center";
  ctx.fillText("Y", xAxisPx + 20, 15);

  ctx.restore();
}

/**
 * 绘制基站（蓝色等边三角形）
 */
function drawStations(
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
function drawPolygonFences(
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
function drawCurrentPolygon(ctx: CanvasRenderingContext2D, scaler: PixelScaler, points: Point[]) {
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
 * 绘制整个地图
 */
async function drawMap() {
  const canvas = document.getElementById("uwb-map-canvas") as HTMLCanvasElement;
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
  if (!mapData.value) {
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
    mapData.value.x_min,
    mapData.value.x_max,
    mapData.value.y_min,
    mapData.value.y_max,
  );

  try {
    // 绘制白色背景（暂时替代底图）
    ctx.fillStyle = "#ffffff";
    ctx.fillRect(0, 0, cssWidth, cssHeight);

    // 1. 绘制底图（暂时注释掉用于测试）
    // await drawBackgroundImage(ctx, mapData.value.image_url, cssWidth, cssHeight);

    // 2. 绘制网格 - 自动计算合适的网格间距
    const range = Math.max(
      mapData.value.x_max - mapData.value.x_min,
      mapData.value.y_max - mapData.value.y_min,
    );
    // 根据范围自动计算网格间距（大约10-20个网格）
    let gridSpacing = Math.pow(10, Math.floor(Math.log10(range / 15)));
    if (range / gridSpacing > 25) gridSpacing *= 2;
    if (range / gridSpacing > 25) gridSpacing *= 2.5;
    console.log("网格间距:", gridSpacing, "坐标范围:", range);
    drawGrid(ctx, scaler, gridSpacing, { color: "#e0e0e0", lineWidth: 0.5 });

    // 3. 绘制坐标轴
    const axisFontSize = Math.max(10, Math.min(cssWidth, cssHeight) / 80);
    drawAxisX(ctx, scaler, 10, {
      color: "#333",
      lineWidth: 3,
      font: `${axisFontSize}px Arial`,
      arrowSize: 15,
    });
    drawAxisY(ctx, scaler, 10, {
      color: "#333",
      lineWidth: 3,
      font: `${axisFontSize}px Arial`,
      arrowSize: 15,
    });
    console.log("🎯 坐标轴绘制在: X轴 y=0, Y轴 x=0 (画布中心)");

    // 4. 绘制电子围栏 - 根据地图范围自动调整
    const fenceLineWidth = Math.max(2, Math.min(cssWidth, cssHeight) / 300);
    const fenceFontSize = Math.max(12, Math.min(cssWidth, cssHeight) / 60);
    drawPolygonFences(ctx, scaler, fences.value, {
      strokeColor: "#3498db",
      fillColor: "rgba(68, 68, 255, 0.15)",
      lineWidth: fenceLineWidth,
      font: `${fenceFontSize}px Arial`,
    });

    // 5. 绘制基站 - 根据地图范围自动调整大小
    const baseSize = Math.max(16, Math.min(cssWidth, cssHeight) / 50);
    const baseFontSize = Math.max(12, Math.min(cssWidth, cssHeight) / 60);
    drawStations(ctx, scaler, stations.value, {
      color: "#3498db",
      size: baseSize,
      font: `${baseFontSize}px Arial`,
    });

    // 6. 绘制正在创建的多边形
    if (isDrawing.value && currentPolygon.value.length > 0) {
      drawCurrentPolygon(ctx, scaler, currentPolygon.value);
    }

    // 调试信息
    console.log("✅ Map drawn successfully");
    console.log("📊 Canvas size:", cssWidth, "x", cssHeight);
    console.log("📍 Coordinate range:", {
      x: [mapData.value.x_min, mapData.value.x_max],
      y: [mapData.value.y_min, mapData.value.y_max],
    });
    console.log("🏢 Stations:", stations.value.length, "个");
    stations.value.forEach((station) => {
      const { px, py } = scaler.toPixel(station.coordinate_x, station.coordinate_y);
      console.log(
        `  - ${station.station_name}: 逻辑坐标(${station.coordinate_x}, ${station.coordinate_y}) → 像素(${px.toFixed(1)}, ${py.toFixed(1)})`,
      );
    });
    console.log("🚧 Fences:", fences.value.length, "个");
  } catch (error) {
    console.error("Error drawing map:", error);
  }
}

/**
 * 加载所有数据
 */
async function loadData() {
  try {
    console.log("开始加载数据...");

    // 并行加载所有数据
    const [mapRes, stationsRes, fencesRes] = await Promise.all([
      getLatestCustomMap(),
      listStations(),
      listPolygonFences(),
    ]);

    console.log("地图响应:", mapRes);
    console.log("基站响应:", stationsRes);
    console.log("围栏响应:", fencesRes);

    // 处理地图数据 - 检查 success 字段
    if (mapRes.data && mapRes.data.success && mapRes.data.data) {
      mapData.value = mapRes.data.data;
      console.log("✅ 地图数据加载成功:", mapData.value);
    } else {
      console.error("❌ 地图数据加载失败:", mapRes.data?.message || mapRes);
    }

    // 处理基站数据 - 检查 success 字段
    if (stationsRes.data && stationsRes.data.success && stationsRes.data.data) {
      stations.value = stationsRes.data.data;
      console.log("✅ 基站数据加载成功，数量:", stations.value.length);
    } else {
      console.error("❌ 基站数据加载失败:", stationsRes.data?.message || stationsRes);
      stations.value = [];
    }

    // 处理围栏数据 - 检查 success 字段
    if (fencesRes.data && fencesRes.data.success && fencesRes.data.data) {
      fences.value = fencesRes.data.data;
      console.log("✅ 围栏数据加载成功，数量:", fences.value.length);
    } else {
      console.error("❌ 围栏数据加载失败:", fencesRes.data?.message || fencesRes);
      fences.value = [];
    }

    // 加载完成后绘制地图
    console.log("准备绘制地图...");
    await drawMap();
  } catch (error) {
    console.error("❌ 加载数据时发生错误:", error);
  }
}

/**
 * 处理canvas点击事件 - 添加多边形顶点
 */
function handleCanvasClick(event: MouseEvent) {
  if (!isDrawing.value || !mapData.value) return;

  const canvas = event.target as HTMLCanvasElement;
  const rect = canvas.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;

  // 计算像素坐标
  const px = event.clientX - rect.left;
  const py = event.clientY - rect.top;

  // 创建坐标转换器
  const scaler = new PixelScaler(
    rect.width,
    rect.height,
    mapData.value.x_min,
    mapData.value.x_max,
    mapData.value.y_min,
    mapData.value.y_max,
  );

  // 转换为逻辑坐标
  const { x, y } = scaler.toXY(px, py);

  // 添加点到当前多边形
  currentPolygon.value.push({ x: Math.round(x), y: Math.round(y) });

  console.log("添加新点:", { x: Math.round(x), y: Math.round(y) });
  console.log("当前顶点数:", currentPolygon.value.length);

  // 重新绘制
  drawMap();

  // 滚动到底部以显示新添加的点
  setTimeout(() => {
    const pointsList = document.querySelector(".points-list-container");
    if (pointsList) {
      pointsList.scrollTop = pointsList.scrollHeight;
    }
  }, 100);
}

/**
 * 开始绘制多边形
 */
function startDrawing() {
  isDrawing.value = true;
  currentPolygon.value = [];
  fenceName.value = "";
  fenceDescription.value = "";
}

/**
 * 取消绘制
 */
function cancelDrawing() {
  isDrawing.value = false;
  currentPolygon.value = [];
  drawMap();
}

/**
 * 删除指定的点
 */
function removePoint(index: number) {
  currentPolygon.value.splice(index, 1);
  drawMap();
}

/**
 * 更新点的坐标
 */
function updatePoint(index: number, axis: "x" | "y", value: string) {
  const numValue = parseFloat(value);
  if (!isNaN(numValue)) {
    currentPolygon.value[index][axis] = Math.round(numValue);
    console.log(`更新点 ${index + 1} 的 ${axis} 坐标为: ${Math.round(numValue)}`);
    drawMap();
  }
}

/**
 * 打开删除确认对话框
 */
function openDeleteDialog(fenceId: string, fenceName: string) {
  fenceToDelete.value = { id: fenceId, name: fenceName };
  showDeleteDialog.value = true;
}

/**
 * 确认删除围栏
 */
async function confirmDeleteFence() {
  if (!fenceToDelete.value) return;

  const { id, name } = fenceToDelete.value;
  deletingFenceId.value = id;
  showDeleteDialog.value = false;

  try {
    const res = await deletePolygonFence(id);

    if (res.data && res.data.success) {
      toast.success("删除成功", {
        description: `围栏"${name}"已被删除`,
      });

      // 重新加载围栏列表
      const fencesRes = await listPolygonFences();
      if (fencesRes.data && fencesRes.data.success && fencesRes.data.data) {
        fences.value = fencesRes.data.data;
      }

      // 重新绘制地图
      await drawMap();
    } else {
      toast.error("删除失败", {
        description: res.data?.message || "未知错误",
      });
    }
  } catch (error) {
    console.error("Error deleting fence:", error);
    toast.error("删除围栏时发生错误", {
      description: "请检查网络连接后重试",
    });
  } finally {
    deletingFenceId.value = null;
    fenceToDelete.value = null;
  }
}

/**
 * 完成绘制并保存围栏
 */
async function finishDrawing() {
  if (currentPolygon.value.length < 3) {
    toast.error("多边形至少需要3个顶点", {
      description: "请在地图上继续添加更多顶点",
    });
    return;
  }

  if (!fenceName.value.trim()) {
    toast.error("请输入围栏名称", {
      description: "围栏名称是必填项",
    });
    return;
  }

  isSaving.value = true;

  try {
    const res = await createPolygonFence({
      fence_name: fenceName.value,
      points: currentPolygon.value,
      description: fenceDescription.value,
    });

    if (res.data && res.data.success) {
      toast.success("围栏创建成功", {
        description: `围栏"${fenceName.value}"已成功创建`,
      });
      // 重新加载围栏列表
      const fencesRes = await listPolygonFences();
      if (fencesRes.data && fencesRes.data.success && fencesRes.data.data) {
        fences.value = fencesRes.data.data;
      }
      // 清空当前绘制
      cancelDrawing();
    } else {
      toast.error("创建失败", {
        description: res.data?.message || "未知错误",
      });
    }
  } catch (error) {
    console.error("Error creating fence:", error);
    toast.error("创建围栏时发生错误", {
      description: "请检查网络连接后重试",
    });
  } finally {
    isSaving.value = false;
  }
}

// ResizeObserver 实例
let resizeObserver: ResizeObserver | null = null;

// 组件挂载时加载数据
onMounted(() => {
  console.log("Component mounted, loading data...");
  loadData();

  // 监听窗口大小变化，重新绘制
  window.addEventListener("resize", drawMap);

  // 监听 canvas 容器大小变化（用于 Resizable 面板调整）
  const canvas = document.getElementById("uwb-map-canvas");
  if (canvas) {
    resizeObserver = new ResizeObserver(() => {
      console.log("Canvas size changed, redrawing...");
      // 使用 requestAnimationFrame 确保在下一帧重绘
      requestAnimationFrame(() => {
        drawMap();
      });
    });
    resizeObserver.observe(canvas);
  }
});

// 组件卸载时清理
onUnmounted(() => {
  window.removeEventListener("resize", drawMap);
  if (resizeObserver) {
    resizeObserver.disconnect();
    resizeObserver = null;
  }
});
</script>

<template>
  <div class="h-full w-full bg-gray-50 p-4">
    <ResizablePanelGroup direction="horizontal" class="h-full rounded-lg border">
      <!-- 左侧：地图画布 -->
      <ResizablePanel :default-size="65" :min-size="30">
        <div class="flex h-full items-center justify-center">
          <canvas
            id="uwb-map-canvas"
            class="h-full w-full rounded-lg border-2 border-gray-300 shadow-lg"
            :class="{ 'cursor-crosshair': isDrawing }"
            @click="handleCanvasClick"
          />
        </div>
      </ResizablePanel>

      <!-- 分隔条 -->
      <ResizableHandle with-handle />

      <!-- 右侧：控制面板 -->
      <ResizablePanel :default-size="35" :min-size="25">
        <Card class="h-full rounded-none border-0">
          <CardHeader>
            <CardTitle>电子围栏绘制</CardTitle>
          </CardHeader>
          <CardContent class="h-[calc(100%-80px)]">
            <ScrollArea class="h-full pr-4">
              <div class="space-y-4">
                <!-- 绘制控制 -->
                <div v-if="!isDrawing" class="space-y-2">
                  <Button class="w-full" @click="startDrawing">
                    <Plus class="mr-2 h-4 w-4" />
                    开始绘制围栏
                  </Button>
                  <p class="text-muted-foreground text-sm">
                    点击"开始绘制围栏"按钮，然后在地图上点击以添加多边形顶点
                  </p>
                </div>

                <!-- 绘制中 -->
                <div v-else class="space-y-4">
                  <div class="rounded-lg bg-orange-50 p-3 text-sm text-orange-800">
                    <p class="font-semibold">绘制模式已激活</p>
                    <p class="mt-1">点击地图添加顶点，至少需要3个顶点才能完成</p>
                  </div>

                  <!-- 围栏名称 -->
                  <div class="space-y-2">
                    <Label for="fence-name">围栏名称 *</Label>
                    <Input id="fence-name" v-model="fenceName" placeholder="例如：区域A" />
                  </div>

                  <!-- 围栏描述 -->
                  <div class="space-y-2">
                    <Label for="fence-description">描述（可选）</Label>
                    <Input
                      id="fence-description"
                      v-model="fenceDescription"
                      placeholder="围栏用途说明"
                    />
                  </div>

                  <!-- 顶点列表 -->
                  <div class="space-y-2">
                    <Label>多边形顶点 ({{ currentPolygon.length }}个)</Label>
                    <div v-if="currentPolygon.length === 0" class="text-muted-foreground text-sm">
                      暂无顶点，点击地图添加
                    </div>
                    <div v-else class="points-list-container max-h-96 space-y-2 overflow-y-auto">
                      <div
                        v-for="(point, index) in currentPolygon"
                        :key="`point-${index}-${point.x}-${point.y}`"
                        class="flex items-center gap-2 rounded-lg border bg-white p-2"
                      >
                        <span class="w-6 text-center font-semibold text-orange-600">
                          {{ index + 1 }}
                        </span>
                        <div class="flex-1 space-y-1">
                          <div class="flex items-center gap-2">
                            <Label class="w-6 text-xs">X:</Label>
                            <Input
                              :model-value="point.x"
                              type="number"
                              class="h-8 text-sm"
                              @update:model-value="(val) => updatePoint(index, 'x', String(val))"
                            />
                          </div>
                          <div class="flex items-center gap-2">
                            <Label class="w-6 text-xs">Y:</Label>
                            <Input
                              :model-value="point.y"
                              type="number"
                              class="h-8 text-sm"
                              @update:model-value="(val) => updatePoint(index, 'y', String(val))"
                            />
                          </div>
                        </div>
                        <Button variant="destructive" size="sm" @click="removePoint(index)">
                          删除
                        </Button>
                      </div>
                    </div>
                  </div>

                  <!-- 操作按钮 -->
                  <div class="flex gap-2">
                    <Button
                      class="flex-1"
                      variant="default"
                      :disabled="currentPolygon.length < 3 || !fenceName.trim() || isSaving"
                      @click="finishDrawing"
                    >
                      <Loader2 v-if="isSaving" class="mr-2 h-4 w-4 animate-spin" />
                      {{ isSaving ? "保存中..." : "完成并保存" }}
                    </Button>
                    <Button
                      class="flex-1"
                      variant="outline"
                      :disabled="isSaving"
                      @click="cancelDrawing"
                    >
                      取消
                    </Button>
                  </div>
                </div>

                <!-- 已有围栏列表 -->
                <div class="mt-6 space-y-2">
                  <Label>已有围栏 ({{ fences.length }}个)</Label>
                  <div v-if="fences.length === 0" class="text-muted-foreground text-sm">
                    暂无围栏
                  </div>
                  <div v-else class="space-y-2">
                    <div
                      v-for="fence in fences"
                      :key="fence.id"
                      class="rounded-lg border bg-white p-3"
                    >
                      <div class="flex items-center justify-between gap-2">
                        <div class="flex-1">
                          <p class="font-semibold">{{ fence.fence_name }}</p>
                          <p class="text-muted-foreground text-xs">
                            {{ fence.points.length }} 个顶点
                            <span v-if="fence.is_active" class="text-blue-600">· 已激活</span>
                            <span v-else class="text-gray-400">· 未激活</span>
                          </p>
                        </div>
                        <Button
                          variant="destructive"
                          size="sm"
                          :disabled="deletingFenceId === fence.id"
                          @click="openDeleteDialog(fence.id, fence.fence_name)"
                        >
                          <Loader2
                            v-if="deletingFenceId === fence.id"
                            class="mr-2 h-4 w-4 animate-spin"
                          />
                          <Trash2 v-else class="h-4 w-4" />
                          {{ deletingFenceId === fence.id ? "删除中..." : "删除" }}
                        </Button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </ScrollArea>
          </CardContent>
        </Card>
      </ResizablePanel>
    </ResizablePanelGroup>

    <!-- 删除确认对话框 -->
    <AlertDialog v-model:open="showDeleteDialog">
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>确定要删除这个围栏吗？</AlertDialogTitle>
          <AlertDialogDescription>
            此操作无法撤销。将永久删除围栏"{{ fenceToDelete?.name }}"及其所有数据。
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>取消</AlertDialogCancel>
          <AlertDialogAction
            class="bg-destructive hover:bg-destructive/90"
            @click="confirmDeleteFence"
          >
            删除
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  </div>
</template>
