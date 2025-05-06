<template>
  <div class="distance-calculator">
    <div class="content-wrapper">
      <div class="devices-container">
        <div class="device-card">
          <div class="device-id">ID: {{ deviceA.id }}</div>
          <div class="device-coords">
            <div class="coord-item">
              <span class="coord-label">纬度</span>
              <span class="coord-value">{{ deviceA.lat }}</span>
            </div>
            <div class="coord-item">
              <span class="coord-label">经度</span>
              <span class="coord-value">{{ deviceA.lon }}</span>
            </div>
          </div>
        </div>

        <div class="separator">
          <div class="distance-value">{{ distance }}m</div>
        </div>

        <div class="device-card">
          <div class="device-id">ID: {{ deviceB.id }}</div>
          <div class="device-coords">
            <div class="coord-item">
              <span class="coord-label">纬度</span>
              <span class="coord-value">{{ deviceB.lat }}</span>
            </div>
            <div class="coord-item">
              <span class="coord-label">经度</span>
              <span class="coord-value">{{ deviceB.lon }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, defineProps } from "vue";

// 定义设备类型
interface Device {
  id: string|number;
  lat: number;
  lon: number;
}

// 接收 Props
const props = defineProps<{
  deviceA: Device;
  deviceB: Device;
}>();

// 计算距离的函数
const calculateDistance = (
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number,
): number => {
  const R = 6371000; // 地球半径（米）
  const radLat1 = (lat1 * Math.PI) / 180;
  const radLon1 = (lon1 * Math.PI) / 180;
  const radLat2 = (lat2 * Math.PI) / 180;
  const radLon2 = (lon2 * Math.PI) / 180;

  const deltaLat = radLat2 - radLat1;
  const deltaLon = radLon2 - radLon1;

  const a = Math.sin(deltaLat / 2) ** 2 +
    Math.cos(radLat1) * Math.cos(radLat2) * Math.sin(deltaLon / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return R * c;
};

// 计算并格式化距离
const distance = computed(() => {
  const { deviceA, deviceB } = props;
  if (!deviceA.lat || !deviceA.lon || !deviceB.lat || !deviceB.lon) return 0;

  return calculateDistance(
    deviceA.lat,
    deviceA.lon,
    deviceB.lat,
    deviceB.lon,
  ).toFixed(2);
});
</script>

<style scoped>
.distance-calculator {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen-Sans, Ubuntu, Cantarell, sans-serif;
  width: 100%;
  margin: 0 auto;
  padding: 16px;
  /* 移除背景色和阴影 */
}

.devices-container {
  display: flex;
  align-items: center;
  gap: 24px;
  flex-wrap: wrap;
}

.device-card {
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 16px;
  flex: 1 1 250px;
  padding: 16px;
  min-width: 180px;
  border: 1px solid #e9ecef; /* 保留浅灰色边框 */
  /* 移除背景色 */
  border-radius: 8px;
}

.device-id {
  flex: 0 0 auto;
  font-size: 16px;
  color: #212529;
  font-weight: 700;
}

.device-coords {
  display: flex;
  flex-direction: row;
  gap: 16px;
  flex-wrap: wrap;
  opacity: 0.75;
  font-size: 12px;
}

.coord-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.coord-label {
  width: 40px;
  text-align: right;
  margin-right: 8px;
}

.coord-value {
  color: #2b8a3e; /* 保留绿色强调色 */
  font-weight: 500;
}

.separator {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.distance-value {
  font-size: 24px;
  font-weight: 700;
  white-space: nowrap;
  padding: 8px 24px;
  /* 移除渐变背景，改为纯色 */

  color: #228be6;
  border-radius: 4px; /* 减小圆角 */
}

.distance-value:hover {
  /* 移除缩放动画 */
  background-color: #e9ecef; /* 简单的悬停反馈 */
}
</style>
