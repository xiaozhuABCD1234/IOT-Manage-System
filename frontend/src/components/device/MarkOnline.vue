<template>
  <div class="h-full w-full p-2">
    <h1 class="mb-4 text-2xl font-bold whitespace-nowrap">标记在线状态</h1>
    <MarkStatusList :marks="marks" :device-names="names" />
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, ref } from "vue";
import { connectMQTT, disconnectMQTT, parseOnlineMessage, TOPIC_ONLINE } from "@/utils/mqtt";
import type { MarkOnline } from "@/utils/mqtt";
import type { MqttClient } from "mqtt";
import { getAllDeviceIDToName } from "@/api/mark";
import { createDeviceStateMachine } from "@/utils/deviceState";
import MarkStatusList from "@/components/device/MarkOnlineGrid.vue";

/* ---------- 原来就有的 ---------- */
const marks = ref<MarkOnline[]>([]);
const names = ref<Map<string, string>>(new Map());
let mqttClient: MqttClient | null = null;

/* ---------- 新增：把状态机搬出去，但逻辑仍在本文件调用 ---------- */
const {
  onMessage,
  start: startStateMachine,
  stop: stopStateMachine,
} = createDeviceStateMachine(marks); // 把 marks 引用传进去，外部直接改

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
  /* 2. 每 5 秒再拉 */
  nameTimer = window.setInterval(loadNames, 5_000);

  /* 3. 连接 MQTT */
  mqttClient = connectMQTT();
  mqttClient.subscribe(TOPIC_ONLINE);
  mqttClient.on("message", (topic, payload) => {
    const data = parseOnlineMessage(topic, payload);
    onMessage(data); // 交给状态机
  });

  /* 4. 启动状态机（内部也有定时器） */
  startStateMachine();
});

onUnmounted(() => {
  /* 清 MQTT */
  if (mqttClient) disconnectMQTT(mqttClient);
  /* 清状态机定时器 */
  stopStateMachine();
  /* 清名字定时器 */
  if (nameTimer !== null) window.clearInterval(nameTimer);
});
</script>
