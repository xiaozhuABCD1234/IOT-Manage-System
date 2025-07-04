<template>
  <div class="container">
    <div class="distance-panel" v-if="showDistancePanel">
      <h3>距离计算</h3>
      <div class="distance-inputs">
        <div class="input-column">
          <label>选择设备1类型:</label>
          <el-select v-model="selectedType1" placeholder="选择类型" size="small" @change="filterTags1">
            <el-option label="全部" value="" />
            <el-option label="人" value="person" />
            <el-option label="物" value="object" />
          </el-select>
          <label style="margin-top: 10px;">选择设备1标签:</label>
          <el-select v-model="selectedTag1" placeholder="选择标签" size="small">
            <el-option v-for="tag in filteredTags1" :key="tag.id" :label="tag.label + ' (' + tag.id + ')'" :value="tag.id" />
          </el-select>
        </div>
        <div class="input-column">
          <label>选择设备2类型:</label>
          <el-select v-model="selectedType2" placeholder="选择类型" size="small" @change="filterTags2">
            <el-option label="全部" value="" />
            <el-option label="人" value="person" />
            <el-option label="物" value="object" />
          </el-select>
          <label style="margin-top: 10px;">选择设备2标签:</label>
          <el-select v-model="selectedTag2" placeholder="选择标签" size="small">
            <el-option v-for="tag in filteredTags2" :key="tag.id" :label="tag.label + ' (' + tag.id + ')'" :value="tag.id" />
          </el-select>
        </div>
      </div>
      <div class="result">
        <div>
          <strong>两设备之间距离:</strong> {{ distance }} cm
        </div>
        <div style="margin-top: 10px;">
          <label>选择安全距离类型:</label>
          <el-select v-model="selectedSafetyDistance" placeholder="选择安全距离" size="small" @change="calculateDistance">
            <el-option v-for="item in safetyDistances" :key="item.type" :label="item.type + ' (' + item.value + 'cm)'" :value="item.value" />
          </el-select>
        </div>
        <div v-if="safetyAlertMessage" style="color: red; margin-top: 10px;">
          <strong>警告:</strong> {{ safetyAlertMessage }}
        </div>
      </div>
    </div>
    
    <div class="controls" v-if="showControls">
      <el-switch v-model="showFloorPlan" active-text="显示平面图-3" />
      <el-switch v-model="showAnchors" active-text="显示基站" />
      <el-switch v-model="showCoordinates" active-text="显示坐标" />
      <el-switch v-model="showFence" active-text="显示围栏区域" />
      <el-button 
        type="primary" 
        :class="{ 'active': drawingFence }"
        @click="toggleFenceDrawing"
      >
        {{ drawingFence ? '完成围栏' : '绘制电子围栏' }}
      </el-button>
      <el-button 
        type="danger"
        @click="resetFence"
        :disabled="!showFence"
      >
        清除围栏
      </el-button>
      <el-button 
        type="info"
        @click="resetMapView"
        title="重置地图视图"
      >
        重置视图
      </el-button>
      <el-button 
        type="success"
        @click="toggleDistancePanel"
      >
        {{ showDistancePanel ? '隐藏距离计算' : '显示距离计算' }}
      </el-button>
      <el-button 
        type="warning"
        @click="showTagManagement = true"
      >
        标签管理
      </el-button>
      <el-button 
        type="warning"
        @click="showSafetyManagement = true"
      >
        安全距离管理
      </el-button>
      <div class="tip">提示: 点击"绘制电子围栏"按钮，然后在地图上点击添加围栏顶点，至少需要3个点</div>
    </div>

    <el-dialog
      title="设备标签管理"
      v-model="showTagManagement"
      width="80%"
      :before-close="handleTagManagementClose"
    >
      <TagManager ref="tagManagerRef" />
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleTagManagementClose">关闭</el-button>
        </span>
      </template>
    </el-dialog>

    <el-dialog
      title="安全距离管理"
      v-model="showSafetyManagement"
      width="80%"
      :before-close="handleSafetyManagementClose"
    >
      <SafetyDistanceManager ref="safetyDistanceManagerRef" />
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="handleSafetyManagementClose">关闭</el-button>
        </span>
      </template>
    </el-dialog>

    <P5MultiTrail
      ref="mapRef"
      :points="points"
      :trail-length="80"
      :grid-step="100"
      :show-grid="true"
      :initialXRange="{ min: 0, max: 1800 }"
      :initialYRange="{ min: 0, max: 2200 }"
      :floorPlanImage="null"
      :showFloorPlan="showFloorPlan"
      :anchors="anchors"
      :showAnchors="showAnchors"
      :showCoordinates="showCoordinates"
      :floorPlanSvg="floorPlanSvg"
      :drawingFence="drawingFence"
      :showFence="showFence"
      @fenceComplete="handleFenceComplete"
      @fenceViolation="handleFenceViolation"
      style="width: 100%; height: 100%; min-height: 98vh;"
    />
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, ref, watch, nextTick } from "vue";
import P5MultiTrail from "@/components/DataDisplay/P5MultiTrail.vue";
import mqtt from "mqtt";
import { useConfigStore } from "@/stores/config";
import { ElNotification } from "element-plus";
import TagManager from "@/components/devops/TagManager.vue";
import SafetyDistanceManager from "@/components/devops/SafetyDistanceManager.vue";

