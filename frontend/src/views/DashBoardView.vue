<template>
  <div class="dashboard-view">
    <el-row :gutter="20">
      <!-- 不带总量的用法 -->
      <el-col :span="8">
        <DashBoard
          :value="85"
          unit="%"
        >
          <h3 class="metric-title">CPU 使用率</h3>
        </DashBoard>
      </el-col>

      <!-- 带总量的用法 -->
      <el-col :span="8">
        <DashBoard
          :value="24"
          :total="32"
          unit="GB"
        >
          <h3 class="metric-title">内存使用</h3>
        </DashBoard>
      </el-col>

      <!-- 动态数据示例 -->
      <el-col :span="8">
        <DashBoard
          :value="diskUsage"
          :total="totalDisk"
          unit="GB"
        >
          <h3 class="metric-title">磁盘存储</h3>
        </DashBoard>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import DashBoard from '@/components/DashBoard.vue'

// 示例数据
const diskUsage = ref(256)
const totalDisk = ref(512)  // 设为null则不显示总量
</script>
