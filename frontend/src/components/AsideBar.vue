<template>
  <el-menu
    default-active="2"
    class="el-menu-vertical-demo"
    @open="handleOpen"
    @close="handleClose"
    router="true"
  >
    <el-menu-item index="/">
      <el-icon>
        <House />
      </el-icon>
      <span>首页</span>
    </el-menu-item>
    <!-- <el-sub-menu index="1">
      <template #title>
        <el-icon>
          <location />
        </el-icon>
        <span>Navigator One</span>
      </template>
<el-menu-item-group title="Group One">
  <el-menu-item index="1-1">item one</el-menu-item>
  <el-menu-item index="1-2">item two</el-menu-item>
</el-menu-item-group>
<el-menu-item-group title="Group Two">
  <el-menu-item index="1-3">item three</el-menu-item>
</el-menu-item-group>
<el-sub-menu index="1-4">
  <template #title>item four</template>
  <el-menu-item index="1-4-1">item one</el-menu-item>
</el-sub-menu>
</el-sub-menu> -->
    <el-menu-item index="/map">
      <el-icon>
        <MapPinned />
      </el-icon>
      <span>地图</span>
    </el-menu-item>
    <el-sub-menu>
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
      <el-menu-item index="1-2">
        <el-icon>
          <Shell />
        </el-icon>
        <span>日志</span>
      </el-menu-item>
      <el-menu-item index="1-3">item three</el-menu-item>
    </el-sub-menu>
    <el-sub-menu index="4">
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
  House,
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
