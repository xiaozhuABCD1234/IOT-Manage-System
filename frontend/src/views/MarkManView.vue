<template>
  <!-- 高度自己定，这里占满屏幕剩余区域 -->
  <div class="flex h-full w-md flex-col">
    <TypeGrid />
    <TagGrid />
  </div>
</template>

<script setup lang="ts">
import TypeGrid from "@/components/TypeGrid.vue";
import TagGrid from "@/components/TagGrid.vue";
</script>
