<script setup lang="ts">
import { type Component } from "vue";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";

interface StatItem {
  title: string;
  value: number;
  icon: Component;
  description: string;
}

defineProps<{
  stats: StatItem[];
  loading?: boolean;
}>();
</script>

<template>
  <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
    <Card v-for="stat in stats" :key="stat.title">
      <CardHeader class="flex flex-row items-center justify-between pb-2">
        <CardTitle class="text-sm font-medium">{{ stat.title }}</CardTitle>
        <component :is="stat.icon" class="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <template v-if="loading">
          <Skeleton class="h-8 w-24" />
          <Skeleton class="mt-1 h-4 w-32" />
        </template>
        <template v-else>
          <div class="text-2xl font-bold">{{ stat.value.toLocaleString() }}</div>
          <p class="text-xs text-muted-foreground">{{ stat.description }}</p>
        </template>
      </CardContent>
    </Card>
  </div>
</template>