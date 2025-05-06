<template>
  <div class="common-layout">
    <el-container>
      <el-header>
        <TopBar></TopBar>
      </el-header>
      <el-container>
        <el-aside width="200px">
          <AsideBar></AsideBar>
        </el-aside>
        <el-main class="main-content">
          <RouterView />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import TopBar from "./components/TopBar.vue";
import AsideBar from "./components/AsideBar.vue";
</script>

<style>
html, body, #app {
  height: 100%;
  margin: 0;
}

.common-layout {
  height: 100vh; /* 或 height: 100% 根据父级情况 */
}

.el-container {
  height: 100%;
}

/* 如果使用 el-header/el-aside 需要明确它们的尺寸 */
.el-header {
  height: 60px; /* 根据实际 TopBar 高度设置 */
}

.el-aside {
  height: calc(100% - 60px); /* 扣除 header 高度 */
}

.el-main {
  height: calc(100% - 60px); /* 根据实际情况调整 */
}
.main-content {
  padding: 20px; /* 根据需要调整内边距 */
  background-color: #f5f5f5; /* 可选背景色 */
  overflow-y: auto; /* 如果内容过多，允许滚动 */
  box-sizing: border-box; /* 包括内边距和边框在内的宽高计算 */
}
</style>
