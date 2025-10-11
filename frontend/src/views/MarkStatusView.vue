<template>
  <div class="flex h-full w-full flex-col gap-4 p-4">
    <ResizablePanelGroup direction="horizontal" class="h-full w-full">
      <ResizablePanel>
        <MarksOnline />
      </ResizablePanel>
      <ResizableHandle with-handle />
      <ResizablePanel>
        <ResizablePanelGroup direction="vertical" class="h-full w-full">
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
  </div>
</template>

<script setup lang="ts">
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
import MarksOnline from "@/components/device/MarkOnline.vue";
import TypeGrid from "@/components/type/TypeGrid.vue";
import TagGrid from "@/components/tag/TagGrid.vue";
</script>
