<!-- src/components/HomeFooter.vue -->
<template>
  <footer class="flex h-12 shrink-0 items-center justify-center px-4 text-sm text-white md:px-6">
    <!-- 左侧版权 -->
    <div class="flex items-center">
      <Copyright :size="16" />
      <p>2025 上海电力大学Lab 107版权所有</p>
      <a
        href="https://beian.miit.gov.cn"
        target="_blank"
        rel="noopener noreferrer"
        class="ml-2 underline"
      >
        还没有网络备案😦
      </a>
    </div>

    <!-- 右侧社交媒体图标 -->
    <div class="flex items-center space-x-3">
      <a href="mailto:contact@example.com" title="Email" class="hover:text-gray-200">
        <i class="fas fa-envelope" />
      </a>
      <a
        href="https://github.com/xiaozhuABCD1234"
        target="_blank"
        rel="noopener noreferrer"
        title="我的github主页"
        class="flex items-center gap-1 hover:text-black"
      >
        我的github主页<Github :size="16" />
      </a>
    </div>
  </footer>
</template>

<script setup lang="ts">
import { Github, Copyright } from "lucide-vue-next";
</script>
