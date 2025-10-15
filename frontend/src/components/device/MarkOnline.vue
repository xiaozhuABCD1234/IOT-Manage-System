<template>
  <Card class="h-full w-full">
    <CardHeader>
      <CardTitle class="flex items-center gap-2">
        <Wifi
          class="h-5 w-5"
          :class="{ 'text-green-500': store.isConnected, 'text-red-500': !store.isConnected }"
        />
        标记在线状态
        <Badge v-if="store.isConnected" variant="outline" class="ml-2"> 已连接 </Badge>
        <Badge v-else variant="destructive" class="ml-2"> 未连接 </Badge>
      </CardTitle>
      <CardDescription>
        实时监控所有标记设备的在线情况
        <span class="text-muted-foreground ml-2 text-sm">
          (在线: {{ store.onlineCount }}, 离线: {{ store.offlineCount }})
        </span>
      </CardDescription>
    </CardHeader>
    <CardContent>
      <div v-if="store.connectionError" class="mb-4 rounded-md border border-red-200 bg-red-50 p-3">
        <p class="text-sm text-red-600">连接错误: {{ store.connectionError }}</p>
        <Button @click="store.reconnectMQTT" variant="outline" size="sm" class="mt-2">
          重新连接
        </Button>
      </div>
      <MarkOnlineGrid :marks="store.markList" :device-names="store.deviceNames" />
    </CardContent>
  </Card>
</template>

<script setup lang="ts">
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Wifi } from "lucide-vue-next";
import { onMounted, onUnmounted } from "vue";
import MarkOnlineGrid from "@/components/device/MarkOnlineGrid.vue";
import { useMarksStore } from "@/stores/marks";

const store = useMarksStore();

onMounted(() => {
  // 启动全局MQTT连接
  store.startMQTT();
});

onUnmounted(() => {
  // 注意：这里不停止MQTT连接，因为其他组件可能还在使用
  // 如果需要完全停止，可以在应用退出时调用 store.stopMQTT()
});
</script>
