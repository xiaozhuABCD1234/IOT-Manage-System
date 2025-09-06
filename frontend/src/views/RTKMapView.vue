<!-- src/views/RTKMapView.vue -->
<script setup lang="ts">
import NewMap from "@/components/maps/RealtimeMap.vue";
</script>

<template>
  <div
    class="h-full w-full overflow-hidden rounded-sm border border-gray-300 p-1 backdrop-blur-2xl dark:border-gray-600"
  >
    <div class="h-full w-full overflow-hidden rounded-sm"><NewMap /></div>
  </div>
</template>
