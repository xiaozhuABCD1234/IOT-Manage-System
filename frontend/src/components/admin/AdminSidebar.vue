<script setup lang="ts">
import { computed } from "vue";
import { useRoute } from "vue-router";
import { RouterLink } from "vue-router";
import { Monitor, LayoutDashboard, Users, Package, Shield } from "lucide-vue-next";
import { Separator } from "@/components/ui/separator";

const route = useRoute();

const navItems = [
  { label: "仪表盘", icon: LayoutDashboard, to: "/admin" },
  { label: "用户管理", icon: Users, to: "/admin/users" },
  { label: "设备管理", icon: Package, to: "/admin/devices" },
  { label: "设备状态", icon: Shield, to: "/admin/status" },
];

const isActive = (to: string) => {
  if (to === "/admin") return route.path === "/admin";
  return route.path.startsWith(to);
};

const activeClass = computed(() => "bg-sidebar-accent text-sidebar-accent-foreground");
</script>

<template>
  <aside
    class="flex h-screen w-64 flex-col border-r border-sidebar-border bg-sidebar text-sidebar-foreground"
  >
    <!-- Logo -->
    <RouterLink
      to="/admin"
      class="flex h-14 items-center gap-2 px-4 font-semibold tracking-tight transition-colors hover:bg-sidebar-accent"
    >
      <Monitor class="h-6 w-6 shrink-0" />
      <span class="text-lg">IOT 管理后台</span>
    </RouterLink>

    <Separator class="bg-sidebar-border" />

    <!-- Navigation -->
    <nav class="flex-1 space-y-1 overflow-y-auto px-2 py-3">
      <RouterLink
        v-for="item in navItems"
        :key="item.to"
        :to="item.to"
        :class="[
          'flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium transition-colors',
          isActive(item.to) ? activeClass : 'text-sidebar-foreground/70 hover:bg-sidebar-accent/50 hover:text-sidebar-foreground',
        ]"
      >
        <component :is="item.icon" class="h-4 w-4 shrink-0" />
        {{ item.label }}
      </RouterLink>
    </nav>

    <!-- Footer -->
    <div class="border-t border-sidebar-border px-4 py-3">
      <p class="text-xs text-sidebar-foreground/50">IOT Manage System v1.0</p>
    </div>
  </aside>
</template>