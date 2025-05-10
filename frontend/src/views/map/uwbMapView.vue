<template>
  <div class="container">
    <P5MultiTrail
      :points="points"
      :trail-length="80"
      :grid-step="5"
      :show-grid="true"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import P5MultiTrail from "@/components/P5MultiTrail.vue";

const points = ref([
  { id: "A", x: 0, y: 0 }, // 原点
  { id: "B", x: 100, y: 50 }, // 第一象限
  { id: "C", x: -80, y: 120 }, // 第二象限
  { id: "D", x: -60, y: -90 }, // 第三象限
  { id: "E", x: 150, y: -40 }, // 第四象限
]);

// 模拟坐标更新
setInterval(() => {
  points.value = points.value.map((p) => ({
    ...p,
    x: p.x + Math.random() * 4 - 2,
    y: p.y + Math.random() * 4 - 2,
  }));
}, 100);
</script>

<style scoped>
.container {
  width: 100%;
  height: 100%;
}
</style>