interface Sensor {
  name: string;
  data?: {
    value: number[];
  };
}

interface TrackingPoint {
  id: string;
  x: number;
  y: number;
  color?: string;
  label?: string;
}

interface Anchor {
  id: string | number;
  x: number;
  y: number;
  coordinates: string;
}

interface TagItem {
  id: string;
  type: 'person' | 'object';
  label: string;
  editing?: boolean;
}

interface SafetyDistanceItem {
  type: string;
  value: number;
  editing?: boolean;
}

const ConfigStore = useConfigStore();
const points = ref<TrackingPoint[]>([]);
const prevIndoorStates = ref(new Map<string, boolean>());
const floorPlanImage = ref<string | null>(null);
const showFloorPlan = ref(true);
const showAnchors = ref(true);
const showCoordinates = ref(true);
const showControls = ref(true);
const drawingFence = ref(false);
const showFence = ref(true);
const fenceCoordinates = ref<{x: number, y: number}[]>([]);
const showDistancePanel = ref(false);

// 标签管理相关
const tagManagerRef = ref<InstanceType<typeof TagManager> | null>(null);
const allTags = ref<TagItem[]>([]);
const selectedType1 = ref<'' | 'person' | 'object'>('');
const selectedTag1 = ref<string>('');
const filteredTags1 = ref<TagItem[]>([]);
const selectedType2 = ref<'' | 'person' | 'object'>('');
const selectedTag2 = ref<string>('');
const filteredTags2 = ref<TagItem[]>([]);
const showTagManagement = ref(false);

// 安全距离管理相关
const safetyDistanceManagerRef = ref<InstanceType<typeof SafetyDistanceManager> | null>(null);
const safetyDistances = ref<SafetyDistanceItem[]>([]);
const selectedSafetyDistance = ref<number | null>(null);
const safetyAlertMessage = ref<string | null>(null);
const showSafetyManagement = ref(false);

const distance = ref<string>('--');

