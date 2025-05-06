<template>
  <el-row :gutter="20" class="row-spacing">
    <el-col
      v-for="(pair, index) in devicePairs"
      :key="index"
      :span="12"
      class="distance-col"
    >
      <DistanceDisplay
        :device-a="pair.a"
        :device-b="pair.b"
      />
    </el-col>
  </el-row>
</template>

<script lang="ts" setup>
import { computed, onMounted, onUnmounted, reactive, ref } from "vue";
import mqtt from "mqtt";
import DistanceDisplay from "@/components/DistanceDisplay.vue";

interface Device {
  id: number;
  lat: number;
  lon: number;
  updated?: number;
}

const MQTT_URL = "ws://106.14.209.20:8083/mqtt";
const MQTT_TOPIC = "location/sensors/#";

// 响应式设备存储
const devices = reactive<Record<number, Device>>({});
const selectedIds = ref<Set<number>>(new Set([1, 2, 3]));
const mqttClient = ref<mqtt.MqttClient | null>(null);

// 计算设备配对
const devicePairs = computed(() => {
  const ids = Array.from(selectedIds.value);
  const pairs = [];

  for (let i = 0; i < ids.length; i++) {
    for (let j = i + 1; j < ids.length; j++) {
      const idA = ids[i];
      const idB = ids[j];
      if (devices[idA] && devices[idB]) {
        pairs.push({ a: devices[idA], b: devices[idB] });
      }
    }
  }

  return pairs;
});

// MQTT初始化
const initMqtt = () => {
  const options = {
    clean: true,
    connectTimeout: 4000,
    clientId: `monitor_${Date.now()}_${
      Math.random().toString(16).substr(2, 8)
    }`,
  };

  mqttClient.value = mqtt.connect(MQTT_URL, options);

  mqttClient.value.on("connect", () => {
    console.log("MQTT Connected");
    mqttClient.value?.subscribe(MQTT_TOPIC, (err) => {
      if (err) console.error("Subscribe error:", err);
    });
  });

  mqttClient.value.on("message", (topic, payload) => {
    try {
      const data = JSON.parse(payload.toString());
      const deviceId = Number(data.id);

      if (!selectedIds.value.has(deviceId)) return;

      const rtkSensor = data.sensors.find((s: any) => s.name === "RTK");
      if (!rtkSensor || !Array.isArray(rtkSensor.data?.value)) return;

      const [lon, lat] = rtkSensor.data.value;
      updateDevicePosition(deviceId, lat, lon);
    } catch (error) {
      console.error("MQTT Message Error:", error);
    }
  });
};

// 更新设备位置
const updateDevicePosition = (id: number, lat: number, lon: number) => {
  if (!isValidCoordinate(lat, lon)) {
    console.warn(`Invalid coordinates for ${id}: ${lat}, ${lon}`);
    return;
  }

  devices[id] = {
    id,
    lat,
    lon,
    updated: Date.now(),
  };
};

// 坐标验证
const isValidCoordinate = (lat: number, lon: number) => {
  return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
};

// 生命周期钩子
onMounted(() => {
  initMqtt();
});

onUnmounted(() => {
  mqttClient.value?.end();
});
</script>

<style>
.row-spacing {
  margin-bottom: 20px;
}

.distance-col {
  margin-bottom: 20px;
}

@media (max-width: 768px) {
  .el-col {
    width: 100%;
    margin-bottom: 15px; /* 移动端垂直间距 */
  }
}
</style>
