<template>
  <Toaster />
  <!-- 最小高度一屏，纵向 3 行：header / 内容 / footer -->
  <div
    class="grid min-h-screen grid-rows-[auto_1fr_auto] bg-white text-gray-900 dark:bg-gray-900 dark:text-gray-100"
  >
    <!-- 顶部 -->
    <header class="h-12 bg-blue-300 dark:bg-sky-800">
      <HomeHeader />
    </header>

    <!-- 主内容：超出可滚动 -->
    <main class="overflow-y-auto bg-gray-100 pb-0 md:pb-0 dark:bg-gray-800 font-maplemono">
      <router-view />
      <!-- 底部：大屏显示 -->
      <footer class="hidden h-12 items-center justify-center bg-blue-400 md:flex dark:bg-sky-900">
        <HomeFooter />
      </footer>
    </main>

    <!-- 底部：小屏固定到底 -->
    <footer
      class="fixed inset-x-0 bottom-0 z-50 flex h-14 items-center justify-center bg-blue-400 md:hidden dark:bg-cyan-700"
    >
      <MenuFooter />
    </footer>
  </div>
</template>

<script setup lang="ts">
import { Toaster } from "@/components/ui/sonner";
import "vue-sonner/style.css"; // vue-sonner v2 requires this import
import HomeFooter from "./components/HomeFooter.vue";
import MenuFooter from "./components/FooterMenu.vue";
import HomeHeader from "./components/HeaderMenu.vue";
</script>
