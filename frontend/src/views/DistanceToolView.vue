<template>
  <el-row :gutter="20" class="row-spacing">
    <el-col :span="12">
      <DistanceDisplay
        :device-a="deviceA"
        :device-b="deviceB"
      />
    </el-col>
    <el-col :span="12">
      <DistanceDisplay
        :device-a="deviceA"
        :device-b="deviceB"
      />
    </el-col>
  </el-row>
  <el-row :gutter="20" class="row-spacing">
    <el-col :span="12">
      <DistanceDisplay
        :device-a="deviceA"
        :device-b="deviceB"
      />
    </el-col>
    <el-col :span="12">
      <DistanceDisplay
        :device-a="deviceA"
        :device-b="deviceB"
      />
    </el-col>
  </el-row>
</template>

<script lang="ts" setup>
import { ref} from "vue";
import DistanceDisplay from "@/components/DistanceDisplay.vue";


interface Device {
  id: string | number;
  lat: number;
  lon: number;
}

// 模拟实时设备数据
const deviceA = ref<Device>({
  id: 1,
  lat: 31.2304,
  lon: 121.4737,
});

const deviceB = ref<Device>({
  id: 2,
  lat: 31.2345,
  lon: 121.4789,
});
</script>

<style>
.row-spacing {
  margin-bottom: 20px; /* 设置行间距 */
}
</style>
