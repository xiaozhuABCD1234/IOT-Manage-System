<!-- src/components/DeviceIDSelect.vue -->
<template>
  <Select v-model="selectedUnnamedId">
    <SelectTrigger id="unnamed-select" class="w-[180px]">
      <SelectValue placeholder="请选择一个未命名设备" />
    </SelectTrigger>
    <SelectContent>
      <!-- 如果没数据，给一句提示 -->
      <SelectItem v-for="id in store.unnamedIds" :key="id" :value="id">
        {{ id }}
        <Badge v-if="store.isDeviceOnline(id)" variant="outline" class="ml-2 text-xs"> 在线 </Badge>
        <Badge v-else variant="secondary" class="ml-2 text-xs"> 离线 </Badge>
      </SelectItem>
      <SelectItem v-if="store.unnamedIds.length === 0" disabled value="__empty">
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
import { Badge } from "@/components/ui/badge";
import { ref, watch } from "vue";
import { useMarksStore } from "@/stores/marks";

const store = useMarksStore();

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
</script>
