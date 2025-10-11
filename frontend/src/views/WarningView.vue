<template>
  <div class="flex gap-2 p-4">
    <Button v-for="i in 10" :key="i - 1" @click="handleStart(i - 1)">
      {{ i - 1 }}
    </Button>
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted } from 'vue';
import { Button } from '@/components/ui/button';
import { startWarning } from '@/api/warning';

async function handleStart(deviceId: number) {
  try {
    await startWarning(deviceId);
    console.log(`设备 ${deviceId} 告警已开启`);
  } catch (e) {
    console.error(`设备 ${deviceId} 开启失败`, e);
  }
}

/* 键盘监听 */
function onKeyDown(e: KeyboardEvent) {
  // 只处理 0-9 主键盘区
  if (e.key >= '0' && e.key <= '9') {
    handleStart(Number(e.key));
  }
}

onMounted(() => window.addEventListener('keydown', onKeyDown));
onUnmounted(() => window.removeEventListener('keydown', onKeyDown));
</script>
