import { createRouter, createWebHistory } from "vue-router";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: "/",
      name: "home",
      component: () => import("@/views/HomeView.vue"),
    },
    {
      path: "/about",
      name: "about",
      component: () => import("@/views/AboutView.vue"),
    },
    {
      path: "/map/real-time",
      name: "map/real-time",
      component: () => import("@/views/MapView.vue"),
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
