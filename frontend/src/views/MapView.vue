<template>
  <ResizablePanelGroup direction="horizontal" class="h-full w-full">
    <ResizablePanel> <UWBLiveScatter /></ResizablePanel>
    <ResizableHandle with-handle />
    <ResizablePanel> <RealtimeMap /></ResizablePanel>
  </ResizablePanelGroup>
</template>

<script setup lang="ts">
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
import UWBLiveScatter from "@/components/maps/UWBLiveScatter.vue";
import RealtimeMap from "@/components/maps/RealtimeMap.vue";
</script>
