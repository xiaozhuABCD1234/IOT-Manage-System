<script setup lang="ts">
import MonitorMap from "@/components/map/MonitorMap.vue";
</script>

<template>
  <main class="container">
    <MonitorMap />
  </main>
</template>

<style scoped>
.container {
  position: relative;
  width: 100%;
  height: 100%;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}
</style>
