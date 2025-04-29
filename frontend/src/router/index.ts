import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import MapView from '@/views/MapView.vue'
import DashBoardView from '@/views/DashBoardView.vue'
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
    },
    {
      path: '/about',
      name: 'about',
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import('../views/AboutView.vue'),
    },
    {
      path: '/map',
      name: 'map',
      component: MapView,
    },
    {
      path: '/devops/dashboard',
      name: 'devops_dashboard',
      component: DashBoardView,
    },
  ],
})

export default router
