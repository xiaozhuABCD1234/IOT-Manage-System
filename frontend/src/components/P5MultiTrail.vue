<script setup lang="ts">
import p5 from "p5";
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

const canvasRef = ref<HTMLElement>();
let p5Instance: p5 | null = null;
const trails = reactive(
  new Map<string | number, Array<{ x: number; y: number }>>(),
);

const transformState = reactive({
  scale: 1,
  offset: { x: 0, y: 0 },
  dragStart: { x: 0, y: 0 },
  isDragging: false,
});

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
  transformState.offset.y = centerY * newScale;
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

const hashCode = (str: string | number) => {
  let hash = 0;
  const s = String(str);
  for (let i = 0; i < s.length; i++) {
    hash = (hash << 5) - hash + s.charCodeAt(i);
    hash |= 0; // 转换为32位整数
  }
  return hash;
};

const idToColor = (id: string | number) => {
  const hash = hashCode(id);
  const hue = ((hash % 360) + 360) % 360; // 确保正值
  const saturation = 70 + (hash % 15); // 65-85% 饱和度
  const lightness = 50 + (hash % 10) - 5; // 45-55% 亮度
  return `hsl(${hue}, ${saturation}%, ${lightness}%)`;
};

const drawGrid = (p: p5) => {
  p.push();
  p.stroke(220);
  p.strokeWeight(0.5 / transformState.scale);

  // 动态计算网格步长
  const step = autoGridStep();

  // 计算可见区域（增加10%余量）
  const visibleWidth = p.width / transformState.scale * 1.1;
  const visibleHeight = p.height / transformState.scale * 1.1;

  // 计算网格起止坐标
  const startX = Math.floor(
    (-visibleWidth / 2 - transformState.offset.x / transformState.scale) / step,
  ) * step;
  const endX = Math.ceil(
    (visibleWidth / 2 - transformState.offset.x / transformState.scale) / step,
  ) * step;
  const startY = Math.floor(
    (-visibleHeight / 2 + transformState.offset.y / transformState.scale) /
    step,
  ) * step;
  const endY = Math.ceil(
    (visibleHeight / 2 + transformState.offset.y / transformState.scale) / step,
  ) * step;

  // 网格密度保护机制
  const xGridCount = (endX - startX) / step;
  const yGridCount = (endY - startY) / step;
  if (xGridCount > 200 || yGridCount > 200) {
    console.warn("Grid density exceeds safety limit, skipping drawing");
    p.pop();
    return;
  }

  // 绘制主网格
  p.stroke(220);
  for (let x = startX; x <= endX; x += step) {
    p.line(x, startY, x, endY);
  }
  for (let y = startY; y <= endY; y += step) {
    p.line(startX, y, endX, y);
  }

  // 智能子网格绘制
  if (transformState.scale > 5) {
    const subStep = step / (transformState.scale > 20 ? 10 : 5);
    p.stroke(240);
    p.strokeWeight(0.3 / transformState.scale);

    for (let x = startX; x <= endX; x += subStep) {
      if (Math.abs(x % step) < 0.001) continue;
      p.line(x, startY, x, endY);
    }
    for (let y = startY; y <= endY; y += subStep) {
      if (Math.abs(y % step) < 0.001) continue;
      p.line(startX, y, endX, y);
    }
  }

  p.pop();
};

