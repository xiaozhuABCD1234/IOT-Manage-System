<template>
  <div class="dashboard-container">
    <div class="left-content">
      <slot></slot>
      <div class="value-display">
        <span class="current-value">{{ displayValue }}</span>

        <!-- 仅当存在total时显示总量 -->
        <template v-if="typeof props.total === 'number'">
          <span class="separator">{{ props.separator }}</span>
          <span class="total-value">{{ props.total }}</span>
        </template>

        <span class="unit">{{ props.unit }}</span>
      </div>
    </div>
    <div class="progress-container">
      <el-progress
        type="circle"
        :percentage="computedPercentage"
        :width="80"
        :color="progressColor"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps({
  value: {
    type: Number,
    required: true,
    default: 0
  },
  total: {
    type: Number,
    default: null  // 改为null表示可选
  },
  unit: {
    type: String,
    default: ''
  },
  separator: {
    type: String,
    default: '/'
  },
  colorThreshold: {
    type: Number,
    default: 80
  }
})

// 计算显示值（保留1位小数）
const displayValue = computed(() => {
  return Number.isInteger(props.value) ? props.value : props.value.toFixed(1)
})

// 智能百分比计算
const computedPercentage = computed(() => {
  if (typeof props.total === 'number' && props.total > 0) {
    const percentage = ((props.value / props.total) * 100).toFixed(1)
    return Math.min(percentage, 100)
  }
  return props.value  // 无总量时直接使用value作为百分比
})

// 动态颜色计算
const progressColor = computed(() => {
  const percentage = computedPercentage.value

  // 颜色分段逻辑
  if (percentage < 50) {
    return '#409eff' // 蓝色 (Element Plus primary color)
  } else if (percentage < 80) {
    return '#FFEB3B' // 黄色 (Element Plus warning color)
  } else {
    return '#f56c6c' // 红色 (Element Plus danger color)
  }
})
</script>

<style scoped>
/* 保持原有样式不变 */
.dashboard-container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.1);
}

.value-display {
  display: flex;
  align-items: baseline;
  gap: 6px;
  margin-top: 8px;
}

.current-value {
  font-size: 24px;
  font-weight: 600;
  color: #1890ff;
}

.total-value {
  font-size: 18px;
  color: #8c8c8c;
}

.separator {
  color: #bfbfbf;
  padding: 0 4px;
}

.unit {
  font-size: 14px;
  color: #595959;
  margin-left: 2px;
}

.progress-container {
  margin-left: 20px;
}
</style>
