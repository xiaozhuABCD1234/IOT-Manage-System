// src/router/index.ts
import { createRouter, createWebHistory } from "vue-router";
import type { RouteRecordRaw } from "vue-router";

const routes: RouteRecordRaw[] = [
  {
    path: "/",
    name: "Home",
    component: () => import("@/views/HomeView.vue"),
  },
  {
    path: "/login",
    name: "login",
    component: () => import("@/views/LoginView.vue"),
  },
  {
    path: "/map/rtk",
    name: "map/rtk",
    component: () => import("@/views/RTKMapView.vue"),
  },
  {
    path: "/map/uwb",
    name: "map/uwb",
    component: () => import("@/views/UWBMapView.vue"),
  },
  {
    path: "/marks/status",
    name: "marks/status",
    component: () => import("@/views/MarksStatusView.vue"),
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
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
});

export default router;
