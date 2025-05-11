<script setup lang="ts">
import { onMounted, onUnmounted, ref } from "vue";
import MonitorMap from '@/components/map/MonitorMap.vue';
import UWBMap from '@/components/map/UWBMap.vue';
import mqtt from "mqtt";
import { useConfigStore } from "@/stores/config";
import { ElNotification } from "element-plus";

// 状态跟踪Map
const prevIndoorStates = ref(new Map<string, boolean>());

// 获取配置信息
const ConfigStore = useConfigStore();

// MQTT配置
const mqttConfig = {
  url: ConfigStore.mqtturl,
  options: {
    clean: true,
    connectTimeout: 4000,
    clientId: ConfigStore.mqttclientid,
    username: ConfigStore.mqttuser,
    password: ConfigStore.mqttpwd,
  },
  topic: ConfigStore.mqtttopic,
};

let client: mqtt.MqttClient | null = null;

const handleMessage = (payload: Buffer) => {
  try {
    const data = JSON.parse(payload.toString());
    const { id, indoor, sensors } = data;

    // 基础校验
    if (!id || typeof indoor === "undefined") return;

    // 处理状态变化
    const prevState = prevIndoorStates.value.get(id);
    if (prevState !== undefined && prevState !== indoor) {
      ElNotification({
        title: "设备状态变化",
        message: `设备 ${id} 已${indoor ? "进入" : "离开"}监测区域`,
        type: indoor ? "success" : "warning",
        duration: 3000,
        offset: 50  // 防止遮挡地图控件
      });
    }

    // 更新状态记录
    prevIndoorStates.value.set(id, indoor);

    // 这里可以添加地图相关的处理逻辑
    // 例如根据indoor状态更新地图标记

  } catch (e) {
    console.error("MQTT消息处理失败:", e);
  }
};

// 生命周期
onMounted(() => {
  client = mqtt.connect(mqttConfig.url, mqttConfig.options);
  client.on("connect", () => {
    console.log("MQTT连接成功");
    client?.subscribe(mqttConfig.topic);
  });
  client.on("message", (_, payload) => handleMessage(payload));
});

onUnmounted(() => {
  client?.end(true);
  console.log("MQTT连接已断开");
});
</script>

<template>
  <div class="container">
    <el-row :gutter="20" class="row-spacing">
      <el-col :span="15">
        <MonitorMap />
      </el-col>
      <el-col :span="9">
        <UWBMap />
      </el-col>
    </el-row>
  </div>
</template>

<style scoped>
.container {
  position: relative;
  width: 100%;
  height: 100vh;
  /* 改为视口高度确保地图容器有明确高度 */
  padding: 10px;
  box-sizing: border-box;
}

.row-spacing {
  height: calc(100vh - 20px);
  /* 减去上下padding */
}

/* 调整地图容器的默认边距 */
:deep(.el-col) {
  height: 100%;
}

/* 优化通知样式 */
:global(.el-notification) {
  max-width: 380px;
  font-family: "Helvetica Neue", Helvetica, "PingFang SC", "Hiragino Sans GB",
    "Microsoft YaHei", "微软雅黑", Arial, sans-serif;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.15);
}
</style>
