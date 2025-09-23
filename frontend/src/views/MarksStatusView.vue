<template>
  <ResizablePanelGroup direction="horizontal" class="h-full w-full">
    <ResizablePanel> <MarksOnline /></ResizablePanel>
    <ResizableHandle with-handle />
    <ResizablePanel>
      <ResizablePanelGroup direction="vertical" class="h-full w-full">
        <ResizablePanel>
          <TypeGrid />
        </ResizablePanel>
        <ResizableHandle with-handle />
        <ResizablePanel>
          <TagGrid />
        </ResizablePanel> </ResizablePanelGroup
    ></ResizablePanel>
  </ResizablePanelGroup>
</template>

<script setup lang="ts">
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
import MarksOnline from "@/components/device/MarkOnline.vue";
import TypeGrid from "@/components/TypeGrid.vue";
import TagGrid from "@/components/TagGrid.vue";
import DeviceCreate from "@/components/MarkCreate.vue";
</script>
