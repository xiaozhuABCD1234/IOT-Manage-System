<!-- src/components/DeviceIDSelect.vue -->
<template>
  <Select v-model="selectedUnnamedId">
    <SelectTrigger id="unnamed-select" class="w-[180px]">
      <SelectValue placeholder="请选择一个未命名设备" />
    </SelectTrigger>
    <SelectContent>
      <!-- 如果没数据，给一句提示 -->
      <SelectItem v-for="id in unnamedIds" :key="id" :value="id">
        {{ id }}
      </SelectItem>
      <SelectItem v-if="unnamedIds.length === 0" disabled value="__empty">
        暂无未命名设备
      </SelectItem>
    </SelectContent>
  </Select>
</template>

<script setup lang="ts">
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

import { onMounted, onUnmounted, ref, computed, watch } from "vue";
import { connectMQTT, disconnectMQTT, parseOnlineMessage, TOPIC_ONLINE } from "@/utils/mqtt";
import type { MqttClient } from "mqtt";
import { getAllDeviceIDToName } from "@/api/mark";
import { useMarksStore } from "@/stores/marks";

const store = useMarksStore();

const marks = store.markList;
const names = ref<Map<string, string>>(new Map());
let mqttClient: MqttClient | null = null;

/* ---------- 新增：每 5 秒刷新一次名字 ---------- */
let nameTimer: number | null = null;
const loadNames = async () => {
  try {
    const res = await getAllDeviceIDToName(); // AxiosResponse
    const obj = res.data.data; // 普通对象
    names.value = new Map(Object.entries(obj || {})); // ← 转成 Map
  } catch {}
};

const unnamedIds = computed(() => {
  const namedSet = new Set(names.value.keys());
  return marks.map((m) => m.id).filter((id) => !namedSet.has(id));
});

const props = defineProps<{
  modelValue?: string; // 父组件绑定的值
}>();

const emit = defineEmits<{
  "update:modelValue": [id: string | undefined];
}>();

const selectedUnnamedId = ref(props.modelValue);
watch(
  () => props.modelValue,
  (val) => (selectedUnnamedId.value = val),
);
watch(selectedUnnamedId, (val) => emit("update:modelValue", val));

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
