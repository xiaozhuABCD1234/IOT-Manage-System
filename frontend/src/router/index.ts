// src/router/index.ts
import { createRouter, createWebHistory } from "vue-router";
import type { RouteRecordRaw } from "vue-router";

const routes: RouteRecordRaw[] = [
  {
    path: "/",
    name: "home",
    component: () => import("@/views/HomeView.vue"),
  },
  {
    path: "/login",
    name: "login",
    component: () => import("@/views/LoginView.vue"),
  },
  {
    path: "/map/rtk",
    name: "map-rtk",
    component: () => import("@/views/RTKMapView.vue"),
  },
  {
    path: "/map",
    name: "map",
    component: () => import("@/views/MapView.vue"),
  },
  {
    path: "/map/uwb",
    name: "map-uwb",
    component: () => import("@/views/UWBMapView.vue"),
  },
  {
    path: "/map/manage",
    name: "map-manage",
    component: () => import("@/views/MapManageView.vue"),
  },
  {
    path: "/map/settings",
    name: "map-settings",
    component: () => import("@/views/MapSettingsView.vue"),
  },
  {
    path: "/marks/status",
    name: "marks-status",
    component: () => import("@/views/MarkStatusView.vue"),
  },
  {
    path: "/marks/manage",
    name: "marks-manage",
    component: () => import("@/views/MarkManageView.vue"),
  },
  {
    path: "/marks/list",
    name: "marks-list",
    component: () => import("@/views/MarkListView.vue"),
  },
  {
    path: "/type/:typeId",
    name: "TypeMarks",
    component: () => import("@/views/TypeDetailsView.vue"),
  },
  {
    path: "/tag/:tagId",
    name: "TagMarks",
    component: () => import("@/views/TagDetailsView.vue"),
  },
  {
    path: "/profile",
    name: "profile",
    component: () => import("@/views/UserProfileView.vue"),
  },
  {
    path: "/about",
    name: "about",
    component: () => import("@/views/AboutView.vue"),
  },
  {
    path: "/WS",
    name: "w",
    component: () => import("@/views/WarningView.vue"),
  },
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
});

/* ------------ 登录守卫 ------------ */
const LOGIN_PATH = "/login";
const SEVEN_DAYS = 7 * 24 * 60 * 60 * 1000;

router.beforeEach((to) => {
  // 登录页本身无需守卫
  if (to.path === LOGIN_PATH) return true;

  const token = localStorage.getItem("access_token");
  const loginTime = Number(localStorage.getItem("refresh_token_time") || 0);

  // 1. 未登录
  if (!token) return { path: LOGIN_PATH, query: { redirect: to.fullPath } };

  // 2. 登录已超 7 天
  if (Date.now() - loginTime >= SEVEN_DAYS) {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    localStorage.removeItem("refresh_token_time");
    return { path: LOGIN_PATH, query: { redirect: to.fullPath } };
  }

  // 3. 放行
  return true;
});

export default router;
