<script setup lang="ts">
import MonitorMap from "@/components/map/MonitorMap.vue";
import UWBMap from "@/components/map/UWBMap.vue";
import { ref, onMounted } from "vue";

// 添加可调整地图比例的功能
const containerRef = ref<HTMLElement | null>(null);
const dividerRef = ref<HTMLElement | null>(null);
const leftMapRef = ref<HTMLElement | null>(null);
const rightMapRef = ref<HTMLElement | null>(null);
let isDragging = false;

// 设置分隔器拖动功能
const startDrag = (e: MouseEvent) => {
  isDragging = true;
  document.addEventListener('mousemove', onDrag);
  document.addEventListener('mouseup', stopDrag);
  e.preventDefault(); // 防止拖动时选中文本
};

const onDrag = (e: MouseEvent) => {
  if (!isDragging || !containerRef.value) return;
  
  const containerRect = containerRef.value.getBoundingClientRect();
  const containerWidth = containerRect.width;
  const mouseX = e.clientX - containerRect.left;
  
  // 计算左右部分的比例
  let leftPercent = (mouseX / containerWidth) * 100;
  leftPercent = Math.max(20, Math.min(80, leftPercent)); // 限制比例在 20% 到 80% 之间
  
  if (leftMapRef.value && rightMapRef.value) {
    leftMapRef.value.style.width = `${leftPercent}%`;
    rightMapRef.value.style.width = `${100 - leftPercent}%`;
  }
};

const stopDrag = () => {
  isDragging = false;
  document.removeEventListener('mousemove', onDrag);
  document.removeEventListener('mouseup', stopDrag);
};

onMounted(() => {
  if (dividerRef.value) {
    dividerRef.value.addEventListener('mousedown', startDrag);
  }

  // 组件卸载时移除事件监听
  return () => {
    if (dividerRef.value) {
      dividerRef.value.removeEventListener('mousedown', startDrag);
    }
    document.removeEventListener('mousemove', onDrag);
    document.removeEventListener('mouseup', stopDrag);
  };
});
</script>

<template>
  <div class="container" ref="containerRef">
    <div class="map-container">
      <div class="left-map" ref="leftMapRef">
        <MonitorMap />
      </div>
      <!-- 可拖动的分隔器 -->
      <div class="map-divider" ref="dividerRef" title="拖动调整地图比例"></div>
      <div class="right-map" ref="rightMapRef">
        <UWBMap />
      </div>
    </div>
  </div>
</template>

<style scoped>
.container {
  position: relative;
  width: 100%;
  height: 100vh;
  overflow: hidden;
}

.map-container {
  display: flex;
  width: 100%;
  height: 100%;
}

.left-map {
  width: 65%; /* 初始宽度比例 */
  height: 100%;
  position: relative;
  overflow: hidden;
}

.right-map {
  width: 35%; /* 初始宽度比例 */
  height: 100%;
  position: relative;
  overflow: hidden;
}

/* 可拖动的分隔器样式 */
.map-divider {
  width: 6px;
  height: 100%;
  background: linear-gradient(to right, rgba(0, 120, 212, 0.1), rgba(0, 120, 212, 0.7), rgba(0, 120, 212, 0.1));
  cursor: col-resize;
  position: relative;
  z-index: 10;
  transition: background 0.3s;
}

.map-divider:hover {
  background: linear-gradient(to right, rgba(0, 120, 212, 0.2), rgba(0, 120, 212, 0.9), rgba(0, 120, 212, 0.2));
}

.map-divider::after {
  content: "⋮";
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  color: #ffffff;
  font-size: 20px;
  font-weight: bold;
  pointer-events: none; /* 确保不干扰鼠标事件 */
}

/* 拖动时的样式 */
.map-divider:active {
  background: linear-gradient(to right, rgba(0, 120, 212, 0.3), rgba(0, 120, 212, 1), rgba(0, 120, 212, 0.3));
}

/* 移动端适配 */
@media screen and (max-width: 768px) {
  .map-container {
    flex-direction: column;
  }
  
  .left-map, .right-map {
    width: 100%;
    height: 50%;
  }
  
  .map-divider {
    width: 100%;
    height: 6px;
    cursor: row-resize;
    background: linear-gradient(to bottom, rgba(0, 120, 212, 0.1), rgba(0, 120, 212, 0.7), rgba(0, 120, 212, 0.1));
  }
  
  .map-divider:hover {
    background: linear-gradient(to bottom, rgba(0, 120, 212, 0.2), rgba(0, 120, 212, 0.9), rgba(0, 120, 212, 0.2));
  }
  
  .map-divider:active {
    background: linear-gradient(to bottom, rgba(0, 120, 212, 0.3), rgba(0, 120, 212, 1), rgba(0, 120, 212, 0.3));
  }
  
  .map-divider::after {
    content: "⋯";
    transform: translate(-50%, -50%) rotate(90deg);
  }
}
</style>