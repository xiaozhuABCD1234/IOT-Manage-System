<script setup lang="ts">
declare global {
  interface Window {
    _AMapSecurityConfig?: {
      securityJsCode: string;
    };
  }
}

import { onMounted, onUnmounted, ref, shallowRef, watch, type Ref } from "vue";
import AMapLoader from "@amap/amap-jsapi-loader";
import mqtt from "mqtt";
import { useConfigStore } from "@/stores/config";
import { ElNotification } from 'element-plus';
import gcoord from 'gcoord';

interface ExposedMonitorMap {
  toggleFenceDrawing: () => void;
  resetFences: () => void;
  showFence: Ref<boolean>;
}

const ConfigStore = useConfigStore();

interface Device {
  id: number;
  path: Array<[number, number]>; // 更明确的写法
  polyline: any;
  marker: any;
}

interface Fence {
  id: string;
  polygon: any;
  editor: any;
}

const mapRef = ref(null);
let map: any = null;
let AMap: any = null; // Store AMap instance
let mouseTool: any = null; // Store MouseTool instance
const devices = ref<Device[]>([]);
let mqttClient: mqtt.MqttClient | null = null;

// 围栏相关状态
const drawingFence = ref(false);
const showFence = ref(false);
const fences = shallowRef<Fence[]>([]); // Use shallowRef for objects that won't be deeply mutated

// MQTT配置
const MQTT_CONFIG = {
  url: ConfigStore.mqtturl,
  options: {
    clean: true,
    connectTimeout: 4000,
    clientId: ConfigStore.mqttclientid +
      Math.random().toString(16).substr(2, 8) + "map",
    username: ConfigStore.mqttuser,
    password: ConfigStore.mqttpwd,
  },
  topic: ConfigStore.mqtttopic,
};

// 解析MQTT消息
const parseMessage = (topic: string, payload: Buffer) => {
  const data = JSON.parse(payload.toString());
  const id = data.id;
  const sensors = data.sensors;
  return {
    id,
    lng: sensors[0].data.value[0],
    lat: sensors[0].data.value[1],
  };
};

// 创建设备地图元素
const createDevice = (AMap: any, id: number, lng: number, lat: number) => {
  const colors = ["#1890ff", "#52c41a", "#fadb14", "#ff4d4f", "#722ed1"];
  const color = colors[id % colors.length];

  // 创建轨迹线
  const polyline = new AMap.Polyline({
    path: [[lng, lat]],
    strokeColor: color,
    strokeWeight: 3,
    lineJoin: "round",
  });

  // 创建设备标记
  const marker = new AMap.Marker({
    position: [lng, lat],
    content: `
      <div class="device-marker" style="background: ${color}">
        ${id}
      </div>`,
    offset: new AMap.Pixel(-12, -12),
  });

  // 添加到地图
  map.add([polyline, marker]);

  return {
    id,
    path: [[lng, lat]] as Array<[number, number]>,
    polyline,
    marker,
  };
};

// 检查设备是否在围栏内
const checkFenceViolation = (deviceId: number, lng: number, lat: number) => {
  const point = new AMap.LngLat(lng, lat);
  let isViolating = false;
  for (const fence of fences.value) {
    if (fence.polygon.contains(point)) {
      isViolating = true;
      break;
    }
  }

  if (isViolating) {
    ElNotification({
      title: "围栏警告",
      message: `设备 ${deviceId} 已进入电子围栏区域！`,
      type: "warning",
      duration: 3000,
    });
  }
};

// 更新设备位置
const updateDevicePosition = (
  AMapInstance: any,
  msg: { id: number; lng: number; lat: number },
) => {
  let device = devices.value.find((d) => d.id === msg.id);

  // 转换坐标系 (WGS84 -> GCJ02)
  const gcjCoord = gcoord.transform([msg.lng, msg.lat], gcoord.WGS84, gcoord.GCJ02);
  const gcjLng = gcjCoord[0];
  const gcjLat = gcjCoord[1];

  if (!device) {
    device = createDevice(AMapInstance, msg.id, gcjLng, gcjLat);
    devices.value.push(device);
  } else {
    const newPath = [
      ...device.path,
      [gcjLng, gcjLat] as [number, number],
    ];
    device.path = newPath;
    device.polyline.setPath(newPath);
    device.marker.setPosition([gcjLng, gcjLat]);
  }

  // 检查围栏违规
  if (showFence.value && fences.value.length > 0) {
    checkFenceViolation(msg.id, gcjLng, gcjLat);
  }
};

// 切换围栏绘制模式
const toggleFenceDrawing = () => {
  console.log('MonitorMap: toggleFenceDrawing called. Current drawingFence:', drawingFence.value);
  if (!AMap || !map) {
    console.log('MonitorMap: AMap or map not initialized.');
    return;
  }

  drawingFence.value = !drawingFence.value;
  if (drawingFence.value) {
    console.log('MonitorMap: Starting fence drawing.');
    // 开始绘制
    mouseTool = new AMap.MouseTool(map);
    mouseTool.polygon({
      strokeColor: "#FF33FF",
      strokeWeight: 6,
      strokeOpacity: 0.2,
      fillColor: "#1791fc",
      fillOpacity: 0.2,
      zIndex: 50,
    });
    mouseTool.on('draw', (event: any) => {
      const newPolygon = event.obj;
      const fenceId = `fence-${Date.now()}`;
      const editor = new AMap.PolyEditor(map, newPolygon);
      editor.open();

      fences.value = [...fences.value, { id: fenceId, polygon: newPolygon, editor }];
      console.log('MonitorMap: Fence drawn. New fences array:', fences.value);
      mouseTool.close(true); // 绘制完成后关闭工具
      mouseTool = null; // 清除mouseTool引用
      drawingFence.value = false;
      ElNotification({
        title: '围栏创建成功',
        message: `已创建新围栏 (ID: ${fenceId})`,
        type: 'success',
        duration: 3000,
      });
    });
    ElNotification({
      title: '开始绘制围栏',
      message: '请在地图上点击绘制多边形，双击完成绘制。',
      type: 'info',
      duration: 5000,
    });
  } else {
    console.log('MonitorMap: Stopping fence drawing.');
    // 停止绘制
    if (mouseTool) {
      mouseTool.close(true);
      mouseTool = null;
    }
    ElNotification({
      title: '停止绘制围栏',
      message: '电子围栏绘制已停止。',
      type: 'info',
      duration: 3000,
    });
  }
};

