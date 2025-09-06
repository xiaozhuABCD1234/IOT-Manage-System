<template>
  <div class="m-0 h-full w-full p-0" id="container"></div>
</template>

<script setup lang="ts">
import AMapLoader from "@amap/amap-jsapi-loader";
import { onMounted, onUnmounted, ref } from "vue";
import { MAP_CONFIG } from "@/config/map";
import { connectMQTT, disconnectMQTT } from "@/utils/mqtt";
import { updateDevicePosition } from "@/utils/map";
import { parseMessage } from "@/utils/mqtt";
import type { Device } from "@/utils/mqtt";
import type { MqttClient } from "mqtt";

let map: AMap.Map | null = null;
let mqttClient: MqttClient | null = null;
const devices = ref<Device[]>([]);

const msgCallback = (topic: string, payload: Buffer) => {
  if (!map) return;
  const { id, lng, lat } = parseMessage(topic, payload);
  updateDevicePosition(map, devices, id, lng, lat);
};

onMounted(() => {
  (window as { _AMapSecurityConfig?: { securityJsCode: string } })._AMapSecurityConfig = {
    securityJsCode: MAP_CONFIG.securityJsCode,
  };
  AMapLoader.load({
    key: MAP_CONFIG.key,
    version: MAP_CONFIG.version,
    plugins: ["AMap.ToolBar", "AMap.Scale"],
  })
    .then((AMap) => {
      map = new AMap.Map("container", {
        viewMode: "2D",
        zoom: MAP_CONFIG.defaultZoom,
        center: MAP_CONFIG.defaultCenter,
      });
      if (map) {
        map.addControl(new AMap.ToolBar());
        map.addControl(new AMap.Scale());
      }
    })
    .catch(console.error);

  // 连接MQTT
  mqttClient = connectMQTT();
  mqttClient.subscribe("location/#", { qos: 0 }, (err) => {
    if (err) return console.error("订阅失败", err);
    console.log("已订阅 location/#");
  });
  mqttClient.on("message", msgCallback);
});

onUnmounted(() => {
  disconnectMQTT(mqttClient as MqttClient);
  devices.value = []; // 清空设备数组
  map?.destroy();
});
</script>