// 内联 SVG 数据
const floorPlanSvg = ref(`<?xml version="1.0" encoding="UTF-8"?>
<svg width="1800" height="2200" viewBox="0 0 1800 2200" xmlns="http://www.w3.org/2000/svg">
  <!-- 白色填充区域 -->
  <rect x="40" y="40" width="540" height="2120" 
        fill="#ffffff" stroke="none"></rect>
  <rect x="580" y="520" width="1200" height="660" 
        fill="#ffffff" stroke="none"></rect>
  
  <!-- 坐标标记 -->
  <text x="30" y="2170" font-size="24" fill="#007bff" font-family="Arial, sans-serif" font-weight="bold">0,0</text>
  <text x="590" y="2170" font-size="18" fill="#007bff" font-family="Arial, sans-serif" font-weight="bold">(600, 0)</text>
  <text x="590" y="40" font-size="18" fill="#007bff" font-family="Arial, sans-serif" font-weight="bold">(600, 2200)</text>
  <text x="30" y="40" font-size="18" fill="#007bff" font-family="Arial, sans-serif" font-weight="bold">(0, 2200)</text>
  <text x="590" y="1190" font-size="18" fill="#007bff" font-family="Arial, sans-serif" font-weight="bold">(600, 1000)</text>
  <text x="590" y="510" font-size="18" fill="#007bff" font-family="Arial, sans-serif" font-weight="bold">(600, 1700)</text>
  <text x="1790" y="1190" font-size="18" fill="#007bff" font-family="Arial, sans-serif" font-weight="bold">(1800, 1000)</text>
  <text x="1790" y="510" font-size="18" fill="#007bff" font-family="Arial, sans-serif" font-weight="bold">(1800, 1700)</text>
</svg>`);
  
// 定义基站位置
const anchors = ref<Anchor[]>([
  { id: 1, x: 0, y: 0, coordinates: "[0, 0]" },
  { id: 2, x: 600, y: 0, coordinates: "[600, 0]" },
  { id: 3, x: 0, y: 300, coordinates: "[0, 300]" },
]);

const mqttConfig = {
  url: ConfigStore.mqtturl,
  options: {
    clean: true,
    connectTimeout: 4000,
    clientId: `${ConfigStore.mqttclientid}-${
      Math.random().toString(16).substr(2, 8)
    }-uwb`,
    username: ConfigStore.mqttuser,
    password: ConfigStore.mqttpwd,
  },
  topic: ConfigStore.mqtttopic,
};

let client: mqtt.MqttClient | null = null;

const mapRef = ref<InstanceType<typeof P5MultiTrail> | null>(null);

const handleMessage = (payload: Buffer) => {
  try {
    const data = JSON.parse(payload.toString());
    const { id, indoor, sensors } = data;

    if (!id) return;

    // 处理室内状态变化
    if (typeof indoor !== "undefined") {
      const prevIndoor = prevIndoorStates.value.get(id);

      // 状态变化通知
      if (prevIndoor !== undefined && prevIndoor !== indoor) {
        ElNotification({
          title: "状态变化",
          message: `设备 ${id} ${indoor ? "进入" : "离开"}室内`,
          type: "info",
          duration: 3000,
        });
      }

      // 离开室内时清除轨迹
      if (!indoor) {
        points.value = points.value.filter((p) => p.id !== id);
      }

      prevIndoorStates.value.set(id, indoor);
    }

    // 仅在室内时处理坐标
    if (indoor) {
      const uwb = sensors?.find((s: Sensor) => s.name === "UWB");
      if (uwb?.data?.value?.length === 2) {
        const [x, y] = uwb.data.value;
        const index = points.value.findIndex((p) => p.id === id);
        
        // 查找标签信息
        const tagInfo = tagManagerRef.value?.getDeviceTag(String(id));
        
        // 如果标签不存在，自动创建一个默认标签
        if (!tagInfo && tagManagerRef.value) {
          // 创建默认标签
          const newTag = {
            id: String(id),
            type: 'object' as 'object', // 默认为设备类型
            label: `未命名设备-${id}`
          };
          
          // 添加到标签管理器
          tagManagerRef.value.tagList.push(newTag);
          
          // 更新本地标签列表
          allTags.value = tagManagerRef.value.tagList;
          filterTags1();
          filterTags2();
        }

        // 添加标签信息或更新点
        if (index > -1) {
          // 更新现有点，保留标签信息
          const updatedPoint = { ...points.value[index], x, y };
          // 如果有新标签信息，则更新
          if (tagInfo) {
            updatedPoint.label = tagInfo.label;
            // 根据类型设置颜色
            updatedPoint.color = tagInfo.type === 'person' ? '#ff6600' : '#00cc00';
          }
          points.value[index] = updatedPoint;
        } else {
          // 添加新点
          const newPoint: TrackingPoint = { id, x, y };
          // 如果有标签信息，则添加
          if (tagInfo) {
            newPoint.label = tagInfo.label;
            // 根据类型设置颜色
            newPoint.color = tagInfo.type === 'person' ? '#ff6600' : '#00cc00';
          } else {
            // 使用默认值
            newPoint.color = '#00cc00'; // 默认为设备
            newPoint.label = `未命名设备-${id}`;
          }
          points.value = [...points.value, newPoint];
        }
      }
    }
  } catch (e) {
    console.warn("Invalid message format:", e);
  }
};

