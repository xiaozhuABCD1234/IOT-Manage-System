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
import P5MultiTrail from "@/components/DataDisplay/P5MultiTrail.vue";
import mqtt from "mqtt";
import { useConfigStore } from "@/stores/config";
import { ElNotification } from "element-plus";

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
const points = ref<TrackingPoint[]>([]);
const prevIndoorStates = ref(new Map<string, boolean>());

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

        if (index > -1) {
          // 更新现有点
          points.value[index] = { ...points.value[index], x, y };
        } else {
          // 添加新点
          points.value = [...points.value, { id, x, y }];
        }
      }
    }
  } catch (e) {
    console.warn("Invalid message format:", e);
  }
};

onMounted(() => {
  client = mqtt.connect(mqttConfig.url, mqttConfig.options);
  client.on("connect", () => {
    console.log("Connected to MQTT broker");
    client?.subscribe(mqttConfig.topic);
  });
  client.on("message", (_, payload) => handleMessage(payload));
});

onUnmounted(() => {
  client?.end(true);
});
</script>

<style scoped>
.container {
  width: 100%;
  height: 100%;
  overflow: hidden;
  background: #f0f2f5;
}
</style>
