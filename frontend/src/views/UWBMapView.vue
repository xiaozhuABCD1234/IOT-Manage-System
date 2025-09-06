<template>
  <UWBScatter :points="list" />
</template>

<script setup lang="ts">
import { ref } from "vue";
import UWBScatter from "@/components/UWBScatter.vue";
import type { UWBFix } from "@/utils/mqtt";

const list = ref<UWBFix[]>([
  { x: 1.2, y: -3.4, id: "A001" },
  { x: -5.6, y: 7.8, id: "A002" },
  { x: 5.6, y: 7.8, id: "A003" },
  /* … */
]);
</script>