// 添加重置地图视图方法
const resetMapView = () => {
  if (mapRef.value && typeof mapRef.value.resetView === 'function') {
    mapRef.value.resetView();
  }
};

// 过滤标签函数
const filterTags1 = () => {
  selectedTag1.value = ''; // 重置已选标签
  // 确保allTags有值
  if (tagManagerRef.value && (!allTags.value || allTags.value.length === 0)) {
    allTags.value = tagManagerRef.value.tagList;
  }

  if (selectedType1.value === '') {
    filteredTags1.value = allTags.value;
  } else {
    filteredTags1.value = allTags.value.filter(tag => tag.type === selectedType1.value);
  }
  calculateDistance();
};

const filterTags2 = () => {
  selectedTag2.value = ''; // 重置已选标签
  // 确保allTags有值
  if (tagManagerRef.value && (!allTags.value || allTags.value.length === 0)) {
    allTags.value = tagManagerRef.value.tagList;
  }
  
  if (selectedType2.value === '') {
    filteredTags2.value = allTags.value;
  } else {
    filteredTags2.value = allTags.value.filter(tag => tag.type === selectedType2.value);
  }
  calculateDistance();
};

// 计算两个标签点之间的距离
const calculateDistance = () => {
  console.log('calculateDistance triggered');
  console.log('selectedTag1:', selectedTag1.value);
  console.log('selectedTag2:', selectedTag2.value);
  console.log('points.value.length:', points.value.length);

  if (!selectedTag1.value || !selectedTag2.value) {
    distance.value = '--';
    safetyAlertMessage.value = null;
    return;
  }

  const point1 = points.value.find(p => String(p.id) === selectedTag1.value);
  const point2 = points.value.find(p => String(p.id) === selectedTag2.value);

  console.log('Found point1:', point1);
  console.log('Found point2:', point2);

  if (point1 && point2) {
    const dx = point1.x - point2.x;
    const dy = point1.y - point2.y;
    const dist = Math.sqrt(dx * dx + dy * dy);
    distance.value = dist.toFixed(2);

    // 比较安全距离
    if (selectedSafetyDistance.value !== null && dist < selectedSafetyDistance.value) {
      safetyAlertMessage.value = null;
    } else if (selectedSafetyDistance.value !== null) {
      safetyAlertMessage.value = `距离 (${dist.toFixed(2)} cm) 超过安全距离 (${selectedSafetyDistance.value} cm)!`;
      ElNotification({
        title: "安全距离警告",
        message: `设备 ${selectedTag1.value} 与设备 ${selectedTag2.value} 距离 (${dist.toFixed(2)} cm) 超过安全距离 (${selectedSafetyDistance.value} cm)!`,
        type: "warning",
        duration: 5000,
      });
    }
  } else {
    distance.value = '--';
    safetyAlertMessage.value = null;
  }
};

// 新增：切换距离计算面板显示状态的函数
const toggleDistancePanel = () => {
  showDistancePanel.value = !showDistancePanel.value;
};

// 处理标签管理对话框关闭
const handleTagManagementClose = () => {
  showTagManagement.value = false;
  // 确保标签列表更新
  if (tagManagerRef.value) {
    allTags.value = tagManagerRef.value.tagList;
    filterTags1();
    filterTags2();
  }
};

// 处理安全距离管理对话框关闭
const handleSafetyManagementClose = () => {
  showSafetyManagement.value = false;
  // 确保安全距离列表更新
  if (safetyDistanceManagerRef.value) {
    safetyDistances.value = safetyDistanceManagerRef.value.safetyDistanceList;
    // 如果安全距离列表有值但未选择，默认选择第一个
    if (safetyDistances.value.length > 0 && selectedSafetyDistance.value === null) {
      selectedSafetyDistance.value = safetyDistances.value[0].value;
    }
  }
};

