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
  (e: "deviceClicked", device: TrailPoint): void; // 新增设备点击事件
}>();

const canvasRef = ref<HTMLElement | null>(null);
let p5Instance: p5 | null = null;
const trails = reactive(new Map<string | number, Array<{ x: number; y: number }>>());

// 添加视图状态 - 保留平移和滚轮缩放功能
const viewState = reactive({
  scale: 1.0,  // 初始缩放比例
  minScale: 0.3, // 最小缩放比例
  maxScale: 3.0, // 最大缩放比例
  scaleStep: 0.1, // 缩放步长
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
  // 外部边界 - 已移除红色线条
  walls: [] as Wall[],
  // 内部区域 - 已移除绿色边框和左侧RTK区域
  areas: [
    // 右侧延伸区域 - 保留白色填充，移除边框
    { x: 580, y: 520, width: 1200, height: 660, color: '#ffffff', borderColor: 'transparent', borderWeight: 0 },
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
      // 使用更好的背景色
      p.background(245, 247, 250);
      
      // 计算缩放比例以适应画布
      const mapWidth = 1800;
      const mapHeight = 2200;
      const padding = 15;  // 减少内边距，让地图内容占用更多可用空间
      
      // 修改比例计算方式，使地图在视觉上更加合理
      const scaleX = (p.width - padding * 2) / mapWidth;
      const scaleY = (p.height - padding * 2) / mapHeight;
      
      // 使用固定比例而非取最小值，改善视觉效果
      // 增加缩放因子，使地图显示更大
      const baseScale = Math.min(scaleX, scaleY) * 0.995 * 1.2; // 增加到1.2倍
      
      // 应用变换，包括用户交互
      p.push();
      p.translate(p.width / 2, p.height / 2);
      // 使用viewState.scale实现滚轮缩放控制
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
      // 检查是否点击了设备点
      const mapWidth = 1800;
      const mapHeight = 2200;
      const padding = 15;
      
      // 计算基础缩放比例和点击位置
      const scaleX = (p.width - padding * 2) / mapWidth;
      const scaleY = (p.height - padding * 2) / mapHeight;
      const baseScale = Math.min(scaleX, scaleY) * 0.995 * 0.8;
      
      // 计算鼠标在实际地图坐标系中的位置
      let mx = p.mouseX - p.width / 2;
      let my = p.mouseY - p.height / 2;
      mx = mx / (baseScale * viewState.scale);
      my = my / (baseScale * viewState.scale);
      mx = mx + mapWidth / 2 - viewState.offsetX;
      my = mapHeight - (my + mapHeight / 2 - viewState.offsetY);
      
      // 检查是否点击了任何设备点
      let deviceClicked = false;
      for (const point of props.points) {
        // 计算点击位置与设备点的距离
        const dist = Math.sqrt(Math.pow(mx - point.x, 2) + Math.pow(my - point.y, 2));
        // 如果距离小于设备图标大小，则判断为点击了该设备
        if (dist < 20) { // 设备图标半径约为20单位
          // 触发设备点击事件
          emit("deviceClicked", point);
          deviceClicked = true;
          break;
        }
      }
      
      // 如果没有点击设备，则进入拖动模式
      if (!deviceClicked) {
        viewState.isDragging = true;
        viewState.lastMouseX = p.mouseX;
        viewState.lastMouseY = p.mouseY;
      }
    }
  };
  
  p.mouseReleased = function() {
    viewState.isDragging = false;
  };
  
  // 添加触摸事件支持（移动端）
  p.touchStarted = function() {
    // 避免在控制区域内进行拖动
    const rightButtonAreaWidth = 300;
    const rightButtonAreaHeight = 450;
    const leftButtonAreaWidth = 500;
    const leftButtonAreaHeight = 400;
    const topButtonAreaHeight = 100;
    
    // 判断触摸是否在控制区域内
    const inRightControlArea = p.mouseX > (p.width - rightButtonAreaWidth) && p.mouseY < rightButtonAreaHeight;
    const inLeftControlArea = p.mouseX < leftButtonAreaWidth && p.mouseY < leftButtonAreaHeight;
    const inTopArea = p.mouseY < topButtonAreaHeight;
    const inBottomArea = p.mouseY > (p.height - 50);
    
    const inControlArea = inRightControlArea || inLeftControlArea || inTopArea || inBottomArea;
    
    if (!inControlArea) {
      viewState.isDragging = true;
      viewState.lastMouseX = p.mouseX;
      viewState.lastMouseY = p.mouseY;
    }
    return false;
  };
  
  p.touchEnded = function() {
    viewState.isDragging = false;
    return false;
  };
  
  p.touchMoved = function() {
    if (viewState.isDragging) {
      const dx = p.mouseX - viewState.lastMouseX;
      const dy = p.mouseY - viewState.lastMouseY;
      
      // 根据缩放调整移动速度
      const mapWidth = 1800;
      const mapHeight = 2200;
      const padding = 15;
      const scaleX = (p.width - padding * 2) / mapWidth;
      const scaleY = (p.height - padding * 2) / mapHeight;
      const dragBaseScale = Math.min(scaleX, scaleY) * 0.995 * 0.8;
      const moveScale = 1 / (dragBaseScale * viewState.scale);
      
      viewState.offsetX += dx * moveScale;
      viewState.offsetY -= dy * moveScale;
      
      viewState.lastMouseX = p.mouseX;
      viewState.lastMouseY = p.mouseY;
    }
    return false;
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
  
  // 添加鼠标滚轮事件，实现缩放功能
  p.mouseWheel = function(event: { deltaY: number }) {
    // 复用mousePressed中的控制区域判断逻辑
    const rightButtonAreaWidth = 300;
    const rightButtonAreaHeight = 450;
    const leftButtonAreaWidth = 500;
    const leftButtonAreaHeight = 400;
    const topButtonAreaHeight = 100;
    
    // 判断鼠标是否在控制区域内
    const inRightControlArea = p.mouseX > (p.width - rightButtonAreaWidth) && p.mouseY < rightButtonAreaHeight;
    const inLeftControlArea = p.mouseX < leftButtonAreaWidth && p.mouseY < leftButtonAreaHeight;
    const inTopArea = p.mouseY < topButtonAreaHeight;
    const inBottomArea = p.mouseY > (p.height - 50);
    
    const inControlArea = inRightControlArea || inLeftControlArea || inTopArea || inBottomArea;
    
    // 如果在控制区域内，不进行缩放
    if (inControlArea) return;
    
    // 计算基础缩放比例（与draw函数中相同）
    const mapWidth = 1800;
    const mapHeight = 2200;
    const padding = 15;
    const scaleX = (p.width - padding * 2) / mapWidth;
    const scaleY = (p.height - padding * 2) / mapHeight;
    const baseScale = Math.min(scaleX, scaleY) * 0.995 * 1.2;
    
    // 确定缩放方向和比例
    const zoomAmount = 0.1; // 每次缩放10%
    
    // deltaY < 0表示向上滚动（放大），deltaY > 0表示向下滚动（缩小）
    if (event.deltaY < 0) {
      // 向上滚动，放大
      const newScale = Math.min(viewState.scale * (1 + zoomAmount), viewState.maxScale);
      if (newScale !== viewState.scale) {
        // 计算鼠标相对于画布中心的位置
        const dx = p.mouseX - p.width / 2;
        const dy = p.mouseY - p.height / 2;
        
        // 调整偏移量，使鼠标指向的点保持相对位置不变
        const zoomFactor = newScale / viewState.scale;
        viewState.offsetX -= dx * (zoomFactor - 1) / (baseScale * viewState.scale);
        viewState.offsetY += dy * (zoomFactor - 1) / (baseScale * viewState.scale); // Y轴已翻转
        
        // 更新缩放比例
        viewState.scale = newScale;
      }
    } else {
      // 向下滚动，缩小
      const newScale = Math.max(viewState.scale / (1 + zoomAmount), viewState.minScale);
      if (newScale !== viewState.scale) {
        // 计算鼠标相对于画布中心的位置
        const dx = p.mouseX - p.width / 2;
        const dy = p.mouseY - p.height / 2;
        
        // 调整偏移量，使鼠标指向的点保持相对位置不变
        const zoomFactor = newScale / viewState.scale;
        viewState.offsetX -= dx * (zoomFactor - 1) / (baseScale * viewState.scale);
        viewState.offsetY += dy * (zoomFactor - 1) / (baseScale * viewState.scale); // Y轴已翻转
        
        // 更新缩放比例
        viewState.scale = newScale;
      }
    }
    
    // 阻止默认的滚动行为
    return false;
  };
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

// 创建一个持久化的Map来存储设备的围栏状态
const deviceFenceStatusMap = reactive(new Map<string, boolean>());

// 检查设备是否违反围栏规则
const checkFenceViolation = () => {
  if (!props.showFence || fencePoints.value.length < 3) return;
  
  props.points.forEach(point => {
    const pointId = String(point.id);
    const isInside = isPointInPolygon({x: point.x, y: point.y}, fencePoints.value);
    
    console.log(`设备 ${pointId} 围栏状态检测: 当前=${isInside ? '内部' : '外部'}, 之前=${deviceFenceStatusMap.has(pointId) ? (deviceFenceStatusMap.get(pointId) ? '内部' : '外部') : '未知'}`);
    
    // 如果是第一次检测到该设备，记录其状态
    if (!deviceFenceStatusMap.has(pointId)) {
      deviceFenceStatusMap.set(pointId, isInside);
      // 如果设备一开始就在围栏内，也触发违规事件
      if (isInside) {
        console.log(`设备 ${pointId} 首次检测到在围栏内，触发违规事件`);
        emit("fenceViolation", pointId);
      }
    } 
    // 如果设备状态发生变化（从外部进入围栏），触发违规事件
    else if (isInside && !deviceFenceStatusMap.get(pointId)) {
      console.log(`设备 ${pointId} 从外部进入围栏，触发违规事件`);
      emit("fenceViolation", pointId);
      deviceFenceStatusMap.set(pointId, isInside);
    }
    
    // 更新设备的围栏状态
    deviceFenceStatusMap.set(pointId, isInside);
  });
};

// 绘制网格
const drawGrid = (p: p5, width: number, height: number) => {
  // 白色背景
  p.background(245, 247, 250);
  
  // 绘制网格线
  p.push();
  
  // 主网格线 - 浅灰色
  p.stroke(220, 220, 220);
  p.strokeWeight(0.8);
  
  // 每100个单位绘制一条线
  for (let x = 0; x <= width; x += 100) {
    p.line(x, 0, x, height);
  }
  
  for (let y = 0; y <= height; y += 100) {
    p.line(0, y, width, y);
  }
  
  // 每500个单位绘制一条稍粗的强调线
  p.stroke(200, 200, 200);
  p.strokeWeight(1.2);
  
  for (let x = 0; x <= width; x += 500) {
    p.line(x, 0, x, height);
    
    // 添加坐标标记
    p.push();
    p.scale(1, -1); // 再次翻转文本，使其正向显示
    p.fill(100, 100, 100);
    p.textSize(16);
    p.textStyle(p.NORMAL);
    p.text(x.toString(), x + 5, -10);
    p.pop();
  }
  
  for (let y = 0; y <= height; y += 500) {
    p.line(0, y, width, y);
    
    // 添加坐标标记
    p.push();
    p.scale(1, -1); // 再次翻转文本，使其正向显示
    p.fill(100, 100, 100);
    p.textSize(16);
    p.textStyle(p.NORMAL);
    p.text(y.toString(), 5, -y - 5);
    p.pop();
  }
  
  // 原点标记 - 简单版
  p.fill(220, 220, 220);
  p.noStroke();
  p.rect(0, 0, 40, 40);
  
  // 添加原点文本
  p.push();
  p.scale(1, -1);
  p.fill(80, 80, 80);
  p.textSize(14);
  p.textAlign(p.CENTER, p.CENTER);
  p.text("0,0", 20, -20);
  p.pop();
  
  p.pop();
};

// 绘制基站
const drawAnchors = (p: p5) => {
  props.anchors.forEach(anchor => {
    p.push();
    
    // 简单的基站标记
    // 绘制外圈
    p.noFill();
    p.stroke(0, 120, 212);
    p.strokeWeight(2);
    p.ellipse(anchor.x, anchor.y, 50);
    
    // 绘制内圈
    p.fill(0, 120, 212);
    p.noStroke();
    p.ellipse(anchor.x, anchor.y, 30);
    
    // 简单的信号范围指示
    p.noFill();
    p.stroke(0, 120, 212, 100);
    p.strokeWeight(1);
    p.ellipse(anchor.x, anchor.y, 100);
    
    // 绘制基站ID和坐标
    p.push();
    p.scale(1, -1); // 再次翻转文本，使其正向显示
    
    // 基站ID标签
    p.textAlign(p.CENTER, p.CENTER);
    // 小标签背景
    p.fill(240, 240, 240);
    p.stroke(0, 120, 212);
    p.strokeWeight(1);
    p.rect(anchor.x - 25, -anchor.y - 45, 50, 20, 3);
    
    // ID文本
    p.fill(0, 120, 212);
    p.textSize(14);
    p.textStyle(p.BOLD);
    p.text(`A:${anchor.id}`, anchor.x, -anchor.y - 35);
    
    // 绘制坐标
    if (props.showCoordinates) {
      // 坐标标签背景
      p.fill(240, 240, 240);
      p.stroke(180, 180, 180);
      p.strokeWeight(1);
      p.rect(anchor.x - 50, -anchor.y + 40, 100, 20, 3);
      
      // 坐标文本
      p.fill(80, 80, 80);
      p.textSize(12);
      p.textStyle(p.NORMAL);
      p.text(anchor.coordinates, anchor.x, -anchor.y + 50);
    }
    p.pop();
    
    // 为原点基站添加特殊标记
    if (anchor.x === 0 && anchor.y === 0) {
      // 原点标记 - 简单方形
      p.stroke(220, 0, 0);
      p.strokeWeight(2);
      p.noFill();
      p.rect(-30, -30, 60, 60);
      
      // 原点标识
      p.push();
      p.scale(1, -1);
      p.fill(220, 0, 0);
      p.textStyle(p.BOLD);
      p.textSize(14);
      p.textAlign(p.CENTER, p.CENTER);
      p.text("ORIGIN", 0, -60);
      p.pop();
    }
    
    p.pop();
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
    
    p.push();
    
    // 绘制轨迹 - 简单版本
    if (trail.length > 1) {
      // 根据类型设置颜色
      const isHuman = point.color === '#ff6600';
      const trailColor = isHuman ? 
        p.color(255, 102, 0, 150) : // 人员 - 橙色
        p.color(0, 180, 0, 150);    // 设备 - 绿色
      
      p.stroke(trailColor);
      p.strokeWeight(3);
      p.noFill();
      
      // 绘制轨迹线
      p.beginShape();
      for (let i = 0; i < trail.length; i++) {
        const pt = trail[i];
        p.vertex(pt.x, pt.y);
      }
      p.endShape();
      
      // 在轨迹点上绘制小圆点
      p.noStroke();
      p.fill(trailColor);
      for (let i = 0; i < trail.length; i += 3) {
        const pt = trail[i];
        p.ellipse(pt.x, pt.y, 5);
      }
    }
    
    // 根据类型设置颜色
    const isHuman = point.color === '#ff6600';
    
    // 绘制位置标记
    if (isHuman) {
      // 人员标签 - 绘制为橙色圆形
      // 外圈
      p.fill(255, 102, 0);
      p.noStroke();
      p.ellipse(point.x, point.y, 28);
      
      // 内圈
      p.fill(255, 255, 255);
      p.ellipse(point.x, point.y, 18);
      
      // 简化的人形图标
      p.fill(255, 102, 0);
      p.ellipse(point.x, point.y, 14);
    } else {
      // 设备标签 - 绘制为绿色方形
      p.rectMode(p.CENTER);
      
      // 外方形
      p.fill(0, 180, 0);
      p.noStroke();
      p.rect(point.x, point.y, 25, 25, 3);
      
      // 内方形
      p.fill(255);
      p.rect(point.x, point.y, 15, 15, 2);
      
      // 中心点
      p.fill(0, 180, 0);
      p.rect(point.x, point.y, 9, 9);
    }
    
    // 绘制标签 - 注意Y轴已翻转，需要调整文本方向
    if (props.showCoordinates) {
      p.push();
      p.scale(1, -1); // 再次翻转文本，使其正向显示
      
      // 为文本添加背景以提高可读性
      let displayText = `ID: ${point.id} (${point.x.toFixed(0)}, ${point.y.toFixed(0)})`;
      
      // 如果点有标签属性，则显示标签信息
      if (point.label) {
        // 根据颜色判断类型
        const deviceType = isHuman ? '人' : '设备';
        displayText = `[${deviceType}] ${point.label} (${point.id})`;
      }
      
      // 计算文本宽度
      p.textSize(14);
      const textWidth = p.textWidth(displayText);
      
      // 绘制文本背景
      p.fill(240, 240, 240);
      p.stroke(isHuman ? '#ff6600' : '#00b400');
      p.strokeWeight(1);
      p.rect(
        point.x + 20, 
        -point.y - 10, 
        textWidth + 20, 
        24, 
        3
      );
      
      // 绘制文本
      p.fill(60, 60, 60);
      p.noStroke();
      p.textSize(14);
      p.textAlign(p.LEFT, p.CENTER);
      p.text(displayText, point.x + 30, -point.y);
      
      // 显示坐标信息
      p.fill(120, 120, 120);
      p.textSize(12);
      p.text(`(${point.x.toFixed(0)}, ${point.y.toFixed(0)})`, point.x + 30, -point.y + 14);
      
      p.pop();
    }
    
    p.pop();
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

// 监听围栏点变化，重置设备状态并重新检查
watch(() => fencePoints.value, () => {
  // 围栏点变化时，清空设备状态记录
  deviceFenceStatusMap.clear();
  // 如果围栏有效，立即检查当前设备
  if (fencePoints.value.length >= 3) {
    console.log('围栏点变化，重新检查所有设备状态');
    checkFenceViolation();
  }
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
  viewState.scale = 1.0; // 重置为初始缩放比例
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
  background-color: #ffffff;
  position: relative;
  cursor: v-bind("props.drawingFence ? 'crosshair' : 'grab'");
  border-radius: 5px;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.p5-canvas-container canvas {
  display: block;
  border-radius: 5px;
}
</style>