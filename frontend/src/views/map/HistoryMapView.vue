<script setup lang="ts">
declare global {
  interface Window {
    _AMapSecurityConfig?: {
      securityJsCode: string;
    };
  }
}

import { onMounted, onUnmounted, ref, defineProps } from 'vue';
import AMapLoader from '@amap/amap-jsapi-loader';
import { useConfigStore } from '@/stores/config';
import { trajectoryAPI } from '@/api/trajectory';
import type { PathMini } from '@/api/trajectory';
import gcoord from 'gcoord';

const ConfigStore = useConfigStore();

interface PathOverlay {
  id: number;
  polyline: any;
  startMarker?: any;  // 起点标记变为可选
  endMarker?: any;    // 终点标记变为可选
}

const mapRef = ref(null);
let map: any = null;
const overlays = ref<PathOverlay[]>([]);
const colors = ['#1890ff', '#52c41a', '#fadb14', '#ff4d4f', '#722ed1'];

const props = defineProps({
  startTime: {
    type: String,
    required: true
  },
  endTime: {
    type: String,
    required: true
  },
  showStartMarker: {
    type: Boolean,
    default: false
  },
  showEndMarker: {
    type: Boolean,
    default: true
  }
});

const createPathOverlay = (AMap: any, deviceId: number, coords: Array<[number, number]>) => {
  if (coords.length === 0) return null;

  const colorIndex = deviceId % colors.length;
  const color = colors[colorIndex];

  // 创建折线（保持不变）
  const polyline = new AMap.Polyline({
    path: coords,
    strokeColor: color,
    strokeWeight: 3,
    lineJoin: 'round'
  });

  let startMarker = null;
  let endMarker = null;

  // 如果 showStartMarker 为 true，则创建起点标记
  if (props.showStartMarker) {
    startMarker = new AMap.Marker({
      position: coords[0],
      content: `
        <div class="device-marker start" style="background: ${color}">
          ${deviceId}
        </div>`,
      offset: new AMap.Pixel(-12, -12)
    });
  }

  // 如果 showEndMarker 为 true，则创建终点标记
  if (props.showEndMarker) {
    endMarker = new AMap.Marker({
      position: coords[coords.length - 1],
      content: `
        <div class="device-marker end" style="background: ${color}">
          ${deviceId}
        </div>`,
      offset: new AMap.Pixel(-12, -12)
    });
  }

  // 只有当标记存在时才添加到地图
  const markersToAdd = [];
  if (startMarker) markersToAdd.push(startMarker);
  if (endMarker) markersToAdd.push(endMarker);

  map.add([polyline, ...markersToAdd]);

  return {
    id: deviceId,
    polyline,
    startMarker,  // 可能为 null
    endMarker     // 可能为 null
  };
};

const loadHistoryPaths = async (AMap: any) => {
  try {
    const idsResponse = await trajectoryAPI.getIds();
    const deviceIds = idsResponse.data.data;

    const pathRequests = deviceIds.map(async (deviceId: number) => {
      try {
        const { data } = await trajectoryAPI.getMiniPath({
          id: deviceId,
          start_time: "2025-05-17T13:28:10",
          end_time: "2025-05-22T13:28:10"
        });
        return data;
      } catch (error) {
        console.error(`设备 ${deviceId} 路径请求失败:`, error);
        return null;
      }
    });

    const pathResponses = await Promise.all(pathRequests);
    const Paths = pathResponses
      .filter((response): response is PathMini[] => response !== null)
      .flat();

    const deviceMap = new Map<number, Array<Array<[number, number]>>>();

    Paths.forEach(response => {
      const deviceId = response.id;
      const rawPath = response.path;

      const validCoords = rawPath
        .map(([lng, lat]) => gcoord.transform([lng, lat], gcoord.WGS84, gcoord.GCJ02))
        .filter(coord => coord !== null) as Array<[number, number]>;

      if (validCoords.length === 0) {
        console.warn(`设备 ${deviceId} 无有效坐标，跳过绘制`);
        return;
      }

      if (!deviceMap.has(deviceId)) {
        deviceMap.set(deviceId, []);
      }
      deviceMap.get(deviceId)?.push(validCoords);
    });

    deviceMap.forEach((pathList, deviceId) => {
      pathList.forEach((coords, index) => {
        const overlay = createPathOverlay(AMap, deviceId, coords);
        if (overlay) {
          overlays.value.push(overlay); // 直接添加覆盖物，不再移除标记
        }
      });
    });

  } catch (error) {
    console.error('路径加载失败:', error);
    throw new Error('无法显示历史路径');
  }
};

onMounted(async () => {
  window._AMapSecurityConfig = {
    securityJsCode: ConfigStore.securityJsCode,
  };

  AMapLoader.load({
    key: ConfigStore.key,
    version: '2.0',
    plugins: ['AMap.Polyline', 'AMap.Marker']
  }).then(async (AMap) => {
    map = new AMap.Map(mapRef.value, {
      viewMode: '3D',
      mapStyle: 'amap://styles/normal',
      zoom: 17,
      center: [121.891751, 30.902079]
    });

    await loadHistoryPaths(AMap);
  }).catch(console.error);
});

onUnmounted(() => {
  overlays.value.forEach(overlay => {
    try {
      if (map && !map.isDestroyed()) {
        if (overlay.polyline) map.remove(overlay.polyline);
        if (overlay.startMarker) map.remove(overlay.startMarker);
        if (overlay.endMarker) map.remove(overlay.endMarker);
      }
      overlay.polyline?.destroy();
      overlay.startMarker?.destroy();
      overlay.endMarker?.destroy();
    } catch (e) {
      console.warn('清理覆盖物失败:', e);
    }
  });
  overlays.value = [];

  try {
    if (map && !map.isDestroyed()) {
      map.destroy();
      map = null;
    }
  } catch (e) {
    console.warn('地图销毁失败:', e);
  }
});
</script>

<template>
  <div class="map-container">
    <div ref="mapRef" style="width: 100%; height: 100%"></div>
  </div>
</template>

<style lang="css" scoped>
.map-container {
  position: relative;
  width: 100%;
  height: 100%;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  background-color: rgba(255, 255, 255, 0.0);
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

.device-marker.end {
  border-radius: 4px;
}
</style>
