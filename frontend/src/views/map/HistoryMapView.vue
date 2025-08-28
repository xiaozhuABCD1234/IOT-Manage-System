<template>
  <div class="trajectory-tracker">
    <el-row :gutter="0" class="control-panel">
      <el-col :span="6">
        <el-select v-model="device_list" multiple placeholder="选择设备" style="width: 240px">
          <el-option v-for="item in options" :key="item.value" :label="item.label" :value="item.value" />
        </el-select>
      </el-col>
      <el-col :span="6">
        <el-date-picker v-model="starttime" type="datetime" placeholder="选择起始时间" format="YYYY-MM-DD HH:mm:ss"
          :shortcuts="shortcuts" :default-time="defaultTime" />
      </el-col>
      <el-col :span="6">
        <el-date-picker v-model="endtime" type="datetime" placeholder="选择结束时间" format="YYYY-MM-DD HH:mm:ss"
          :shortcuts="shortcuts" :default-time="defaultTime" />
      </el-col>
      <el-col :span="6">
        <el-button type="primary" @click="fetchTrajectories">
          查询历史轨迹
        </el-button>
      </el-col>
    </el-row>

    <!-- 地图容器 -->
    <HistoryMap v-if="showMap" :key="mapKey" :startTime="starttime" :endTime="endtime" :deviceIds="device_list"
      :showStartMarker="false" :showEndMarker="true" class="map-container" />
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { trajectoryAPI } from '@/api/trajectory'
import HistoryMap from '@/components/map/HistoryMap.vue'

const starttime = ref('')
const endtime = ref('')
const device_list = ref<number[]>([])
const options = ref<{ value: number; label: string }[]>([])
const defaultTime = new Date(2000, 1, 1, 0, 0, 0)
const showMap = ref(false)
const mapKey = ref(0)

const shortcuts = [
  { text: '今天', value: new Date() },
  {
    text: '昨天',
    value: () => new Date(new Date().setDate(new Date().getDate() - 1))
  },
  {
    text: '一周前',
    value: () => new Date(new Date().setDate(new Date().getDate() - 7))
  }
]

const fetchTrajectories = () => {
  if (validateInput()) {
    refreshMap()
    ElMessage({
      message: '查询成功',
      type: 'success',
      duration: 3000
    })
  }
}

const validateInput = () => {
  if (!device_list.value.length) {
    ElMessage({
      message: '请选择至少一个设备',
      type: 'warning',
      duration: 3000
    })
    return false
  }
  if (!starttime.value || !endtime.value) {
    ElMessage({
      message: '请选择完整的时间范围',
      type: 'warning',
      duration: 3000
    })
    return false
  }
  if (new Date(starttime.value) > new Date(endtime.value)) {
    ElMessage({
      message: '结束时间不能早于开始时间',
      type: 'warning',
      duration: 3000
    })
    return false
  }
  return true
}

const refreshMap = () => {
  showMap.value = false
  nextTick(() => {
    mapKey.value++
    showMap.value = true
  })
}

onMounted(async () => {
  try {
    const response = await trajectoryAPI.getIds()
    options.value = response.data.data.map(id => ({
      value: id,
      label: `设备 ${id}`
    }))
  } catch (error) {
    ElMessage({
      message: '设备列表加载失败',
      type: 'error',
      duration: 3000
    })
    console.error('设备列表加载失败:', error)
  }
})
</script>

<style scoped>
.trajectory-tracker {
  display: flex;
  flex-direction: column;
  width: 100%;
  height: 100%;
  gap: 20px;
  background: #f5f7fa;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.control-panel {
  display: flex;
  /* gap: 16px; */
  width: 100%;
  align-items: center;
  padding: 16px;
  background: #ffffff;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
}

.map-container {
  flex: 1;
  min-height: 400px;
  background: #ffffff;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  overflow: hidden;
}

/* 元素悬停效果 */
.el-select:hover :deep(.el-input__inner),
.el-date-picker:hover :deep(.el-input__inner) {
  border-color: #409eff;
  box-shadow: 0 1px 6px rgba(32, 160, 255, 0.1);
}

.el-button:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 6px -1px rgba(64, 158, 255, 0.2);
}
</style>
