<script setup lang="ts">
import {
  onMounted,
  onUnmounted,
  type PropType,
  reactive,
  ref,
  watch,
} from "vue";

type TrailPoint = {
  x: number;
  y: number;
  id: string | number;
  color?: string;
};

const props = defineProps({
  points: {
    type: Array as PropType<TrailPoint[]>,
    required: true,
    validator: (val: unknown[]) =>
      val.every((p) =>
        p !== null && typeof p === "object" && "id" in p && "x" in p && "y" in p
      ),
  },
  trailLength: {
    type: Number,
    default: 50,
  },
  pointSize: {
    type: Number,
    default: 15,
  },
  showGrid: {
    type: Boolean,
    default: true,
  },
  gridStep: {
    type: Number,
    default: 10,
    validator: (v: number) => v > 0,
  },
  initialXRange: {
    type: Object as PropType<{ min: number; max: number }>,
    default: () => ({ min: 0, max: 20 }),
  },
  initialYRange: {
    type: Object as PropType<{ min: number; max: number }>,
    default: () => ({ min: 0, max: 20 }),
  },
});

const canvasRef = ref<HTMLCanvasElement | null>(null);
const trails = reactive(
  new Map<string | number, Array<{ x: number; y: number }>>(),
);

const transformState = reactive({
  scale: 1,
  offset: { x: 0, y: 0 },
  dragStart: { x: 0, y: 0 },
  isDragging: false,
});

let animationFrameId: number | null = null;

const calculateInitialView = () => {
  const container = canvasRef.value?.parentElement;
  if (!container) return;

  const canvasWidth = container.clientWidth;
  const canvasHeight = container.clientHeight;

  const xRange = props.initialXRange.max - props.initialXRange.min;
  const yRange = props.initialYRange.max - props.initialYRange.min;

  const scaleX = canvasWidth / xRange;
  const scaleY = canvasHeight / yRange;
  const newScale = Math.min(scaleX, scaleY) * 0.9;

  const centerX = (props.initialXRange.min + props.initialXRange.max) / 2;
  const centerY = (props.initialYRange.min + props.initialYRange.max) / 2;

  transformState.scale = newScale;
  transformState.offset.x = -centerX * newScale;
  // 调整初始y轴偏移，适应正常y轴方向
  transformState.offset.y = -centerY * newScale;
};

const autoGridStep = () => {
  const baseStep = props.gridStep;
  const scale = transformState.scale;
  if (scale <= 0.001) return baseStep * 100000;
  if (scale <= 0.005) return baseStep * 50000;
  if (scale <= 0.01) return baseStep * 1000;
  if (scale <= 0.1) return baseStep * 100;
  if (scale <= 0.5) return baseStep * 10;
  if (scale <= 1) return baseStep * 5;
  if (scale <= 5) return baseStep * 2;
  if (scale <= 10) return baseStep;
  if (scale <= 20) return baseStep / 2;
  if (scale <= 50) return baseStep / 5;
  if (scale <= 100) return baseStep / 10;
  if (scale <= 500) return baseStep / 50;
  if (scale <= 1000) return baseStep / 100;
  return baseStep / 1000;
};


// 修改后的 idToColor 函数
const idToColor = (id: string | number) => {
  const str = String(id);
  let hash = 0;

  // 改进的乘法哈希算法
  for (let i = 0; i < str.length; i++) {
    hash = (hash << 5) - hash + str.charCodeAt(i);
    hash |= 0; // 转换为32位整数
  }

  // 增强色相分布 (0-360度)
  const hue = ((hash * 137.5) % 360 + 360) % 360; // 使用黄金角增强分布

  // 提高饱和度 (80-95%)
  const saturation = 80 + (hash % 16);

  // 优化亮度范围 (60-75%)
  const lightness = 60 + (hash % 16);

  return `hsl(${hue}, ${saturation}%, ${lightness}%)`;
};

