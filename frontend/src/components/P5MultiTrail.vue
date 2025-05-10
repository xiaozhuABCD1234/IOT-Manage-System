<script setup lang="ts">
import p5 from 'p5';
import { onMounted, watch, ref, reactive, type PropType, onUnmounted } from 'vue';

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
      val.every((p) => p !== null && typeof p === 'object' && 'id' in p && 'x' in p && 'y' in p),
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
    default: 50,
    validator: (v: number) => v > 0,
  },
});

const canvasRef = ref<HTMLElement>();
let p5Instance: p5 | null = null;
const trails = reactive(new Map<string | number, Array<{ x: number; y: number }>>());

const transformState = reactive({
  scale: 1,
  offset: { x: 0, y: 0 },
  dragStart: { x: 0, y: 0 },
  isDragging: false,
});

const autoGridStep = () => {
  const baseStep = props.gridStep;
  const scale = transformState.scale;

  if (scale < 0.2) return baseStep * 10;
  if (scale < 0.5) return baseStep * 5;
  if (scale < 1) return baseStep * 2;
  if (scale > 5) return baseStep / 2;
  if (scale > 2) return baseStep;
  return baseStep;
};

const hashCode = (str: string | number) => {
  let hash = 0;
  const s = String(str);
  for (let i = 0; i < s.length; i++) {
    hash = s.charCodeAt(i) + ((hash << 5) - hash);
  }
  return hash;
};

const idToColor = (id: string | number) => {
  const hash = hashCode(id);
  return `hsl(${Math.abs(hash % 360)}, 70%, 50%)`;
};

const drawGrid = (p: p5) => {
  p.push();
  p.stroke(220);
  p.strokeWeight(0.5 / transformState.scale);

  const step = autoGridStep();
  const visibleWidth = p.width / transformState.scale;
  const visibleHeight = p.height / transformState.scale;

  const startX = Math.floor((-visibleWidth / 2 - transformState.offset.x / transformState.scale) / step) * step;
  const endX = Math.ceil((visibleWidth / 2 - transformState.offset.x / transformState.scale) / step) * step;
  const startY = Math.floor(
    (-visibleHeight / 2 + transformState.offset.y / transformState.scale) / step
  ) * step;
  const endY = Math.ceil(
    (visibleHeight / 2 + transformState.offset.y / transformState.scale) / step
  ) * step;

  for (let x = startX; x <= endX; x += step) {
    p.line(x, startY, x, endY);
  }

  for (let y = startY; y <= endY; y += step) {
    p.line(startX, y, endX, y);
  }

  if (transformState.scale > 2) {
    p.stroke(240);
    p.strokeWeight(0.3 / transformState.scale);
    const subStep = step / 5;

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

  // 计算当前可视区域的边界
  const visibleWidth = p.width / transformState.scale;
  const visibleHeight = p.height / transformState.scale;

  // X轴动态范围（基于当前偏移和缩放）
  const axisStartX = (-visibleWidth / 2 - transformState.offset.x / transformState.scale);
  const axisEndX = (visibleWidth / 2 - transformState.offset.x / transformState.scale);

  // Y轴动态范围（基于当前偏移和缩放）
  const axisStartY = (-visibleHeight / 2 + transformState.offset.y / transformState.scale);
  const axisEndY = (visibleHeight / 2 + transformState.offset.y / transformState.scale);

  // 绘制X轴
  p.line(axisStartX, 0, axisEndX, 0);

  // X轴箭头（动态定位到轴末端）
  const arrowSize = 8 / transformState.scale;
  p.line(axisEndX - arrowSize, -arrowSize / 2, axisEndX, 0);
  p.line(axisEndX - arrowSize, arrowSize / 2, axisEndX, 0);

  // 绘制Y轴
  p.line(0, axisStartY, 0, axisEndY);

  // Y轴箭头（动态定位到轴末端）
  p.line(-arrowSize / 2, axisEndY - arrowSize, 0, axisEndY);
  p.line(arrowSize / 2, axisEndY - arrowSize, 0, axisEndY);

  // 绘制刻度标签
  p.fill(0);
  p.textSize(12);
  p.textAlign(p.CENTER, p.CENTER);

  const step = autoGridStep();

  // X轴刻度
  const startX = Math.floor((-visibleWidth / 2 - transformState.offset.x / transformState.scale) / step) * step;
  const endX = Math.ceil((visibleWidth / 2 - transformState.offset.x / transformState.scale) / step) * step;

  for (let x = startX; x <= endX; x += step) {
    if (Math.abs(x) < 0.001) continue;

    p.line(x, 0, x, arrowSize / 2);

    p.push();
    p.resetMatrix();
    const screenX = p.width / 2 + transformState.offset.x + x * transformState.scale;
    const screenY = p.height / 2 + transformState.offset.y + 20;
    p.text(x.toFixed(transformState.scale > 2 ? 1 : 0), screenX, screenY);
    p.pop();
  }

  // Y轴刻度
  const startY = Math.floor(
    (-visibleHeight / 2 + transformState.offset.y / transformState.scale) / step
  ) * step;
  const endY = Math.ceil(
    (visibleHeight / 2 + transformState.offset.y / transformState.scale) / step
  ) * step;

  for (let y = startY; y <= endY; y += step) {
    if (Math.abs(y) < 0.001) continue;

    p.line(0, y, arrowSize / 2, y);

    p.push();
    p.resetMatrix();
    const screenX = p.width / 2 + transformState.offset.x + 20;
    const screenY = p.height / 2 + transformState.offset.y - y * transformState.scale;
    p.text(y.toFixed(transformState.scale > 2 ? 1 : 0), screenX, screenY);
    p.pop();
  }

  // 原点标签
  p.push();
  p.resetMatrix();
  const originX = p.width / 2 + transformState.offset.x;
  const originY = p.height / 2 + transformState.offset.y + 20;
  p.text("0", originX, originY);
  p.pop();

  p.pop();
};

const sketch = (p: p5) => {
  p.setup = () => {
    const container = canvasRef.value?.parentElement;
    if (!container) return;

    const canvas = p.createCanvas(container.clientWidth, container.clientHeight);
    canvas.parent(canvasRef.value!);
    p.textAlign(p.CENTER, p.CENTER);
    canvas.elt.addEventListener('wheel', (e: WheelEvent) => e.preventDefault());
  };

  p.draw = () => {
    p.background(255);
    p.translate(p.width / 2 + transformState.offset.x, p.height / 2 + transformState.offset.y);
    p.scale(transformState.scale, -transformState.scale);

    if (props.showGrid) drawGrid(p);
    drawAxes(p);

    trails.forEach((points, id) => {
      const color = props.points.find((p) => p.id === id)?.color || idToColor(id);

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
          props.pointSize / transformState.scale
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

    const newScale = Math.min(Math.max(transformState.scale * zoomFactor, 0.05), 20);

    const mouseX = (p.mouseX - p.width / 2 - transformState.offset.x) / transformState.scale;
    const mouseY = (p.mouseY - p.height / 2 - transformState.offset.y) / -transformState.scale;

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
  { deep: true }
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
