<template>
  <div class="distance-calculator">
    <div class="device-info">
      <div class="device-card">
        <div class="device-content">
          <div class="device-id">ID: {{ deviceA.id }}</div>
          <div class="device-coords">
            <div class="coord-item">纬度: {{ deviceA.lat }}</div>
            <div class="coord-item">经度: {{ deviceA.lon }}</div>
          </div>
        </div>
      </div>

      <div class="device-card">
        <div class="device-content">
          <div class="device-id">ID: {{ deviceB.id }}</div>
          <div class="device-coords">
            <div class="coord-item">纬度: {{ deviceB.lat }}</div>
            <div class="coord-item">经度: {{ deviceB.lon }}</div>
          </div>
        </div>
      </div>
    </div>

    <div class="distance-container">
      <div class="distance-value">{{ distance }} m</div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, defineProps } from "vue";

// 定义设备类型
interface Device {
  id: string;
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
  font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
  max-width: 600px;
  margin: 20px auto;
  padding: 20px;
  border-radius: 12px;
  background-color: #f5f7fa;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.device-info {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
}

.device-card {
  flex: 1;
  background-color: white;
  border-radius: 8px;
  padding: 16px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  transition: transform 0.2s ease;
}

.device-card:hover {
  transform: translateY(-3px);
}

.device-header {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid #eee;
}

.device-id {
  font-size: 14px;
  color: #666;
  margin-bottom: 8px;
}

.coord-item {
  font-size: 14px;
  margin-bottom: 4px;
  display: flex;
  align-items: center;
}

.coord-item::before {
  content: "";
  display: inline-block;
  width: 6px;
  height: 6px;
  background-color: #4a90e2;
  border-radius: 50%;
  margin-right: 8px;
}

.device-coords {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.distance-container {
  text-align: center;
  padding: 20px;
  background-color: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.distance-label {
  font-size: 14px;
  color: #666;
  margin-bottom: 8px;
}

.distance-value {
  font-size: 32px;
  font-weight: 600;
  color: #333;
  margin: 0;
}

@media (max-width: 600px) {
  .device-info {
    flex-direction: column;
  }

  .distance-value {
    font-size: 28px;
  }
}
</style>
