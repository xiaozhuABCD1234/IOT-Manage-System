<template>
  <!-- 整个视口高度，纵向 flex 布局 -->
  <div class="font-maplemono flex min-h-screen w-full flex-col">
    <!-- 头部 -->
    <header class="h-12 shrink-0 bg-blue-300">头</header>

    <!-- 主内容区，自动占满剩余高度 -->
    <main class="flex-1 bg-gray-100"></main>

    <!-- 页脚，始终在底部(大屏) -->
    <footer
      class="hidden h-12 shrink-0 items-center justify-center bg-blue-400 text-center md:flex"
    >
      <HomeFooter />
    </footer>
    <!-- 底部导航栏（小屏） -->
    <footer
      class="flex h-14 shrink-0 items-center justify-center bg-blue-400 text-center md:hidden"
    >
      <MenuFooter></MenuFooter>
    </footer>
  </div>
</template>

<script setup lang="ts">
import HomeFooter from "./components/HomeFooter.vue";
import MenuFooter from "./components/MenuFooter.vue";
</script>
