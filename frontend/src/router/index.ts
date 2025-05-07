import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('@/views/HomeView.vue'),
      meta: {
        fullScreen: false,
        requiresAuth: true,
      },
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/LoginView.vue'),
      meta: {
        fullScreen: true,
        requiresAuth: false,
      },
    },
    {
      path: '/about',
      name: 'about',
      component: () => import('@/views/AboutView.vue'),
      meta: {
        fullScreen: false,
        requiresAuth: true,
      },
    },
    {
      path: '/map/real-time',
      name: 'map/real-time',
      component: () => import('@/views/map/MapView.vue'),
      meta: {
        fullScreen: false,
        requiresAuth: true,
      },
    },
    {
      path: '/map/UWB',
      name: 'map/UWB',
      component: () => import('@/views/map/uwbMapView.vue'),
      meta: {
        fullScreen: false,
        requiresAuth: true,
      },
    },
    {
      path: '/devops/dashboard',
      name: 'devops_dashboard',
      component: () => import('@/views/DashBoardView.vue'),
      meta: {
        fullScreen: false,
        requiresAuth: true,
      },
    },
    {
      path: '/tools/distance',
      name: 'distance_tool',
      component: () => import('@/views/DistanceToolView.vue'),
      meta: {
        fullScreen: false,
        requiresAuth: true,
      },
    },
  ],
})
// Cookie操作函数
const getCookie = (name: string): string | null => {
  const value = `; ${document.cookie}`
  const parts = value.split(`; ${name}=`)
  if (parts.length === 2) return parts.pop()?.split(';').shift() || null
  return null
}



// 路由守卫
router.beforeEach((to, from, next) => {
  // 检查路由是否需要认证
  const requiresAuth = to.matched.some((record) => record.meta.requiresAuth)

  // 检查用户是否已登录
  const isAuthenticated = !!getCookie('access_token')

  if (requiresAuth && !isAuthenticated) {
    // 需要认证且未登录，跳转到登录页并携带原路径
    next({
      path: '/login',
      query: { redirect: to.fullPath },
    })
  } else if (to.path === '/login' && isAuthenticated) {
    // 已登录用户访问登录页，跳转到首页
    next('/')
  } else {
    // 其他情况直接放行
    next()
  }
})

export default router
