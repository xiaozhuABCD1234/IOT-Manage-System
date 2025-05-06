<template>
  <el-select
    v-model="value"
    multiple="true"
    clearable="true"
    collapse-tags="true"
    placeholder="选择设备id"
    popper-class="custom-header"
    :max-collapse-tags="3"
    style="width: 240px"
  >
    <template #header>
      <el-checkbox
        v-model="checkAll"
        :indeterminate="indeterminate"
        @change="handleCheckAll"
      >
        全选
      </el-checkbox>
    </template>
    <el-option v-for="item in cities" :key="item.value" :value="item.value" />
  </el-select>
  <DistanceDisplay
      :device-a="deviceA"
      :device-b="deviceB"
    />
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

const handleCheckAll = (val: CheckboxValueType) => {
  indeterminate.value = false;
  if (val) {
    value.value = cities.value.map((_) => _.value);
  } else {
    value.value = [];
  }
};

interface Device {
  id: string|number;
  lat: number;
  lon: number;
}

// 模拟实时设备数据
const deviceA = ref<Device>({
  id: 1,
  lat: 31.2304,
  lon: 121.4737
})

const deviceB = ref<Device>({
  id: 2,
  lat: 31.2345,
  lon: 121.4789
})
</script>

<style>
.custom-header {
  .el-checkbox {
    display: flex;
    height: unset;
  }
}
</style>
