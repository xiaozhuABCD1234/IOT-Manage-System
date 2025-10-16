import type { Ref } from "vue";
import type { Device } from "./mqtt";
import { getAllDeviceIDToName } from "@/api/mark";

const COLORS = ["#1890ff", "#52c41a", "#fadb14", "#ff4d4f", "#722ed1"];

// 位置更新节流控制
const lastUpdateTime = new Map<string, number>();
const UPDATE_INTERVAL = 1000; // ?秒更新一次位置

// 设备ID到名称的映射缓存
let deviceIDToNameCache: Record<string, string> = {};
let cacheInitialized = false;

// 初始化设备ID到名称的映射
async function initializeDeviceIDToNameCache() {
  if (cacheInitialized) return;

  try {
    const response = await getAllDeviceIDToName();
    if (response.data && response.data.success) {
      deviceIDToNameCache = response.data.data;
      cacheInitialized = true;
    }
  } catch (error) {
    console.warn("Failed to load device ID to name mapping:", error);
    cacheInitialized = true; // 避免重复请求
  }
}

// 获取设备显示名称
function getDeviceDisplayName(deviceId: string): string {
  return deviceIDToNameCache[deviceId] || deviceId;
}

// 导出初始化函数，供其他组件调用
export const initializeDeviceNameCache = initializeDeviceIDToNameCache;

export const createDevice = (map: AMap.Map, id: string, lng: number, lat: number): Device => {
  const idx = id.split("").reduce((sum, c) => sum + c.charCodeAt(0), 0) % COLORS.length;
  const color = COLORS[idx];

  // 获取设备显示名称
  const displayName = getDeviceDisplayName(id);

  const polyline = new AMap.Polyline({
    path: [[lng, lat]],
    strokeColor: color,
    strokeWeight: 3,
    lineJoin: "round",
  });

  const marker = new AMap.Marker({
    position: [lng, lat],
    content:
    `
      <div class="
        px-2 py-1 min-w-6 h-6 rounded-full flex items-center justify-center
        text-xs font-medium text-white shadow-lg cursor-pointer
        border border-white/20 backdrop-blur-sm
        transition-all duration-200 hover:scale-110 hover:shadow-xl
" style="background:${color}">${displayName}</div>
`,
    offset: new AMap.Pixel(-12, -12),
  });

  map.add([polyline, marker]);

  return { id, path: [[lng, lat]], polyline, marker };
};

export const updateDevicePosition = async (
  map: AMap.Map,
  devices: Ref<Device[]>,
  id: string,
  lng: number,
  lat: number,
) => {
  await initializeDeviceIDToNameCache(); // ✅ 等待缓存初始化完成

  const now = Date.now();
  const lastUpdate = lastUpdateTime.get(id) || 0;
  if (now - lastUpdate < UPDATE_INTERVAL) return;
  lastUpdateTime.set(id, now);

  let device = devices.value.find((d) => d.id === id);
  if (!device) {
    device = createDevice(map, id, lng, lat);
    devices.value.push(device);
  } else {
    const newPath = [...device.path, [lng, lat] as [number, number]];
    device.path = newPath;
    device.polyline.setPath(newPath);
    device.marker.setPosition([lng, lat]);
  }
};
