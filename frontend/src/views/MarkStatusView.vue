<template>
    <!-- 移动端垂直布局 -->
    <div class="flex h-full w-full flex-col gap-2 md:hidden">
      <div class="flex-1">
        <MarksOnline />
      </div>
      <div class="flex-1">
        <TypeGrid />
      </div>
      <div class="flex-1">
        <TagGrid />
      </div>
    </div>

    <!-- 桌面端可调节布局 -->
    <ResizablePanelGroup direction="horizontal" class="hidden h-full w-full gap-2 md:flex">
      <ResizablePanel>
        <MarksOnline />
      </ResizablePanel>
      <ResizableHandle with-handle />
      <ResizablePanel>
        <ResizablePanelGroup direction="vertical" class="h-full w-full gap-2">
          <ResizablePanel>
            <TypeGrid />
          </ResizablePanel>
          <ResizableHandle with-handle />
          <ResizablePanel>
            <TagGrid />
          </ResizablePanel>
        </ResizablePanelGroup>
      </ResizablePanel>
    </ResizablePanelGroup>
</template>

<script setup lang="ts">
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
import MarksOnline from "@/components/device/MarkOnline.vue";
import TypeGrid from "@/components/type/TypeGrid.vue";
import TagGrid from "@/components/tag/TagGrid.vue";
</script>
