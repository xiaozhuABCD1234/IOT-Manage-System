<template>
  <div
    class="device-marker"
    :style="{ background: props.color }"
  >
    <slot></slot>
  </div>
</template>

<script setup lang="ts">
import { defineProps } from "vue";

const props = defineProps({
  color: { type: String, required: true },
});
</script>

<style scoped>
.device-marker {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: bold;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  border: 2px solid white;
}
</style>
