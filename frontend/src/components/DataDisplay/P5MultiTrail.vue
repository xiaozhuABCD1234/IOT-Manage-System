<script setup lang="ts">
import p5 from "p5";
import {
  onMounted,
  onUnmounted,
  type PropType,
  reactive,
  ref,
  watch,
  nextTick,
} from "vue";

type TrailPoint = {
  x: number;
  y: number;
  id: string | number;
  color?: string;
  label?: string;
};

type Anchor = {
  id: string | number;
  x: number;
  y: number;
  coordinates: string;
};

type FencePoint = {
  x: number;
  y: number;
};

type Wall = {
  x1: number;
  y1: number;
  x2: number;
  y2: number;
  color: string;
  weight: number;
};

type Area = {
  x: number;
  y: number;
  width: number;
  height: number;
  color: string;
  borderColor: string;
  borderWeight: number;
};

const props = defineProps({
  points: {
    type: Array as PropType<TrailPoint[]>,
    required: true,
    validator: (val: unknown[]) =>
      val.every(
        (p) => p !== null && typeof p === "object" && "id" in p && "x" in p && "y" in p,
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
  floorPlanImage: {
    type: String as PropType<string | null>,
    default: null,
  },
  showFloorPlan: {
    type: Boolean,
    default: true,
  },
  anchors: {
    type: Array as PropType<Anchor[]>,
    default: () => [],
  },
  showAnchors: {
    type: Boolean,
    default: true,
  },
  showCoordinates: {
    type: Boolean,
    default: true,
  },
  floorPlanSvg: {
    type: String,
    default: "",
  },
  drawingFence: {
    type: Boolean,
    default: false,
  },
  showFence: {
    type: Boolean,
    default: true,
  },
});

const emit = defineEmits<{
  (e: "fenceComplete", coordinates: FencePoint[]): void;
  (e: "fenceViolation", deviceId: string): void;
}>();

const canvasRef = ref<HTMLElement | null>(null);
let p5Instance: p5 | null = null;
const trails = reactive(new Map<string | number, Array<{ x: number; y: number }>>());

// 添加视图状态 - 去掉缩放功能，只保留平移
const viewState = reactive({
  scale: 1.0,  // 固定缩放比例
  offsetX: 0,  // 初始X偏移
  offsetY: 0,  // 初始Y偏移
  isDragging: false,
  lastMouseX: 0,
  lastMouseY: 0
});

// 添加电子围栏状态
const fencePoints = ref<FencePoint[]>([]);
const currentFencePoint = ref<FencePoint | null>(null);
const isDrawingFence = ref(false);

// 添加地图布局数据
const mapLayout = {
  // 外部边界
  walls: [
    // 左侧垂直线
    { x1: 20, y1: 20, x2: 20, y2: 2180, color: '#ff0000', weight: 5 },
    // 底部水平线
    { x1: 20, y1: 2180, x2: 600, y2: 2180, color: '#ff0000', weight: 5 },
    // 右侧垂直线（下半部分）
    { x1: 600, y1: 1200, x2: 600, y2: 2180, color: '#ff0000', weight: 5 },
    // 右侧垂直线（上半部分）
    { x1: 600, y1: 20, x2: 600, y2: 500, color: '#ff0000', weight: 5 },
    // 顶部水平线
    { x1: 20, y1: 20, x2: 600, y2: 20, color: '#ff0000', weight: 5 },
    // 右侧延伸部分顶部
    { x1: 600, y1: 500, x2: 1800, y2: 500, color: '#ff0000', weight: 5 },
    // 右侧延伸部分底部
    { x1: 600, y1: 1200, x2: 1800, y2: 1200, color: '#ff0000', weight: 5 },
    // 右侧延伸部分右侧
    { x1: 1800, y1: 500, x2: 1800, y2: 1200, color: '#ff0000', weight: 5 },
  ] as Wall[],
  // 内部区域（绿色边框）
  areas: [
    // 主要区域
    { x: 40, y: 40, width: 540, height: 2120, color: '#ffffff', borderColor: '#00cc00', borderWeight: 3 },
    // 右侧延伸区域
    { x: 580, y: 520, width: 1200, height: 660, color: '#ffffff', borderColor: '#00cc00', borderWeight: 3 },
  ] as Area[],
  // 不再需要绿色填充区域和门
  greenAreas: [],
  doors: []
};

// 极简版本的sketch函数，去除所有复杂功能
const sketch = (p: p5) => {
  p.setup = function() {
    try {
      if (canvasRef.value) {
        const canvas = p.createCanvas(
          canvasRef.value.clientWidth || 300,
          canvasRef.value.clientHeight || 200
        );
        canvas.parent(canvasRef.value);
      }
    } catch (error) {
      console.error("Error in p5 setup:", error);
    }
  };
  
  p.draw = function() {
    try {
      p.background(255);
      
      // 计算缩放比例以适应画布
      const mapWidth = 1800;
      const mapHeight = 2200;
      const padding = 15;  // 减少内边距，让地图内容占用更多可用空间
      
      // 修改比例计算方式，使地图在视觉上更加合理
      const scaleX = (p.width - padding * 2) / mapWidth;
      const scaleY = (p.height - padding * 2) / mapHeight;
      
      // 使用固定比例而非取最小值，改善视觉效果
      // 增加0.8的乘数来缩放到当前大小的80%
      const baseScale = Math.min(scaleX, scaleY) * 0.995 * 0.8; // 添加0.8缩放因子
      
      // 应用变换，包括用户交互
      p.push();
      p.translate(p.width / 2, p.height / 2);
      p.scale(baseScale * viewState.scale);
      
      // 翻转Y轴，使得Y轴向上为正方向（符合数学坐标系）
      p.scale(1, -1);
      
      // 调整地图在画布中的位置，使其更加居中且比例更协调
      p.translate(-mapWidth / 2 + viewState.offsetX, -mapHeight / 2 + viewState.offsetY);
      
      // 绘制地图
      drawMap(p);
      
      // 绘制网格（可选）
      if (props.showGrid) {
        drawGrid(p, mapWidth, mapHeight);
      }
      
      // 绘制基站
      if (props.showAnchors) {
        drawAnchors(p);
      }
      
      // 绘制电子围栏
      if (props.showFence && fencePoints.value.length > 0) {
        drawFence(p);
      }
      
      // 绘制点和轨迹
      drawPointsAndTrails(p);
      
      // 绘制当前正在绘制的围栏点
      if (props.drawingFence && currentFencePoint.value) {
        p.fill(255, 0, 0);
        p.noStroke();
        p.ellipse(currentFencePoint.value.x, currentFencePoint.value.y, 10);
      }
      
      p.pop();
    } catch (error) {
      console.error("Error in p5 draw:", error);
    }
  };
  
  // 添加鼠标交互
  p.mousePressed = function() {
    // 屏蔽控制区域的点击
    // 控制区域通常在屏幕右上角和左上角
    const rightButtonAreaWidth = 300;  // 右侧控制区域宽度增加
    const rightButtonAreaHeight = 450; // 右侧控制区域高度增加
    const leftButtonAreaWidth = 500;   // 左侧控制区域宽度增加（距离面板）
    const leftButtonAreaHeight = 400;  // 左侧控制区域高度增加（距离面板）
    const topButtonAreaHeight = 100;   // 顶部区域高度（适用于整个顶部）
    
    // 判断鼠标是否在控制区域内
    // 右上角控制栏区域
    const inRightControlArea = p.mouseX > (p.width - rightButtonAreaWidth) && p.mouseY < rightButtonAreaHeight;
    // 左上角距离计算面板区域
    const inLeftControlArea = p.mouseX < leftButtonAreaWidth && p.mouseY < leftButtonAreaHeight;
    // 顶部区域（整个顶部）
    const inTopArea = p.mouseY < topButtonAreaHeight;
    // 底部边缘区域
    const inBottomArea = p.mouseY > (p.height - 50);
    
    // 任一区域都视为控制区域
    const inControlArea = inRightControlArea || inLeftControlArea || inTopArea || inBottomArea;
    
    if (props.drawingFence && isDrawingFence.value && !inControlArea) { // 确保不在控制区域内
      // 获取鼠标在画布上的位置
      const mapWidth = 1800;
      const mapHeight = 2200;
      const padding = 15;
      
      // 计算基础缩放比例
      const scaleX = (p.width - padding * 2) / mapWidth;
      const scaleY = (p.height - padding * 2) / mapHeight;
      const baseScale = Math.min(scaleX, scaleY) * 0.995 * 0.8;
      
      // 计算鼠标在实际地图坐标系中的位置（应用逆变换）
      // 1. 从屏幕坐标转为画布中心为原点的坐标
      let mx = p.mouseX - p.width / 2;
      let my = p.mouseY - p.height / 2;
      
      // 2. 应用逆缩放（除以总缩放比例）
      mx = mx / (baseScale * viewState.scale);
      my = my / (baseScale * viewState.scale);
      
      // 3. 应用逆平移和坐标系转换
      mx = mx + mapWidth / 2 - viewState.offsetX;
      // Y轴已经翻转，所以需要使用减法并反转Y轴方向
      my = mapHeight - (my + mapHeight / 2 - viewState.offsetY);
      
      // 添加围栏点
      fencePoints.value.push({ x: mx, y: my });
      console.log(`添加围栏点: (${mx}, ${my}), 像素位置: (${p.mouseX}, ${p.mouseY})`);
    } else if (!inControlArea) { // 确保拖动也不在控制区域
      // 普通拖动模式
      viewState.isDragging = true;
      viewState.lastMouseX = p.mouseX;
      viewState.lastMouseY = p.mouseY;
    }
  };
  
  p.mouseReleased = function() {
    viewState.isDragging = false;
  };
  
  p.mouseDragged = function() {
    if (!props.drawingFence && viewState.isDragging) {
      const dx = p.mouseX - viewState.lastMouseX;
      const dy = p.mouseY - viewState.lastMouseY;
      
      // 根据缩放调整移动速度
      const mapWidth = 1800;
      const mapHeight = 2200;
      const padding = 15;
      const scaleX = (p.width - padding * 2) / mapWidth;
      const scaleY = (p.height - padding * 2) / mapHeight;
      const dragBaseScale = Math.min(scaleX, scaleY) * 0.995 * 0.8; // 添加0.8缩放因子
      const moveScale = 1 / (dragBaseScale * viewState.scale);
      
      viewState.offsetX += dx * moveScale;
      viewState.offsetY -= dy * moveScale; // 注意这里是减，因为Y轴已经翻转
      
      viewState.lastMouseX = p.mouseX;
      viewState.lastMouseY = p.mouseY;
    }
  };
  
  p.mouseMoved = function() {
    // 复用mousePressed中的控制区域判断逻辑
    const rightButtonAreaWidth = 300;  // 右侧控制区域宽度增加
    const rightButtonAreaHeight = 450; // 右侧控制区域高度增加
    const leftButtonAreaWidth = 500;   // 左侧控制区域宽度增加（距离面板）
    const leftButtonAreaHeight = 400;  // 左侧控制区域高度增加（距离面板）
    const topButtonAreaHeight = 100;   // 顶部区域高度（适用于整个顶部）
    
    // 判断鼠标是否在控制区域内
    const inRightControlArea = p.mouseX > (p.width - rightButtonAreaWidth) && p.mouseY < rightButtonAreaHeight;
    const inLeftControlArea = p.mouseX < leftButtonAreaWidth && p.mouseY < leftButtonAreaHeight;
    const inTopArea = p.mouseY < topButtonAreaHeight;
    const inBottomArea = p.mouseY > (p.height - 50);
    
    const inControlArea = inRightControlArea || inLeftControlArea || inTopArea || inBottomArea;
    
    if (props.drawingFence && isDrawingFence.value && !inControlArea) {
      // 获取鼠标在画布上的位置
      const mapWidth = 1800;
      const mapHeight = 2200;
      const padding = 15;
      
      // 计算基础缩放比例
      const scaleX = (p.width - padding * 2) / mapWidth;
      const scaleY = (p.height - padding * 2) / mapHeight;
      const baseScale = Math.min(scaleX, scaleY) * 0.995 * 0.8;
      
      // 使用与mousePressed相同的转换逻辑
      // 1. 从屏幕坐标转为画布中心为原点的坐标
      let mx = p.mouseX - p.width / 2;
      let my = p.mouseY - p.height / 2;
      
      // 2. 应用逆缩放
      mx = mx / (baseScale * viewState.scale);
      my = my / (baseScale * viewState.scale);
      
      // 3. 应用逆平移和坐标系转换
      mx = mx + mapWidth / 2 - viewState.offsetX;
      // Y轴已经翻转，所以需要使用减法并反转Y轴方向
      my = mapHeight - (my + mapHeight / 2 - viewState.offsetY);
      
      currentFencePoint.value = { x: mx, y: my };
    } else {
      // 如果不是绘制模式或在控制区域内，确保没有当前预览点
      currentFencePoint.value = null;
    }
  };
  
  // 移除鼠标滚轮事件，禁用缩放功能
};

// 绘制地图函数
const drawMap = (p: p5) => {
  // 绘制白色背景
  p.fill(255);
  p.noStroke();
  p.rect(0, 0, 1800, 2200);
  
  // 绘制室内区域
  mapLayout.areas.forEach(area => {
    p.fill(area.color);
    p.stroke(area.borderColor);
    p.strokeWeight(area.borderWeight);
    p.rect(area.x, area.y, area.width, area.height);
  });
  
  // 绘制墙壁
  mapLayout.walls.forEach(wall => {
    p.stroke(wall.color);
    p.strokeWeight(wall.weight);
    p.line(wall.x1, wall.y1, wall.x2, wall.y2);
  });
};

// 绘制电子围栏
const drawFence = (p: p5) => {
  if (fencePoints.value.length < 2) return;
  
  p.stroke('#ff6600');
  p.strokeWeight(9);  // 围栏线条粗细增加到300%（原值3）
  p.noFill();
  
  p.beginShape();
  fencePoints.value.forEach(point => {
    p.vertex(point.x, point.y);
  });
  
  if (props.drawingFence && currentFencePoint.value) {
    // 如果正在绘制，连接到当前鼠标位置
    p.vertex(currentFencePoint.value.x, currentFencePoint.value.y);
  } else {
    // 如果不是绘制模式，则闭合多边形
    p.endShape(p.CLOSE);
  }
  
  // 绘制围栏顶点
  fencePoints.value.forEach((point, index) => {
    p.fill('#ff6600');
    p.noStroke();
    p.ellipse(point.x, point.y, 24);  // 顶点大小增加到300%（原值8）
    
    // 显示顶点序号
    p.push();
    p.scale(1, -1); // 再次翻转文本，使其正向显示
    p.fill(0);
    p.textSize(36);  // 字体大小增加到300%（原值12）
    p.textAlign(p.CENTER, p.CENTER);
    p.text(index + 1, point.x, -point.y);
    p.pop();
  });
};

// 检查点是否在多边形内部
const isPointInPolygon = (point: {x: number, y: number}, polygon: FencePoint[]): boolean => {
  if (polygon.length < 3) return false;
  
  let inside = false;
  for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    const xi = polygon[i].x, yi = polygon[i].y;
    const xj = polygon[j].x, yj = polygon[j].y;
    
    const intersect = ((yi > point.y) !== (yj > point.y)) &&
        (point.x < (xj - xi) * (point.y - yi) / (yj - yi) + xi);
    if (intersect) inside = !inside;
  }
  
  return inside;
};

// 检查设备是否违反围栏规则
const checkFenceViolation = () => {
  if (!props.showFence || fencePoints.value.length < 3) return;
  
  props.points.forEach(point => {
    const isInside = isPointInPolygon({x: point.x, y: point.y}, fencePoints.value);
    
    // 如果设备不在围栏内，触发违规事件
    if (!isInside) {
      emit("fenceViolation", String(point.id));
    }
  });
};

// 绘制网格
const drawGrid = (p: p5, width: number, height: number) => {
  p.stroke(220);
  p.strokeWeight(1.5);  // 网格线粗细增加到180%（原值0.8）
  
  // 每100个单位绘制一条线
  for (let x = 0; x <= width; x += 100) {
    p.line(x, 0, x, height);
    
    // 添加坐标标记
    if (x % 500 === 0) {  // 每500个单位添加一个坐标标记
      p.push();
      p.scale(1, -1); // 再次翻转文本，使其正向显示
      p.fill(100, 100, 100);
      p.textSize(26);  // 字体大小增加到180%（原值14）
      p.text(x.toString(), x + 5, -20);
      p.pop();
    }
  }
  
  for (let y = 0; y <= height; y += 100) {
    p.line(0, y, width, y);
    
    // 添加坐标标记
    if (y % 500 === 0) {  // 每500个单位添加一个坐标标记
      p.push();
      p.scale(1, -1); // 再次翻转文本，使其正向显示
      p.fill(100, 100, 100);
      p.textSize(26);  // 字体大小增加到180%（原值14）
      p.text(y.toString(), 20, -y - 15);
      p.pop();
    }
  }
  
  // 强调原点位置 - 左下角红框区域
  p.fill(255, 0, 0, 150);
  p.noStroke();
  p.rect(0, 0, 40, 40);
  
  // 添加原点标记
  p.push();
  p.scale(1, -1); // 再次翻转文本，使其正向显示
  p.fill(255);
  p.textSize(28);  // 字体大小增加到180%（原值16）
  p.textAlign(p.CENTER, p.CENTER);
  p.text("0,0", 20, -20);
  p.pop();
};

// 绘制基站
const drawAnchors = (p: p5) => {
  props.anchors.forEach(anchor => {
    // 绘制基站圆圈
    p.fill(0, 100, 255);
    p.noStroke();
    p.ellipse(anchor.x, anchor.y, 54);  // 基站圆圈大小增加到180%（原值30）
    
    // 绘制基站ID和坐标 - 注意Y轴已翻转，需要调整文本方向
    p.push();
    p.scale(1, -1); // 再次翻转文本，使其正向显示
    
    // 绘制基站ID
    p.fill(0);
    p.textSize(28);  // 字体大小增加到180%（原值16）
    p.textAlign(p.CENTER, p.CENTER);
    p.text(`A: ${anchor.id}`, anchor.x, -anchor.y - 45); // 注意Y坐标取负值，调整位置
    
    // 绘制坐标
    if (props.showCoordinates) {
      p.textSize(25);  // 字体大小增加到180%（原值14）
      p.text(`[${anchor.coordinates}]`, anchor.x, -anchor.y + 50); // 注意Y坐标取负值，调整位置
    }
    
    p.pop();
    
    // 绘制信号圈
    p.noFill();
    p.stroke(0, 100, 255, 100);
    p.strokeWeight(2.7);  // 线条粗细增加到180%（原值1.5）
    for (let r = 54; r <= 162; r += 54) {  // 圈大小增加到180%
      p.ellipse(anchor.x, anchor.y, r * 2);
    }
    
    // 为原点基站添加特殊标记
    if (anchor.x === 0 && anchor.y === 0) {
      p.stroke(255, 0, 0);
      p.strokeWeight(3.6);  // 线条粗细增加到180%（原值2）
      p.noFill();
      p.rect(-36, -36, 72, 72);  // 方框大小增加到180%
    }
  });
};

// 绘制点和轨迹
const drawPointsAndTrails = (p: p5) => {
  props.points.forEach((point) => {
    const deviceId = String(point.id);
    
    // 确保该设备有轨迹数组
    if (!trails.has(deviceId)) {
      trails.set(deviceId, []);
    }
    
    const trail = trails.get(deviceId)!;
    
    // 添加当前点到轨迹
    trail.push({ x: point.x, y: point.y });
    
    // 限制轨迹长度
    if (trail.length > props.trailLength) {
      trail.shift();
    }
    
    // 绘制轨迹
    if (trail.length > 1) {
      p.noFill();
      p.stroke(point.color || '#00ff00');
      p.strokeWeight(5.4);  // 轨迹线条粗细增加到180%（原值3）
      p.beginShape();
      trail.forEach(pt => {
        p.vertex(pt.x, pt.y);
      });
      p.endShape();
    }
    
    // 绘制点 - 根据标签类型决定形状
    p.fill(point.color || '#00ff00');
    p.noStroke();
    
    const pointSizeFactor = 2.2;  // 点大小增加到180%（原值1.2）
    
    // 判断是否是人员标签（橙色）或设备标签（绿色）
    if (point.color === '#ff6600') { 
      // 人员标签 - 绘制为圆形
      p.ellipse(point.x, point.y, props.pointSize * pointSizeFactor); 
    } else {
      // 设备标签 - 绘制为方形
      p.rectMode(p.CENTER);
      p.rect(point.x, point.y, props.pointSize * pointSizeFactor, props.pointSize * pointSizeFactor);
    }
    
    // 绘制标签 - 注意Y轴已翻转，需要调整文本方向
    if (props.showCoordinates) {
      p.push();
      p.scale(1, -1); // 再次翻转文本，使其正向显示
      p.fill(0);
      p.textSize(28);  // 字体大小增加到180%（原值16）
      p.textAlign(p.LEFT, p.CENTER);
      
      // 显示设备ID与标签信息（如果有）
      let displayText = `ID: ${point.id} (${point.x.toFixed(0)}, ${point.y.toFixed(0)})`;
      
      // 如果点有标签属性，则显示标签信息
      if (point.label) {
        // 根据颜色判断类型
        const deviceType = point.color === '#ff6600' ? '人' : '设备';
        displayText = `[${deviceType}] ${point.label} (${point.id}) (${point.x.toFixed(0)}, ${point.y.toFixed(0)})`;
      }
      
      p.text(displayText, point.x + 27, -point.y); // 偏移量增加到180%（原值15）
      p.pop();
    }
  });
};

// 处理窗口大小变化
const handleResize = () => {
  if (p5Instance && canvasRef.value) {
    p5Instance.resizeCanvas(canvasRef.value.clientWidth, canvasRef.value.clientHeight);
  }
};

// 监听drawingFence属性变化
watch(() => props.drawingFence, (newVal, oldVal) => {
  if (newVal) {
    // 开始绘制围栏
    isDrawingFence.value = true;
    if (!oldVal) { // 只有从false变为true时才清空围栏点
      fencePoints.value = []; // 清空之前的围栏点
    }
    currentFencePoint.value = null;
  } else if (isDrawingFence.value) {
    // 结束绘制围栏
    isDrawingFence.value = false;
    
    // 取消当前预览点
    currentFencePoint.value = null;
    
    // 如果有至少3个点，则触发围栏完成事件
    if (fencePoints.value.length >= 3) {
      emit("fenceComplete", fencePoints.value);
    }
  }
});

// 监听点位置变化，检查围栏违规
watch(() => props.points, () => {
  checkFenceViolation();
}, { deep: true });

onMounted(() => {
  window.addEventListener('resize', handleResize);
  
  // 确保DOM元素已经渲染完成
  nextTick(() => {
    if (!canvasRef.value) return;
    
    try {
      p5Instance = new p5(sketch, canvasRef.value);
    } catch (error) {
      console.error("Error creating p5 instance:", error);
    }
  });
});

onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
  if (p5Instance) {
    p5Instance.remove();
    p5Instance = null;
  }
});

