<template>
  <ResizablePanelGroup direction="horizontal">
    <ResizablePanel> </ResizablePanel>
    <ResizableHandle />
    <ResizablePanel>
      <StationManagePanel></StationManagePanel>
    </ResizablePanel>
  </ResizablePanelGroup>
</template>

<script setup lang="ts">
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";

import StationManagePanel from "@/components/station/StationManagePanel.vue";
</script>