const drawGrid = (ctx: CanvasRenderingContext2D, width: number, height: number) => {
  ctx.save();
  ctx.strokeStyle = 'rgba(220, 220, 220, 0.8)';
  ctx.lineWidth = 0.5 / transformState.scale;

  // 动态计算网格步长
  const step = autoGridStep();

  // 计算可见区域（增加10%余量）
  const visibleWidth = width / transformState.scale * 1.1;
  const visibleHeight = height / transformState.scale * 1.1;

  // 计算网格起止坐标
  const startX = Math.floor(
    (-visibleWidth / 2 - transformState.offset.x / transformState.scale) / step,
  ) * step;
  const endX = Math.ceil(
    (visibleWidth / 2 - transformState.offset.x / transformState.scale) / step,
  ) * step;
  const startY = Math.floor(
    (-visibleHeight / 2 - transformState.offset.y / transformState.scale) /
    step,
  ) * step;
  const endY = Math.ceil(
    (visibleHeight / 2 - transformState.offset.y / transformState.scale) / step,
  ) * step;

  // 网格密度保护机制
  const xGridCount = (endX - startX) / step;
  const yGridCount = (endY - startY) / step;
  if (xGridCount > 200 || yGridCount > 200) {
    console.warn("Grid density exceeds safety limit, skipping drawing");
    ctx.restore();
    return;
  }

  // 绘制主网格
  ctx.strokeStyle = 'rgba(220, 220, 220, 0.8)';
  for (let x = startX; x <= endX; x += step) {
    ctx.beginPath();
    ctx.moveTo(x, startY);
    ctx.lineTo(x, endY);
    ctx.stroke();
  }
  for (let y = startY; y <= endY; y += step) {
    ctx.beginPath();
    ctx.moveTo(startX, y);
    ctx.lineTo(endX, y);
    ctx.stroke();
  }

  // 智能子网格绘制
  if (transformState.scale > 5) {
    const subStep = step / (transformState.scale > 20 ? 10 : 5);
    ctx.strokeStyle = 'rgba(240, 240, 240, 0.8)';
    ctx.lineWidth = 0.3 / transformState.scale;

    for (let x = startX; x <= endX; x += subStep) {
      if (Math.abs(x % step) < 0.001) continue;
      ctx.beginPath();
      ctx.moveTo(x, startY);
      ctx.lineTo(x, endY);
      ctx.stroke();
    }
    for (let y = startY; y <= endY; y += subStep) {
      if (Math.abs(y % step) < 0.001) continue;
      ctx.beginPath();
      ctx.moveTo(startX, y);
      ctx.lineTo(endX, y);
      ctx.stroke();
    }
  }

  ctx.restore();
};