// 重置所有围栏
const resetFences = () => {
  console.log('MonitorMap: resetFences called. Current fences before clear:', fences.value.length);
  fences.value.forEach(fence => {
    if (fence.editor) {
      fence.editor.close();
      fence.editor = null; // 清除编辑器引用
    }
    if (map && !map.isDestroyed()) {
      map.remove(fence.polygon);
    }
    fence.polygon?.destroy();
  });
  fences.value = [];
  showFence.value = false;
  console.log('MonitorMap: Fences cleared. Current fences after clear:', fences.value.length);
  ElNotification({
    title: '围栏已重置',
    message: '所有电子围栏已清除。',
    type: 'info',
    duration: 3000,
  });
};

// 监听 showFence 变化，控制围栏的显示/隐藏
watch(showFence, (newVal) => {
  console.log('MonitorMap: showFence watch triggered. New value:', newVal);
  fences.value.forEach(fence => {
    if (fence.polygon) {
      fence.polygon.setVisible(newVal);
      console.log(`MonitorMap: Fence ${fence.id} visibility set to ${newVal}. Current visible: ${fence.polygon.getVisible()}`);
    }
  });
});

onMounted(async () => {
  window._AMapSecurityConfig = {
    securityJsCode: ConfigStore.securityJsCode,
  };

  AMapLoader.load({
    key: ConfigStore.key,
    version: "2.0",
    plugins: ["AMap.Polyline", "AMap.Marker", "AMap.MouseTool", "AMap.PolyEditor"],
  }).then((AMapInstance) => {
    AMap = AMapInstance; // Store AMap instance
    map = new AMap.Map(mapRef.value, {
      viewMode: "3D",
      mapStyle: "amap://styles/normal",
      zoom: 17,
      center: [121.891751, 30.902079],
    });

    mqttClient = mqtt.connect(MQTT_CONFIG.url, MQTT_CONFIG.options);

    mqttClient.on("connect", () => {
      mqttClient!.subscribe(MQTT_CONFIG.topic);
    });

    mqttClient.on("message", (topic, payload) => {
      const msg = parseMessage(topic, payload);
      updateDevicePosition(AMap, msg);
    });
  }).catch(console.error);
});

onUnmounted(() => {
  console.log('MonitorMap: Component unmounted. Starting cleanup.');
  if (mqttClient) {
    mqttClient.unsubscribe(MQTT_CONFIG.topic);
    mqttClient.end(true);
    mqttClient = null;
  }

  devices.value.forEach((device) => {
    try {
      if (map && !map.isDestroyed()) {
        map.remove([device.polyline, device.marker]);
      }
      device.polyline?.destroy();
      device.marker?.destroy();
    } catch (e) {
      console.warn("Cleanup error:", e);
    } finally {
      device.polyline = null;
      device.marker = null;
    }
  });
  devices.value = [];

  fences.value.forEach(fence => {
    if (fence.editor) fence.editor.close();
    if (map && !map.isDestroyed()) {
      map.remove(fence.polygon);
    }
    fence.polygon?.destroy();
    fence.editor = null;
  });
  fences.value = [];

  try {
    if (map && !map.isDestroyed()) {
      map.destroy();
      map = null;
    }
  } catch (e) {
    console.warn("Map destroy error:", e);
  }

  if (mouseTool) {
    mouseTool.close(true);
    mouseTool = null;
  }
  console.log('MonitorMap: Cleanup finished.');
});

defineExpose<ExposedMonitorMap>({
  toggleFenceDrawing,
  resetFences,
  showFence,
});
</script>

<template>
  <div class="map-container">
    <div ref="mapRef" style="width: 100%; height: 100%"></div>
    <div class="map-controls">
      <el-switch v-model="showFence" active-text="显示围栏区域" />
      <el-button 
        type="primary" 
        :class="{ 'active': drawingFence }"
        @click="toggleFenceDrawing"
      >
        {{ drawingFence ? '完成围栏' : '绘制电子围栏' }}
      </el-button>
      <el-button 
        type="info"
        @click="resetFences"
      >
        清除所有围栏
      </el-button>
    </div>
  </div>
</template>

<style lang="css" scoped>
.map-container {
  position: relative;
  width: 100%;
  height: 100%;
  min-height: 98vh;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  background-color: rgba(255, 255, 255, 0.0);
}

.map-controls {
  position: absolute;
  top: 10px;
  right: 10px;
  background: rgba(255, 255, 255, 0.9);
  padding: 10px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  z-index: 1000;
  display: flex;
  gap: 10px;
  align-items: center;
}
</style>

<style>
.device-marker {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: bold;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  border: 2px solid white;
}
</style>
