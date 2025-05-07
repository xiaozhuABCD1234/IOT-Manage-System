<template>
  <el-menu
    default-active="2"
    class="el-menu-vertical-demo"
    @open="handleOpen"
    @close="handleClose"
    :router="true"
  >
    <el-menu-item index="/">
      <el-icon>
        <House />
      </el-icon>
      <span>首页</span>
    </el-menu-item>
    <el-sub-menu index="/map">
      <template #title>
        <el-icon>
          <Map />
        </el-icon>
        <span>地图</span>
      </template>
      <el-menu-item index="/map/real-time">
        <el-icon>
          <MapPinned />
        </el-icon>
        <span>实时位置</span>
      </el-menu-item>
      <el-menu-item index="/map/UWB">
        <el-icon>
          <MapPinHouse />
        </el-icon>
        <span>UWB室内定位</span>
      </el-menu-item>
      <el-menu-item index="/map/history">
        <el-icon>
          <History />
        </el-icon>
        <span>历史轨迹</span>
      </el-menu-item>
    </el-sub-menu>
    <el-sub-menu index="/devops">
      <template #title>
        <el-icon>
          <Server />
        </el-icon>
        <span>运维管理</span>
      </template>
      <el-menu-item index="/devops/dashboard">
        <el-icon>
          <ChartArea />
        </el-icon>
        <span>仪表盘</span>
      </el-menu-item>
      <el-menu-item index="/devops/logs">
        <el-icon>
          <Shell />
        </el-icon>
        <span>日志</span>
      </el-menu-item>
    </el-sub-menu>
    <el-sub-menu index="/tools">
      <template #title>
        <el-icon>
          <Wrench />
        </el-icon>
        <span>工具</span>
      </template>
      <el-menu-item index="/tools/distance">
        <el-icon>
          <Calculator />
        </el-icon>
        <span>距离计算</span>
      </el-menu-item>
    </el-sub-menu>
  </el-menu>
</template>
<script lang="ts" setup>
import {
  Calculator,
  ChartArea,
  History,
  House,
  Map,
  MapPinHouse,
  MapPinned,
  Server,
  Shell,
  Wrench,
} from "lucide-vue-next";

const handleOpen = (key: string, keyPath: string[]) => {
  console.log(key, keyPath);
};
const handleClose = (key: string, keyPath: string[]) => {
  console.log(key, keyPath);
};
</script>
