<!-- src/views/About.vue -->
<template>
  <div
    class="flex min-h-full flex-col bg-gradient-to-br from-slate-50 to-slate-100 dark:from-slate-900 dark:to-slate-800"
  >
    <div class="mx-auto w-full max-w-3xl flex-1 p-8">
      <h1 class="mb-2 text-4xl font-bold text-slate-900 dark:text-slate-100">关于项目</h1>
      <p class="mb-8 text-slate-600 dark:text-slate-400">基于现代化技术栈开发的全栈应用</p>

      <div class="space-y-4">
        <!-- 前端 -->
        <div
          class="rounded-xl border bg-white p-6 shadow-sm dark:border-slate-700 dark:bg-slate-800"
        >
          <h2 class="mb-3 text-lg font-semibold text-slate-900 dark:text-slate-100">前端技术栈</h2>
          <div class="flex flex-wrap gap-2">
            <span
              class="rounded-full bg-blue-100 px-3 py-1 text-sm text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
              >Vue 3</span
            >
            <span
              class="rounded-full bg-purple-100 px-3 py-1 text-sm text-purple-800 dark:bg-purple-900/30 dark:text-purple-300"
              >Vite</span
            >
            <span
              class="rounded-full bg-cyan-100 px-3 py-1 text-sm text-cyan-800 dark:bg-cyan-900/30 dark:text-cyan-300"
              >Tailwind CSS</span
            >
            <span
              class="rounded-full bg-indigo-100 px-3 py-1 text-sm text-indigo-800 dark:bg-indigo-900/30 dark:text-indigo-300"
              >shadcn-vue</span
            >
            <span
              class="rounded-full bg-slate-100 px-3 py-1 text-sm text-slate-800 dark:bg-slate-700 dark:text-slate-300"
              >Lucide</span
            >
          </div>
        </div>

        <!-- 后端 -->
        <div
          class="rounded-xl border bg-white p-6 shadow-sm dark:border-slate-700 dark:bg-slate-800"
        >
          <h2 class="mb-3 text-lg font-semibold text-slate-900 dark:text-slate-100">后端技术栈</h2>
          <div class="flex flex-wrap gap-2">
            <span
              class="rounded-full bg-green-100 px-3 py-1 text-sm text-green-800 dark:bg-green-900/30 dark:text-green-300"
              >Go</span
            >
            <span
              class="rounded-full bg-teal-100 px-3 py-1 text-sm text-teal-800 dark:bg-teal-900/30 dark:text-teal-300"
              >Gin</span
            >
            <span
              class="rounded-full bg-emerald-100 px-3 py-1 text-sm text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-300"
              >Fiber</span
            >
            <span
              class="rounded-full bg-amber-100 px-3 py-1 text-sm text-amber-800 dark:bg-amber-900/30 dark:text-amber-300"
              >GORM</span
            >
            <span
              class="rounded-full bg-blue-100 px-3 py-1 text-sm text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
              >PostgreSQL</span
            >
            <span
              class="rounded-full bg-green-100 px-3 py-1 text-sm text-green-800 dark:bg-green-900/30 dark:text-green-300"
              >MongoDB</span
            >
          </div>
        </div>

        <!-- 通信 & 基础设施 -->
        <div
          class="rounded-xl border bg-white p-6 shadow-sm dark:border-slate-700 dark:bg-slate-800"
        >
          <h2 class="mb-3 text-lg font-semibold text-slate-900 dark:text-slate-100">通信与部署</h2>
          <div class="flex flex-wrap gap-2">
            <span
              class="rounded-full bg-green-100 px-3 py-1 text-sm text-green-800 dark:bg-green-900/30 dark:text-green-300"
              >Nginx</span
            >
            <span
              class="rounded-full bg-orange-100 px-3 py-1 text-sm text-orange-800 dark:bg-orange-900/30 dark:text-orange-300"
              >MQTT</span
            >
            <span
              class="rounded-full bg-blue-100 px-3 py-1 text-sm text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
              >Mosquitto</span
            >
            <span
              class="rounded-full bg-sky-100 px-3 py-1 text-sm text-sky-800 dark:bg-sky-900/30 dark:text-sky-300"
              >Docker</span
            >
            <span
              class="rounded-full bg-blue-100 px-3 py-1 text-sm text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
              >Docker Compose</span
            >
            <span
              class="rounded-full bg-red-100 px-3 py-1 text-sm text-red-800 dark:bg-red-900/30 dark:text-red-300"
              >Axios</span
            >
          </div>
        </div>
      </div>
    </div>

    <!-- 页脚 -->
    <footer class="h-12 bg-blue-400 dark:bg-sky-900">
      <HomeFooter />
    </footer>
  </div>
</template>

<script setup lang="ts">
import HomeFooter from "@/components/layout/SiteFooter.vue";
</script>