// 切换围栏绘制模式
const toggleFenceDrawing = () => {
  if (drawingFence.value) {
    // 如果当前正在绘制围栏，点击按钮表示完成围栏
    drawingFence.value = false;
    // P5MultiTrail组件会监听drawingFence的变化并自动触发fenceComplete事件
    console.log("完成围栏绘制");
    
    // 获取当前围栏点（如果有）
    if (mapRef.value && typeof mapRef.value.getFencePoints === 'function') {
      fenceCoordinates.value = mapRef.value.getFencePoints();
      
      // 检查围栏点数量
      if (fenceCoordinates.value.length < 3) {
        ElNotification({
          title: "围栏创建失败",
          message: "电子围栏至少需要3个点才能生效",
          type: "warning",
          duration: 3000,
        });
      } else {
        ElNotification({
          title: "围栏已创建",
          message: `电子围栏已创建，共 ${fenceCoordinates.value.length} 个点`,
          type: "success",
          duration: 3000,
        });
      }
    }
  } else {
    // 如果当前不在绘制围栏，点击按钮表示开始绘制
    drawingFence.value = true;
    // 确保显示围栏
    showFence.value = true;
    console.log("开始围栏绘制");
  }
};

// 清除围栏
const resetFence = () => {
  if (mapRef.value && typeof mapRef.value.resetFence === 'function') {
    mapRef.value.resetFence();
    fenceCoordinates.value = [];
    console.log("围栏已清除");
    
    ElNotification({
      title: "围栏已清除",
      message: "电子围栏已被清除",
      type: "info",
      duration: 3000,
    });
  }
};

// 处理围栏完成事件
const handleFenceComplete = (coordinates: {x: number, y: number}[]) => {
  fenceCoordinates.value = coordinates;
  console.log("围栏已创建，共 " + coordinates.length + " 个点");
  console.log("围栏坐标:", JSON.stringify(coordinates));
  
  // 不再重复显示通知，因为在toggleFenceDrawing中已经处理
};

// 处理围栏违规事件
const handleFenceViolation = (deviceId: string) => {
  ElNotification({
    title: "围栏警告",
    message: `设备 ${deviceId} 已超出电子围栏范围`,
    type: "warning",
    duration: 5000,
  });
};

watch([selectedTag1, selectedTag2, points, selectedSafetyDistance], calculateDistance, { deep: true });

onMounted(() => {
  // 连接MQTT
  client = mqtt.connect(mqttConfig.url, mqttConfig.options);
  client.on("connect", () => {
    console.log("Connected to MQTT broker");
    client?.subscribe(mqttConfig.topic);
  });
  client.on("message", (_, payload) => handleMessage(payload));
  
  // 首先确保标签管理组件和安全距离管理组件加载完成
  nextTick(async () => {
    // 初始化标签数据
    if (tagManagerRef.value) {
      // 获取初始标签数据
      allTags.value = tagManagerRef.value.tagList;
      
      // 监听标签数据变化
      watch(() => tagManagerRef.value?.tagList, (newTags) => {
        if (newTags) {
          allTags.value = newTags;
          // 更新筛选列表
          filterTags1();
          filterTags2();
        }
      }, { deep: true });
      
      // 初始过滤
      filterTags1();
      filterTags2();
    }
    
    // 初始化安全距离数据
    if (safetyDistanceManagerRef.value) {
      // 获取初始安全距离数据
      safetyDistances.value = safetyDistanceManagerRef.value.safetyDistanceList;
      
      // 如果没有安全距离数据，创建默认安全距离
      if (safetyDistances.value.length === 0) {
        // 默认安全距离示例
        const defaultSafetyDistances = [
          { type: '人与人安全距离', value: 150, editing: false },
          { type: '人与设备安全距离', value: 300, editing: false },
          { type: '设备与设备安全距离', value: 200, editing: false }
        ];
        
        // 添加默认安全距离
        defaultSafetyDistances.forEach(sd => {
          safetyDistanceManagerRef.value?.safetyDistanceList.push(sd);
        });
        
        // 更新本地缓存
        safetyDistances.value = safetyDistanceManagerRef.value.safetyDistanceList;
      }
      
      // 监听安全距离数据变化
      watch(() => safetyDistanceManagerRef.value?.safetyDistanceList, (newDistances) => {
        if (newDistances) {
          safetyDistances.value = newDistances;
        }
      }, { deep: true });
    }
    
    // 默认选择第一个安全距离值（如果存在）
    if (safetyDistances.value.length > 0) {
      selectedSafetyDistance.value = safetyDistances.value[0].value;
    }
    
    // 初始计算距离
    calculateDistance();
    
    // 默认开启距离面板
    showDistancePanel.value = true;
  });
});

