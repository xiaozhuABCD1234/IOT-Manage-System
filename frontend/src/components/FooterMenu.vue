<!-- src/components/MenuFooter.vue -->
<template>
  <nav
    class="flex h-full w-full items-stretch border-t border-gray-200 bg-white dark:border-gray-700 dark:bg-gray-900"
  >
    <button
      v-for="(item, idx) in menu"
      :key="idx"
      :class="[
        'flex flex-1 flex-col items-center justify-center text-gray-600',
        'hover:text-blue-500 focus:outline-none',
        active === idx && 'font-maplemono text-blue-600',
        'dark:text-gray-400 dark:hover:text-blue-400',
        active === idx && 'dark:text-blue-400',
      ]"
      @click="active = idx"
    >
      <component :is="item.icon" :size="22" />
      <span class="mt-1 text-xs">{{ item.label }}</span>
    </button>
  </nav>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { Home, MapPin, Tag, User } from "lucide-vue-next";

const active = ref(0);

const menu = [
  { icon: Home, label: "首页" },
  { icon: MapPin, label: "地图" },
  { icon: Tag, label: "标签" },
  { icon: User, label: "用户" },
];
</script>
