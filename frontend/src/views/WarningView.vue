<template>
  <!-- 大屏：2×4 网格 -->
  <div class="hidden h-full auto-rows-max grid-cols-4 gap-2 p-4 md:grid">
    <Button v-for="i in 8" :key="i" @click="handleStart(i)">
      {{ i }}
    </Button>
  </div>

  <!-- 小屏：从上往下平均占满，间隔 5 -->
  <div class="flex h-lvh flex-col gap-5 p-4 md:hidden">
    <Button v-for="i in 4" :key="i" @click="handleStart(i)" class="w-full flex-1">
      {{ i }}
    </Button>
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted } from "vue";
import { Button } from "@/components/ui/button";
import { startWarning } from "@/api/warning";

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
  if (e.key >= "0" && e.key <= "9") {
    handleStart(Number(e.key));
  }
}

onMounted(() => window.addEventListener("keydown", onKeyDown));
onUnmounted(() => window.removeEventListener("keydown", onKeyDown));
</script>
