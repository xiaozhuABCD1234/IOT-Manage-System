<template>
  <div class="flex h-full w-full flex-col items-center justify-start gap-4 md:justify-center">
    <h1 class="mt-2 text-3xl">所有标记</h1>
    <MarkTablePager :fetcher="listMarks" />
  </div>
</template>

<script setup lang="ts">
import MarkTablePager from "@/components/MarkTablePager.vue";
import { listMarks } from "@/api/mark";
</script>
