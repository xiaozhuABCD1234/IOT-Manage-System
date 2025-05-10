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
import { ref, onMounted, onUnmounted } from "vue";
import P5MultiTrail from "@/components/P5MultiTrail.vue";
import mqtt from "mqtt";
import { useConfigStore } from "@/stores/config";

const ConfigStore = useConfigStore();
const points = ref([]);

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

    const uwb = sensors.find((s) => s.name === "UWB");
    if (uwb?.data?.value?.length === 2) {
      const [x, y] = uwb.data.value;

      // 更新或添加点
      const index = points.value.findIndex(p => p.id === id);
      if (index > -1) {
        points.value[index] = { ...points.value[index], x, y };
      } else {
        points.value = [...points.value, { id, x, y }];
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
