<template>
  <UWBScatter :points="list" />
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, ref } from "vue";
import { connectMQTT, disconnectMQTT, parseUWBMessage } from "@/utils/mqtt";
import type { UWBFix } from "@/utils/mqtt";
import type { MqttClient } from "mqtt";
import UWBScatter from "@/components/maps/UWBScatter.vue";

/* ---------- 1. 响应式数据 ---------- */
const list = ref<UWBFix[]>([]);

/* ---------- 2. 节流控制 ---------- */
const lastUpdateTime = new Map<string, number>();
const UPDATE_INTERVAL = 1000; // ?秒更新一次

/* ---------- 3. MQTT 回调 ---------- */
let mqttClient: MqttClient | null = null;

const msgCallback = (_topic: string, payload: Buffer) => {
  try {
    const fix: UWBFix = parseUWBMessage(_topic, payload); // {x,y,id}

    // 节流控制
    const now = Date.now();
    const lastUpdate = lastUpdateTime.get(fix.id) || 0;
    if (now - lastUpdate < UPDATE_INTERVAL) {
      return;
    }
    lastUpdateTime.set(fix.id, now);

    /* 简单策略：有就更新，没有就追加 */
    const idx = list.value.findIndex((p) => p.id === fix.id);
    if (idx >= 0) list.value.splice(idx, 1, fix);
    else list.value.push(fix);
  } catch (e) {
    console.warn("丢弃一条非法 UWB 消息", e);
  }
};

/* ---------- 3. 生命周期 ---------- */
onMounted(() => {
  mqttClient = connectMQTT(); // 复用你封装的连接函数
  mqttClient.subscribe("location/#", { qos: 0 }, (err) => {
    if (err) return console.error("UWB 订阅失败", err);
    console.log("已订阅 location/#");
  });
  mqttClient.on("message", msgCallback);
});

onUnmounted(() => {
  disconnectMQTT(mqttClient!);
  list.value = []; // 清空
});
</script>
