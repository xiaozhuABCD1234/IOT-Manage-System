<template>
  <Toaster />
  <div
    class="flex min-h-screen flex-col bg-white text-gray-900 dark:bg-gray-900 dark:text-gray-100"
  >
    <header class="sticky top-0 z-10 h-12 bg-blue-300 dark:bg-sky-800">
      <HomeHeader />
    </header>

    <main class="h-[calc(100vh-3rem)] min-h-[calc(100vh-3rem)] bg-gray-100 dark:bg-gray-800">
      <router-view />
      <footer class="h-12 bg-blue-400 dark:bg-sky-900">
        <HomeFooter />
      </footer>
    </main>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from "vue";
import { useRouter } from "vue-router";
import type { RefreshTokenRequest, RefreshTokenResponse } from "@/api/user";
import { userApi } from "@/api";
import { Toaster } from "@/components/ui/sonner";
import "vue-sonner/style.css"; // vue-sonner v2 requires this import
import HomeFooter from "./components/layout/SiteFooter.vue";
import MenuFooter from "./components/layout/BottomNav.vue";
import HomeHeader from "./components/layout/AppHeader.vue";

onMounted(async () => {
  const refreshToken = localStorage.getItem("refresh_token");
  const loginTime = Number(localStorage.getItem("login_token_time") || 0);

  // 1. 未登录
  if (!refreshToken || Date.now() - loginTime < 18 * 3600 * 1000) return;

  try {
    const resp = await userApi.refreshToken({ refresh_token: refreshToken });
    const newAccessToken = resp.data.data.access_token;

    localStorage.setItem("access_token", newAccessToken);
    localStorage.setItem("login_token_time", Date.now().toString());
  } catch {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    localStorage.removeItem("login_token_time");
  }
  // 2. 登录失败
  if (!localStorage.getItem("access_token")) {
    const { path } = useRouter().currentRoute.value;
    if (path !== "/login") {
      useRouter().push("/login");
    }
  }
});
</script>
