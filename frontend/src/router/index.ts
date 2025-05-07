import { createRouter, createWebHistory } from "vue-router";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/",
      name: "home",
      component: () => import("@/views/HomeView.vue"),
      meta: {
        fullScreen: false, // 常规布局
      },
    },
    {
      path: "/login",
      name: "login",
      component: () => import("@/views/LoginView.vue"),
      meta: {
        fullScreen: true, // 常规布局
      },
    },
    {
      path: "/about",
      name: "about",
      component: () => import("@/views/AboutView.vue"),
    },
    {
      path: "/map/real-time",
      name: "map/real-time",
      component: () => import("@/views/map/MapView.vue"),
    },
    {
      path: "/map/UWB",
      name: "map/UWB",
      component: () => import("@/views/map/uwbMapView.vue"),
    },
    {
      path: "/devops/dashboard",
      name: "devops_dashboard",
      component: () => import("@/views/DashBoardView.vue"),
    },
    {
      path: "/tools/distance",
      name: "distance_tool",
      component: () => import("@/views/DistanceToolView.vue"),
    },
  ],
});

export default router;
