<template>
  <div class="container">
    <!-- 页面顶部分隔器 -->
    <div class="page-top-divider"></div>
    
    <!-- UWB地图区域 -->
    <div class="uwb-map-container" style="width: 100%">
      <!-- 固定位置的警告信息面板 -->
      <div class="alerts-panel" v-if="fenceViolationDevices.size > 0 || safetyAlertMessage">
        <div class="alerts-header">
          <h3>⚠️ 实时警告信息</h3>
          <el-button type="text" @click="clearAllAlerts">清除全部</el-button>
        </div>
        
        <!-- 围栏违规警告 -->
        <div v-if="fenceViolationDevices.size > 0" class="alert-section">
          <h4>围栏警告</h4>
          <div v-for="[deviceId, info] in Array.from(fenceViolationDevices.entries())" :key="deviceId" class="alert-item fence-alert">
            <span>设备 {{ info.name }} ({{ deviceId }}) 已进入电子围栏区域！</span>
            <el-button type="text" size="small" @click="clearFenceAlert(deviceId)">×</el-button>
          </div>
        </div>
        
        <!-- 安全距离警告 -->
        <div v-if="safetyAlertMessage" class="alert-section">
          <h4>安全距离警告</h4>
          <div class="alert-item distance-alert">
            <span>{{ safetyAlertMessage }}</span>
          </div>
        </div>
      </div>
    
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
          <div v-if="safetyAlertMessage" class="safety-alert-message">
            {{ safetyAlertMessage }}
          </div>
        </div>
      </div>
    
      <div class="controls" v-if="showControls" :class="{'collapsed': isPanelCollapsed}">
        <div class="control-title" @click="toggleControlPanel">
          地图控制面板
          <el-icon v-if="isPanelCollapsed"><el-icon-arrow-up /></el-icon>
          <el-icon v-else><el-icon-arrow-down /></el-icon>
        </div>
        
        <div class="el-switch-group">
          <el-switch v-model="showFloorPlan" active-text="显示平面图-3" />
          <el-switch v-model="showAnchors" active-text="显示基站" />
          <el-switch v-model="showCoordinates" active-text="显示坐标" />
          <el-switch v-model="showFence" active-text="显示围栏区域" />
        </div>
        
        <!-- 水平分隔器 -->
        <div class="horizontal-divider"></div>
        
        <div class="button-group">
          <el-button 
            type="primary" 
            :class="{ 'active': drawingFence }"
            @click="toggleFenceDrawing"
            icon="Edit"
          >
            {{ drawingFence ? '完成围栏' : '绘制电子围栏' }}
          </el-button>
          
          <el-button 
            type="danger"
            @click="resetFence"
            :disabled="!showFence"
            icon="Delete"
          >
            清除围栏
          </el-button>
          
          <el-button 
            type="info"
            @click="resetMapView"
            title="重置地图视图"
            icon="Refresh"
          >
            重置视图
          </el-button>
          
          <el-button 
            type="success"
            @click="toggleDistancePanel"
            icon="Ruler"
          >
            {{ showDistancePanel ? '隐藏距离计算' : '显示距离计算' }}
          </el-button>
        </div>
        
        <!-- 水平分隔器 -->
        <div class="horizontal-divider"></div>
        
        <div class="button-group management-buttons">
          <el-button 
            type="warning"
            @click="showTagManagement = true"
            icon="Management"
          >
            标签管理
          </el-button>
          
          <el-button 
            type="warning"
            @click="showSafetyManagement = true"
            icon="Setting"
          >
            安全距离管理
          </el-button>
          
          <el-button 
            type="warning"
            @click="showAnchorManagement = true"
            icon="Location"
          >
            基站管理
          </el-button>
        </div>
        
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
    
      <el-dialog
        title="基站管理"
        v-model="showAnchorManagement"
        width="80%"
        :before-close="handleAnchorManagementClose"
      >
        <AnchorManager ref="anchorManagerRef" />
        <template #footer>
          <span class="dialog-footer">
            <el-button @click="handleAnchorManagementClose">关闭</el-button>
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
        @deviceClicked="handleDeviceClick"
        style="width: 100%; height: 100%; min-height: 90vh;"
      />
      
      <!-- 地图和控制面板之间的水平分隔器 -->
      <div class="map-controls-divider"></div>
    
      <!-- 移动端设备详情弹窗 -->
      <el-dialog
        v-model="showDeviceDetail"
        title="设备详情"
        width="90%"
        center
        class="mobile-device-dialog"
      >
        <div v-if="selectedDevice">
          <div class="device-detail-item">
            <span class="label">ID:</span>
            <span class="value">{{ selectedDevice.id }}</span>
          </div>
          <div class="device-detail-item">
            <span class="label">类型:</span>
            <span class="value">{{ selectedDevice.color === '#ff6600' ? '人员' : '设备' }}</span>
          </div>
          <div class="device-detail-item">
            <span class="label">标签:</span>
            <span class="value">{{ selectedDevice.label || '未命名' }}</span>
          </div>
          <div class="device-detail-item">
            <span class="label">位置:</span>
            <span class="value">({{ selectedDevice.x.toFixed(0) }}, {{ selectedDevice.y.toFixed(0) }})</span>
          </div>
        </div>
      </el-dialog>
    </div>
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
import AnchorManager from "@/components/devops/AnchorManager.vue";

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
const isPanelCollapsed = ref(false); // 控制面板是否收起（移动端特性）
const showDeviceDetail = ref(false); // 移动端设备详情弹窗
const selectedDevice = ref<TrackingPoint | null>(null); // 选中的设备