const drawAxes = (ctx: CanvasRenderingContext2D, width: number, height: number) => {
  ctx.save();
  ctx.strokeStyle = 'black';
  ctx.lineWidth = 1.5 / transformState.scale;

  // 计算可见区域（与drawGrid保持一致）
  const visibleWidth = width / transformState.scale * 1.1;
  const visibleHeight = height / transformState.scale * 1.1;

  // 独立计算轴范围
  const axisStartX = -visibleWidth / 2 -
    transformState.offset.x / transformState.scale;
  const axisEndX = visibleWidth / 2 -
    transformState.offset.x / transformState.scale;
  const axisStartY = -visibleHeight / 2 -
    transformState.offset.y / transformState.scale;
  const axisEndY = visibleHeight / 2 -
    transformState.offset.y / transformState.scale;

  // 绘制X轴
  ctx.beginPath();
  ctx.moveTo(axisStartX, 0);
  ctx.lineTo(axisEndX, 0);
  ctx.stroke();

  // X轴箭头
  const arrowSize = 12 / transformState.scale;
  ctx.beginPath();
  ctx.moveTo(axisEndX - arrowSize, -arrowSize / 2);
  ctx.lineTo(axisEndX, 0);
  ctx.lineTo(axisEndX - arrowSize, arrowSize / 2);
  ctx.fill();

  // 绘制Y轴
  ctx.beginPath();
  ctx.moveTo(0, axisStartY);
  ctx.lineTo(0, axisEndY);
  ctx.stroke();

  // Y轴箭头（调整方向以适应正常y轴）
  ctx.beginPath();
  ctx.moveTo(-arrowSize / 2, axisEndY);
  ctx.lineTo(0, axisEndY - arrowSize);
  ctx.lineTo(arrowSize / 2, axisEndY);
  ctx.fill();

  // 动态计算标签参数
  const step = autoGridStep();
  const minLabelSpacing = 80; // 像素单位
  const labelPrecision = Math.max(0, Math.floor(2 - Math.log10(step)));
  ctx.font = '12px Arial';
  ctx.fillStyle = 'black';
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';

  // 绘制X轴刻度标签
  let lastScreenX = -Infinity;
  for (let x = Math.floor(axisStartX / step) * step; x <= axisEndX; x += step) {
    if (Math.abs(x) < 1e-6) continue; // 跳过原点

    // 转换到屏幕坐标
    const screenX = width / 2 + transformState.offset.x +
      x * transformState.scale;
    const screenY = height / 2 + transformState.offset.y;

    // 密度控制
    if (Math.abs(screenX - lastScreenX) < minLabelSpacing) continue;

    // 绘制刻度线
    ctx.beginPath();
    ctx.moveTo(x, 0);
    ctx.lineTo(x, arrowSize / 2 / transformState.scale);
    ctx.stroke();

    // 绘制标签
    ctx.save();
    ctx.resetTransform();
    ctx.fillText(x.toFixed(labelPrecision), screenX, screenY);
    ctx.restore();

    lastScreenX = screenX;
  }

  // 绘制Y轴刻度标签
  let lastScreenY = -Infinity;
  for (let y = Math.floor(axisStartY / step) * step; y <= axisEndY; y += step) {
    if (Math.abs(y) < 1e-6) continue;

    // 修复：使用正确的y轴坐标计算公式
    const screenX = width / 2 + transformState.offset.x;
    // 修改前（错误）：
    // const screenY = height / 2 + transformState.offset.y - y * transformState.scale;
    // 修改后（正确）：
    const screenY = height / 2 + transformState.offset.y + y * transformState.scale;
    if (Math.abs(screenY - lastScreenY) < minLabelSpacing) continue;

    // 绘制刻度线
    ctx.beginPath();
    ctx.moveTo(0, y);
    ctx.lineTo(arrowSize / 2 / transformState.scale, y);
    ctx.stroke();

    // 绘制标签
    ctx.save();
    ctx.resetTransform();
    ctx.fillText(y.toFixed(labelPrecision), screenX, screenY);
    ctx.restore();

    lastScreenY = screenY;
  }

  // 绘制原点标签（智能避让）
  ctx.save();
  ctx.resetTransform();
  const originScreenX = width / 2 + transformState.offset.x;
  const originScreenY = height / 2 + transformState.offset.y;
  // 检查是否与其他标签重叠
  if (
    Math.abs(originScreenX - lastScreenX) > 20 &&
    Math.abs(originScreenY - lastScreenY) > 20
  ) {
    ctx.fillText("0", originScreenX, originScreenY);
  }
  ctx.restore();

  ctx.restore();
};