watch(
  () => props.points,
  (newPoints) => {
    // 清理不再存在的点的轨迹
    const currentIds = new Set(newPoints.map(p => String(p.id)));
    for (const id of trails.keys()) {
      if (!currentIds.has(String(id))) {
        trails.delete(id);
      }
    }
  },
  { deep: true }
);

// 重置视图函数
const resetView = () => {
  viewState.scale = 1.0;
  viewState.offsetX = 0;
  viewState.offsetY = 0;
};

// 导出方法
defineExpose({
  clearAllTrails: () => {
    trails.clear();
  },
  resetView: () => {
    // 使用重置视图函数
    resetView();
  },
  resetFence: () => {
    // 清空围栏
    fencePoints.value = [];
    currentFencePoint.value = null;
  },
  getFencePoints: () => {
    // 返回当前围栏点
    return fencePoints.value;
  }
});
</script>

<template>
  <div ref="canvasRef" class="p5-canvas-container"></div>
</template>

<style scoped>
.p5-canvas-container {
  width: 100%;
  height: 100%;
  min-height: 98vh;
  background-color: #f0f0f0;
  position: relative;
  cursor: v-bind("props.drawingFence ? 'crosshair' : 'grab'");
}

.p5-canvas-container canvas {
  display: block;
}
</style>