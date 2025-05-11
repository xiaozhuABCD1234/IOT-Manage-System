<template>
  <div class="container">
    <P5MultiTrail
      :points="points"
      :trail-length="80"
      :grid-step="5"
      :show-grid="true"
    />
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, ref } from "vue";
import P5MultiTrail from "@/components/P5MultiTrail.vue";
import mqtt from "mqtt";
import { useConfigStore } from "@/stores/config";

// 新增类型定义
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
}

const ConfigStore = useConfigStore();
const points = ref<TrackingPoint[]>([]); // 明确定义数组类型
// MQTT配置
const mqttConfig = {
  url: ConfigStore.mqtturl,
  options: {
    clean: true,
    connectTimeout: 4000,
    clientId: ConfigStore.mqttclientid,
    username: ConfigStore.mqttuser,
    password: ConfigStore.mqttpwd,
  },
  topic: ConfigStore.mqtttopic,
};

let client: mqtt.MqttClient | null = null;

const handleMessage = (payload: Buffer) => {
  try {
    const { id, indoor, sensors } = JSON.parse(payload.toString());
    if (!indoor) return;

    // 添加类型注解
    const uwb = sensors.find((s: Sensor) => s.name === "UWB");
    if (uwb?.data?.value?.length === 2) {
      const [x, y] = uwb.data.value;

      // 使用类型断言确保操作安全
      const index = points.value.findIndex((p: TrackingPoint) => p.id === id);
      if (index > -1) {
        points.value[index] = { ...points.value[index], x, y };
      } else {
        points.value = [...points.value, { id, x, y } as TrackingPoint];
      }
    }
  } catch (e) {
    console.warn("Invalid message format:", e);
  }
};

onMounted(() => {
  client = mqtt.connect(mqttConfig.url, mqttConfig.options);
  client.on("connect", () => client?.subscribe(mqttConfig.topic));
  client.on("message", (_, payload) => handleMessage(payload));
});

onUnmounted(() => {
  client?.end();
});
</script>

<style scoped>
.container {
  width: 100%;
  height: 100%;
}
</style>
