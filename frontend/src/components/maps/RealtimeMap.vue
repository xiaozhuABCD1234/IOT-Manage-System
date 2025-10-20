<template>
  <div class="m-0 h-full w-full p-0" id="container"></div>
</template>

<script setup lang="ts">
import AMapLoader from "@amap/amap-jsapi-loader";
import { onMounted, onUnmounted, ref, defineEmits, defineExpose } from "vue";
import { MAP_CONFIG } from "@/config/map";
import { connectMQTT, disconnectMQTT } from "@/utils/mqtt";
import { updateDevicePosition } from "@/utils/map";
import { parseMessage } from "@/utils/mqtt";
import type { Device } from "@/utils/mqtt";
import type { MqttClient } from "mqtt";
import type { PolygonFenceResp } from "@/types/polygonFence";

let map: AMap.Map | null = null;
let mqttClient: MqttClient | null = null;
const devices = ref<Device[]>([]);

// 绘制相关
let mouseTool: AMap.MouseTool | null = null;
let tempPolygon: AMap.Polygon | null = null;
const fencePolygons: AMap.Polygon[] = [];

const emit = defineEmits<{
  (e: "polygon-drawn", points: { x: number; y: number }[]): void;
}>();

const msgCallback = (topic: string, payload: Buffer) => {
  if (!map) return;
  const fix = parseMessage(topic, payload);
  if (!fix) {
    console.log("收到 0,0，已忽略");
    return;
  }
  updateDevicePosition(map, devices, fix.id, fix.lng, fix.lat);
};

onMounted(() => {
  (window as { _AMapSecurityConfig?: { securityJsCode: string } })._AMapSecurityConfig = {
    securityJsCode: MAP_CONFIG.securityJsCode,
  };
  AMapLoader.load({
    key: MAP_CONFIG.key,
    version: MAP_CONFIG.version,
    plugins: ["AMap.ToolBar", "AMap.Scale", "AMap.MouseTool", "AMap.PolyEditor"],
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
        mouseTool = new AMap.MouseTool(map);
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
  devices.value = [];
  fencePolygons.forEach((p) => p.setMap(null as unknown as AMap.Map));
  if (tempPolygon) tempPolygon.setMap(null as unknown as AMap.Map);
  map?.destroy();
});

function clearTempPolygon() {
  if (tempPolygon) {
    tempPolygon.setMap(null as unknown as AMap.Map);
    tempPolygon = null;
  }
}

function startPolygonDrawing() {
  if (!mouseTool || !map) return;
  clearTempPolygon();
  mouseTool.polygon({
    strokeColor: "#ff7f50",
    strokeWeight: 2,
    fillColor: "#ff7f50",
    fillOpacity: 0.2,
  });
  // 根据官方示例，MouseTool 绘制结束会触发 draw 事件
  // 参考：`polylineeditor` 与 `add-polygon` 教程示例
  // https://lbs.amap.com/demo/javascript-api-v2/example/overlay-editor/polylineeditor
  // https://lbs.amap.com/api/javascript-api-v2/tutorails/add-polygon
  (mouseTool as AMap.MouseTool).on("draw", (e: { obj: AMap.Polygon }) => {
    tempPolygon = e.obj;
    mouseTool?.close(true);
    const path = (tempPolygon.getPath?.() || []) as AMap.LngLat[];
    const points = path.map((lnglat) => ({ x: lnglat.lng, y: lnglat.lat }));
    emit("polygon-drawn", points);
  });
}

function cancelDrawing() {
  if (mouseTool) mouseTool.close(true);
  clearTempPolygon();
}

function setOutdoorFences(fences: PolygonFenceResp[]) {
  if (!map) return;
  // 清空旧的
  fencePolygons.forEach((p) => p.setMap(null as unknown as AMap.Map));
  fencePolygons.length = 0;
  // 添加新的
  fences.forEach((f) => {
    const polygon = new (window as any).AMap.Polygon({
      path: f.points.map((pt) => [pt.x, pt.y] as [number, number]),
      strokeColor: f.is_active ? "#1677ff" : "#999999",
      strokeWeight: 2,
      fillColor: f.is_indoor ? "#16a34a" : "#f97316",
      fillOpacity: 0.15,
    });
    polygon.setMap(map as AMap.Map);
    fencePolygons.push(polygon);
  });
}

defineExpose({ startPolygonDrawing, cancelDrawing, setOutdoorFences, clearTempPolygon });
</script>
