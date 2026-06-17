<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from "vue";
import { markApi } from "@/api";
import type { MarkResponse } from "@/types/mark";
import { useMarksStore } from "@/stores/marks";
import { toast } from "vue-sonner";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Wifi, WifiOff, Package } from "lucide-vue-next";

const marksStore = useMarksStore();

// Device list from API
const devices = ref<MarkResponse[]>([]);
const loading = ref(false);

// Stats
const onlineCount = computed(() => marksStore.onlineCount);
const offlineCount = computed(() => {
  const onlineIds = new Set(marksStore.markList.map((m) => m.id));
  return devices.value.filter((d) => !onlineIds.has(d.device_id)).length;
});
const totalCount = computed(() => devices.value.length);

// Check if device is online via marksStore
function isOnline(deviceId: string): boolean {
  return marksStore.isDeviceOnline(deviceId);
}

function getLastOnline(mark: MarkResponse): string {
  // Use API data for last online time
  if (mark.last_online_at) {
    return new Date(mark.last_online_at).toLocaleString("zh-CN");
  }
  return "-";
}

// Fetch device list
async function fetchDevices() {
  loading.value = true;
  try {
    const res = await markApi.listMarks({ limit: 100, preload: true });
    devices.value = (res.data.data as unknown as MarkResponse[]) ?? [];
  } catch (err) {
    console.error("获取设备列表失败:", err);
    toast.error("获取设备列表失败");
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  // Start MQTT for real-time status (store uses ref counting)
  marksStore.startMQTT();
  fetchDevices();
});

onUnmounted(() => {
  marksStore.stopMQTT();
});
</script>

<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-2xl font-bold tracking-tight">设备状态</h1>
      <p class="text-muted-foreground">实时监控设备在线状态</p>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-3 gap-4">
      <div class="rounded-lg border bg-card p-4">
        <div class="flex items-center gap-2">
          <Wifi class="h-4 w-4 text-green-500" />
          <span class="text-sm text-muted-foreground">在线设备</span>
        </div>
        <p class="mt-1 text-2xl font-bold text-green-600">{{ onlineCount }}</p>
      </div>
      <div class="rounded-lg border bg-card p-4">
        <div class="flex items-center gap-2">
          <WifiOff class="h-4 w-4 text-muted-foreground" />
          <span class="text-sm text-muted-foreground">离线设备</span>
        </div>
        <p class="mt-1 text-2xl font-bold">{{ offlineCount }}</p>
      </div>
      <div class="rounded-lg border bg-card p-4">
        <div class="flex items-center gap-2">
          <Package class="h-4 w-4 text-muted-foreground" />
          <span class="text-sm text-muted-foreground">设备总数</span>
        </div>
        <p class="mt-1 text-2xl font-bold">{{ totalCount }}</p>
      </div>
    </div>

    <!-- Connection Status -->
    <div class="flex items-center gap-2 text-sm">
      <span
        class="inline-block h-2 w-2 rounded-full"
        :class="marksStore.isConnected ? 'bg-green-500' : 'bg-red-500'"
      />
      <span class="text-muted-foreground">
        {{ marksStore.isConnected ? "MQTT 已连接" : "MQTT 未连接" }}
      </span>
    </div>

    <!-- Table -->
    <div class="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead class="w-[140px]">设备ID</TableHead>
            <TableHead>设备名称</TableHead>
            <TableHead class="w-[100px]">状态</TableHead>
            <TableHead>最后在线时间</TableHead>
            <TableHead>类型</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <template v-if="loading">
            <TableRow v-for="i in 5" :key="i">
              <TableCell><Skeleton class="h-4 w-24" /></TableCell>
              <TableCell><Skeleton class="h-4 w-24" /></TableCell>
              <TableCell><Skeleton class="h-5 w-16" /></TableCell>
              <TableCell><Skeleton class="h-4 w-32" /></TableCell>
              <TableCell><Skeleton class="h-5 w-16" /></TableCell>
            </TableRow>
          </template>
          <template v-else-if="devices.length === 0">
            <TableRow>
              <TableCell colspan="5" class="h-24 text-center text-muted-foreground">
                <div class="flex flex-col items-center gap-2">
                  <Package class="h-8 w-8 text-muted-foreground/50" />
                  <span>暂无设备数据</span>
                </div>
              </TableCell>
            </TableRow>
          </template>
          <template v-else>
            <TableRow v-for="device in devices" :key="device.id">
              <TableCell class="font-mono text-xs">{{ device.device_id }}</TableCell>
              <TableCell class="font-medium">{{ device.mark_name }}</TableCell>
              <TableCell>
                <div class="flex items-center gap-2">
                  <span
                    class="inline-block h-2.5 w-2.5 rounded-full"
                    :class="isOnline(device.device_id) ? 'bg-green-500' : 'bg-gray-400'"
                  />
                  <Badge :variant="isOnline(device.device_id) ? 'default' : 'secondary'">
                    {{ isOnline(device.device_id) ? "在线" : "离线" }}
                  </Badge>
                </div>
              </TableCell>
              <TableCell class="text-muted-foreground text-xs">
                {{ getLastOnline(device) }}
              </TableCell>
              <TableCell>
                <Badge variant="outline">
                  {{ device.mark_type?.type_name ?? "未分类" }}
                </Badge>
              </TableCell>
            </TableRow>
          </template>
        </TableBody>
      </Table>
    </div>
  </div>
</template>