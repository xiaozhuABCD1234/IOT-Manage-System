// @/utils/map.ts
import type { Ref } from "vue";
import type { Device } from "./mqtt";
import { getAllDeviceIDToName, getMarkByID,getMarkByDeviceID } from "@/api/mark";

const COLORS = ["#1890ff", "#52c41a", "#fadb14", "#ff4d4f", "#722ed1"];
const lastUpdateTime = new Map<string, number>();
const UPDATE_INTERVAL = 1000;

/* ---------- 设备名缓存 ---------- */
let deviceIDToNameCache: Record<string, string> = {};
let cacheInitialized = false;
async function initializeDeviceIDToNameCache() {
  if (cacheInitialized) return;
  try {
    const { data } = await getAllDeviceIDToName();
    if (data?.success) deviceIDToNameCache = data.data;
  } finally { cacheInitialized = true; }
}
function getDeviceDisplayName(id: string) {
  return deviceIDToNameCache[id] || id;
}

/* ---------- 危险半径缓存 ---------- */
const deviceDangerRadiusCache = new Map<string, number>(); // id -> danger_zone_m

/* ---------- 当前正在显示的圆 ---------- */
const deviceCircleMap = new Map<string, AMap.Circle>();

/* 创建设备 */
export const createDevice = (map: AMap.Map, id: string, lng: number, lat: number): Device => {
  const idx = id.split("").reduce((s, c) => s + c.charCodeAt(0), 0) % COLORS.length;
  const color = COLORS[idx];
  const displayName = getDeviceDisplayName(id);

  const polyline = new AMap.Polyline({
    path: [[lng, lat]],
    strokeColor: color,
    strokeWeight: 3,
    lineJoin: "round",
  });
  const marker = new AMap.Marker({
    position: [lng, lat],
    content: `
      <div class="px-2 py-1 min-w-16 h-6 rounded-full flex items-center justify-center
                  text-xs font-medium text-white shadow-lg cursor-pointer
                  border border-white/20 backdrop-blur-sm
                  transition-all duration-200 hover:scale-110 hover:shadow-xl"
           style="background:${color}">${displayName}</div>`,
    offset: new AMap.Pixel(-12, -12),
  });
  map.add([polyline, marker]);
  return { id, path: [[lng, lat]], polyline, marker };
};

/* 画危险圆（内部工具） */
async function drawDangerCircle(map: AMap.Map, device: Device) {
  const deviceId = device.id;
  let radius = deviceDangerRadiusCache.get(deviceId);

  /* 第一次：拿后端数据并缓存 */
  if (radius === undefined) {
    try {
      const { data } = await getMarkByDeviceID(deviceId); // 若 markId 与 deviceId 不同，换成对应接口
      radius = data?.data?.danger_zone_m ?? 0;
    } catch { radius = 0; }
    deviceDangerRadiusCache.set(deviceId, radius);
  }

  /* 半径无效就删圆并结束 */
  if (!radius || radius <= 0) {
    const old = deviceCircleMap.get(deviceId);
    if (old) { map.remove(old); deviceCircleMap.delete(deviceId); }
    return;
  }

  /* 取最新位置 */
  const lastPos = device.path.at(-1);
  if (!lastPos) return;
  const [lng, lat] = lastPos;

  /* 删旧圆 */
  const oldCircle = deviceCircleMap.get(deviceId);
  if (oldCircle) map.remove(oldCircle);

  /* 画新圆 */
  const circle = new AMap.Circle({
    center: new AMap.LngLat(lng, lat),
    radius,
    fillColor: "#ff0000",
    strokeColor: "#cc0000",
    strokeWeight: 2,
    fillOpacity: 0.3,
  });
  map.add(circle);
  deviceCircleMap.set(deviceId, circle);
}

/* 主更新函数 */
export const updateDevicePosition = async (
  map: AMap.Map,
  devices: Ref<Device[]>,
  id: string,
  lng: number,
  lat: number,
) => {
  await initializeDeviceIDToNameCache();

  const now = Date.now();
  if (now - (lastUpdateTime.get(id) ?? 0) < UPDATE_INTERVAL) return;
  lastUpdateTime.set(id, now);

  let device = devices.value.find(d => d.id === id);
  if (!device) {
    device = createDevice(map, id, lng, lat);
    devices.value.push(device);
  } else {
    const newPath = [...device.path, [lng, lat] as [number, number]];
    device.path = newPath;
    device.polyline.setPath(newPath);
    device.marker.setPosition([lng, lat]);
  }

  /* ✅ 每次位置变化都自动重画危险圆 */
  await drawDangerCircle(map, device);
};

/* 清理函数 —— 组件卸载时调用 */
export function clearDeviceCircles(map: AMap.Map) {
  deviceCircleMap.forEach(c => map.remove(c));
  deviceCircleMap.clear();
}