const drawTrails = (ctx: CanvasRenderingContext2D, width: number, height: number) => {
  trails.forEach((points, id) => {
    const color = props.points.find((p) => p.id === id)?.color ||
      idToColor(id);

    // 绘制轨迹线
    ctx.save();
    ctx.strokeStyle = color;
    ctx.lineWidth = 2 / transformState.scale;
    ctx.beginPath();

    if (points.length > 0) {
      ctx.moveTo(points[0].x, points[0].y);
      for (let i = 1; i < points.length; i++) {
        ctx.lineTo(points[i].x, points[i].y);
      }
    }

    ctx.stroke();
    ctx.restore();

    // 绘制当前点
    const currentPoint = props.points.find((p) => p.id === id);
    if (currentPoint) {
      ctx.save();
      ctx.fillStyle = color;
      ctx.beginPath();
      ctx.arc(
        currentPoint.x,
        currentPoint.y,
        props.pointSize / 2 / transformState.scale,
        0,
        2 * Math.PI
      );
      ctx.fill();

      // 添加ID标签
      ctx.save();
      ctx.resetTransform();

      // 转换到屏幕坐标（调整y轴计算）
      const screenX = width / 2 + transformState.offset.x +
        currentPoint.x * transformState.scale;
      const screenY = height / 2 + transformState.offset.y -
        currentPoint.y * transformState.scale;

      ctx.fillStyle = color;
      ctx.font = `${12 / transformState.scale}px Arial`;
      ctx.textAlign = 'left';
      ctx.textBaseline = 'middle';
      ctx.fillText(
        String(id),
        screenX + 8 / transformState.scale,
        screenY
      );
      ctx.restore();

      ctx.restore();
    }
  });
};

const renderCanvas = () => {
  const canvas = canvasRef.value;
  if (!canvas) return;

  const ctx = canvas.getContext('2d');
  if (!ctx) return;

  // 清除画布
  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // 应用变换（移除y轴负缩放）
  ctx.save();
  ctx.translate(
    canvas.width / 2 + transformState.offset.x,
    canvas.height / 2 + transformState.offset.y
  );
  ctx.scale(transformState.scale, transformState.scale); // 两个方向都使用正缩放

  // 绘制背景
  ctx.fillStyle = 'white';
  ctx.fillRect(-canvas.width, -canvas.height, canvas.width * 2, canvas.height * 2);

  // 绘制网格和坐标轴
  if (props.showGrid) drawGrid(ctx, canvas.width, canvas.height);
  drawAxes(ctx, canvas.width, canvas.height);

  // 绘制轨迹
  drawTrails(ctx, canvas.width, canvas.height);

  ctx.restore();

  // 继续动画循环
  animationFrameId = requestAnimationFrame(renderCanvas);
};

// 在setup函数中添加canvas事件监听
const setupCanvasEvents = () => {
  const canvas = canvasRef.value;
  if (!canvas) return;

  // 阻止所有默认的触摸行为
  canvas.addEventListener("touchstart", (e) => {
    if (e.target === canvas) e.preventDefault();
  }, { passive: false });

  canvas.addEventListener("touchmove", (e) => {
    if (e.target === canvas) e.preventDefault();
  }, { passive: false });

  // 鼠标拖拽
  canvas.addEventListener("mousedown", (e) => {
    // 只在画布范围内响应
    if (e.offsetX < 0 || e.offsetX > canvas.width ||
      e.offsetY < 0 || e.offsetY > canvas.height) return;

    transformState.isDragging = true;
    transformState.dragStart.x = e.offsetX;
    transformState.dragStart.y = e.offsetY;
  });

  canvas.addEventListener("mousemove", (e) => {
    if (transformState.isDragging) {
      // 添加边界检查
      const MAX_OFFSET = 1000; // 根据实际需求调整
      transformState.offset.x = Math.min(
        Math.max(transformState.offset.x + (e.offsetX - transformState.dragStart.x), -MAX_OFFSET),
        MAX_OFFSET
      );
      transformState.offset.y = Math.min(
        Math.max(transformState.offset.y + (e.offsetY - transformState.dragStart.y), -MAX_OFFSET),
        MAX_OFFSET
      );

      transformState.dragStart.x = e.offsetX;
      transformState.dragStart.y = e.offsetY;
    }
  });

  window.addEventListener("mouseup", () => {
    transformState.isDragging = false;
  });

  // 鼠标滚轮缩放
  canvas.addEventListener("wheel", (e) => {
    e.preventDefault();

    // 只在画布范围内响应
    if (e.offsetX < 0 || e.offsetX > canvas.width ||
      e.offsetY < 0 || e.offsetY > canvas.height) return;

    const zoomIntensity = 0.1;
    const delta = e.deltaY > 0 ? 1 : -1;
    const zoomFactor = delta > 0 ? 1 - zoomIntensity : 1 + zoomIntensity;

    // 修改这行代码，调整缩放最小值和最大值
    const newScale = Math.min(
      Math.max(transformState.scale * zoomFactor, 1),
      2000
    );

    // 计算鼠标在世界坐标系中的位置（调整y轴计算）
    const mouseX = (e.offsetX - canvas.width / 2 - transformState.offset.x) / transformState.scale;
    const mouseY = (e.offsetY - canvas.height / 2 - transformState.offset.y) / transformState.scale;

    // 调整偏移量，使鼠标指向的世界坐标点保持不变
    transformState.offset.x = e.offsetX - canvas.width / 2 - mouseX * newScale;
    transformState.offset.y = e.offsetY - canvas.height / 2 - mouseY * newScale;
    transformState.scale = newScale;
  });

  // 窗口大小调整
  window.addEventListener("resize", () => {
    resizeCanvas();
  });
};

