<template>
  <!-- 动态方向：>=768px 时水平，<768px 时垂直 -->
  <ResizablePanelGroup :direction="isMobile ? 'vertical' : 'horizontal'" class="h-full w-full">
    <ResizablePanel>
      <RealtimeMap />
    </ResizablePanel>

    <!-- 手机端隐藏拖拽条，更清爽 -->
    <ResizableHandle v-if="!isMobile" with-handle />

    <ResizablePanel>
      <UWBLiveScatter />
    </ResizablePanel>
  </ResizablePanelGroup>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from "vue";
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
import UWBLiveScatter from "@/components/maps/UWBLiveScatter.vue";
import RealtimeMap from "@/components/maps/RealtimeMap.vue";

/* ---------- 响应式断点 ---------- */
const isMobile = ref(false); // 默认先给 false，避免 SSR 抖动

function checkMobile() {
  isMobile.value = window.matchMedia("(max-width: 767px)").matches;
}

let mql: MediaQueryList;
onMounted(() => {
  mql = window.matchMedia("(max-width: 767px)");
  checkMobile();
  mql.addEventListener("change", checkMobile); // 监听旋转/resize
});

onBeforeUnmount(() => {
  mql.removeEventListener("change", checkMobile);
});
</script>
