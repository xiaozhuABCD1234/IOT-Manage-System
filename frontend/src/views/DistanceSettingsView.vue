<template>
  <div class="container mx-auto space-y-6 p-6">
    <div class="space-y-2">
      <h1 class="text-3xl font-bold">距离设置管理</h1>
      <p class="text-muted-foreground">配置标记、标签和类型之间的安全距离</p>
    </div>

    <div class="grid grid-cols-1 gap-6 lg:grid-cols-2 xl:grid-cols-3">
      <!-- 单对距离设置 -->
      <PairDistanceForm />

      <!-- 组合距离设置 -->
      <CombinationsDistanceForm />

      <!-- 笛卡尔积距离设置 -->
      <CartesianDistanceForm />
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  PairDistanceForm,
  CombinationsDistanceForm,
  CartesianDistanceForm,
} from "@/components/distance";
</script>

