<template>
  <div class="h-full w-full">
    <DeviceCreate />
  </div>
</template>

<script setup lang="ts">
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
import DeviceCreate from "@/components/mark/MarkCreateForm.vue";
</script>
