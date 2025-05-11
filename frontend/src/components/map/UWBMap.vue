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
import { ElNotification } from "element-plus"; // 引入通知组件

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
const prevIndoorStates = ref(new Map<string, boolean>()); // 存储设备的上一次室内状态

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
    const data = JSON.parse(payload.toString());
    const { id, indoor, sensors } = data;

    if (!id) return; // 缺少设备ID时直接返回

    // 处理室内状态变化
    if (typeof indoor !== "undefined") {
      const prevIndoor = prevIndoorStates.value.get(id);
      // 当状态存在且发生变化时触发通知
      if (prevIndoor !== undefined && prevIndoor !== indoor) {
        ElNotification({
          title: "状态变化",
          message: `设备 ${id} ${indoor ? "进入" : "离开"}室内`,
          type: "info",
          duration: 3000,
        });
      }
      prevIndoorStates.value.set(id, indoor); // 更新状态记录
    }

    // 仅在室内状态为true时处理定位数据
    if (indoor) {
      const uwb = sensors?.find((s: Sensor) => s.name === "UWB");
      if (uwb?.data?.value?.length === 2) {
        const [x, y] = uwb.data.value;
        const index = points.value.findIndex((p) => p.id === id);

        if (index > -1) {
          points.value[index] = { ...points.value[index], x, y };
        } else {
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
