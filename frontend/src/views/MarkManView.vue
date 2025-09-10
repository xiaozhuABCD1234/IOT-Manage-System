<template>
  <!-- 高度自己定，这里占满屏幕剩余区域 -->
  <div class="flex h-full w-md flex-col">
    <main class="flex-1 overflow-hidden">
      <MarkTypeGrid />
    </main>
  </div>
</template>

<script setup lang="ts">
import MarkTypeGrid from "@/components/MarkTypeGrid.vue";
</script>
