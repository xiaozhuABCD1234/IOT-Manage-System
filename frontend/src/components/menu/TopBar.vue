<script setup lang="ts">
import { House, Info, Layers } from "lucide-vue-next";
import { ref } from "vue";
import UserInfo from "../UserInfo.vue";

const activeIndex = ref("1");
const handleSelect = (key: string, keyPath: string[]) => {
  console.log(key, keyPath);
};
</script>

<template>
  <el-row :gutter="20" type="flex">
    <el-col :span="3" class="logo-col">
      <div class="logo-wrapper">
        <img src="/src/assets/imgs/iot.png" alt="物联网平台" class="logo-img">
        <div class="logo-text">
          物联网平台
        </div>
      </div>
    </el-col>
    <el-col :span="18">
      <div class="menu">
        <el-menu
          :default-active="activeIndex"
          class="el-menu-demo"
          mode="horizontal"
          @select="handleSelect"
          router="true"
        >
          <el-menu-item index="/">
            <el-icon>
              <House />
            </el-icon>
            <span>
              首页
            </span>
          </el-menu-item>
          <el-sub-menu index="2">
            <template #title>
              <el-icon>
                <Layers />
              </el-icon>
              <span>
                工作区
              </span>
            </template>
            <el-menu-item index="2-1">item one</el-menu-item>
            <el-menu-item index="2-2">item two</el-menu-item>
            <el-menu-item index="2-3">item three</el-menu-item>
            <el-sub-menu index="2-4">
              <template #title>item four</template>
              <el-menu-item index="2-4-1">item one</el-menu-item>
              <el-menu-item index="2-4-2">item two</el-menu-item>
              <el-menu-item index="2-4-3">item three</el-menu-item>
            </el-sub-menu>
          </el-sub-menu>
          <el-menu-item index="/about">
            <el-icon>
              <Info />
            </el-icon>
            <span>
              关于
            </span>
          </el-menu-item>
        </el-menu>
      </div>
    </el-col>
    <el-col :span="3">
      <UserInfo />
    </el-col>
  </el-row>
</template>

<style scoped>
.logo-col {
  min-width: 200px;
  max-width: 300px;
  padding: 0px;
}

.logo-wrapper {
  display: flex;
  align-items: center;
  /* 垂直居中 */
  height: 100%;
  gap: 12px;
  /* 添加图片和文字间距 */
}

.logo-img {
  width: 50px;
  /* 正方形尺寸 */
  height: 50px;
  /* 保持与宽度一致 */
  object-fit: cover;
  /* 保持图片比例 */
  flex-shrink: 0;
  /* 防止图片被压缩 */
}

.logo-text {
  font-size: 18px;
  font-weight: 500;
  line-height: 50px;
  /* 与图片高度一致保持垂直居中 */
  white-space: nowrap;
}

/* 其他元素保持默认样式 */
.el-row {
  height: 60px;
  /* 建议设置固定高度 */
}

:deep(.el-menu--horizontal) {
  --el-menu-item-font-size: 16px;
  /* 增大菜单字体 */
  height: 100%;
}
</style>
