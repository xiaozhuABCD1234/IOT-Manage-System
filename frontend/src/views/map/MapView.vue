<script setup lang="ts">
import { ref, type Ref } from 'vue';
import MonitorMap from "@/components/map/MonitorMap.vue";

// 定义 MonitorMap 组件暴露的接口类型
interface MonitorMapExposed {
  toggleFenceDrawing: () => void;
  resetFences: () => void;
  showFence: Ref<boolean>; // 明确声明 showFence 是一个 Ref<boolean>
}

const monitorMapRef = ref<InstanceType<typeof MonitorMap> | null>(null) as Ref<MonitorMapExposed | null>;

const toggleFenceDrawing = () => {
  if (monitorMapRef.value) {
    console.log('MapView: Calling toggleFenceDrawing on MonitorMap');
    monitorMapRef.value.toggleFenceDrawing();
  }
};

const resetFences = () => {
  if (monitorMapRef.value) {
    console.log('MapView: Calling resetFences on MonitorMap');
    monitorMapRef.value.resetFences();
  }
};

const showFence = ref(false); // 控制围栏显示状态的响应式变量

// 监听showFence的变化并同步到MonitorMap组件
const handleShowFenceChange = (val: boolean) => {
  console.log('MapView: showFence changed to', val);
  if (monitorMapRef.value) {
    monitorMapRef.value.showFence.value = val; // 正确地访问 .value 属性
    console.log('MapView: Updated MonitorMap showFence to', monitorMapRef.value.showFence.value);
  }
};

</script>

<template>
  <main class="container">
    <MonitorMap ref="monitorMapRef" />
    <div class="map-controls">
      <el-switch v-model="showFence" active-text="显示围栏区域" @change="handleShowFenceChange" />
      <el-button 
        type="primary" 
        @click="toggleFenceDrawing"
      >
        绘制电子围栏
      </el-button>
      <el-button 
        type="info"
        @click="resetFences"
      >
        清除所有围栏
      </el-button>
    </div>
  </main>
</template>

<style scoped>
.container {
  position: relative;
  width: 100%;
  height: 100%;
  min-height: 98vh;
  margin: 0;
  padding: 0;
}

.map-controls {
  position: absolute;
  top: 10px;
  right: 10px;
  background: rgba(255, 255, 255, 0.9);
  padding: 10px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  z-index: 1000;
  display: flex;
  gap: 10px;
  align-items: center;
}
</style>
