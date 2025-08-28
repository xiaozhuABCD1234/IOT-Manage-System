<script setup lang="ts">
import { onMounted, onUnmounted, ref, defineProps, type PropType, watch } from 'vue';
import AMapLoader from '@amap/amap-jsapi-loader';
import { useConfigStore } from '@/stores/config';
import { trajectoryAPI } from '@/api/trajectory';
import type { PathMini } from '@/api/trajectory';
import gcoord from 'gcoord';

declare global {
  interface Window {
    _AMapSecurityConfig?: {
      securityJsCode: string;
    };
  }
}

interface PathOverlay {
  id: number;
  polyline: any;
  startMarker?: any;
  endMarker?: any;
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
  },
  deviceIds: {
    type: Array as PropType<number[]>,
    required: true,
    validator: (value: number[]) => value.length > 0 && value.every(Number.isInteger)
  }
});

// 保存 AMap 实例供全局使用
let AMapInstance: any = null;

const ConfigStore = useConfigStore();

// 创建路径覆盖物
const createPathOverlay = (AMap: any, deviceId: number, coords: Array<[number, number]>) => {
  if (coords.length === 0) return null;

  const colorIndex = deviceId % colors.length;
  const color = colors[colorIndex];

  const polyline = new AMap.Polyline({
    path: coords,
    strokeColor: color,
    strokeWeight: 3,
    lineJoin: 'round'
  });

  let startMarker = null;
  let endMarker = null;

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

  map.add([polyline, ...(startMarker ? [startMarker] : []), ...(endMarker ? [endMarker] : [])]);

  return {
    id: deviceId,
    polyline,
    startMarker,
    endMarker
  };
};

// 加载历史轨迹数据
const loadHistoryPaths = async (AMap: any) => {
  try {
    const deviceIds = props.deviceIds;

    const pathRequests = deviceIds.map(async (deviceId: number) => {
      try {
        const { data } = await trajectoryAPI.getMiniPath({
          id: deviceId,
          start_time: props.startTime,
          end_time: props.endTime
        });
        return data;
      } catch (error) {
        console.error(`设备 ${deviceId} 路径请求失败:`, error);
        return null;
      }
    });

    const pathResponses = await Promise.all(pathRequests);
    const Paths = pathResponses.filter((response): response is PathMini[] => response !== null).flat();

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
          overlays.value.push(overlay);
        }
      });
    });

  } catch (error) {
    console.error('路径加载失败:', error);
    throw new Error('无法显示历史路径');
  }
};

// 监听参数变化并重新加载轨迹
watch(
  () => [props.deviceIds, props.startTime, props.endTime],
  async () => {
    if (map && !map.isDestroyed() && AMapInstance) {
      // 清除旧覆盖物
      overlays.value.forEach(overlay => {
        map.remove(overlay.polyline);
        overlay.startMarker && map.remove(overlay.startMarker);
        overlay.endMarker && map.remove(overlay.endMarker);
      });
      overlays.value = [];

      // 重新加载路径
      await loadHistoryPaths(AMapInstance);
    }
  },
  { deep: true }
);

// 初始化地图
onMounted(async () => {
  window._AMapSecurityConfig = {
    securityJsCode: ConfigStore.securityJsCode,
  };

  AMapLoader.load({
    key: ConfigStore.key,
    version: '2.0',
    plugins: ['AMap.Polyline', 'AMap.Marker']
  }).then((AMap) => {
    AMapInstance = AMap; // 保存 AMap 实例

    map = new AMap.Map(mapRef.value, {
      viewMode: '3D',
      mapStyle: 'amap://styles/normal',
      zoom: 17,
      center: [121.891751, 30.902079]
    });

    loadHistoryPaths(AMapInstance);
  }).catch(console.error);
});

// 销毁地图和资源
onUnmounted(() => {
  const cleanupOverlays = () => {
    for (let i = overlays.value.length - 1; i >= 0; i--) {
      const overlay = overlays.value[i];
      overlay.polyline && map?.remove(overlay.polyline);
      overlay.startMarker && map?.remove(overlay.startMarker);
      overlay.endMarker && map?.remove(overlay.endMarker);
    }
    overlays.value = [];
  };

  const destroyMap = () => {
    if (map && !map.isDestroyed()) {
      map.clearMap();
      map.destroy();
      map = null;
    }
  };

  cleanupOverlays();
  destroyMap();
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
