<template>
  <!-- 最外层滚动容器 -->
  <ScrollArea class="h-full w-full">
    <!-- 网格容器：自动换行，最小宽度 280px，列数随容器宽度变化 -->
    <div
      class="grid gap-3 p-0.5"
      style="grid-template-columns: repeat(auto-fill, minmax(280px, 1fr))"
    >
      <div
        v-for="m in marks"
        :key="m.id"
        class="bg-card flex items-center gap-3 rounded-md border px-3 py-2 shadow-sm"
      >
        <Wifi v-if="m.online" class="h-5 w-5 text-green-500" />
        <WifiOff v-else class="h-5 w-5 text-gray-400" />

        <Label class="flex-1 truncate" :class="{ 'text-amber-300': !m.name }">
          {{ m.name || "未知设备" }}
        </Label>

        <Badge variant="outline">{{ m.id }}</Badge>
        <Badge variant="secondary">{{ m.topic }}</Badge>
      </div>
    </div>

    <!-- 空数据提示 -->
    <p v-if="!marks.length" class="mt-4 text-center text-sm text-gray-400">暂无设备在线......</p>
  </ScrollArea>
</template>

<script setup lang="ts">
import type { MarkOnline } from "@/utils/mqtt";
import { Wifi, WifiOff } from "lucide-vue-next";
import { Badge } from "@/components/ui/badge";
import { Label } from "@/components/ui/label";
import { ScrollArea } from "@/components/ui/scroll-area";

defineProps<{
  marks: MarkOnline[];
}>();
</script>
