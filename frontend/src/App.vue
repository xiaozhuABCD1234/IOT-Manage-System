<template>
  <!-- 全屏布局（用于登录页等） -->
  <div v-if="isFullScreenLayout" class="full-screen-layout">
    <RouterView />
  </div>

  <!-- 常规布局（带顶部栏和侧边栏） -->
  <div v-else class="common-layout">
    <el-container>
      <el-header>
        <TopBar />
      </el-header>
      <el-container>
        <el-aside width="200px">
          <AsideBar />
        </el-aside>
        <el-main class="main-content">
          <RouterView />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { useRoute } from "vue-router";
import TopBar from "./components/menu/TopBar.vue";
import AsideBar from "./components/menu/AsideBar.vue";

const route = useRoute();

// 根据路由元信息判断是否使用全屏布局
const isFullScreenLayout = computed(() => {
  return route.meta.fullScreen === true;
});
</script>

<style scoped>
/* 全屏布局样式 */
.full-screen-layout {
  height: 100vh;
  width: 100vw;
}

/* 常规布局样式 */
.common-layout {
  height: 100vh;
}

.el-container {
  height: 100%;
}

.el-header {
  height: 60px;
}

.el-aside {
  height: calc(100% - 60px);
}

.el-main {
  height: calc(100% - 60px);
}

.main-content {
  padding: 20px;
  background-color: #f5f5f5;
  overflow-y: auto;
  box-sizing: border-box;
}
</style>

<style>
/* 全局样式 */
html, body, #app {
  height: 100%;
  margin: 0;
  padding: 0;
}
</style>
