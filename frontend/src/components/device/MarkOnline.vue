<template>
  <Card class="h-full w-full">
    <CardHeader>
      <CardTitle class="flex items-center gap-2">
        <Wifi class="h-5 w-5" />
        标记在线状态
      </CardTitle>
      <CardDescription>实时监控所有标记设备的在线情况</CardDescription>
    </CardHeader>
    <CardContent>
      <MarkOnlineGrid :marks="store.markList" :device-names="names" />
    </CardContent>
  </Card>
</template>

<script setup lang="ts">
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Wifi } from "lucide-vue-next";
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
