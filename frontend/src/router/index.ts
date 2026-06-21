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
    path: "/stations",
    name: "stations",
    component: () => import("@/views/StationManageView.vue"),
  },
  {
    path: "/map/settings",
    name: "map-settings",
    component: () => import("@/views/MapSettingsView.vue"),
  },
  {
    path: "/map/settings/fence",
    name: "fence-settings",
    component: () => import("@/views/UWBMapNewView.vue"),
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
    path: "/marks/distance",
    name: "distance-settings",
    component: () => import("@/views/DistanceSettingsView.vue"),
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
  // Admin routes with own layout
  {
    path: "/admin",
    component: () => import("@/views/admin/AdminLayout.vue"),
    meta: { requiresAdmin: true },
    children: [
      {
        path: "",
        name: "admin-dashboard",
        component: () => import("@/views/admin/DashboardView.vue"),
      },
      {
        path: "users",
        name: "admin-users",
        component: () => import("@/views/admin/UserManageView.vue"),
      },
      {
        path: "devices",
        name: "admin-devices",
        component: () => import("@/views/admin/DeviceManageView.vue"),
      },
      {
        path: "status",
        name: "admin-status",
        component: () => import("@/views/admin/DeviceStatusView.vue"),
      },
    ],
  },
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
});

/* ------------ 登录守卫 ------------ */
const LOGIN_PATH = "/login";
const SEVEN_DAYS = 7 * 24 * 60 * 60 * 1000;

router.beforeEach(async (to) => {
  if (to.path === LOGIN_PATH) return true;

  const PUBLIC_PATHS: string[] = ["/", "/about"];
  if (PUBLIC_PATHS.includes(to.path)) return true;

  const token = localStorage.getItem("access_token");
  const loginTime = Number(localStorage.getItem("refresh_token_time") || 0);

  if (!token) return { path: LOGIN_PATH, query: { redirect: to.fullPath } };

  if (Date.now() - loginTime >= SEVEN_DAYS) {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    localStorage.removeItem("refresh_token_time");
    localStorage.removeItem("login_token_time");
    return { path: LOGIN_PATH, query: { redirect: to.fullPath } };
  }

  if (to.meta.requiresAdmin) {
    const { userApi } = await import("@/api");
    const { UserType } = await import("@/api/user");
    try {
      const res = await userApi.getMe();
      const userType = res.data.data.user_type;
      if (userType !== UserType.Root && userType !== UserType.Admin) {
        return { path: "/" };
      }
    } catch {
      return { path: LOGIN_PATH, query: { redirect: to.fullPath } };
    }
  }

  return true;
});

export default router;
