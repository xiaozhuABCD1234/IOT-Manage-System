<!-- ParentDemo.vue -->
<template>
  <div class="space-y-4 p-6">
    <!-- 1. 类型下拉 -->
    <div>
      <label class="block mb-2 text-sm font-medium">选择标注类型</label>
      <TypeSelect v-model="markTypeId" />
    </div>

    <!-- 2. 未命名设备下拉 -->
    <div>
      <label class="block mb-2 text-sm font-medium">选择未命名设备</label>
      <DeviceIDSelect v-model="deviceId" />
    </div>

    <!-- 3. 仅用于演示：实时显示父组件拿到的值 -->
    <div class="text-sm text-gray-600">
      父组件拿到的类型 id：{{ markTypeId ?? '未选择' }}<br>
      父组件拿到的设备 id：{{ deviceId ?? '未选择' }}
    </div>

    <!-- 4. 提交按钮 -->
    <Button @click="handleSubmit">提交</Button>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import TypeSelect from '@/components/TypeSelect.vue'
import DeviceIDSelect from '@/components/DeviceIDSelect.vue'
import { Button } from '@/components/ui/button'

/* 父组件本地变量，双向绑定到两个子组件 */
const markTypeId = ref<number | undefined>(undefined)
const deviceId  = ref<string | undefined>(undefined)

/* 提交示例 */
function handleSubmit() {
  if (markTypeId.value == null) {
    alert('请先选择标注类型')
    return
  }
  if (deviceId.value == null) {
    alert('请先选择未命名设备')
    return
  }

  // 这里就可以调用后端接口
  console.log('提交参数', {
    markTypeId: markTypeId.value,
    deviceId:   deviceId.value
  })
}
</script>
