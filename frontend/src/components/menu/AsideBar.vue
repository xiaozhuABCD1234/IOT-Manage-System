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
  User,
} from "lucide-vue-next";
import { useRoute } from "vue-router";
import { useMenuStore } from "@/stores/useMenuStore";
import { ref, watch } from "vue";

const route = useRoute(); // 获取当前路由
const menuStore = useMenuStore(); // 使用 Pinia store
const activeIndex = ref(menuStore.activeIndex); // 初始值从 store 获取

// 监听路由变化，动态更新 activeIndex
watch(route, () => {
  activeIndex.value = route.path; // 更新 activeIndex 为当前路由路径
  menuStore.setActiveIndex(route.path); // 同步更新 Pinia store 中的值
});

const handleOpen = (key: string, keyPath: string[]) => {
  console.log(key, keyPath);
  menuStore.setActiveIndex(key); // 更新 store 中的选中页面路径
};
const handleClose = (key: string, keyPath: string[]) => {
  console.log(key, keyPath);
};
</script>

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
      <el-menu-item index="/devops/tag-admin">
        <el-icon>
          <User />
        </el-icon>
        <span>标签管理</span>
      </el-menu-item>
      <el-menu-item index="/devops/safety-distance-admin">
        <el-icon>
          <Wrench />
        </el-icon>
        <span>安全距离管理</span>
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
