<!-- src/components/TypeSelect.vue -->
<script setup lang="ts">
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { ref, watch } from "vue";
import { listMarkTypes } from "@/api/markType";
import type { MarkTypeResponse } from "@/types/mark";

const props = defineProps<{
  modelValue?: number; // 父组件传入的选中 id
}>();

const emit = defineEmits<{
  "update:modelValue": [id: number | undefined];
}>();

const options = ref<MarkTypeResponse[]>([]);
const innerId = ref(props.modelValue);

/* 同步父组件值变化 */
watch(
  () => props.modelValue,
  (val) => (innerId.value = val),
);

/* 内部选中变化时通知父组件 */
watch(innerId, (val) => emit("update:modelValue", val));

/* 拉取数据 */
listMarkTypes().then((res) => (options.value = res.data.data));
</script>

<template>
  <Select v-model="innerId">
    <SelectTrigger class="w-[180px]">
      <SelectValue placeholder="请选择类型" />
    </SelectTrigger>
    <SelectContent>
      <SelectItem
        v-for="opt in options"
        :key="opt.id"
        :value="opt.id"
        class="flex w-full justify-between"
      >
        <span>{{ opt.type_name }}</span>
        <span class="text-muted-foreground">({{ opt.default_danger_zone_m }}m)</span>
      </SelectItem>
    </SelectContent>
  </Select>
</template>