const drawAxes = (p: p5) => {
  p.push();
  p.stroke(0);
  p.strokeWeight(1.5 / transformState.scale);

  // 计算可见区域（与drawGrid保持一致）
  const visibleWidth = p.width / transformState.scale * 1.1;
  const visibleHeight = p.height / transformState.scale * 1.1;

  // 独立计算轴范围
  const axisStartX = -visibleWidth / 2 -
    transformState.offset.x / transformState.scale;
  const axisEndX = visibleWidth / 2 -
    transformState.offset.x / transformState.scale;
  const axisStartY = -visibleHeight / 2 +
    transformState.offset.y / transformState.scale;
  const axisEndY = visibleHeight / 2 +
    transformState.offset.y / transformState.scale;

  // 绘制X轴
  p.line(axisStartX, 0, axisEndX, 0);
  // X轴箭头
  const arrowSize = 12 / transformState.scale;
  p.line(axisEndX - arrowSize, -arrowSize / 2, axisEndX, 0);
  p.line(axisEndX - arrowSize, arrowSize / 2, axisEndX, 0);

  // 绘制Y轴
  p.line(0, axisStartY, 0, axisEndY);
  // Y轴箭头
  p.line(-arrowSize / 2, axisEndY - arrowSize, 0, axisEndY);
  p.line(arrowSize / 2, axisEndY - arrowSize, 0, axisEndY);

  // 动态计算标签参数
  const step = autoGridStep();
  const minLabelSpacing = 80; // 像素单位
  const labelPrecision = Math.max(0, Math.floor(2 - Math.log10(step)));
  p.textSize(12);
  p.fill(0);

  // 绘制X轴刻度标签
  let lastScreenX = -Infinity;
  for (let x = Math.floor(axisStartX / step) * step; x <= axisEndX; x += step) {
    if (Math.abs(x) < 1e-6) continue; // 跳过原点

    // 转换到屏幕坐标
    const screenX = p.width / 2 + transformState.offset.x +
      x * transformState.scale;
    const screenY = p.height / 2 + transformState.offset.y + 25;

    // 密度控制
    if (Math.abs(screenX - lastScreenX) < minLabelSpacing) continue;

    p.push();
    p.resetMatrix();
    p.text(x.toFixed(labelPrecision), screenX, screenY);
    p.pop();

    // 绘制刻度线
    p.line(x, 0, x, arrowSize / 2 / transformState.scale);

    lastScreenX = screenX;
  }

  // 绘制Y轴刻度标签
  let lastScreenY = -Infinity;
  for (let y = Math.floor(axisStartY / step) * step; y <= axisEndY; y += step) {
    if (Math.abs(y) < 1e-6) continue;

    const screenX = p.width / 2 + transformState.offset.x + 25;
    const screenY = p.height / 2 + transformState.offset.y -
      y * transformState.scale;

    if (Math.abs(screenY - lastScreenY) < minLabelSpacing) continue;

    p.push();
    p.resetMatrix();
    p.text(y.toFixed(labelPrecision), screenX, screenY);
    p.pop();

    // 绘制刻度线
    p.line(0, y, arrowSize / 2 / transformState.scale, y);

    lastScreenY = screenY;
  }

  // 绘制原点标签（智能避让）
  p.push();
  p.resetMatrix();
  const originScreenX = p.width / 2 + transformState.offset.x + 5;
  const originScreenY = p.height / 2 + transformState.offset.y + 25;
  // 检查是否与其他标签重叠
  if (
    Math.abs(originScreenX - lastScreenX) > 20 &&
    Math.abs(originScreenY - lastScreenY) > 20
  ) {
    p.text("0", originScreenX, originScreenY);
  }
  p.pop();

  p.pop();
};
const sketch = (p: p5) => {
  p.setup = () => {
    const container = canvasRef.value?.parentElement;
    if (!container) return;

    const canvas = p.createCanvas(
      container.clientWidth,
      container.clientHeight,
    );
    canvas.parent(canvasRef.value!);
    p.textAlign(p.CENTER, p.CENTER);
    canvas.elt.addEventListener("wheel", (e: WheelEvent) => e.preventDefault());

    // 计算初始视图
    calculateInitialView();
  };

  p.draw = () => {
    p.background(255);
    p.translate(
      p.width / 2 + transformState.offset.x,
      p.height / 2 + transformState.offset.y,
    );
    p.scale(transformState.scale, -transformState.scale);

    if (props.showGrid) drawGrid(p);
    drawAxes(p);

    trails.forEach((points, id) => {
      const color = props.points.find((p) => p.id === id)?.color ||
        idToColor(id);

      p.stroke(color);
      p.strokeWeight(2 / transformState.scale);
      p.noFill();
      p.beginShape();
      points.forEach((point) => p.vertex(point.x, point.y));
      p.endShape();

      const currentPoint = props.points.find((p) => p.id === id);
      if (currentPoint) {
        p.fill(color);
        p.noStroke();
        p.ellipse(
          currentPoint.x,
          currentPoint.y,
          props.pointSize / transformState.scale,
          props.pointSize / transformState.scale,
        );
        // 添加ID标签
        p.fill(color);
        p.scale(1, -1);
        p.textSize(12 / transformState.scale);  // 根据缩放调整字号
        p.textAlign(p.LEFT, p.CENTER);          // 左对齐，垂直居中
        p.text(
          String(id),
          currentPoint.x + 8 / transformState.scale,  // X偏移
          currentPoint.y                             // Y位置与点中心一致
        );
      }
    });
  };

  p.mouseDragged = () => {
    if (transformState.isDragging) {
      transformState.offset.x += p.mouseX - transformState.dragStart.x;
      transformState.offset.y += p.mouseY - transformState.dragStart.y;
      transformState.dragStart.x = p.mouseX;
      transformState.dragStart.y = p.mouseY;
    }
  };

  p.mousePressed = () => {
    transformState.isDragging = true;
    transformState.dragStart.x = p.mouseX;
    transformState.dragStart.y = p.mouseY;
  };

  p.mouseReleased = () => {
    transformState.isDragging = false;
  };

  p.mouseWheel = (event: WheelEvent) => {
    const zoomIntensity = 0.1;
    const delta = event.deltaY > 0 ? 1 : -1;
    const zoomFactor = delta > 0 ? 1 - zoomIntensity : 1 + zoomIntensity;
    // 修改这行代码，调整缩放最小值和最大值
    const newScale = Math.min(
      Math.max(transformState.scale * zoomFactor, 1),
      2000,
    );

    const mouseX = (p.mouseX - p.width / 2 - transformState.offset.x) /
      transformState.scale;
    const mouseY = (p.mouseY - p.height / 2 - transformState.offset.y) /
      -transformState.scale;

    transformState.offset.x = p.mouseX - p.width / 2 - mouseX * newScale;
    transformState.offset.y = p.mouseY - p.height / 2 + mouseY * newScale;
    transformState.scale = newScale;
  };

  p.windowResized = () => {
    const container = canvasRef.value?.parentElement;
    if (container) {
      p.resizeCanvas(container.clientWidth, container.clientHeight);
    }
  };
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
  { deep: true },
);

onMounted(() => {
  if (!canvasRef.value) return;
  p5Instance = new p5(sketch);
});

onUnmounted(() => {
  p5Instance?.remove();
});
</script>

<template>
  <div ref="canvasRef" class="canvas-container"></div>
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
