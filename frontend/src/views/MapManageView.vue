<template>
  <ResizablePanelGroup direction="horizontal">
    <ResizablePanel> </ResizablePanel>
    <ResizableHandle />
    <ResizablePanel>
      <StationMangePanel></StationMangePanel>
    </ResizablePanel>
  </ResizablePanelGroup>
</template>

<script setup lang="ts">
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";

import StationMangePanel from "@/components/StationMangePanel.vue";
</script>
