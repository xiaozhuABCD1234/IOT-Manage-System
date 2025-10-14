<!-- src/components/DeviceSelect.vue -->
<template>
  <Select v-model="modelValue">
    <SelectTrigger id="unnamed-select" class="w-[180px]">
      <SelectValue placeholder="请选择一个设备" />
    </SelectTrigger>

    <SelectContent>
      <!-- 正常选项 -->
      <SelectItem v-for="[id, name] in nameList" :key="id" :value="id">
        {{ name }}
      </SelectItem>

      <!-- 空数据提示 -->
      <SelectItem v-if="nameList.length === 0" disabled value="__empty"> 暂无设备 </SelectItem>
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

import { getAllDeviceIDToName } from "@/api/mark";
import { ref, computed, watchEffect } from "vue";

/* -----------------  父组件 v-model 绑定  ----------------- */
const props = defineProps<{
  modelValue?: string; // 父组件当前选中的设备 id
}>();

const emit = defineEmits<{
  "update:modelValue": [id: string];
}>();

/* 本地中转变量，保持单向数据流 */
const selectedId = ref(props.modelValue);
watchEffect(() => (selectedId.value = props.modelValue)); // 外部改 -> 内部同步

/* -----------------  拉取远端数据  ----------------- */
const remoteMap = ref<Map<string, string>>(new Map());

async function load() {
  try {
    const res = await getAllDeviceIDToName();
    // 将 Record 转换为 Map
    const record = res.data.data ?? {};
    remoteMap.value = new Map(Object.entries(record));
  } catch (e) {
    console.error("获取设备列表失败", e);
    remoteMap.value = new Map();
  }
}

load();

/* 把 Map 转成数组方便 v-for 渲染 */
const nameList = computed(() => [...remoteMap.value]);
</script>
