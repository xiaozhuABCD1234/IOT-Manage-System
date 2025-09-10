<template>
  <!-- 高度自己定，这里占满屏幕剩余区域 -->
  <ResizablePanelGroup direction="horizontal" class="h-full w-full">
    <ResizablePanel>
      <ResizablePanelGroup direction="vertical" class="h-full w-full">
        <ResizablePanel><TypeGrid /></ResizablePanel>
        <ResizableHandle with-handle />
        <ResizablePanel><TagGrid /></ResizablePanel> </ResizablePanelGroup
    ></ResizablePanel>

    <ResizableHandle with-handle />
    <ResizablePanel> <MarksOnline /></ResizablePanel>
  </ResizablePanelGroup>
</template>

<script setup lang="ts">
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
import TypeGrid from "@/components/TypeGrid.vue";
import TagGrid from "@/components/TagGrid.vue";

</script>
