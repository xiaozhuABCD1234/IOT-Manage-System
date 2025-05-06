<template>
  <div class="distance-calculator">
    <el-row>
      <el-col :span="9">
        <el-row>
          <el-col :span="8" class="id-column">
            <el-text type="primary" size="large" tag="b">
              <el-icon>
                <MapPin />
              </el-icon>
              ID: {{ deviceA.id }}</el-text>
          </el-col>
          <el-col :span="16">
            <el-row>
              <el-col :span="6">
                <el-text class="coord-label" type="info" size="small"
                >纬度</el-text>
              </el-col>
              <el-col :span="18">
                <el-text class="coord-value" type="info">{{
                  formatCoordinate(deviceA.lat)
                }}</el-text>
              </el-col>
            </el-row>
            <el-row>
              <el-col :span="6">
                <el-text class="coord-label" type="info" size="small"
                >经度</el-text>
              </el-col>
              <el-col :span="18">
                <el-text class="coord-value" type="info">{{
                  formatCoordinate(deviceA.lon)
                }}</el-text>
              </el-col>
            </el-row>
          </el-col>
        </el-row>
      </el-col>
      <el-col :span="6">
        <div class="distance-value">{{ distance }}m</div>
      </el-col>
      <el-col :span="9">
        <el-row>
          <el-col :span="8" class="id-column">
            <el-text type="primary" size="large" tag="b">
              <el-icon>
                <MapPin />
              </el-icon>
              ID: {{ deviceB.id }}</el-text>
          </el-col>
          <el-col :span="16">
            <el-row>
              <el-col :span="6">
                <el-text class="coord-label" type="info" size="small"
                >纬度</el-text>
              </el-col>
              <el-col :span="18">
                <el-text class="coord-value" type="info">{{
                  formatCoordinate(deviceB.lat)
                }}</el-text>
              </el-col>
            </el-row>
            <el-row>
              <el-col :span="6">
                <el-text class="coord-label" type="info" size="small"
                >经度</el-text>
              </el-col>
              <el-col :span="18">
                <el-text class="coord-value" type="info">{{
                  formatCoordinate(deviceB.lon)
                }}</el-text>
              </el-col>
            </el-row>
          </el-col>
        </el-row>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { computed, defineProps } from "vue";
import { MapPin } from "lucide-vue-next";

const formatCoordinate = (coord: number): string => {
  // 处理无效值情况
  if (typeof coord !== "number" || isNaN(coord)) return "0.00000000";
  // 固定显示8位小数
  return coord.toFixed(8);
};
// 定义设备类型
interface Device {
  id: string | number;
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
.id-column {
  display: flex;
  align-items: center;
  justify-content: center;
}

.distance-calculator {
  font-family:
    -apple-system,
    BlinkMacSystemFont,
    "Segoe UI",
    Roboto,
    Oxygen-Sans,
    Ubuntu,
    Cantarell,
    sans-serif;
  margin: 0 auto;
  padding: 16px;
  background-color: #ffffff;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.coord-label {
  width: 40px;
  text-align: right;
  margin-right: 8px;
}

.coord-value {
  color: #2b8a3e;
  font-weight: 500;
}

.distance-value {
  font-size: 24px;
  font-weight: 700;
  white-space: nowrap;
  padding: 8px 24px;
  color: #228be6;
  border-radius: 4px;
}
</style>
