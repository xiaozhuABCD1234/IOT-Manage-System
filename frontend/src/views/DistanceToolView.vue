<template>
  <el-select v-model="value" multiple=true clearable=true collapse-tags=true placeholder="选择设备id"
    popper-class="custom-header" :max-collapse-tags="3" style="width: 240px">
    <template #header>
      <el-checkbox v-model="checkAll" :indeterminate="indeterminate" @change="handleCheckAll">
        全选
      </el-checkbox>
    </template>
    <el-option v-for="item in cities" :key="item.value" :value="item.value" />
  </el-select>
</template>

<script lang="ts" setup>
import { ref, watch } from 'vue'
import type { CheckboxValueType } from 'element-plus'

const checkAll = ref(false)
const indeterminate = ref(false)
const value = ref<CheckboxValueType[]>([])
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
])

watch(value, (val) => {
  if (val.length === 0) {
    checkAll.value = false
    indeterminate.value = false
  } else if (val.length === cities.value.length) {
    checkAll.value = true
    indeterminate.value = false
  } else {
    indeterminate.value = true
  }
})

const handleCheckAll = (val: CheckboxValueType) => {
  indeterminate.value = false
  if (val) {
    value.value = cities.value.map((_) => _.value)
  } else {
    value.value = []
  }
}
</script>

<style>
.custom-header {
  .el-checkbox {
    display: flex;
    height: unset;
  }
}
</style>
