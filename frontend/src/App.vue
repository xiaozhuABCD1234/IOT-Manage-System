<template>
  <Toaster />
  <template v-if="isAdminRoute">
    <router-view />
  </template>
  <template v-else>
    <div
      class="flex min-h-screen flex-col text-gray-900 dark:bg-gray-900 dark:text-gray-100"
    >
      <header class="sticky top-0 z-10 h-12 bg-blue-300 dark:bg-sky-800">
        <HomeHeader />
      </header>

      <main class="min-h-[calc(100vh-3rem)] bg-white dark:bg-gray-800">
        <router-view />
      </main>
          <!-- 页脚 -->
      <footer class="h-12 bg-blue-400 dark:bg-sky-900">
        <SiteFooter />
      </footer>
    </div>
  </template>
</template>

<script setup lang="ts">
import { computed, onMounted } from "vue";
import { useRouter, useRoute } from "vue-router";
import type { RefreshTokenRequest, RefreshTokenResponse } from "@/api/user";
import { userApi } from "@/api";
import { Toaster } from "@/components/ui/sonner";
import "vue-sonner/style.css"; // vue-sonner v2 requires this import
import HomeHeader from "./components/layout/AppHeader.vue";
import SiteFooter from "./components/layout/SiteFooter.vue";

const route = useRoute();
const router = useRouter();

const isAdminRoute = computed(() => route.path.startsWith("/admin"));

onMounted(async () => {
  const refreshToken = localStorage.getItem("refresh_token");
  const loginTime = Number(localStorage.getItem("login_token_time") || 0);

  // 1. 未登录，或 token 仍在有效期内（18小时内）无需刷新
  if (!refreshToken || Date.now() - loginTime < 18 * 3600 * 1000) return;

  try {
    const resp = await userApi.refreshToken({ refresh_token: refreshToken });
    const newAccessToken = resp.data.data?.access_token;

    if (newAccessToken) {
      localStorage.setItem("access_token", newAccessToken);
      localStorage.setItem("login_token_time", Date.now().toString());
    }
  } catch {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    localStorage.removeItem("login_token_time");
    router.push("/login");
  }
});
</script>
