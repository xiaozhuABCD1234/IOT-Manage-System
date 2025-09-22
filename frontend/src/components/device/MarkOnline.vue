<template>
  <div class="h-full w-full p-2">
    <h1 class="mb-4 text-2xl font-bold whitespace-nowrap">标记在线状态</h1>
    <MarkOnlineGrid :marks="store.markList" :device-names="names" />
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, ref } from "vue";
import { connectMQTT, disconnectMQTT, parseOnlineMessage, TOPIC_ONLINE } from "@/utils/mqtt";
import type { MqttClient } from "mqtt";
import { getAllDeviceIDToName } from "@/api/mark";
import MarkOnlineGrid from "@/components/device/MarkOnlineGrid.vue";
import { useMarksStore } from "@/stores/marks";

const store = useMarksStore();

const names = ref<Map<string, string>>(new Map());
let mqttClient: MqttClient | null = null;

/* ---------- 新增：每 5 秒刷新一次名字 ---------- */
let nameTimer: number | null = null;
const loadNames = async () => {
  try {
    const res = await getAllDeviceIDToName(); // AxiosResponse
    const obj = res.data.data; // 普通对象
    names.value = new Map(Object.entries(obj)); // ← 转成 Map
  } catch {}
};

onMounted(() => {
  /* 1. 先拉一次名字 */
  loadNames();
  /* 2. 每 3 秒再拉 */
  nameTimer = window.setInterval(loadNames, 3_000);

  /* 3. 连接 MQTT */
  mqttClient = connectMQTT();
  mqttClient.subscribe(TOPIC_ONLINE);
  mqttClient.on("message", (topic, payload) => {
    const data = parseOnlineMessage(topic, payload);
    store.onMessage(data);
  });

  /* 4. 启动状态机（内部也有定时器） */
  store.start();
});

onUnmounted(() => {
  /* 清 MQTT */
  if (mqttClient) disconnectMQTT(mqttClient);
  /* 清状态机定时器 */
  store.stop();
  /* 清名字定时器 */
  if (nameTimer !== null) window.clearInterval(nameTimer);
});
</script>
