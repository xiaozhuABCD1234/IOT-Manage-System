<template>
  <Toaster />
  <div
    class="flex min-h-screen flex-col bg-white text-gray-900 dark:bg-gray-900 dark:text-gray-100"
  >
    <header class="sticky top-0 z-10 h-12 bg-blue-300 dark:bg-sky-800">
      <HomeHeader />
    </header>

    <main
      class="font-maplemono h-[calc(100vh-3rem)] min-h-[calc(100vh-3rem)] bg-gray-100 dark:bg-gray-800"
    >
      <router-view />
      <footer class="h-12 bg-blue-400 dark:bg-sky-900">
        <HomeFooter />
      </footer>
    </main>
  </div>
</template>

<script setup lang="ts">
import { Toaster } from "@/components/ui/sonner";
import "vue-sonner/style.css"; // vue-sonner v2 requires this import
import HomeFooter from "./components/layout/SiteFooter.vue";
import MenuFooter from "./components/layout/BottomNav.vue";
import HomeHeader from "./components/layout/AppHeader.vue";
</script>