onUnmounted(() => {
  client?.end(true);
});
</script>

<style scoped>
.container {
  width: 100%;
  height: 100vh; /* 使用视口高度确保有足够空间 */
  overflow: hidden;
  background: #f0f2f5;
  position: relative;
  display: flex; /* 使用flex布局 */
  flex-direction: column; /* 垂直排列子元素 */
}

/* 确保P5MultiTrail组件占据剩余所有空间 */
.container :deep(.p5-canvas-container) {
  flex: 1; /* 占据所有剩余空间 */
  min-height: 650px; /* 增加最小高度 */
  width: 100%;
  position: relative;
}

/* 恢复原始的距离计算面板样式 */
.distance-panel {
  position: absolute;
  top: 20px;
  left: 20px;
  background: rgba(255, 255, 255, 0.9); /* 增加不透明度，与控制面板一致 */
  padding: 15px;
  border-radius: 8px; /* 与控制面板一致 */
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1); /* 与控制面板一致 */
  z-index: 1000;
  width: 360px; /* 原来是450px，缩小到80%为360px */
}

.distance-panel h3 {
  margin-top: 0;
  margin-bottom: 12px;
  color: #333;
  font-size: 1em; /* 稍微缩小标题 */
}

.distance-inputs {
  display: flex;
  justify-content: space-between;
  margin-bottom: 15px;
}

.input-column {
  display: flex;
  flex-direction: column;
  width: 47%; /* 稍微调整，确保两列之间有足够间距 */
}

.input-column label {
  margin-bottom: 5px;
  font-size: 0.85em; /* 稍微缩小字体 */
  color: #555;
}

.input-column .el-select {
  width: 100%;
  font-size: 0.9em; /* 稍微缩小字体 */
}

.distance-panel .result div {
  margin-bottom: 5px;
  font-size: 0.85em; /* 稍微缩小字体 */
  color: #333;
}

.controls {
  position: absolute;
  top: 10px;
  right: 10px;
  z-index: 10;
  background: rgba(255, 255, 255, 0.9); /* 增加不透明度，提高可读性 */
  padding: 15px; /* 增加内边距，让内容更宽松 */
  border-radius: 8px; /* 增大圆角，更现代化 */
  display: flex;
  flex-direction: column;
  gap: 12px; /* 增加间距，提高可读性 */
  width: 190px; /* 固定宽度，使所有开关对齐 */
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1); /* 添加阴影，增强层次感 */
}

/* 添加开关样式，使其更突出 */
.controls :deep(.el-switch) {
  transform: scale(1.1); /* 稍微放大开关 */
}

/* 改善开关文字样式 */
.controls :deep(.el-switch__label) {
  font-size: 14px; /* 增大字体 */
  font-weight: 500; /* 加粗字体 */
  color: #333; /* 更深的文字颜色 */
}

/* 提示文字样式优化 */
.tip {
  font-size: 13px; /* 稍微增大字体 */
  color: #606266; /* 更明显的颜色 */
  margin-top: 10px;
  text-align: center;
  line-height: 1.4; /* 增加行高，提高可读性 */
}

.active {
  background-color: #409eff;
  border-color: #409eff;
  color: white;
}
</style>


<!-- 1 -->