<script setup lang="ts">
import MonitorMap from "@/components/map/MonitorMap.vue";
import UWBMap from "@/components/map/UWBMap.vue";
</script>

<template>
  <div class="container">
    <el-row :gutter="20" class="row-spacing">
      <el-col :span="15">
        <MonitorMap />
      </el-col>
      <el-col :span="9">
        <UWBMap />
      </el-col>
    </el-row>
  </div>
</template>

<style scoped>
.container {
  position: relative;
  width: 100%;
  height: 100%;
}

.row-spacing {
  height: 100%;
}
</style>
