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
        <el-main>
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

<style></style>
