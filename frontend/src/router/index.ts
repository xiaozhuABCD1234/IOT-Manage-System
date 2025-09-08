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
    path: "/marks/status",
    name: "marks-status",
    component: () => import("@/views/MarksStatusView.vue"),
  },
  {
    path: "/marks/manage",
    name: "marks-manage",
    component: () => import("@/views/MarkManView.vue"),
  },
  {
    path: "/marks/list/:pageNumber(\\d+)",
    name: "marks-list",
    component: () => import("@/views/MarkListView.vue"),
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
