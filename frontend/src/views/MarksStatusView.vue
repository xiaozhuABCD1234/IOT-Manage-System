<template>
  <ResizablePanelGroup direction="horizontal" class="h-full w-full">
    <ResizablePanel> <MarksOnline /></ResizablePanel>
    <ResizableHandle with-handle />
    <ResizablePanel> <DeviceCreate /></ResizablePanel>
    <ResizableHandle with-handle />
    <ResizablePanel>
      <ResizablePanelGroup direction="vertical" class="h-full w-full">
        <ResizablePanel> 右上角</ResizablePanel>
        <ResizableHandle with-handle />
        <ResizablePanel>Two</ResizablePanel>
      </ResizablePanelGroup>
    </ResizablePanel>
  </ResizablePanelGroup>
</template>

<script setup lang="ts">
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
import MarksOnline from "@/components/device/MarkOnline.vue";
import DeviceCreate from "@/components/DeviceCreate.vue";
</script>