const resizeCanvas = () => {
  const canvas = canvasRef.value;
  if (!canvas) return;

  const container = canvas.parentElement;
  if (!container) return;

  // 设置canvas的显示尺寸
  canvas.style.width = '100%';
  canvas.style.height = '100%';

  // 获取显示尺寸（CSS像素）
  const displayWidth = container.clientWidth;
  const displayHeight = container.clientHeight;

  // 考虑设备像素比，避免模糊
  const dpr = window.devicePixelRatio || 1;

  // 设置canvas元素的实际尺寸
  canvas.width = displayWidth * dpr;
  canvas.height = displayHeight * dpr;

  // 调整上下文的缩放以匹配设备像素比
  const ctx = canvas.getContext('2d');
  if (ctx) {
    ctx.scale(dpr, dpr);
  }

  // 重新渲染
  renderCanvas();
};

watch(
  () => props.points,
  (newPoints) => {
    newPoints.forEach((point) => {
      if (!trails.has(point.id)) {
        trails.set(point.id, []);
      }

      const trail = trails.get(point.id)!;
      trail.push({ x: point.x, y: point.y });

      if (trail.length > props.trailLength) {
        trail.splice(0, trail.length - props.trailLength);
      }
    });

    const existingIds = new Set(newPoints.map((p) => p.id));
    Array.from(trails.keys()).forEach((id) => {
      if (!existingIds.has(id)) {
        trails.delete(id);
      }
    });
  },
  { deep: true }
);

onMounted(() => {
  if (!canvasRef.value) return;

  // 设置画布尺寸
  resizeCanvas();

  // 计算初始视图
  calculateInitialView();

  // 设置事件监听
  setupCanvasEvents();

  // 开始渲染循环
  renderCanvas();
});

onUnmounted(() => {
  // 清除动画帧
  if (animationFrameId) {
    cancelAnimationFrame(animationFrameId);
  }

  // 移除事件监听
  const canvas = canvasRef.value;
  if (canvas) {
    canvas.removeEventListener("touchstart", () => { });
    canvas.removeEventListener("touchmove", () => { });
    canvas.removeEventListener("mousedown", () => { });
    canvas.removeEventListener("mousemove", () => { });
    canvas.removeEventListener("wheel", () => { });
  }

  window.removeEventListener("mouseup", () => { });
  window.removeEventListener("resize", () => { });
});
</script>

<template>
  <div class="canvas-container">
    <canvas ref="canvasRef"></canvas>
  </div>
</template>

<style scoped>
.canvas-container {
  width: 100%;
  height: 100%;
  background: #fafafa;
  touch-action: none;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}
</style>
