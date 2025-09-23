<template>
  <Card class="mx-auto mb-4 w-full max-w-4xl">
    <CardHeader>
      <CardTitle>
        <span class="text-gray-500">类型名称：</span>
        <span class="font-medium">{{ typeInfo.type_name }}</span></CardTitle
      >
      <CardDescription>
        <span>默认安全距离：</span>
        <span class="font-medium">
          {{ typeInfo.default_danger_zone_m === -1 ? "-" : typeInfo.default_danger_zone_m + " m" }}
        </span></CardDescription
      >
    </CardHeader>
  </Card>
</template>

<script setup lang="ts">
import {
  Card,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import type { MarkTypeResponse } from "@/types/mark";

defineProps<{
  typeInfo: MarkTypeResponse;
}>();
</script>
