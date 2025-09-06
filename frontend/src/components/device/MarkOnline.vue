<template>
  <div class="h-full w-full p-2">
    <h1 class="mb-4 text-2xl font-bold whitespace-nowrap">标记在线状态</h1>
    <MarkStatusList :marks="marks" />
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, ref } from "vue";
import { connectMQTT, disconnectMQTT, parseOnlineMessage, TOPIC_ONLINE } from "@/utils/mqtt";
import type { MarkOnline } from "@/utils/mqtt";
import type { MqttClient } from "mqtt";
import { getMarkByDeviceID } from "@/api/mark";
import { createDeviceStateMachine } from "@/utils/deviceState";
// import { sortMarks } from "@/utils/sort";
import MarkStatusList from "@/components/device/MarkOnlineGrid.vue";

/* ---------- 原来就有的 ---------- */
const marks = ref<MarkOnline[]>([]);
let mqttClient: MqttClient | null = null;

/* ---------- 新增：把状态机搬出去，但逻辑仍在本文件调用 ---------- */
const {
  onMessage,
  start: startStateMachine,
  stop: stopStateMachine,
} = createDeviceStateMachine(marks); // 把 marks 引用传进去，外部直接改

/* ---------- 生命周期 ---------- */
onMounted(() => {
  mqttClient = connectMQTT();
  mqttClient.subscribe(TOPIC_ONLINE);
  mqttClient.on("message", async (topic, payload) => {
    const data = parseOnlineMessage(topic, payload);
    try {
      // 补名字
      const res = await getMarkByDeviceID(data.id);
      data.name = res.data.data.mark_name;
    } catch {}
    onMessage(data); // 交给状态机
  });

  /* 每 5 秒排序一次（状态机内部也会即时排序，这里做双保险） */
  startStateMachine();
});

onUnmounted(() => {
  if (mqttClient) disconnectMQTT(mqttClient);
  stopStateMachine(); // 清定时器
});
</script>
