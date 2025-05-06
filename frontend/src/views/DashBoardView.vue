<template>
  <div class="dashboard-view">
    <el-row :gutter="20">
      <!-- CPU使用率 -->
      <el-col :span="8">
        <DashBoard :value="cpuUsage" unit="%">
          <h3 class="metric-title">
            <el-icon>
              <Cpu />
            </el-icon>
            CPU 使用率
          </h3>
        </DashBoard>
      </el-col>

      <!-- 内存使用 -->
      <el-col :span="8">
        <DashBoard :value="memory.used" :total="memory.total" unit="GB">
          <h3 class="metric-title">
            <el-icon>
              <MemoryStick />
            </el-icon>
            内存使用
          </h3>
        </DashBoard>
      </el-col>

      <!-- 磁盘存储 -->
      <el-col :span="8">
        <DashBoard :value="disk.used" :total="disk.total" unit="GB">
          <h3 class="metric-title">
            <el-icon>
              <HardDrive />
            </el-icon>
            磁盘存储
          </h3>
        </DashBoard>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { onBeforeUnmount, ref } from "vue";
import DashBoard from "@/components/DashBoard.vue";
import { useConfigStore } from "@/stores/config";
import { Cpu, HardDrive, MemoryStick } from "lucide-vue-next";

const ConfigStore = useConfigStore();

// 响应式数据
const cpuUsage = ref(0);
const memory = ref({ used: 0, total: 0 });
const disk = ref({ used: 0, total: 0 });

// WebSocket处理
const ws = ref<WebSocket | null>(null);
const reconnectInterval = ref(5000);
const maxReconnectAttempts = 5;
let reconnectAttempts = 0;
const isMounted = ref(true); // 新增挂载状态跟踪
const reconnectTimer = ref<ReturnType<typeof setTimeout> | null>(null); // 新增重连定时器引用

function connect() {
  if (!isMounted.value) return; // 组件已卸载不再连接

  ws.value = new WebSocket(ConfigStore.effectiveServerUrl + "/devops/status");

  ws.value.onopen = () => {
    if (!isMounted.value) return; // 组件已卸载不处理
    console.log("WebSocket已连接");
    reconnectAttempts = 0;
  };

  ws.value.onmessage = (event) => {
    try {
      const data = JSON.parse(event.data);

      //console.log("接收到原始数据:", data);

      // 处理CPU数据
      if (typeof data.cpu_used === "number") {
        cpuUsage.value = Number(data.cpu_used.toFixed(1));
      }

      // 处理内存数据
      memory.value = {
        used: parseFloat(formatGB(data.memory_used)),
        total: parseFloat(formatGB(data.memory_total)),
      };

      // 处理磁盘数据
      disk.value = {
        used: parseFloat(formatGB(data.disk_used)),
        total: parseFloat(formatGB(data.disk_total)),
      };

      // console.log("转换后数据:", {
      //   cpuUsage: cpuUsage.value,
      //   memory: memory.value,
      //   disk: disk.value,
      // });
    } catch (error) {
      console.error("数据解析错误:", error);
    }
  };

  ws.value.onerror = (error) => {
    if (!isMounted.value) return;
    console.error("WebSocket错误:", error);
    reconnect();
  };

  ws.value.onclose = () => {
    if (!isMounted.value) return;
    console.log("WebSocket连接关闭");
    reconnect();
  };
}

function formatGB(bytes: number) {
  return (bytes / Math.pow(1024, 3)).toFixed(2);
}

function reconnect() {
  if (!isMounted.value || reconnectAttempts >= maxReconnectAttempts) return;

  reconnectTimer.value = setTimeout(() => {
    console.log(
      `尝试重新连接 (${reconnectAttempts + 1}/${maxReconnectAttempts})`,
    );
    reconnectAttempts++;
    connect();
  }, reconnectInterval.value);
}

onBeforeUnmount(() => {
  // 标记组件已卸载
  isMounted.value = false;

  // 清理WebSocket
  if (ws.value) {
    ws.value.onclose = null; // 移除关闭回调
    ws.value.onerror = null; // 移除错误回调
    ws.value.close();
    ws.value = null;
  }

  // 清理重连定时器
  if (reconnectTimer.value) {
    clearTimeout(reconnectTimer.value);
    reconnectTimer.value = null;
  }
});

connect();
</script>