// UWB地图相关

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

// 基站管理相关
const anchorManagerRef = ref<InstanceType<typeof AnchorManager> | null>(null);
const showAnchorManagement = ref(false);

const distance = ref<string>('--');

// 内联 SVG 数据
const floorPlanSvg = ref(`<?xml version="1.0" encoding="UTF-8"?>
<svg width="1800" height="2200" viewBox="0 0 1800 2200" xmlns="http://www.w3.org/2000/svg">
  <!-- 白色填充区域 -->
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

// 向设备发送MQTT警报消息
const sendMqttAlertToDevice = (deviceId: string, message: string) => {
  if (!client) {
    console.error("MQTT client not connected");
    return;
  }
  
  try {
    // 构建设备特定的话题，格式为：location/sensors/{deviceId}
    const deviceTopic = `location/sensors/${deviceId}`;
    
    // 发布消息到设备话题
    client.publish(deviceTopic, message, { qos: 1 }, (error) => {
      if (error) {
        console.error(`Error sending alert to device ${deviceId}:`, error);
      } else {
        console.log(`Alert sent to device ${deviceId}: ${message}`);
      }
    });
  } catch (error) {
    console.error(`Failed to send alert to device ${deviceId}:`, error);
  }
};

let client: mqtt.MqttClient | null = null;

const mapRef = ref<InstanceType<typeof P5MultiTrail> | null>(null);

const handleMessage = (payload: Buffer) => {
  try {
    const data = JSON.parse(payload.toString());
    const { id, indoor, sensors } = data;

    if (!id) return;
    
    // 忽略ID为2的设备数据
    if (id === 2 || String(id) === '2') return;

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

// 清除测试设备
const clearTestDevices = () => {
  // 清除特定ID的测试设备（设备ID为2的设备）
  points.value = points.value.filter(p => {
    // 精确过滤ID为2的设备
    return String(p.id) !== '2';
  });
  
  // 如果有标签管理器，也从标签列表中移除测试设备
  if (tagManagerRef.value) {
    const tagList = tagManagerRef.value.tagList;
    const filteredTags = tagList.filter((tag: TagItem) => {
      // 精确过滤ID为2的设备标签
      return tag.id !== '2';
    });
    
    // 更新标签列表
    tagManagerRef.value.tagList.length = 0;
    filteredTags.forEach(tag => tagManagerRef.value?.tagList.push(tag));
    
    // 更新本地标签列表
    allTags.value = tagManagerRef.value.tagList;
    filterTags1();
    filterTags2();
  }
  
  // 确保本地存储中也删除了这个标签
  try {
    const storageKey = 'device_tag_list';
    const raw = localStorage.getItem(storageKey);
    if (raw) {
      const tags = JSON.parse(raw);
      const filteredTags = tags.filter((tag: {id: string}) => tag.id !== '2');
      localStorage.setItem(storageKey, JSON.stringify(filteredTags));
    }
  } catch (e) {
    console.error("Error updating local storage:", e);
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
      // 当距离小于安全距离时报警（与原逻辑相反）
      safetyAlertMessage.value = `⚠️ 距离 (${dist.toFixed(2)} cm) 小于安全距离 (${selectedSafetyDistance.value} cm)! ⚠️`;
      
      // 向两个触发安全距离警告的设备发送MQTT消息
      sendMqttAlertToDevice(selectedTag1.value, "on");
      sendMqttAlertToDevice(selectedTag2.value, "on");
    } else {
      safetyAlertMessage.value = null;
    }
  } else {
    distance.value = '--';
    safetyAlertMessage.value = null;
  }
};

// 切换距离计算面板显示状态的函数
const toggleDistancePanel = () => {
  showDistancePanel.value = !showDistancePanel.value;
};

// 切换控制面板展开/收起状态（移动端特性）
const toggleControlPanel = () => {
  isPanelCollapsed.value = !isPanelCollapsed.value;
};

// 分隔器相关功能已移除

// 处理拖动过程 - 已移除

// 停止拖动 - 已移除

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

// 处理基站管理对话框关闭
const handleAnchorManagementClose = () => {
  showAnchorManagement.value = false;
  // 确保基站列表更新
  if (anchorManagerRef.value) {
    // 更新地图中的基站数据
    anchors.value = anchorManagerRef.value.anchorList;
    ElNotification({
      title: "基站更新",
      message: `已更新 ${anchors.value.length} 个基站位置`,
      type: "success",
      duration: 2000,
    });
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

// 处理设备点击事件
const handleDeviceClick = (device: any) => {
  // 在移动端，点击设备显示详细信息
  if (window.innerWidth <= 768) {
    // 确保ID是字符串类型
    const trackingDevice: TrackingPoint = {
      id: String(device.id),
      x: device.x,
      y: device.y,
      color: device.color,
      label: device.label
    };
    selectedDevice.value = trackingDevice;
    showDeviceDetail.value = true;
  }
};

// 添加响应式变量来跟踪围栏违规设备
const fenceViolationDevices = ref<Map<string, {name: string, timestamp: number}>>(new Map());

// 清除单个围栏警告
const clearFenceAlert = (deviceId: string) => {
  fenceViolationDevices.value.delete(deviceId);
};

// 清除所有警告
const clearAllAlerts = () => {
  fenceViolationDevices.value.clear();
  safetyAlertMessage.value = null;
};

// 处理围栏违规事件
const handleFenceViolation = (deviceId: string) => {
  console.log(`UWBMap 收到围栏违规事件: 设备 ${deviceId} 进入围栏`);
  
  // 查找设备标签信息
  const deviceTag = allTags.value.find(tag => tag.id === deviceId);
  const deviceName = deviceTag ? deviceTag.label : deviceId;
  
  // 更新违规设备列表，记录当前时间戳
  fenceViolationDevices.value.set(deviceId, {
    name: deviceName,
    timestamp: Date.now()
  });
  
  // 向触发警告的设备发送MQTT消息
  sendMqttAlertToDevice(deviceId, "on");
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
    // 清除测试设备
    clearTestDevices();
    
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
    
    // 初始化基站数据
    if (anchorManagerRef.value) {
      // 同步基站数据
      anchors.value = anchorManagerRef.value.anchorList;
      
      // 监听基站数据变化
      watch(() => anchorManagerRef.value?.anchorList, (newAnchors) => {
        if (newAnchors) {
          anchors.value = newAnchors;
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
  background: #f5f6fa; /* 浅灰色背景，类似参考图 */
  position: relative;
  display: flex; /* 使用flex布局 */
  flex-direction: column; /* 垂直排列子元素 */
  font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', Arial, sans-serif;
  padding: 10px;
  box-sizing: border-box; /* 确保内边距不会增加元素总宽度 */
}

/* 地图分屏容器 */
/* UWB地图容器 */
.uwb-map-container {
  height: 100%;
  width: 100%;
  position: relative;
  overflow: hidden;
}

/* 分隔器相关样式已移除 */

/* 页面顶部分隔器样式 */
.page-top-divider {
  width: 100%;
  height: 2px;
  background: linear-gradient(to right, #0078d4, #00a1ff, #0078d4);
  margin-bottom: 15px;
  box-shadow: 0 1px 3px rgba(0, 120, 212, 0.2);
  border-radius: 2px;
  position: relative;
  z-index: 10;
}

/* 地图和控制面板之间的水平分隔器样式 */
.map-controls-divider {
  width: 100%;
  height: 3px;
  background: linear-gradient(to right, rgba(0, 120, 212, 0.1), rgba(0, 120, 212, 0.7), rgba(0, 120, 212, 0.1));
  margin: 5px 0;
  border-radius: 3px;
  position: relative;
  z-index: 10;
}

/* 地图和右侧控制区域之间的垂直分隔器样式 */
.vertical-divider {
  position: absolute;
  top: 10px;
  right: 450px; /* 根据实际布局调整位置 */
  width: 4px;
  height: calc(100% - 20px);
  background: linear-gradient(to bottom, rgba(220, 53, 69, 0.1), rgba(220, 53, 69, 0.8), rgba(220, 53, 69, 0.1));
  border-radius: 4px;
  box-shadow: 0 0 8px rgba(220, 53, 69, 0.3);
  z-index: 100;
  display: flex;
  justify-content: center;
  align-items: center;
}

/* 垂直分隔器的文字标签 */
.vertical-divider::after {
  content: "分隔器";
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: rgba(220, 53, 69, 0.7);
  font-size: 12px;
  writing-mode: vertical-rl;
  text-orientation: mixed;
  white-space: nowrap;
  letter-spacing: 2px;
  font-weight: bold;
}

/* 移动端样式调整 */
@media screen and (max-width: 768px) {
  .container {
    padding: 5px;
    height: calc(100vh - 50px); /* 为移动端的底部导航条留出空间 */
  }
  
  /* 移动端分隔器样式调整 */
  .page-top-divider {
    height: 1px;
    margin-bottom: 8px;
  }
  
  .map-controls-divider {
    height: 2px;
    margin: 3px 0;
  }
  
  /* 移动端UWB地图样式 */
  .uwb-map-container {
    height: calc(100vh - 60px);
  }
}

/* 警告面板样式 */
.alerts-panel {
  position: fixed;
  top: 10px;
  right: 10px;
  width: 350px;
  max-height: 400px;
  overflow-y: auto;
  background-color: #ffffff;
  border: 1px solid #f0f0f0;
  border-radius: 5px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  z-index: 9999;
  padding: 15px;
  transition: all 0.3s ease-in-out;
}

/* 移动端警告面板样式 */
@media screen and (max-width: 768px) {
  .alerts-panel {
    width: calc(100% - 20px);
    max-height: 30vh;
    top: auto;
    bottom: calc(40vh + 20px); /* 放在控制面板上方 */
    padding: 10px;
  }
  
  .alerts-header h3 {
    font-size: 14px;
  }
  
  .alert-section h4 {
    font-size: 13px;
  }
  
  .alert-item {
    padding: 8px 10px;
    font-size: 13px;
  }
}

.alerts-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  border-bottom: 1px solid rgba(255, 77, 79, 0.2);
  padding-bottom: 12px;
}

.alerts-header h3 {
  margin: 0;
  color: #ff4d4f;
  font-size: 16px;
  font-weight: 600;
  display: flex;
  align-items: center;
}

.alerts-header h3:before {
  content: "";
  display: inline-block;
  width: 8px;
  height: 8px;
  background-color: #ff4d4f;
  border-radius: 50%;
  margin-right: 8px;
  animation: pulse 1.5s infinite;
}

.alert-section {
  margin-bottom: 18px;
}

.alert-section h4 {
  margin: 0 0 12px 0;
  color: #ff4d4f;
  font-size: 14px;
  font-weight: 600;
  display: flex;
  align-items: center;
}

.alert-item {
  background-color: rgba(255, 77, 79, 0.08);
  border-radius: 8px;
  padding: 12px 15px;
  margin-bottom: 10px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: all 0.2s ease;
}

.alert-item:hover {
  background-color: rgba(255, 77, 79, 0.12);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(255, 77, 79, 0.15);
}

.fence-alert {
  border-left: 4px solid #ff4d4f;
  color: #cf1322;
}

.distance-alert {
  border-left: 4px solid #ff4d4f;
  color: #cf1322;
  animation: glow 2s infinite alternate;
}

@keyframes glow {
  from {
    box-shadow: 0 0 5px rgba(255, 77, 79, 0.5);
  }
  to {
    box-shadow: 0 0 15px rgba(255, 77, 79, 0.8), 0 0 5px rgba(255, 77, 79, 0.4) inset;
  }
}

/* 移动端设备详情弹窗样式 */
.mobile-device-dialog {
  margin: 0 !important;
}

.device-detail-item {
  display: flex;
  padding: 10px 0;
  border-bottom: 1px solid #eee;
}

.device-detail-item .label {
  font-weight: bold;
  min-width: 80px;
  color: #666;
}

.device-detail-item .value {
  flex: 1;
}

/* 水平分隔器样式 */
.horizontal-divider {
  height: 1px;
  background: linear-gradient(to right, rgba(0, 120, 212, 0.1), rgba(0, 120, 212, 0.5), rgba(0, 120, 212, 0.1));
  margin: 12px 0;
  border-radius: 1px;
}

@media screen and (max-width: 768px) {
  /* 调整移动端下的弹窗样式 */
  .el-dialog {
    width: 90% !important;
    margin: 10vh auto !important;
    max-width: none !important;
  }
  
  /* 调整按钮组在移动端的显示 */
  .button-group {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;
  }
  
  /* 移动端下的水平分隔器 */
  .horizontal-divider {
    margin: 8px 0;
  }
}

@keyframes pulse {
  from {
    box-shadow: 0 0 5px rgba(255, 77, 79, 0.5);
  }
  to {
    box-shadow: 0 0 15px rgba(255, 77, 79, 0.8);
  }
}

/* 面板内警告信息样式 */
.safety-alert-message {
  background-color: #ffccc7;
  border: 2px solid #ff4d4f;
  color: #ff4d4f;
  padding: 10px;
  margin-top: 10px;
  border-radius: 4px;
  font-weight: bold;
  text-align: center;
}

/* 确保P5MultiTrail组件占据剩余所有空间 */
.container :deep(.p5-canvas-container) {
  flex: 1; /* 占据所有剩余空间 */
  min-height: 900px; /* 进一步增加最小高度 */
  width: 100%;
  position: relative;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.15);
  margin: 5px;
}

/* 距离计算面板样式 */
.distance-panel {
  position: absolute;
  top: 20px;
  left: 20px;
  background: #ffffff;
  padding: 16px;
  border-radius: 5px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  z-index: 1000;
  width: 380px;
  transition: all 0.3s ease-in-out;
}

/* 移动端距离面板样式 */
@media screen and (max-width: 768px) {
  .distance-panel {
    position: fixed;
    top: 10px;
    left: 10px;
    width: calc(100% - 20px);
    padding: 10px;
    font-size: 14px;
    max-height: 40vh;
    overflow-y: auto;
  }
  
  .distance-panel h3 {
    font-size: 16px;
    margin-bottom: 10px;
  }
  
  .distance-inputs {
    flex-direction: column;
    gap: 10px;
  }
  
  .input-column {
    width: 100%;
  }
}

.distance-panel h3 {
  margin-top: 0;
  margin-bottom: 15px;
  color: #409eff;
  font-size: 16px;
  font-weight: 600;
  text-align: center;
  padding-bottom: 10px;
  border-bottom: 1px solid rgba(64, 158, 255, 0.2);
}

.distance-inputs {
  display: flex;
  justify-content: space-between;
  margin-bottom: 20px;
}

.input-column {
  display: flex;
  flex-direction: column;
  width: 47%;
}

.input-column label {
  margin-bottom: 8px;
  font-size: 14px;
  color: #606266;
  font-weight: 500;
}

.input-column .el-select {
  width: 100%;
}

.distance-panel .result {
  background-color: rgba(64, 158, 255, 0.05);
  padding: 15px;
  border-radius: 8px;
  margin-top: 10px;
}

.distance-panel .result div {
  margin-bottom: 10px;
  font-size: 14px;
  color: #333;
  font-weight: 500;
}

.distance-panel .result div strong {
  color: #409eff;
}

.controls {
  position: absolute;
  top: 20px;
  right: 20px;
  z-index: 10;
  background: #ffffff;
  padding: 16px;
  border-radius: 5px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 230px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease-in-out;
}

/* 移动端控制面板样式 */
@media screen and (max-width: 768px) {
  .controls {
    position: fixed;
    top: auto;
    bottom: 10px;
    right: 10px;
    width: calc(100% - 20px); /* 减去左右外边距 */
    max-height: 40vh;
    overflow-y: auto;
    padding: 10px;
    gap: 8px;
    z-index: 1001; /* 确保在其他元素上方 */
    border-radius: 8px;
  }
  
  .control-title {
    font-size: 14px;
    margin-bottom: 5px;
    padding-bottom: 5px;
  }
  
  /* 在移动端为控制面板添加收起/展开功能 */
  .controls.collapsed {
    height: 40px;
    overflow: hidden;
  }
}

.control-title {
  font-size: 15px;
  font-weight: 600;
  color: #0078d4;
  margin-bottom: 8px;
  padding-bottom: 8px;
  border-bottom: 1px solid #e0e0e0;
  text-align: center;
}

/* 开关组样式 */
.controls .el-switch-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 5px;
  padding-bottom: 15px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

/* 添加开关样式，使其更突出 */
.controls :deep(.el-switch) {
  transform: scale(1.1);
}

/* 改善开关文字样式 */
.controls :deep(.el-switch__label) {
  font-size: 14px;
  font-weight: 500;
  color: #333;
}

/* 按钮组样式 */
.controls .button-group {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.controls .management-buttons {
  margin-top: 5px;
  padding-top: 15px;
  border-top: 1px solid rgba(0, 0, 0, 0.05);
}

/* 按钮样式优化 */
.controls .el-button {
  border-radius: 8px;
  font-weight: 500;
  transition: all 0.3s ease;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.05);
}

.controls .el-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

/* 提示文字样式优化 */
.tip {
  font-size: 13px;
  color: #606266;
  margin-top: 12px;
  padding: 10px;
  background-color: rgba(64, 158, 255, 0.1);
  border-radius: 6px;
  text-align: center;
  line-height: 1.5;
  border-left: 3px solid #409eff;
}

.active {
  background-color: #409eff;
  border-color: #409eff;
  color: white;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
}
</style>