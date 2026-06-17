<script setup lang="ts">
import { onMounted, computed } from "vue";
import { useRouter } from "vue-router";
import { Monitor, Users, Package, AlertTriangle } from "lucide-vue-next";
import { useAdminStore } from "@/stores/admin";
import { useMarksStore } from "@/stores/marks";
import StatsCards from "@/components/admin/StatsCards.vue";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const adminStore = useAdminStore();
const marksStore = useMarksStore();
const router = useRouter();

onMounted(() => {
  adminStore.fetchDashboardStats();
  // Start MQTT to get online count
  if (!marksStore.isConnected) {
    marksStore.startMQTT();
  }
});

const stats = computed(() => [
  {
    title: "设备总数",
    value: adminStore.deviceCount,
    icon: Package,
    description: "已注册的 IOT 设备数量",
  },
  {
    title: "在线设备",
    value: marksStore.onlineCount,
    icon: Monitor,
    description: "当前在线的设备数量",
  },
  {
    title: "用户总数",
    value: adminStore.userCount,
    icon: Users,
    description: "系统注册用户数量",
  },
  {
    title: "活跃警报",
    value: 0,
    icon: AlertTriangle,
    description: "当前未处理的警报数量",
  },
]);

const quickActions = [
  { label: "管理用户", to: "/admin/users", icon: Users },
  { label: "管理设备", to: "/marks/manage", icon: Package },
  { label: "设备状态", to: "/marks/status", icon: Monitor },
];
</script>

<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-2xl font-bold tracking-tight">仪表盘</h1>
      <p class="text-muted-foreground">IOT 管理系统概览</p>
    </div>

    <!-- Stats Cards -->
    <StatsCards :stats="stats" :loading="adminStore.loading" />

    <!-- Quick Actions -->
    <Card>
      <CardHeader>
        <CardTitle>快捷操作</CardTitle>
      </CardHeader>
      <CardContent>
        <div class="flex flex-wrap gap-3">
          <Button
            v-for="action in quickActions"
            :key="action.to"
            variant="outline"
            @click="router.push(action.to)"
          >
            <component :is="action.icon" class="mr-2 h-4 w-4" />
            {{ action.label }}
          </Button>
        </div>
      </CardContent>
    </Card>
  </div>
</template>