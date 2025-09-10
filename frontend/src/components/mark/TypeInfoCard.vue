<template>
  <Card class="mx-auto mb-4 w-full max-w-4xl">
    <CardHeader>
      <CardTitle>类型信息</CardTitle>
    </CardHeader>
    <CardContent class="grid grid-cols-2 gap-2 text-sm">
      <div>
        <span class="text-gray-500">ID：</span>
        <span class="font-medium">{{ typeInfo.id }}</span>
      </div>
      <div>
        <span class="text-gray-500">名称：</span>
        <span class="font-medium">{{ typeInfo.type_name }}</span>
      </div>
      <div>
        <span class="text-gray-500">默认安全距离：</span>
        <span class="font-medium">{{ typeInfo.default_safe_distance_m }} m</span>
      </div>
    </CardContent>
  </Card>
</template>

<script setup lang="ts">
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import type { MarkTypeResponse } from "@/types/mark";

defineProps<{
  typeInfo: MarkTypeResponse;
}>();
</script>
