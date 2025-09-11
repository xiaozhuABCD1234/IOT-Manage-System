<template>
  <ResizablePanelGroup direction="horizontal" class="h-full w-full">
    <ResizablePanel> <MarksOnline /></ResizablePanel>
    <ResizableHandle with-handle />
    <ResizablePanel> <DeviceCreate /></ResizablePanel>
  </ResizablePanelGroup>
</template>

<script setup lang="ts">
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
import MarksOnline from "@/components/device/MarkOnline.vue";
import DeviceCreate from "@/components/DeviceCreateForm.vue";
</script>
