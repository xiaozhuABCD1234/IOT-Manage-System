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
import { ref, watch } from "vue";
import type { CheckboxValueType } from "element-plus";
import DistanceDisplay from "@/components/DistanceDisplay.vue";

const checkAll = ref(false);
const indeterminate = ref(false);
const value = ref<CheckboxValueType[]>([]);
const cities = ref([
  {
    value: "1",
  },
  {
    value: 2,
  },
  {
    value: 3,
  },
  {
    value: 4,
  },
  {
    value: 5,
  },
]);

watch(value, (val) => {
  if (val.length === 0) {
    checkAll.value = false;
    indeterminate.value = false;
  } else if (val.length === cities.value.length) {
    checkAll.value = true;
    indeterminate.value = false;
  } else {
    indeterminate.value = true;
  }
});

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
