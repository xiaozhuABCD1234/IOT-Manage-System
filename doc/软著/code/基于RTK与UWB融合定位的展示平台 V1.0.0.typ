#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

#show: codly-init.with()

// ===== 软著格式页眉 =====
#set page(
  margin: (top: 2.8cm, bottom: 2.5cm, x: 2cm),
  header: context {
    // 0.13 推荐用 context 取代 locate
    if here().page() >= 1 {
      // 正文页码从第 1 页开始才显示页眉
      set text(size: 10.5pt, font: "SimSun")
      "基于RTK与UWB融合定位的展示平台 V1.0.0"
      h(1fr)
      "第 " + str(counter(page).at(here()).first()) + " 页"
      line(length: 100%, stroke: 0.5pt)
    }
  },
  numbering: none,
)
// ========================


#codly(languages: codly-languages,zebra-fill: none,number-format: none,)



#show raw: set text(size: 0.8em)
#show raw: set par(leading: 12em)  // 行间距
```ts
export interface SetPairDistanceRequest {
  mark1_id: string; 
  mark2_id: string; 
  distance: number; 
}
export interface SetCombinationsDistanceRequest {
  mark_ids: string[]; 
  distance: number; 
}
export type IdentifierKind = "mark" | "tag" | "type";
export interface Identifier {
  kind: IdentifierKind;
  mark_id?: string; 
  tag_id?: number; 
  type_id?: number; 
}
export interface SetCartesianDistanceRequest {
  first: Identifier; 
  second: Identifier; 
  distance: number; 
}
export interface PairDistanceResponse {
  mark1_id: string;
  mark2_id: string;
  distance: number;
}
export type DistanceMapResponse = Record<string, number>;
export interface PairItem {
  mark1_id: string;
  mark2_id: string;
  distance_m: number;
}
interface ErrorObj {
  code: string;
  message: string;
  details?: unknown;
}
interface PaginationObj {
  currentPage: number;
  totalPages: number;
  totalItems: number;
  itemsPerPage: number;
  has_next: boolean;
  has_prev: boolean;
}
interface ApiResponse<T = unknown> {
  success: boolean;
  data: T;
  message?: string;
  error?: ErrorObj;
  pagination?: PaginationObj;
  timestamp: string;
}
export type { ApiResponse, PaginationObj, ErrorObj };
export interface Point {
  x: number;
  y: number;
}
export interface PolygonFenceCreateReq {
  is_indoor: boolean;
  fence_name: string;
  points: Point[];
  description?: string;
}
export interface PolygonFenceUpdateReq {
  is_indoor?: boolean;
  fence_name?: string;
  points?: Point[];
  description?: string;
  is_active?: boolean;
}
export interface PolygonFenceResp {
  id: string;
  is_indoor: boolean;
  fence_name: string;
  points: Point[];
  description: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}
export interface PointCheckReq {
  x: number;
  y: number;
}
export interface PointCheckResp {
  is_inside: boolean;
  fence_id?: string;
  fence_name?: string;
  fence_names?: string[];
}
export interface MarkTypeRequest {
  type_name: string | null; 
  default_danger_zone_m?: number | null; 
}
export interface MarkTypeResponse {
  id: number;
  type_name: string;
  default_danger_zone_m: number;
}
export interface MarkTagRequest {
  tag_name: string; 
}
export interface MarkTagResponse {
  id: number;
  tag_name: string;
}
export interface MarkCreateRequest {
  device_id: string; 
  mark_name: string; 
  mqtt_topic?: string[]; 
  persist_mqtt?: boolean; 
  danger_zone_m?: number | null; 
  mark_type_id?: number; 
  tags?: string[]; 
}
export interface MarkUpdateRequest {
  device_id?: string;
  mark_name?: string;
  mqtt_topic?: string[];
  persist_mqtt?: boolean;
  danger_zone_m?: number;
  mark_type_id?: number;
  tags?: string[] | null;
}
export interface MarkResponse {
  id: string;
  device_id: string;
  mark_name: string;
  mqtt_topic: string[];
  persist_mqtt: boolean;
  danger_zone_m: number | null;
  mark_type: MarkTypeResponse | null;
  tags: MarkTagResponse[];
  created_at: string; 
  updated_at: string;
  last_online_at: string | null;
}
export interface CustomMapCreateReq {
  map_name: string;
  image_base64?: string;
  image_ext?: ".jpg" | ".jpeg" | ".png" | ".gif" | ".webp";
  x_min: number;
  x_max: number;
  y_min: number;
  y_max: number;
  center_x: number;
  center_y: number;
  scale_ratio?: number; 
  description?: string;
}
export interface CustomMapUpdateReq {
  map_name?: string;
  image_base64?: string;
  image_ext?: ".jpg" | ".jpeg" | ".png" | ".gif" | ".webp";
  x_min?: number;
  x_max?: number;
  y_min?: number;
  y_max?: number;
  center_x?: number;
  center_y?: number;
  scale_ratio?: number; 
  description?: string;
}
export interface CustomMapResp {
  id: string;
  map_name: string;
  image_path: string;
  image_url: string;
  x_min: number;
  x_max: number;
  y_min: number;
  y_max: number;
  center_x: number;
  center_y: number;
  scale_ratio: number; 
  description: string;
  created_at: string;
  updated_at: string;
}
interface ImportMetaEnv {
  readonly VITE_API_BASE: string;
}
interface ImportMeta {
  readonly env: ImportMetaEnv;
}
export interface StationCreateReq {
  station_name: string;
  coordinate_x: number;
  coordinate_y: number;
}
export interface StationUpdateReq {
  station_name?: string;
  coordinate_x?: number;
  coordinate_y?: number;
}
export interface StationResp {
  id: string;
  station_name: string;
  coordinate_x: number;
  coordinate_y: number;
  created_at: string;
  updated_at: string;
}
import type { MarkOnline } from "@/utils/mqtt";
export function sortMarks(list: MarkOnline[]) {
  list.sort((a, b) => {
    if (a.online !== b.online) return Number(b.online) - Number(a.online);
    return a.id.localeCompare(b.id);
  });
}
import axios, { type AxiosResponse, type AxiosError } from "axios";
import { toast } from "vue-sonner";
import type { ApiResponse } from "@/types/response";
const service = axios.create({
  baseURL: import.meta.env.VITE_API_BASE as string,
  timeout: 10000,
  headers: {
    "Content-Type": "application/json",
    Accept: "application/json",
  },
});
service.interceptors.request.use((config) => {
  const token = localStorage.getItem("access_token");
  if (token && token !== "undefined") {
    config.headers.set("Authorization", `Bearer ${token}`);
  }
  return config;
});
service.interceptors.response.use(
  <T>(response: AxiosResponse<ApiResponse<T>>) => {
    const { success, message, error } = response.data;
    if (success) return response;
    const errorMessage = message || error?.message || "请求失败";
    toast.error(errorMessage);
    (response as unknown as { _handled: boolean })._handled = true;
    return Promise.reject(response);
  },
  (error: AxiosError<ApiResponse>) => {
    const { response, message } = error;
    if (response?.status) {
      if (response.status >= 500) {
        toast.error("服务器内部错误");
      } else if (response.status >= 400) {
        toast.error("网络错误");
      } else {
        toast.error("网络异常");
      }
    } else {
      toast.error("网络连接失败");
    }
    (error as unknown as { _handled: boolean })._handled = true;
    return Promise.reject(error);
  },
);
export default service;
import mqtt from "mqtt";
import type { MqttClient } from "mqtt";
import { MQTT_CONFIG } from "@/config/mqtt";
import gcoord from "gcoord";
const MQTT_URL = MQTT_CONFIG.MQTT_URL;
export const TOPIC_ONLINE = "location/#";
const MQTT_OPTS = {
  clientId: MQTT_CONFIG.clientId,
  clean: MQTT_CONFIG.clean,
  connectTimeout: MQTT_CONFIG.connectTimeout,
  reconnectPeriod: MQTT_CONFIG.reconnectPeriod,
  username: MQTT_CONFIG.username,
  password: MQTT_CONFIG.password,
  will: {
    topic: "device/lwt", 
    payload: JSON.stringify({
      msg: "客户端异常离线",
      ts: Date.now(),
    }),
    qos: 1 as const,
    retain: false, 
  },
};
let Client: MqttClient | null = null;
export function connectMQTT(): MqttClient {
  const client: MqttClient = mqtt.connect(MQTT_URL, {
    ...MQTT_OPTS,
    clientId: MQTT_CONFIG.clientId + "_" + Math.random().toString(16).slice(2),
  });
  client.on("connect", () => console.log("MQTT 已连接"));
  client.on("reconnect", () => console.log("MQTT 正在重连"));
  client.on("error", (e) => console.error("MQTT 错误", e));
  client.on("offline", () => console.warn("MQTT 离线"));
  Client = client;
  return client;
}
export function disconnectMQTT(client: MqttClient) {
  if (client) {
    client.end();
  }
}
export interface Sen {
  n: string;
  u: string;
  v: number | number[];
}
export interface Msg {
  id: string;
  sens: Sen[];
}
export interface Device {
  id: string;
  path: Array<[number, number]>;
  polyline: AMap.Polyline;
  marker: AMap.Marker;
}
export interface MarkOnlineMsg {
  id: string;
}
export interface MarkOnline {
  id: string;
  online: boolean;
  topic: string;
  st?: number;
}
export interface GeoFix {
  id: string;
  lng: number;
  lat: number;
}
export interface UWBFix {
  x: number;
  y: number;
  id: string;
}
export const parseMessage = (topic: string, payload: Buffer): GeoFix | null => {
  const data = JSON.parse(payload.toString()) as Msg;
  const rtkSen = data.sens.find((s) => s.n === "RTK");
  if (!rtkSen || !Array.isArray(rtkSen.v) || rtkSen.v.length !== 2) {
    throw new Error("缺少 RTK 字段或格式错误");
  }
  const [lngWGS, latWGS] = rtkSen.v as [number, number];
  if (lngWGS === 0 && latWGS === 0) {
    return null; 
  }
  const [lngGCJ, latGCJ] = gcoord.transform([lngWGS, latWGS], gcoord.WGS84, gcoord.GCJ02);
  return { id: data.id, lng: lngGCJ, lat: latGCJ };
};
export const parseUWBMessage = (topic: string, payload: Buffer): UWBFix => {
  const data = JSON.parse(payload.toString()) as Msg;
  const uwbSen = data.sens.find((s) => s.n === "UWB");
  if (!uwbSen || !Array.isArray(uwbSen.v) || uwbSen.v.length !== 2) {
    throw new Error("缺少 UWB 字段或格式错误");
  }
  const [x, y] = uwbSen.v as [number, number];
  return { id: data.id, x, y };
};
export const parseOnlineMessage = (topic: string, payload: Buffer): MarkOnline => {
  const data = JSON.parse(payload.toString()) as Msg;
  let idFromTopic = topic.replace("location", "");
  idFromTopic = idFromTopic.replace(/^\/+|\/+$/g, "");
  const id = data?.id?.trim() || idFromTopic;
  if (!id) {
    return { id: "unknown", online: true, topic };
  }
  return { id, online: true, topic };
};
import { ref } from "vue";
import { getAllMarkIDToName } from "@/api/mark/index";
const markNames = ref<Record<string, string>>({});
let isLoaded = false;
export const getMarkName = (markId: string): string => {
  return markNames.value[markId] || markId;
};
export const loadMarkNames = async (): Promise<void> => {
  try {
    const response = await getAllMarkIDToName();
    if (response.data.data) {
      markNames.value = response.data.data;
      isLoaded = true;
    }
  } catch (error) {
    console.error("加载标记名称失败:", error);
    throw error;
  }
};
export const ensureMarkNamesLoaded = async (): Promise<void> => {
  if (!isLoaded) {
    await loadMarkNames();
  }
};
export const getAllMarkNames = (): Record<string, string> => {
  return markNames.value;
};
export const resetMarkNames = (): void => {
  markNames.value = {};
  isLoaded = false;
};
import type { Ref } from "vue";
import type { Device } from "./mqtt";
import { getAllDeviceIDToName, getMarkByID,getMarkByDeviceID } from "@/api/mark";
const COLORS = ["#1890ff", "#52c41a", "#fadb14", "#ff4d4f", "#722ed1"];
const lastUpdateTime = new Map<string, number>();
const UPDATE_INTERVAL = 1000;
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
const deviceDangerRadiusCache = new Map<string, number>(); 
const deviceCircleMap = new Map<string, AMap.Circle>();
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
async function drawDangerCircle(map: AMap.Map, device: Device) {
  const deviceId = device.id;
  let radius = deviceDangerRadiusCache.get(deviceId);
  if (radius === undefined) {
    try {
      const { data } = await getMarkByDeviceID(deviceId); 
      radius = data?.data?.danger_zone_m ?? 0;
    } catch { radius = 0; }
    deviceDangerRadiusCache.set(deviceId, radius);
  }
  if (!radius || radius <= 0) {
    const old = deviceCircleMap.get(deviceId);
    if (old) { map.remove(old); deviceCircleMap.delete(deviceId); }
    return;
  }
  const lastPos = device.path.at(-1);
  if (!lastPos) return;
  const [lng, lat] = lastPos;
  const oldCircle = deviceCircleMap.get(deviceId);
  if (oldCircle) map.remove(oldCircle);
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
  await drawDangerCircle(map, device);
};
export function clearDeviceCircles(map: AMap.Map) {
  deviceCircleMap.forEach(c => map.remove(c));
  deviceCircleMap.clear();
}
import type { Ref } from "vue";
import type { MarkOnline } from "@/utils/mqtt";
import { sortMarks } from "./sort";
export function createDeviceStateMachine(marks: Ref<MarkOnline[]>) {
  const timerMap = new Map<string, number>();
  const offlineTimerMap = new Map<string, number>();
  function setOnlineFalse(id: string) {
    const idx = marks.value.findIndex((m) => m.id === id);
    if (idx !== -1) marks.value[idx].online = false;
    timerMap.delete(id);
  }
  function removeDevice(id: string) {
    const idx = marks.value.findIndex((m) => m.id === id);
    if (idx !== -1) marks.value.splice(idx, 1);
    offlineTimerMap.delete(id);
    timerMap.delete(id);
  }
  function onMessage(data: MarkOnline) {
    if (offlineTimerMap.has(data.id)) clearTimeout(offlineTimerMap.get(data.id)!);
    if (timerMap.has(data.id)) clearTimeout(timerMap.get(data.id)!);
    const idx = marks.value.findIndex((m) => m.id === data.id);
    if (idx >= 0) {
      marks.value[idx] = data;
    } else {
      marks.value.push(data);
    }
    timerMap.set(
      data.id,
      window.setTimeout(() => setOnlineFalse(data.id), 10000),
    );
    offlineTimerMap.set(
      data.id,
      window.setTimeout(() => removeDevice(data.id), 60_000),
    ); 
    sortMarks(marks.value); 
  }
  let sortTimer: number | undefined;
  function start() {
    sortTimer = window.setInterval(() => sortMarks(marks.value), 10000); 
  }
  function stop() {
    if (sortTimer !== undefined) clearInterval(sortTimer);
    timerMap.forEach(clearTimeout);
    offlineTimerMap.forEach(clearTimeout);
  }
  return { onMessage, start, stop };
}
import type { StationResp } from "@/types/station";
import type { PolygonFenceResp, Point } from "@/types/polygonFence";
import type { UWBFix, MarkOnline } from "@/utils/mqtt";
import type { CustomMapResp } from "@/types/customMap";
export class PixelScaler {
  readonly pixelWidth: number;
  readonly pixelHeight: number;
  readonly x_min: number;
  readonly x_max: number;
  readonly y_min: number;
  readonly y_max: number;
  constructor(
    pixelWidth: number,
    pixelHeight: number,
    x_min: number,
    x_max: number,
    y_min: number,
    y_max: number,
  ) {
    this.pixelWidth = pixelWidth;
    this.pixelHeight = pixelHeight;
    this.x_min = x_min;
    this.x_max = x_max;
    this.y_min = y_min;
    this.y_max = y_max;
  }
  toPixel(x: number, y: number): { px: number; py: number } {
    const px = ((x - this.x_min) / (this.x_max - this.x_min)) * this.pixelWidth;
    const py = (1 - (y - this.y_min) / (this.y_max - this.y_min)) * this.pixelHeight;
    return { px, py };
  }
  toXY(px: number, py: number): { x: number; y: number } {
    const x = this.x_min + (px / this.pixelWidth) * (this.x_max - this.x_min);
    const y = this.y_min + (1 - py / this.pixelHeight) * (this.y_max - this.y_min);
    return { x, y };
  }
}
export function drawBackgroundImage(
  ctx: CanvasRenderingContext2D,
  imageUrl: string,
  width: number,
  height: number,
): Promise<void> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.crossOrigin = "anonymous";
    img.src = imageUrl;
    img.onload = () => {
      ctx.drawImage(img, 0, 0, width, height);
      resolve();
    };
    img.onerror = () => {
      console.error("Failed to load background image:", imageUrl);
      reject(new Error("Failed to load image"));
    };
  });
}
export function generateNiceTicks(min: number, max: number, maxTicks: number = 10): number[] {
  const range = max - min;
  if (range === 0) return [min];
  const roughStep = range / (maxTicks - 1);
  const magnitude = Math.pow(10, Math.floor(Math.log10(roughStep)));
  const normalized = roughStep / magnitude; 
  let niceStep;
  if (normalized < 1.5) {
    niceStep = 1 * magnitude;
  } else if (normalized < 3) {
    niceStep = 2 * magnitude;
  } else if (normalized < 7) {
    niceStep = 5 * magnitude;
  } else {
    niceStep = 10 * magnitude;
  }
  const niceMin = Math.floor(min / niceStep) * niceStep;
  const niceMax = Math.ceil(max / niceStep) * niceStep;
  const ticks: number[] = [];
  for (let tick = niceMin; tick <= niceMax; tick += niceStep) {
    ticks.push(Math.round(tick / niceStep) * niceStep);
  }
  return ticks;
}
export function formatTickLabel(value: number): string {
  const absValue = Math.abs(value);
  if (absValue >= 1000000) {
    return (value / 1000000).toFixed(1).replace(/\.0$/, "") + "M";
  } else if (absValue >= 1000) {
    return (value / 1000).toFixed(1).replace(/\.0$/, "") + "k";
  } else if (absValue < 1 && absValue > 0) {
    return value.toFixed(2).replace(/\.?0+$/, "");
  } else {
    return value.toFixed(0);
  }
}
export function drawGrid(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  gridSpacing: number = 60,
  options: {
    color?: string;
    lineWidth?: number;
  } = {},
) {
  const { color = "#e0e0e0", lineWidth = 0.5 } = options;
  ctx.save();
  ctx.strokeStyle = color;
  ctx.lineWidth = lineWidth;
  const startX = Math.floor(scaler.x_min / gridSpacing) * gridSpacing;
  const endX = Math.ceil(scaler.x_max / gridSpacing) * gridSpacing;
  const startY = Math.floor(scaler.y_min / gridSpacing) * gridSpacing;
  const endY = Math.ceil(scaler.y_max / gridSpacing) * gridSpacing;
  for (let x = startX; x <= endX; x += gridSpacing) {
    const { px } = scaler.toPixel(x, 0);
    ctx.beginPath();
    ctx.moveTo(px, 0);
    ctx.lineTo(px, scaler.pixelHeight);
    ctx.stroke();
  }
  for (let y = startY; y <= endY; y += gridSpacing) {
    const { py } = scaler.toPixel(0, y);
    ctx.beginPath();
    ctx.moveTo(0, py);
    ctx.lineTo(scaler.pixelWidth, py);
    ctx.stroke();
  }
  ctx.restore();
}
export function drawAxisX(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  ticks: number = 10,
  options: {
    color?: string;
    lineWidth?: number;
    tickLength?: number;
    font?: string;
    textColor?: string;
    arrowSize?: number;
  } = {},
) {
  const {
    color = "#333",
    lineWidth = 2,
    tickLength = 8,
    font = "12px Arial",
    textColor = "#333",
    arrowSize = 10,
  } = options;
  const yPos = scaler.y_min <= 0 && scaler.y_max >= 0 ? 0 : scaler.y_min;
  const { py: yAxisPx } = scaler.toPixel(0, yPos);
  ctx.save();
  ctx.strokeStyle = color;
  ctx.fillStyle = color;
  ctx.lineWidth = lineWidth;
  ctx.beginPath();
  ctx.moveTo(0, yAxisPx);
  ctx.lineTo(scaler.pixelWidth, yAxisPx);
  ctx.stroke();
  ctx.beginPath();
  ctx.moveTo(scaler.pixelWidth, yAxisPx);
  ctx.lineTo(scaler.pixelWidth - arrowSize, yAxisPx - arrowSize / 2);
  ctx.lineTo(scaler.pixelWidth - arrowSize, yAxisPx + arrowSize / 2);
  ctx.closePath();
  ctx.fill();
  ctx.font = font;
  ctx.fillStyle = textColor;
  ctx.textAlign = "center";
  ctx.textBaseline = "top";
  const tickValues = generateNiceTicks(scaler.x_min, scaler.x_max, ticks);
  for (const x of tickValues) {
    if (x < scaler.x_min || x > scaler.x_max) continue;
    const { px } = scaler.toPixel(x, 0);
    ctx.strokeStyle = color;
    ctx.lineWidth = lineWidth;
    ctx.beginPath();
    ctx.moveTo(px, yAxisPx);
    ctx.lineTo(px, yAxisPx + tickLength);
    ctx.stroke();
    const label = formatTickLabel(x);
    ctx.strokeStyle = "rgba(255, 255, 255, 0.8)";
    ctx.lineWidth = 3;
    ctx.strokeText(label, px, yAxisPx + tickLength + 4);
    ctx.fillStyle = textColor;
    ctx.fillText(label, px, yAxisPx + tickLength + 4);
  }
  ctx.font = "bold 14px Arial";
  ctx.strokeStyle = "rgba(255, 255, 255, 0.8)";
  ctx.lineWidth = 3;
  ctx.strokeText("X", scaler.pixelWidth - 25, yAxisPx - 20);
  ctx.fillText("X", scaler.pixelWidth - 25, yAxisPx - 20);
  ctx.restore();
}
export function drawAxisY(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  ticks: number = 10,
  options: {
    color?: string;
    lineWidth?: number;
    tickLength?: number;
    font?: string;
    textColor?: string;
    arrowSize?: number;
  } = {},
) {
  const {
    color = "#333",
    lineWidth = 2,
    tickLength = 8,
    font = "12px Arial",
    textColor = "#333",
    arrowSize = 10,
  } = options;
  const xPos = scaler.x_min <= 0 && scaler.x_max >= 0 ? 0 : scaler.x_min;
  const { px: xAxisPx } = scaler.toPixel(xPos, 0);
  ctx.save();
  ctx.strokeStyle = color;
  ctx.fillStyle = color;
  ctx.lineWidth = lineWidth;
  ctx.beginPath();
  ctx.moveTo(xAxisPx, scaler.pixelHeight);
  ctx.lineTo(xAxisPx, 0);
  ctx.stroke();
  ctx.beginPath();
  ctx.moveTo(xAxisPx, 0);
  ctx.lineTo(xAxisPx - arrowSize / 2, arrowSize);
  ctx.lineTo(xAxisPx + arrowSize / 2, arrowSize);
  ctx.closePath();
  ctx.fill();
  ctx.font = font;
  ctx.fillStyle = textColor;
  ctx.textAlign = "right";
  ctx.textBaseline = "middle";
  const tickValues = generateNiceTicks(scaler.y_min, scaler.y_max, ticks);
  for (const y of tickValues) {
    if (y < scaler.y_min || y > scaler.y_max) continue;
    const { py } = scaler.toPixel(0, y);
    ctx.strokeStyle = color;
    ctx.lineWidth = lineWidth;
    ctx.beginPath();
    ctx.moveTo(xAxisPx - tickLength, py);
    ctx.lineTo(xAxisPx, py);
    ctx.stroke();
    const label = formatTickLabel(y);
    ctx.strokeStyle = "rgba(255, 255, 255, 0.8)";
    ctx.lineWidth = 3;
    ctx.strokeText(label, xAxisPx - tickLength - 4, py);
    ctx.fillStyle = textColor;
    ctx.fillText(label, xAxisPx - tickLength - 4, py);
  }
  ctx.font = "bold 14px Arial";
  ctx.textAlign = "center";
  ctx.strokeStyle = "rgba(255, 255, 255, 0.8)";
  ctx.lineWidth = 3;
  ctx.strokeText("Y", xAxisPx + 20, 15);
  ctx.fillText("Y", xAxisPx + 20, 15);
  ctx.restore();
}
export function drawStations(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  stations: StationResp[],
  options: {
    color?: string;
    size?: number;
    font?: string;
    textColor?: string;
  } = {},
) {
  const { color = "#3498db", size = 12, font = "12px Arial", textColor = "#333" } = options;
  ctx.save();
  stations.forEach((station) => {
    const { px, py } = scaler.toPixel(station.coordinate_x, station.coordinate_y);
    const height = (size * Math.sqrt(3)) / 2; 
    const halfBase = size / 2; 
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.moveTo(px, py - (height * 2) / 3);
    ctx.lineTo(px - halfBase, py + height / 3);
    ctx.lineTo(px + halfBase, py + height / 3);
    ctx.closePath();
    ctx.fill();
    ctx.strokeStyle = "#fff";
    ctx.lineWidth = 2;
    ctx.stroke();
    ctx.fillStyle = "#888";
    ctx.font = font;
    ctx.textAlign = "left";
    ctx.textBaseline = "bottom";
    ctx.fillText(station.station_name, px + halfBase + 4, py - (height * 2) / 3);
  });
  ctx.restore();
}
export function drawPolygonFences(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  fences: PolygonFenceResp[],
  options: {
    strokeColor?: string;
    fillColor?: string;
    lineWidth?: number;
    font?: string;
    textColor?: string;
  } = {},
) {
  const {
    strokeColor = "#3498db",
    fillColor = "rgba(68, 68, 255, 0.1)",
    lineWidth = 2,
    font = "12px Arial",
    textColor = "#3498db",
  } = options;
  ctx.save();
  fences.forEach((fence) => {
    if (fence.points.length < 3) return;
    const indoorStrokeColor = "#22c55e"; 
    const outdoorStrokeColor = "#f97316"; 
    const indoorFillColor = "rgba(34, 197, 94, 0.1)"; 
    const outdoorFillColor = "rgba(249, 115, 22, 0.1)"; 
    const currentStrokeColor = fence.is_indoor ? indoorStrokeColor : outdoorStrokeColor;
    const currentFillColor = fence.is_indoor ? indoorFillColor : outdoorFillColor;
    ctx.beginPath();
    const firstPoint = scaler.toPixel(fence.points[0].x, fence.points[0].y);
    ctx.moveTo(firstPoint.px, firstPoint.py);
    for (let i = 1; i < fence.points.length; i++) {
      const { px, py } = scaler.toPixel(fence.points[i].x, fence.points[i].y);
      ctx.lineTo(px, py);
    }
    ctx.closePath();
    ctx.fillStyle = fence.is_active ? currentFillColor : "rgba(150, 150, 150, 0.1)";
    ctx.fill();
    ctx.strokeStyle = fence.is_active ? currentStrokeColor : "#999";
    ctx.lineWidth = lineWidth;
    ctx.stroke();
    fence.points.forEach((point) => {
      const { px, py } = scaler.toPixel(point.x, point.y);
      ctx.fillStyle = fence.is_active ? currentStrokeColor : "#999";
      ctx.beginPath();
      ctx.arc(px, py, 4, 0, Math.PI * 2);
      ctx.fill();
    });
    if (fence.points.length > 0) {
      let centerX = 0,
        centerY = 0;
      fence.points.forEach((p) => {
        centerX += p.x;
        centerY += p.y;
      });
      centerX /= fence.points.length;
      centerY /= fence.points.length;
      const { px, py } = scaler.toPixel(centerX, centerY);
      ctx.fillStyle = fence.is_active ? currentStrokeColor : "#999";
      ctx.font = font;
      ctx.textAlign = "center";
      ctx.textBaseline = "middle";
      ctx.fillText(`${fence.fence_name}${fence.is_active ? "" : " (未激活)"}`, px, py);
    }
  });
  ctx.restore();
}
export function drawCurrentPolygon(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  points: Point[],
) {
  if (points.length === 0) return;
  ctx.save();
  if (points.length > 1) {
    ctx.beginPath();
    const firstPoint = scaler.toPixel(points[0].x, points[0].y);
    ctx.moveTo(firstPoint.px, firstPoint.py);
    for (let i = 1; i < points.length; i++) {
      const { px, py } = scaler.toPixel(points[i].x, points[i].y);
      ctx.lineTo(px, py);
    }
    ctx.strokeStyle = "#ff6b35";
    ctx.lineWidth = 2;
    ctx.setLineDash([5, 5]);
    ctx.stroke();
    ctx.setLineDash([]);
  }
  points.forEach((point, index) => {
    const { px, py } = scaler.toPixel(point.x, point.y);
    ctx.fillStyle = "#ff6b35";
    ctx.beginPath();
    ctx.arc(px, py, 6, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = "#fff";
    ctx.lineWidth = 2;
    ctx.stroke();
    ctx.fillStyle = "#fff";
    ctx.font = "bold 10px Arial";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText((index + 1).toString(), px, py);
  });
  ctx.restore();
}
export function drawUWBDevices(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  deviceCoordinates: Map<string, UWBFix>,
  onlineDevices: MarkOnline[],
  deviceNames: Map<string, string>,
  options: {
    onlineColor?: string;
    offlineColor?: string;
    size?: number;
    font?: string;
    textColor?: string;
    showTrail?: boolean;
    trailLength?: number;
  } = {},
) {
  const {
    onlineColor = "#e74c3c",
    offlineColor = "#95a5a6",
    size = 4,
    font = "10px Arial",
    textColor = "#333",
    showTrail = false,
    trailLength = 10,
  } = options;
  ctx.save();
  const deviceTrails = new Map<string, Array<{ x: number; y: number; timestamp: number }>>();
  deviceCoordinates.forEach((uwbData, deviceId) => {
    const { px, py } = scaler.toPixel(uwbData.x, uwbData.y);
    const isOnline = onlineDevices.some((device) => device.id === deviceId && device.online);
    const deviceColor = isOnline ? onlineColor : offlineColor;
    ctx.fillStyle = deviceColor;
    ctx.beginPath();
    ctx.arc(px, py, size, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = "#000"; 
    ctx.lineWidth = 1;
    ctx.stroke();
    const deviceName = deviceNames.get(deviceId) || "未知设备";
    const displayText = `${deviceName}(${deviceId})`;
    ctx.fillStyle = textColor;
    ctx.font = font;
    ctx.textAlign = "center";
    ctx.textBaseline = "top";
    ctx.strokeStyle = "rgba(255, 255, 255, 0.8)";
    ctx.lineWidth = 2;
    ctx.strokeText(displayText, px, py + size + 4);
    ctx.fillText(displayText, px, py + size + 4);
    const coordText = `(${uwbData.x.toFixed(1)}, ${uwbData.y.toFixed(1)})`;
    ctx.font = "8px Arial";
    ctx.textBaseline = "top";
    ctx.strokeText(coordText, px, py + size + 16);
    ctx.fillText(coordText, px, py + size + 16);
    if (showTrail) {
      if (!deviceTrails.has(deviceId)) {
        deviceTrails.set(deviceId, []);
      }
      const trail = deviceTrails.get(deviceId)!;
      trail.push({ x: uwbData.x, y: uwbData.y, timestamp: Date.now() });
      if (trail.length > trailLength) {
        trail.shift();
      }
      if (trail.length > 1) {
        ctx.strokeStyle = deviceColor;
        ctx.lineWidth = 1;
        ctx.globalAlpha = 0.6;
        ctx.beginPath();
        const firstPoint = scaler.toPixel(trail[0].x, trail[0].y);
        ctx.moveTo(firstPoint.px, firstPoint.py);
        for (let i = 1; i < trail.length; i++) {
          const { px: trailPx, py: trailPy } = scaler.toPixel(trail[i].x, trail[i].y);
          ctx.lineTo(trailPx, trailPy);
        }
        ctx.stroke();
        ctx.globalAlpha = 1;
      }
    }
  });
  ctx.restore();
}
export class DoubleBufferCanvas {
  private displayCanvas: HTMLCanvasElement;
  private offscreenCanvas: HTMLCanvasElement;
  private displayCtx: CanvasRenderingContext2D;
  private offscreenCtx: CanvasRenderingContext2D;
  private dpr: number;
  constructor(displayCanvas: HTMLCanvasElement) {
    this.displayCanvas = displayCanvas;
    this.dpr = window.devicePixelRatio || 1;
    this.offscreenCanvas = document.createElement("canvas");
    this.offscreenCanvas.style.display = "none"; 
    this.displayCtx = this.displayCanvas.getContext("2d")!;
    this.offscreenCtx = this.offscreenCanvas.getContext("2d")!;
    this.resize();
    console.log("🔄 双缓冲Canvas管理器已创建");
    console.log("📱 设备像素比:", this.dpr);
  }
  resize(): void {
    const rect = this.displayCanvas.getBoundingClientRect();
    this.displayCanvas.width = Math.round(rect.width * this.dpr);
    this.displayCanvas.height = Math.round(rect.height * this.dpr);
    this.offscreenCanvas.width = this.displayCanvas.width;
    this.offscreenCanvas.height = this.displayCanvas.height;
    this.displayCtx.scale(this.dpr, this.dpr);
    this.offscreenCtx.scale(this.dpr, this.dpr);
  }
  getOffscreenContext(): CanvasRenderingContext2D {
    return this.offscreenCtx;
  }
  getSize(): { width: number; height: number } {
    const rect = this.displayCanvas.getBoundingClientRect();
    return { width: rect.width, height: rect.height };
  }
  swapBuffers(): void {
    const imageData = this.offscreenCtx.getImageData(
      0,
      0,
      this.offscreenCanvas.width,
      this.offscreenCanvas.height,
    );
    this.displayCtx.putImageData(imageData, 0, 0);
    console.log("🔄 双缓冲交换完成，避免闪动");
  }
  clearOffscreen(): void {
    const { width, height } = this.getSize();
    this.offscreenCtx.clearRect(0, 0, width, height);
  }
  destroy(): void {
    this.offscreenCanvas.remove();
  }
}
export async function drawMapWithDoubleBuffer(
  doubleBufferCanvas: DoubleBufferCanvas,
  mapData: CustomMapResp | null,
  stations: StationResp[],
  fences: PolygonFenceResp[],
  deviceCoordinates: Map<string, UWBFix>,
  onlineDevices: MarkOnline[],
  deviceNames: Map<string, string>,
  currentPolygon: Point[] = [],
  isDrawing: boolean = false,
): Promise<void> {
  const { width: cssWidth, height: cssHeight } = doubleBufferCanvas.getSize();
  const ctx = doubleBufferCanvas.getOffscreenContext();
  doubleBufferCanvas.clearOffscreen();
  if (!mapData) {
    ctx.fillStyle = "#999";
    ctx.font = "16px Arial";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText("正在加载地图...", cssWidth / 2, cssHeight / 2);
    doubleBufferCanvas.swapBuffers();
    return;
  }
  const scaler = new PixelScaler(
    cssWidth,
    cssHeight,
    mapData.x_min,
    mapData.x_max,
    mapData.y_min,
    mapData.y_max,
  );
  try {
    if (mapData.image_url) {
      try {
        await drawBackgroundImage(ctx, mapData.image_url, cssWidth, cssHeight);
        console.log("✅ 底图加载成功:", mapData.image_url);
      } catch (error) {
        console.warn("⚠️ 底图加载失败，使用白色背景:", error);
        ctx.fillStyle = "#ffffff";
        ctx.fillRect(0, 0, cssWidth, cssHeight);
      }
    } else {
      ctx.fillStyle = "#ffffff";
      ctx.fillRect(0, 0, cssWidth, cssHeight);
    }
    const gridSpacing = 60;
    console.log(
      "网格间距:",
      gridSpacing,
      "坐标范围:",
      mapData.x_max - mapData.x_min,
      "x",
      mapData.y_max - mapData.y_min,
    );
    drawGrid(ctx, scaler, gridSpacing, {
      color: mapData.image_url ? "rgba(0, 0, 0, 0.15)" : "#e0e0e0",
      lineWidth: 1,
    });
    const axisFontSize = Math.max(10, Math.min(cssWidth, cssHeight) / 80);
    const axisColor = mapData.image_url ? "#000" : "#333";
    const textColor = mapData.image_url ? "#000" : "#333";
    console.log("🎯 坐标轴绘制在: X轴 y=0, Y轴 x=0 (画布中心)");
    const fenceLineWidth = Math.max(2, Math.min(cssWidth, cssHeight) / 300);
    const fenceFontSize = Math.max(12, Math.min(cssWidth, cssHeight) / 60);
    drawPolygonFences(ctx, scaler, fences, {
      strokeColor: "#3498db",
      fillColor: "rgba(68, 68, 255, 0.15)",
      lineWidth: fenceLineWidth,
      font: `${fenceFontSize}px Arial`,
    });
    const baseSize = Math.max(16, Math.min(cssWidth, cssHeight) / 50);
    const baseFontSize = Math.max(12, Math.min(cssWidth, cssHeight) / 60);
    drawStations(ctx, scaler, stations, {
      color: "#3498db",
      size: baseSize,
      font: `${baseFontSize}px Arial`,
    });
    const deviceSize = Math.max(8, Math.min(cssWidth, cssHeight) / 150);
    const deviceFontSize = Math.max(10, Math.min(cssWidth, cssHeight) / 80);
    drawUWBDevices(ctx, scaler, deviceCoordinates, onlineDevices, deviceNames, {
      onlineColor: "#e74c3c",
      offlineColor: "#95a5a6",
      size: deviceSize,
      font: `${deviceFontSize}px Arial`,
      textColor: "#333",
      showTrail: false, 
      trailLength: 10,
    });
    if (isDrawing && currentPolygon.length > 0) {
      drawCurrentPolygon(ctx, scaler, currentPolygon);
    }
    console.log("✅ Map drawn successfully with double buffer");
    console.log("📊 Canvas size:", cssWidth, "x", cssHeight);
    console.log("📍 Coordinate range:", {
      x: [mapData.x_min, mapData.x_max],
      y: [mapData.y_min, mapData.y_max],
    });
    console.log("🏢 Stations:", stations.length, "个");
    stations.forEach((station) => {
      const { px, py } = scaler.toPixel(station.coordinate_x, station.coordinate_y);
      console.log(
        `  - ${station.station_name}: 逻辑坐标(${station.coordinate_x}, ${station.coordinate_y}) → 像素(${px.toFixed(1)}, ${py.toFixed(1)})`,
      );
    });
    console.log("🚧 Fences:", fences.length, "个");
    console.log("📱 UWB Devices:", deviceCoordinates.size, "个");
    deviceCoordinates.forEach((uwbData, deviceId) => {
      const { px, py } = scaler.toPixel(uwbData.x, uwbData.y);
      const isOnline = onlineDevices.some((device) => device.id === deviceId && device.online);
      console.log(
        `  - ${deviceId}: UWB坐标(${uwbData.x}, ${uwbData.y}) → 像素(${px.toFixed(1)}, ${py.toFixed(1)}) [${isOnline ? "在线" : "离线"}]`,
      );
    });
    doubleBufferCanvas.swapBuffers();
  } catch (error) {
    console.error("Error drawing map with double buffer:", error);
  }
}
export async function drawStaticLayerWithDoubleBuffer(
  doubleBufferCanvas: DoubleBufferCanvas,
  mapData: CustomMapResp | null,
  stations: StationResp[],
  fences: PolygonFenceResp[],
): Promise<void> {
  const { width: cssWidth, height: cssHeight } = doubleBufferCanvas.getSize();
  const ctx = doubleBufferCanvas.getOffscreenContext();
  doubleBufferCanvas.clearOffscreen();
  if (!mapData) {
    ctx.fillStyle = "#999";
    ctx.font = "16px Arial";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText("正在加载地图...", cssWidth / 2, cssHeight / 2);
    doubleBufferCanvas.swapBuffers();
    return;
  }
  const scaler = new PixelScaler(
    cssWidth,
    cssHeight,
    mapData.x_min,
    mapData.x_max,
    mapData.y_min,
    mapData.y_max,
  );
  try {
    if (mapData.image_url) {
      try {
        await drawBackgroundImage(ctx, mapData.image_url, cssWidth, cssHeight);
      } catch {
        ctx.fillStyle = "#ffffff";
        ctx.fillRect(0, 0, cssWidth, cssHeight);
      }
    } else {
      ctx.fillStyle = "#ffffff";
      ctx.fillRect(0, 0, cssWidth, cssHeight);
    }
    const gridSpacing = 60;
    drawGrid(ctx, scaler, gridSpacing, {
      color: mapData.image_url ? "rgba(0, 0, 0, 0.15)" : "#e0e0e0",
      lineWidth: 1,
    });
    const fenceLineWidth = Math.max(2, Math.min(cssWidth, cssHeight) / 300);
    const fenceFontSize = Math.max(12, Math.min(cssWidth, cssHeight) / 60);
    drawPolygonFences(ctx, scaler, fences, {
      strokeColor: "#3498db",
      fillColor: "rgba(68, 68, 255, 0.15)",
      lineWidth: fenceLineWidth,
      font: `${fenceFontSize}px Arial`,
    });
    const baseSize = Math.max(16, Math.min(cssWidth, cssHeight) / 50);
    const baseFontSize = Math.max(12, Math.min(cssWidth, cssHeight) / 60);
    drawStations(ctx, scaler, stations, {
      color: "#3498db",
      size: baseSize,
      font: `${baseFontSize}px Arial`,
    });
    doubleBufferCanvas.swapBuffers();
  } catch (error) {
    console.error("Error drawing static layer:", error);
  }
}
export async function drawDynamicLayerWithDoubleBuffer(
  doubleBufferCanvas: DoubleBufferCanvas,
  mapData: CustomMapResp | null,
  deviceCoordinates: Map<string, UWBFix>,
  onlineDevices: MarkOnline[],
  deviceNames: Map<string, string>,
  currentPolygon: Point[] = [],
  isDrawing: boolean = false,
): Promise<void> {
  const { width: cssWidth, height: cssHeight } = doubleBufferCanvas.getSize();
  const ctx = doubleBufferCanvas.getOffscreenContext();
  doubleBufferCanvas.clearOffscreen();
  if (!mapData) {
    doubleBufferCanvas.swapBuffers();
    return;
  }
  const scaler = new PixelScaler(
    cssWidth,
    cssHeight,
    mapData.x_min,
    mapData.x_max,
    mapData.y_min,
    mapData.y_max,
  );
  try {
    const deviceSize = Math.max(8, Math.min(cssWidth, cssHeight) / 150);
    const deviceFontSize = Math.max(10, Math.min(cssWidth, cssHeight) / 80);
    drawUWBDevices(ctx, scaler, deviceCoordinates, onlineDevices, deviceNames, {
      onlineColor: "#e74c3c",
      offlineColor: "#95a5a6",
      size: deviceSize,
      font: `${deviceFontSize}px Arial`,
      textColor: "#333",
      showTrail: false,
      trailLength: 10,
    });
    const connectionFontSize = Math.max(10, Math.min(cssWidth, cssHeight) / 100);
    drawDeviceConnections(ctx, scaler, deviceCoordinates, onlineDevices, deviceNames, {
      lineColor: "#003399",
      lineWidth: 2,
      textColor: "#cc3333",
      fontSize: `${connectionFontSize}px Arial`,
      backgroundColor: "rgba(255, 255, 255, 0.8)",
    });
    if (isDrawing && currentPolygon.length > 0) {
      drawCurrentPolygon(ctx, scaler, currentPolygon);
    }
    doubleBufferCanvas.swapBuffers();
  } catch (error) {
    console.error("Error drawing dynamic layer:", error);
  }
}
export async function drawMap(
  canvas: HTMLCanvasElement,
  mapData: CustomMapResp | null,
  stations: StationResp[],
  fences: PolygonFenceResp[],
  deviceCoordinates: Map<string, UWBFix>,
  onlineDevices: MarkOnline[],
  deviceNames: Map<string, string>,
  currentPolygon: Point[] = [],
  isDrawing: boolean = false,
): Promise<void> {
  if (!canvas) return;
  const rect = canvas.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;
  canvas.width = Math.round(rect.width * dpr);
  canvas.height = Math.round(rect.height * dpr);
  const ctx = canvas.getContext("2d")!;
  ctx.scale(dpr, dpr);
  const cssWidth = rect.width;
  const cssHeight = rect.height;
  ctx.clearRect(0, 0, cssWidth, cssHeight);
  if (!mapData) {
    ctx.fillStyle = "#999";
    ctx.font = "16px Arial";
    ctx.textAlign = "center";
    ctx.textBaseline = "middle";
    ctx.fillText("正在加载地图...", cssWidth / 2, cssHeight / 2);
    return;
  }
  const scaler = new PixelScaler(
    cssWidth,
    cssHeight,
    mapData.x_min,
    mapData.x_max,
    mapData.y_min,
    mapData.y_max,
  );
  try {
    if (mapData.image_url) {
      try {
        await drawBackgroundImage(ctx, mapData.image_url, cssWidth, cssHeight);
        console.log("✅ 底图加载成功:", mapData.image_url);
      } catch (error) {
        console.warn("⚠️ 底图加载失败，使用白色背景:", error);
        ctx.fillStyle = "#ffffff";
        ctx.fillRect(0, 0, cssWidth, cssHeight);
      }
    } else {
      ctx.fillStyle = "#ffffff";
      ctx.fillRect(0, 0, cssWidth, cssHeight);
    }
    const gridSpacing = 60;
    console.log(
      "网格间距:",
      gridSpacing,
      "坐标范围:",
      mapData.x_max - mapData.x_min,
      "x",
      mapData.y_max - mapData.y_min,
    );
    drawGrid(ctx, scaler, gridSpacing, {
      color: mapData.image_url ? "rgba(0, 0, 0, 0.15)" : "#e0e0e0",
      lineWidth: 1,
    });
    console.log("🎯 坐标轴绘制在: X轴 y=0, Y轴 x=0 (画布中心)");
    const fenceLineWidth = Math.max(2, Math.min(cssWidth, cssHeight) / 300);
    const fenceFontSize = Math.max(12, Math.min(cssWidth, cssHeight) / 60);
    drawPolygonFences(ctx, scaler, fences, {
      strokeColor: "#3498db",
      fillColor: "rgba(68, 68, 255, 0.15)",
      lineWidth: fenceLineWidth,
      font: `${fenceFontSize}px Arial`,
    });
    const baseSize = Math.max(16, Math.min(cssWidth, cssHeight) / 50);
    const baseFontSize = Math.max(12, Math.min(cssWidth, cssHeight) / 60);
    drawStations(ctx, scaler, stations, {
      color: "#3498db",
      size: baseSize,
      font: `${baseFontSize}px Arial`,
    });
    const deviceSize = Math.max(8, Math.min(cssWidth, cssHeight) / 150);
    const deviceFontSize = Math.max(10, Math.min(cssWidth, cssHeight) / 80);
    drawUWBDevices(ctx, scaler, deviceCoordinates, onlineDevices, deviceNames, {
      onlineColor: "#e74c3c",
      offlineColor: "#95a5a6",
      size: deviceSize,
      font: `${deviceFontSize}px Arial`,
      textColor: "#333",
      showTrail: false, 
      trailLength: 10,
    });
    if (isDrawing && currentPolygon.length > 0) {
      drawCurrentPolygon(ctx, scaler, currentPolygon);
    }
    console.log("✅ Map drawn successfully");
    console.log("📊 Canvas size:", cssWidth, "x", cssHeight);
    console.log("📍 Coordinate range:", {
      x: [mapData.x_min, mapData.x_max],
      y: [mapData.y_min, mapData.y_max],
    });
    console.log("🏢 Stations:", stations.length, "个");
    stations.forEach((station) => {
      const { px, py } = scaler.toPixel(station.coordinate_x, station.coordinate_y);
      console.log(
        `  - ${station.station_name}: 逻辑坐标(${station.coordinate_x}, ${station.coordinate_y}) → 像素(${px.toFixed(1)}, ${py.toFixed(1)})`,
      );
    });
    console.log("🚧 Fences:", fences.length, "个");
    console.log("📱 UWB Devices:", deviceCoordinates.size, "个");
    deviceCoordinates.forEach((uwbData, deviceId) => {
      const { px, py } = scaler.toPixel(uwbData.x, uwbData.y);
      const isOnline = onlineDevices.some((device) => device.id === deviceId && device.online);
      console.log(
        `  - ${deviceId}: UWB坐标(${uwbData.x}, ${uwbData.y}) → 像素(${px.toFixed(1)}, ${py.toFixed(1)}) [${isOnline ? "在线" : "离线"}]`,
      );
    });
  } catch (error) {
    console.error("Error drawing map:", error);
  }
}
export function calculateDistance(
  point1: { x: number; y: number },
  point2: { x: number; y: number },
): number {
  const dx = point2.x - point1.x;
  const dy = point2.y - point1.y;
  return Math.sqrt(dx * dx + dy * dy);
}
export function drawDeviceConnections(
  ctx: CanvasRenderingContext2D,
  scaler: PixelScaler,
  deviceCoordinates: Map<string, UWBFix>,
  onlineDevices: MarkOnline[],
  deviceNames: Map<string, string>,
  options: {
    lineColor?: string;
    lineWidth?: number;
    textColor?: string;
    fontSize?: string;
    backgroundColor?: string;
  } = {},
) {
  const {
    lineColor = "#3498db",
    lineWidth = 2,
    textColor = "#2c3e50",
    fontSize = "12px Arial",
    backgroundColor = "rgba(255, 255, 255, 0.8)",
  } = options;
  ctx.save();
  const onlineDeviceCoords: Array<{ id: string; x: number; y: number; name: string }> = [];
  deviceCoordinates.forEach((uwbData, deviceId) => {
    const isOnline = onlineDevices.some((device) => device.id === deviceId && device.online);
    if (isOnline) {
      const deviceName = deviceNames.get(deviceId) || "未知设备";
      onlineDeviceCoords.push({
        id: deviceId,
        x: uwbData.x,
        y: uwbData.y,
        name: deviceName,
      });
    }
  });
  if (onlineDeviceCoords.length < 2) {
    ctx.restore();
    return;
  }
  for (let i = 0; i < onlineDeviceCoords.length; i++) {
    for (let j = i + 1; j < onlineDeviceCoords.length; j++) {
      const device1 = onlineDeviceCoords[i];
      const device2 = onlineDeviceCoords[j];
      const { px: px1, py: py1 } = scaler.toPixel(device1.x, device1.y);
      const { px: px2, py: py2 } = scaler.toPixel(device2.x, device2.y);
      ctx.strokeStyle = lineColor;
      ctx.lineWidth = lineWidth;
      ctx.setLineDash([5, 5]); 
      ctx.beginPath();
      ctx.moveTo(px1, py1);
      ctx.lineTo(px2, py2);
      ctx.stroke();
      ctx.setLineDash([]); 
      const distance = calculateDistance(device1, device2);
      const distanceText = `${(distance / 100).toFixed(2)}m`;
      const midX = (px1 + px2) / 2;
      const midY = (py1 + py2) / 2;
      ctx.font = fontSize;
      ctx.textAlign = "center";
      ctx.textBaseline = "middle";
      const textMetrics = ctx.measureText(distanceText);
      const textWidth = textMetrics.width;
      const textHeight = parseInt(fontSize) * 0.8;
      ctx.fillStyle = backgroundColor;
      ctx.fillRect(
        midX - textWidth / 2 - 4,
        midY - textHeight / 2 - 2,
        textWidth + 8,
        textHeight + 4,
      );
      ctx.fillStyle = textColor;
      ctx.fillText(distanceText, midX, midY);
    }
  }
  ctx.restore();
}
import { defineStore } from "pinia";
import { computed } from "vue";
import { useRouter } from "vue-router";
export const useMenuStore = defineStore("menu", () => {
  const router = useRouter();
  const activeIndex = computed(() => {
    switch (router.currentRoute.value.name) {
      case "home":
        return 0;
      case "map":
        return 1;
      case "tags":
        return 2;
      case "user":
        return 3;
      default:
        return 0;
    }
  });
  function jump(idx: number) {
    const names = ["home", "map", "tags", "user"] as const;
    router.push({ name: names[idx] });
  }
  return { activeIndex, jump };
});
import { defineStore } from "pinia";
import { ref, computed } from "vue";
import type { MarkOnline } from "@/utils/mqtt";
import { createDeviceStateMachine } from "@/utils/deviceState";
import { connectMQTT, disconnectMQTT, parseOnlineMessage, TOPIC_ONLINE } from "@/utils/mqtt";
import { getAllDeviceIDToName } from "@/api/mark";
import type { MqttClient } from "mqtt";
export const useMarksStore = defineStore("marks", () => {
  const marks = ref<MarkOnline[]>([]);
  const deviceNames = ref<Map<string, string>>(new Map());
  const isConnected = ref(false);
  const connectionError = ref<string | null>(null);
  let mqttClient: MqttClient | null = null;
  let nameTimer: number | null = null;
  const sm = createDeviceStateMachine(marks);
  const unnamedIds = computed(() => {
    const namedSet = new Set(deviceNames.value.keys());
    return marks.value.map((m) => m.id).filter((id) => !namedSet.has(id));
  });
  const onlineCount = computed(() => marks.value.filter((m) => m.online).length);
  const offlineCount = computed(() => marks.value.filter((m) => !m.online).length);
  const loadDeviceNames = async () => {
    try {
      const res = await getAllDeviceIDToName();
      const obj = res.data.data;
      deviceNames.value = new Map(Object.entries(obj || {}));
    } catch (error) {
      console.error("加载设备名称失败:", error);
    }
  };
  const startMQTT = () => {
    if (mqttClient) {
      console.log("MQTT已连接，跳过重复连接");
      return;
    }
    try {
      mqttClient = connectMQTT();
      isConnected.value = true;
      connectionError.value = null;
      mqttClient.subscribe(TOPIC_ONLINE, { qos: 0 }, (err) => {
        if (err) {
          console.error("订阅online/#失败", err);
          connectionError.value = "订阅失败: " + err.message;
          return;
        }
        console.log("已订阅 online/#");
      });
      mqttClient.on("message", (topic, payload) => {
        const data = parseOnlineMessage(topic, payload);
        sm.onMessage(data);
      });
      mqttClient.on("connect", () => {
        isConnected.value = true;
        connectionError.value = null;
        console.log("MQTT已连接");
      });
      mqttClient.on("reconnect", () => {
        console.log("MQTT正在重连");
      });
      mqttClient.on("error", (error) => {
        console.error("MQTT错误", error);
        connectionError.value = "连接错误: " + error.message;
        isConnected.value = false;
      });
      mqttClient.on("offline", () => {
        console.warn("MQTT离线");
        isConnected.value = false;
      });
      sm.start();
      loadDeviceNames(); 
      nameTimer = window.setInterval(loadDeviceNames, 10000); 
    } catch (error) {
      console.error("启动MQTT失败:", error);
      connectionError.value = "启动失败: " + (error as Error).message;
      isConnected.value = false;
    }
  };
  const stopMQTT = () => {
    if (mqttClient) {
      disconnectMQTT(mqttClient);
      mqttClient = null;
    }
    if (nameTimer !== null) {
      window.clearInterval(nameTimer);
      nameTimer = null;
    }
    sm.stop();
    isConnected.value = false;
    connectionError.value = null;
  };
  const reconnectMQTT = () => {
    stopMQTT();
    setTimeout(() => {
      startMQTT();
    }, 1000);
  };
  const getDeviceName = (deviceId: string): string => {
    return deviceNames.value.get(deviceId) || "未知设备";
  };
  const isDeviceOnline = (deviceId: string): boolean => {
    const device = marks.value.find((m) => m.id === deviceId);
    return device?.online || false;
  };
  const getDeviceInfo = (deviceId: string): MarkOnline | undefined => {
    return marks.value.find((m) => m.id === deviceId);
  };
  return {
    markList: marks,
    deviceNames,
    isConnected,
    connectionError,
    unnamedIds,
    onlineCount,
    offlineCount,
    startMQTT,
    stopMQTT,
    reconnectMQTT,
    loadDeviceNames,
    getDeviceName,
    isDeviceOnline,
    getDeviceInfo,
    onMessage: sm.onMessage,
    start: sm.start,
    stop: sm.stop,
  };
});
import { createRouter, createWebHistory } from "vue-router";
import type { RouteRecordRaw } from "vue-router";
const routes: RouteRecordRaw[] = [
  {
    path: "/",
    name: "home",
    component: () => import("@/views/HomeView.vue"),
  },
  {
    path: "/login",
    name: "login",
    component: () => import("@/views/LoginView.vue"),
  },
  {
    path: "/map/rtk",
    name: "map-rtk",
    component: () => import("@/views/RTKMapView.vue"),
  },
  {
    path: "/map",
    name: "map",
    component: () => import("@/views/MapView.vue"),
  },
  {
    path: "/map/uwb",
    name: "map-uwb",
    component: () => import("@/views/UWBMapView.vue"),
  },
  {
    path: "/stations",
    name: "stations",
    component: () => import("@/views/StationManageView.vue"),
  },
  {
    path: "/map/settings",
    name: "map-settings",
    component: () => import("@/views/MapSettingsView.vue"),
  },
  {
    path: "/map/settings/fence",
    name: "fence-settings",
    component: () => import("@/views/UWBMapNewView.vue"),
  },
  {
    path: "/marks/status",
    name: "marks-status",
    component: () => import("@/views/MarkStatusView.vue"),
  },
  {
    path: "/marks/manage",
    name: "marks-manage",
    component: () => import("@/views/MarkManageView.vue"),
  },
  {
    path: "/marks/distance",
    name: "distance-settings",
    component: () => import("@/views/DistanceSettingsView.vue"),
  },
  {
    path: "/type/:typeId",
    name: "TypeMarks",
    component: () => import("@/views/TypeDetailsView.vue"),
  },
  {
    path: "/tag/:tagId",
    name: "TagMarks",
    component: () => import("@/views/TagDetailsView.vue"),
  },
  {
    path: "/profile",
    name: "profile",
    component: () => import("@/views/UserProfileView.vue"),
  },
  {
    path: "/about",
    name: "about",
    component: () => import("@/views/AboutView.vue"),
  },
  {
    path: "/WS",
    name: "w",
    component: () => import("@/views/WarningView.vue"),
  },
];
const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
});
const LOGIN_PATH = "/login";
const SEVEN_DAYS = 7 * 24 * 60 * 60 * 1000;
router.beforeEach((to) => {
  if (to.path === LOGIN_PATH) return true;
  const token = localStorage.getItem("access_token");
  const loginTime = Number(localStorage.getItem("refresh_token_time") || 0);
  if (!token) return { path: LOGIN_PATH, query: { redirect: to.fullPath } };
  if (Date.now() - loginTime >= SEVEN_DAYS) {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    localStorage.removeItem("refresh_token_time");
    return { path: LOGIN_PATH, query: { redirect: to.fullPath } };
  }
  return true;
});
export default router;
import { createApp } from "vue";
import { createPinia } from "pinia";
import App from "./App.vue";
import router from "./router";
import "@/styles/index.css";
import { usePreferredDark, useDark } from "@vueuse/core";
useDark({
  selector: "html",
  attribute: "class",
  valueDark: "dark",
  valueLight: "",
  storageKey: null, 
});
const pinia = createPinia();
const app = createApp(App);
app.use(pinia);
app.use(router);
app.mount("#app");
export const MQTT_CONFIG = {
  MQTT_URL: import.meta.env.VITE_MQTT_URL,
  clientId: "vue_" + Math.random().toString(16).slice(3, 9),
  clean: true,
  connectTimeout: 4000,
  reconnectPeriod: 1000,
  username: "admin",
  password: "admin",
};
export const MAP_CONFIG = {
  key: import.meta.env.VITE_AMAP_KEY,
  securityJsCode: import.meta.env.VITE_AMAP_SECURITY_CODE,
  version: "2.0",
  plugins: ["AMap.Scale"] as const,
  defaultCenter: [121.509852,31.23098] as [number, number],
  defaultZoom: 17,
};
import request from "@/utils/request";
import type { ApiResponse } from "@/types/response";
const URLS = {
  start: "/api/v1/mqtt/warning/:deviceId/start",
  stop: "/api/v1/mqtt/warning/:deviceId/end",
} as const;
export async function startWarning(deviceId: string | number) {
  const url = URLS.start.replace(":deviceId", String(deviceId));
  return request.post<ApiResponse<null>>(url, {});
}
export async function endWarning(deviceId: string | number) {
  const url = URLS.stop.replace(":deviceId", String(deviceId));
  return request.post<ApiResponse<null>>(url, {});
}
import request from "@/utils/request";
import type { ApiResponse } from "@/types/response";
import type { UserListParams } from "./types";
export enum UserType {
  Root = "root",
  User = "user",
  Admin = "admin",
}
export interface LoginRequest {
  username: string;
  password: string;
}
export interface LoginResponse {
  access_token: string;
  refresh_token: string;
}
export interface RefreshTokenRequest {
  refresh_token: string;
}
export interface RefreshTokenResponse {
  access_token: string;
}
export interface CreateRequest {
  username: string;
  password: string;
  user_type: UserType;
}
export type UpdateRequest = Partial<Pick<CreateRequest, "username" | "user_type">>;
export interface User {
  id: string;
  username: string;
  user_type: UserType;
  created_at: string;
  updated_at: string;
}
const URLS = {
  users: "/api/v1/users",
  token: "/api/v1/users/token",
  refresh: "/api/v1/users/refresh",
  me: "/api/v1/users/me",
} as const;
export async function createUser(data: CreateRequest) {
  return request.post<ApiResponse<User>>(URLS.users, data);
}
export async function login(data: LoginRequest) {
  return request.post<ApiResponse<LoginResponse>>(URLS.token, data);
}
export async function refreshToken(data: RefreshTokenRequest) {
  return request.post<ApiResponse<RefreshTokenResponse>>(URLS.refresh, data);
}
export async function getMe() {
  return request.get<ApiResponse<User>>(URLS.me);
}
export async function getUser(id: string) {
  return request.get<ApiResponse<User>>(`${URLS.users}/${id}`);
}
export async function updateUser(id: string, data: UpdateRequest) {
  return request.put<ApiResponse<User>>(`${URLS.users}/${id}`, data);
}
export async function deleteUser(id: string) {
  return request.delete<ApiResponse<null>>(`${URLS.users}/${id}`);
}
export async function listUsers(params: UserListParams = {}) {
  return request.get<ApiResponse<User[]>>(URLS.users, { params });
}
export type { UserListParams };
export interface ListParams {
  page?: number;
  limit?: number;
  preload?: boolean;
}
export interface UserListParams {
  page?: number;
  per_page?: number;
}
import request from "@/utils/request";
import type { ApiResponse } from "@/types/response";
import type { StationCreateReq, StationUpdateReq, StationResp } from "@/types/station";
const URLS = {
  station: "/api/v1/station/",
} as const;
export async function createStation(data: StationCreateReq) {
  return request.post<ApiResponse<StationResp>>(URLS.station, data);
}
export async function listStations() {
  return request.get<ApiResponse<StationResp[]>>(URLS.station);
}
export async function getStationByID(id: string) {
  return request.get<ApiResponse<StationResp>>(`${URLS.station}${id}`);
}
export async function updateStation(id: string, data: StationUpdateReq) {
  return request.put<ApiResponse<StationResp>>(`${URLS.station}${id}`, data);
}
export async function deleteStation(id: string) {
  return request.delete<ApiResponse<null>>(`${URLS.station}${id}`);
}
import request from "@/utils/request";
import type { ApiResponse } from "@/types/response";
import type {
  PolygonFenceCreateReq,
  PolygonFenceUpdateReq,
  PolygonFenceResp,
  PointCheckReq,
  PointCheckResp,
} from "@/types/polygonFence";
const URLS = {
  polygonFence: "/api/v1/polygon-fence",
  indoor: "/api/v1/polygon-fence/indoor",
  outdoor: "/api/v1/polygon-fence/outdoor",
  checkAll: "/api/v1/polygon-fence/check-all",
  checkIndoorAll: "/api/v1/polygon-fence/check-indoor-all",
  checkIndoorAny: "/api/v1/polygon-fence/check-indoor-any",
  checkOutdoorAll: "/api/v1/polygon-fence/check-outdoor-all",
  checkOutdoorAny: "/api/v1/polygon-fence/check-outdoor-any",
} as const;
export async function createPolygonFence(data: PolygonFenceCreateReq) {
  return request.post<ApiResponse<null>>(`${URLS.polygonFence}/`, data);
}
export async function listPolygonFences(activeOnly: boolean = false) {
  const url = activeOnly ? `${URLS.polygonFence}/?active_only=true` : `${URLS.polygonFence}/`;
  return request.get<ApiResponse<PolygonFenceResp[]>>(url);
}
export async function listIndoorFences(activeOnly: boolean = false) {
  const url = activeOnly ? `${URLS.indoor}?active_only=true` : URLS.indoor;
  return request.get<ApiResponse<PolygonFenceResp[]>>(url);
}
export async function listOutdoorFences(activeOnly: boolean = false) {
  const url = activeOnly ? `${URLS.outdoor}?active_only=true` : URLS.outdoor;
  return request.get<ApiResponse<PolygonFenceResp[]>>(url);
}
export async function getPolygonFenceByID(id: string) {
  return request.get<ApiResponse<PolygonFenceResp>>(`${URLS.polygonFence}/${id}`);
}
export async function updatePolygonFence(id: string, data: PolygonFenceUpdateReq) {
  return request.put<ApiResponse<null>>(`${URLS.polygonFence}/${id}`, data);
}
export async function deletePolygonFence(id: string) {
  return request.delete<ApiResponse<null>>(`${URLS.polygonFence}/${id}`);
}
export async function checkPointInFence(fenceId: string, point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(`${URLS.polygonFence}/${fenceId}/check`, point);
}
export async function checkPointInAllFences(point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(URLS.checkAll, point);
}
export async function checkPointInIndoorFences(point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(URLS.checkIndoorAll, point);
}
export async function checkPointInAnyIndoorFence(point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(URLS.checkIndoorAny, point);
}
export async function checkPointInOutdoorFences(point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(URLS.checkOutdoorAll, point);
}
export async function checkPointInAnyOutdoorFence(point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(URLS.checkOutdoorAny, point);
}
export async function checkPointInIndoorFence(fenceId: string, point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(
    `${URLS.polygonFence}/${fenceId}/check-indoor`,
    point,
  );
}
export async function checkPointInOutdoorFence(fenceId: string, point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(
    `${URLS.polygonFence}/${fenceId}/check-outdoor`,
    point,
  );
}
import request from "@/utils/request";
import type { ApiResponse, PaginationObj } from "@/types/response";
import type { MarkTypeRequest, MarkTypeResponse, MarkResponse } from "@/types/mark";
import type { ListParams } from "../types";
const URLS = {
  types: "/api/v1/types/",
} as const;
export async function createMarkType(data: MarkTypeRequest) {
  return request.post<ApiResponse<MarkTypeResponse>>(URLS.types, data);
}
export async function listMarkTypes(params: ListParams = {}) {
  return request.get<ApiResponse<MarkTypeResponse[]>>(URLS.types, { params });
}
export async function getMarkTypeByID(typeId: number) {
  return request.get<ApiResponse<MarkTypeResponse>>(`${URLS.types}${typeId}`);
}
export async function getMarkTypeByName(name: string) {
  return request.get<ApiResponse<MarkTypeResponse>>(`${URLS.types}name/${name}`);
}
export async function getAllTypeIDToName() {
  return request.get<ApiResponse<Record<number, string>>>(`${URLS.types}id-to-name`);
}
export async function updateMarkType(typeId: number, data: MarkTypeRequest) {
  return request.put<ApiResponse<MarkTypeResponse>>(`${URLS.types}${typeId}`, data);
}
export async function deleteMarkType(typeId: number) {
  return request.delete<ApiResponse<null>>(`${URLS.types}${typeId}`);
}
export async function getMarksByTypeID(typeId: number, params: ListParams = {}) {
  return request.get<ApiResponse<MarkResponse>>(`${URLS.types}${typeId}/marks`, {
    params,
  });
}
export async function getMarksByTypeName(name: string, params: ListParams = {}) {
  return request.get<ApiResponse<MarkResponse>>(`${URLS.types}name/${name}/marks`, {
    params,
  });
}
export type { ListParams };
import request from "@/utils/request";
import type { ApiResponse, PaginationObj } from "@/types/response";
import type { MarkTagRequest, MarkTagResponse, MarkResponse } from "@/types/mark";
import type { ListParams } from "../types";
const URLS = {
  tags: "/api/v1/tags/",
} as const;
export async function createMarkTag(data: MarkTagRequest) {
  return request.post<ApiResponse<MarkTagResponse>>(URLS.tags, data);
}
export async function listMarkTags(params: ListParams = {}) {
  return request.get<ApiResponse<MarkTagResponse[]>>(URLS.tags, { params });
}
export async function getMarkTagByID(tagId: number) {
  return request.get<ApiResponse<MarkTagResponse>>(`${URLS.tags}${tagId}`);
}
export async function getMarkTagByName(name: string) {
  return request.get<ApiResponse<MarkTagResponse>>(`${URLS.tags}name/${name}`);
}
export async function getAllTagIDToName() {
  return request.get<ApiResponse<Record<number, string>>>(`${URLS.tags}id-to-name`);
}
export async function updateMarkTag(tagId: number, data: MarkTagRequest) {
  return request.put<ApiResponse<MarkTagResponse>>(`${URLS.tags}${tagId}`, data);
}
export async function deleteMarkTag(tagId: number) {
  return request.delete<ApiResponse<null>>(`${URLS.tags}${tagId}`);
}
export async function getMarksByTagID(tagId: number, params: ListParams = {}) {
  return request.get<ApiResponse<MarkResponse>>(`${URLS.tags}${tagId}/marks`, {
    params,
  });
}
export async function getMarksByTagName(name: string, params: ListParams = {}) {
  return request.get<ApiResponse<MarkResponse>>(`${URLS.tags}name/${name}/marks`, {
    params,
  });
}
export type { ListParams };
import request from "@/utils/request";
import type { ApiResponse, PaginationObj } from "@/types/response";
import type {
  SetPairDistanceRequest,
  SetCombinationsDistanceRequest,
  SetCartesianDistanceRequest,
  PairDistanceResponse,
  DistanceMapResponse,
  PairItem,
} from "@/types/distance";
const URLS = {
  pairs: "/api/v1/pairs",
} as const;
export async function getPairsList(page: number = 1, limit: number = 10) {
  return request.get<ApiResponse<PairItem[]>>(`${URLS.pairs}/`, {
    params: { page, limit },
  });
}
export async function setPairDistance(data: SetPairDistanceRequest) {
  return request.post<ApiResponse<null>>(`${URLS.pairs}/distance`, data);
}
export async function setCombinationsDistance(data: SetCombinationsDistanceRequest) {
  return request.post<ApiResponse<null>>(`${URLS.pairs}/combinations`, data);
}
export async function setCartesianDistance(data: SetCartesianDistanceRequest) {
  return request.post<ApiResponse<null>>(`${URLS.pairs}/cartesian`, data);
}
export async function getPairDistance(mark1Id: string, mark2Id: string) {
  return request.get<ApiResponse<PairDistanceResponse>>(
    `${URLS.pairs}/distance/${mark1Id}/${mark2Id}`,
  );
}
export async function getDistanceMapByMarkId(markId: string) {
  return request.get<ApiResponse<DistanceMapResponse>>(`${URLS.pairs}/distance/map/mark/${markId}`);
}
export async function getDistanceMapByDeviceId(deviceId: string) {
  return request.get<ApiResponse<DistanceMapResponse>>(
    `${URLS.pairs}/distance/map/device/${deviceId}`,
  );
}
export async function deletePairDistance(mark1Id: string, mark2Id: string) {
  return request.delete<ApiResponse<null>>(`${URLS.pairs}/distance/${mark1Id}/${mark2Id}`);
}
import request from "@/utils/request";
import type { ApiResponse, PaginationObj } from "@/types/response";
import type { MarkCreateRequest, MarkUpdateRequest, MarkResponse } from "@/types/mark";
import type { ListParams } from "../types";
const URLS = {
  marks: "/api/v1/marks/",
  persist: "/api/v1/marks/persist",
  tags: "/api/v1/tags/",
  types: "/api/v1/types/",
} as const;
export async function createMark(data: MarkCreateRequest) {
  return request.post<ApiResponse<MarkResponse>>(URLS.marks, data);
}
export async function getMarkByID(id: string, preload = false) {
  return request.get<ApiResponse<MarkResponse>>(`${URLS.marks}${id}`, {
    params: { preload },
  });
}
export async function getMarkByDeviceID(deviceId: string, preload = false) {
  return request.get<ApiResponse<MarkResponse>>(`${URLS.marks}device/${deviceId}`, {
    params: { preload },
  });
}
export async function getAllDeviceIDToName() {
  return request.get<ApiResponse<Record<string, string>>>(`${URLS.marks}device/id-to-name`);
}
export async function getAllMarkIDToName() {
  return request.get<ApiResponse<Record<string, string>>>(`${URLS.marks}id-to-name`);
}
export async function listMarks(params: ListParams = {}) {
  return request.get<ApiResponse<MarkResponse>>(URLS.marks, { params });
}
export async function updateMark(id: string, data: MarkUpdateRequest) {
  return request.put<ApiResponse<MarkResponse>>(`${URLS.marks}${id}`, data);
}
export async function deleteMark(id: string) {
  return request.delete<ApiResponse<null>>(`${URLS.marks}${id}`);
}
export async function updateMarkLastOnline(deviceId: string) {
  return request.put<ApiResponse<null>>(`${URLS.marks}device/${deviceId}/last-online`, {});
}
export async function getPersistMQTTByDeviceID(deviceId: string) {
  return request.get<ApiResponse<boolean>>(`${URLS.persist}/device/${deviceId}`);
}
export async function getMarksByPersistMQTT(persist: boolean, params: ListParams = {}) {
  return request.get<ApiResponse<MarkResponse>>(`${URLS.persist}/list`, {
    params: { persist, ...params },
  });
}
export async function getDeviceIDsByPersistMQTT(persist: boolean) {
  return request.get<ApiResponse<string[]>>(`${URLS.persist}/device-ids`, {
    params: { persist },
  });
}
export type { ListParams };
export * as markApi from "./mark";
export * as tagApi from "./mark/tag";
export * as typeApi from "./mark/type";
export * as pairApi from "./mark/pair";
export * as userApi from "./user";
export * as warningApi from "./warning";
export * as stationApi from "./station";
export * as customMapApi from "./customMap";
export * as polygonFenceApi from "./polygonFence";
export type { ListParams, UserListParams } from "./types";
import request from "@/utils/request";
import type { ApiResponse } from "@/types/response";
import type { CustomMapCreateReq, CustomMapUpdateReq, CustomMapResp } from "@/types/customMap";
const URLS = {
  customMap: "/api/v1/custom-map/",
  latest: "/api/v1/custom-map/latest",
} as const;
export async function createCustomMap(data: CustomMapCreateReq) {
  return request.post<ApiResponse<null>>(URLS.customMap, data);
}
export async function listCustomMaps() {
  return request.get<ApiResponse<CustomMapResp[]>>(URLS.customMap);
}
export async function getLatestCustomMap() {
  return request.get<ApiResponse<CustomMapResp>>(URLS.latest);
}
export async function getCustomMapByID(id: string) {
  return request.get<ApiResponse<CustomMapResp>>(`${URLS.customMap}${id}`);
}
export async function updateCustomMap(id: string, data: CustomMapUpdateReq) {
  return request.put<ApiResponse<null>>(`${URLS.customMap}${id}`, data);
}
export async function deleteCustomMap(id: string) {
  return request.delete<ApiResponse<null>>(`${URLS.customMap}${id}`);
}

```

```vue
<template>
  <Toaster />
  <div
    class="flex min-h-screen flex-col text-gray-900 dark:bg-gray-900 dark:text-gray-100"
  >
    <header class="sticky top-0 z-10 h-12 bg-blue-300 dark:bg-sky-800">
      <HomeHeader />
    </header>
    <main class="min-h-[calc(100vh-3rem)] bg-white dark:bg-gray-800">
      <router-view />
    </main>
        <!-- 页脚 -->
    <footer class="h-12 bg-blue-400 dark:bg-sky-900">
      <SiteFooter />
    </footer>
  </div>
</template>
<script setup lang="ts">
import { onMounted } from "vue";
import { useRouter } from "vue-router";
import type { RefreshTokenRequest, RefreshTokenResponse } from "@/api/user";
import { userApi } from "@/api";
import { Toaster } from "@/components/ui/sonner";
import "vue-sonner/style.css"; 
import HomeHeader from "./components/layout/AppHeader.vue";
import SiteFooter from "./components/layout/SiteFooter.vue";
onMounted(async () => {
  const refreshToken = localStorage.getItem("refresh_token");
  const loginTime = Number(localStorage.getItem("login_token_time") || 0);
  if (!refreshToken || Date.now() - loginTime < 18 * 3600 * 1000) return;
  try {
    const resp = await userApi.refreshToken({ refresh_token: refreshToken });
    const newAccessToken = resp.data.data?.access_token;
    if (newAccessToken) {
      localStorage.setItem("access_token", newAccessToken);
      localStorage.setItem("login_token_time", Date.now().toString());
    }
  } catch {
    localStorage.removeItem("access_token");
    localStorage.removeItem("refresh_token");
    localStorage.removeItem("login_token_time");
    useRouter().push("/login");
  }
  if (!localStorage.getItem("access_token")) {
    const { path } = useRouter().currentRoute.value;
    if (path !== "/login") {
      useRouter().push("/login");
    }
  }
});
</script>
<template>
  <Card>
    <CardHeader>
      <CardTitle class="flex items-center gap-2">
        <Link2 class="h-5 w-5" />
        点对点距离设置
      </CardTitle>
      <CardDescription>为两个标记之间设置安全距离</CardDescription>
    </CardHeader>
    <CardContent>
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <!-- 第一个标记选择 -->
        <div class="space-y-2">
          <Label for="mark1">第一个标记</Label>
          <Select v-model="formData.mark1_id" :disabled="Object.keys(markOptions).length === 0">
            <SelectTrigger id="mark1">
              <SelectValue
                :placeholder="Object.keys(markOptions).length === 0 ? '暂无数据' : '选择第一个标记'"
              />
            </SelectTrigger>
            <SelectContent>
              <SelectItem v-for="[id, name] in Object.entries(markOptions)" :key="id" :value="id">
                {{ name }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>
        <!-- 第二个标记选择 -->
        <div class="space-y-2">
          <Label for="mark2">第二个标记</Label>
          <Select v-model="formData.mark2_id" :disabled="Object.keys(markOptions).length === 0">
            <SelectTrigger id="mark2">
              <SelectValue
                :placeholder="Object.keys(markOptions).length === 0 ? '暂无数据' : '选择第二个标记'"
              />
            </SelectTrigger>
            <SelectContent>
              <SelectItem
                v-for="[id, name] in Object.entries(markOptions)"
                :key="id"
                :value="id"
                :disabled="id === formData.mark1_id"
              >
                {{ name }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>
        <!-- 距离输入 -->
        <div class="space-y-2">
          <Label for="distance">安全距离（米）</Label>
          <div class="flex items-center gap-2">
            <Input
              id="distance"
              v-model.number="formData.distance"
              type="number"
              min="0"
              step="0.1"
              placeholder="输入距离值"
              class="flex-1"
            />
            <Badge variant="secondary">米</Badge>
          </div>
        </div>
        <!-- 提交按钮 -->
        <div class="flex gap-2">
          <Button type="submit" :disabled="!isFormValid || isSubmitting" class="flex-1">
            <Save class="mr-2 h-4 w-4" />
            {{ isSubmitting ? "设置中..." : "设置距离" }}
          </Button>
          <Button type="button" variant="outline" @click="handleReset">
            <RotateCcw class="mr-2 h-4 w-4" />
            重置
          </Button>
        </div>
      </form>
    </CardContent>
  </Card>
</template>
<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { Link2, Save, RotateCcw } from "lucide-vue-next";
import { toast } from "vue-sonner";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { getAllMarkIDToName } from "@/api/mark/index";
import { setPairDistance } from "@/api/mark/pair";
import type { SetPairDistanceRequest } from "@/types/distance";
const formData = ref<SetPairDistanceRequest>({
  mark1_id: "",
  mark2_id: "",
  distance: 0,
});
const markOptions = ref<Record<string, string>>({});
const isSubmitting = ref(false);
const isFormValid = computed(() => {
  return (
    formData.value.mark1_id &&
    formData.value.mark2_id &&
    formData.value.mark1_id !== formData.value.mark2_id &&
    formData.value.distance >= 0
  );
});
const loadMarkOptions = async () => {
  try {
    const response = await getAllMarkIDToName();
    console.log("获取标记列表响应:", response.data);
    if (response.data.data) {
      markOptions.value = response.data.data;
    } else {
      console.warn("响应中没有 data 字段:", response.data);
      markOptions.value = {};
    }
  } catch (error: any) {
    console.error("加载标记列表失败:", error);
  }
};
const handleSubmit = async () => {
  if (!isFormValid.value) return;
  isSubmitting.value = true;
  try {
    const response = await setPairDistance(formData.value);
    toast.success("距离设置成功");
    handleReset();
  } catch (error: any) {
    console.error("设置距离失败:", error);
  } finally {
    isSubmitting.value = false;
  }
};
const handleReset = () => {
  formData.value = {
    mark1_id: "",
    mark2_id: "",
    distance: 0,
  };
};
onMounted(() => {
  loadMarkOptions();
});
</script>
<template>
  <Card>
    <CardHeader>
      <CardTitle class="flex items-center gap-2">
        <Network class="h-5 w-5" />
        组合距离设置
      </CardTitle>
      <CardDescription>为多个标记之间批量设置统一的安全距离</CardDescription>
    </CardHeader>
    <CardContent>
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <!-- 标记多选 -->
        <div class="space-y-2">
          <Label>选择标记（至少2个）</Label>
          <div class="max-h-64 overflow-y-auto rounded-md border p-3">
            <div
              v-if="Object.keys(markOptions).length === 0"
              class="text-muted-foreground py-4 text-center text-sm"
            >
              暂无数据，请检查后端服务
            </div>
            <div v-else class="grid grid-cols-2 gap-2">
              <div
                v-for="[id, name] in Object.entries(markOptions)"
                :key="id"
                class="flex items-center space-x-2"
              >
                <input
                  type="checkbox"
                  :id="`mark-${id}`"
                  :value="id"
                  v-model="selectedMarkIds"
                  class="h-4 w-4 rounded border-gray-300"
                />
                <Label :for="`mark-${id}`" class="flex-1 cursor-pointer">
                  {{ name }}
                </Label>
              </div>
            </div>
          </div>
          <div class="text-muted-foreground flex items-center gap-2 text-sm">
            <Badge variant="outline"> 已选择: {{ selectedMarkIds.length }} 个标记 </Badge>
          </div>
        </div>
        <!-- 距离输入 -->
        <div class="space-y-2">
          <Label for="distance">统一安全距离（米）</Label>
          <div class="flex items-center gap-2">
            <Input
              id="distance"
              v-model.number="formData.distance"
              type="number"
              min="0"
              step="0.1"
              placeholder="输入距离值"
              class="flex-1"
            />
            <Badge variant="secondary">米</Badge>
          </div>
          <p class="text-muted-foreground text-sm">将为所选标记两两之间设置此距离</p>
        </div>
        <!-- 提交按钮 -->
        <div class="flex gap-2">
          <Button type="submit" :disabled="!isFormValid || isSubmitting" class="flex-1">
            <Save class="mr-2 h-4 w-4" />
            {{ isSubmitting ? "设置中..." : "批量设置距离" }}
          </Button>
          <Button type="button" variant="outline" @click="handleReset">
            <RotateCcw class="mr-2 h-4 w-4" />
            重置
          </Button>
        </div>
      </form>
    </CardContent>
  </Card>
</template>
<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { Network, Save, RotateCcw } from "lucide-vue-next";
import { toast } from "vue-sonner";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { getAllMarkIDToName } from "@/api/mark/index";
import { setCombinationsDistance } from "@/api/mark/pair";
import type { SetCombinationsDistanceRequest } from "@/types/distance";
const formData = ref<{ distance: number }>({
  distance: 0,
});
const selectedMarkIds = ref<string[]>([]);
const markOptions = ref<Record<string, string>>({});
const isSubmitting = ref(false);
const isFormValid = computed(() => {
  return selectedMarkIds.value.length >= 2 && formData.value.distance >= 0;
});
const loadMarkOptions = async () => {
  try {
    const response = await getAllMarkIDToName();
    console.log("获取标记列表响应:", response.data);
    if (response.data.data) {
      markOptions.value = response.data.data;
    } else {
      console.warn("响应中没有 data 字段:", response.data);
      markOptions.value = {};
    }
  } catch (error: any) {
    console.error("加载标记列表失败:", error);
  }
};
const handleSubmit = async () => {
  if (!isFormValid.value) return;
  const requestData: SetCombinationsDistanceRequest = {
    mark_ids: selectedMarkIds.value,
    distance: formData.value.distance,
  };
  isSubmitting.value = true;
  try {
    const response = await setCombinationsDistance(requestData);
    toast.success(`成功为 ${selectedMarkIds.value.length} 个标记设置距离`);
    handleReset();
  } catch (error: any) {
    console.error("设置距离失败:", error);
  } finally {
    isSubmitting.value = false;
  }
};
const handleReset = () => {
  selectedMarkIds.value = [];
  formData.value = {
    distance: 0,
  };
};
onMounted(() => {
  loadMarkOptions();
});
</script>
<template>
  <Card>
    <CardHeader>
      <CardTitle class="flex items-center gap-2">
        <Grid3x3 class="h-5 w-5" />
        组群距离设置
      </CardTitle>
      <CardDescription
        >一次性为两组标记 / 分组 / 类型之间的「全部组合」设定安全距离</CardDescription
      >
    </CardHeader>
    <CardContent>
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <!-- 第一组选择 -->
        <div class="bg-muted/50 space-y-3 rounded-lg p-4">
          <div class="mb-2 flex items-center gap-2">
            <Layers class="h-4 w-4" />
            <Label class="text-base font-semibold">分组集合一</Label>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="first-kind">选择范围</Label>
              <Select v-model="formData.first.kind" @update:model-value="handleFirstKindChange">
                <SelectTrigger id="first-kind">
                  <SelectValue placeholder="选择类型" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="mark">标记名称 (选择单个标记)</SelectItem>
                  <SelectItem value="tag">分组 (选择所有分组一样的标记)</SelectItem>
                  <SelectItem value="type">类型 (选择所有类型一样的标记)</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div v-if="formData.first.kind" class="space-y-2">
              <Label for="first-value">选择 {{ getKindLabel(formData.first.kind) }}</Label>
              <Select
                :model-value="getFirstValue()"
                @update:model-value="(value) => setFirstValue(value)"
              >
                <SelectTrigger id="first-value">
                  <SelectValue :placeholder="`选择${getKindLabel(formData.first.kind)}`" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem
                    v-for="[id, name] in Object.entries(getOptionsForKind(formData.first.kind))"
                    :key="id"
                    :value="id"
                  >
                    {{ name }}
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </div>
        <!-- 第二组选择 -->
        <div class="bg-muted/50 space-y-3 rounded-lg p-4">
          <div class="mb-2 flex items-center gap-2">
            <Layers class="h-4 w-4" />
            <Label class="text-base font-semibold">分组集合二</Label>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="second-kind">选择范围</Label>
              <Select v-model="formData.second.kind" @update:model-value="handleSecondKindChange">
                <SelectTrigger id="second-kind">
                  <SelectValue placeholder="选择类型" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="mark">标记名称 (单个标记)</SelectItem>
                  <SelectItem value="tag">分组 (选择所有分组一样的标记)</SelectItem>
                  <SelectItem value="type">类型 (选择所有类型一样的标记)</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div v-if="formData.second.kind" class="space-y-2">
              <Label for="second-value">选择 {{ getKindLabel(formData.second.kind) }}</Label>
              <Select
                :model-value="getSecondValue()"
                @update:model-value="(value) => setSecondValue(value)"
              >
                <SelectTrigger id="second-value">
                  <SelectValue :placeholder="`选择${getKindLabel(formData.second.kind)}`" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem
                    v-for="[id, name] in Object.entries(getOptionsForKind(formData.second.kind))"
                    :key="id"
                    :value="id"
                  >
                    {{ name }}
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </div>
        <!-- 距离输入 -->
        <div class="space-y-2">
          <Label for="distance">安全距离（米）</Label>
          <div class="flex items-center gap-2">
            <Input
              id="distance"
              v-model.number="formData.distance"
              type="number"
              min="0"
              step="0.1"
              placeholder="输入距离值"
              class="flex-1"
            />
            <Badge variant="secondary">米</Badge>
          </div>
          <p class="text-muted-foreground text-sm">将为两组之间的所有标记对设置此距离</p>
        </div>
        <!-- 提交按钮 -->
        <div class="flex gap-2">
          <Button type="submit" :disabled="!isFormValid || isSubmitting" class="flex-1">
            <Save class="mr-2 h-4 w-4" />
            {{ isSubmitting ? "设置中..." : "批量设置距离" }}
          </Button>
          <Button type="button" variant="outline" @click="handleReset">
            <RotateCcw class="mr-2 h-4 w-4" />
            重置
          </Button>
        </div>
      </form>
    </CardContent>
  </Card>
</template>
<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { Grid3x3, Layers, Save, RotateCcw } from "lucide-vue-next";
import { toast } from "vue-sonner";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { getAllMarkIDToName } from "@/api/mark/index";
import { getAllTagIDToName } from "@/api/mark/tag";
import { getAllTypeIDToName } from "@/api/mark/type";
import { setCartesianDistance } from "@/api/mark/pair";
import type { SetCartesianDistanceRequest, Identifier, IdentifierKind } from "@/types/distance";
const formData = ref<SetCartesianDistanceRequest>({
  first: {
    kind: "mark",
  },
  second: {
    kind: "mark",
  },
  distance: 0,
});
const markOptions = ref<Record<string, string>>({});
const tagOptions = ref<Record<number, string>>({});
const typeOptions = ref<Record<number, string>>({});
const isSubmitting = ref(false);
const isFormValid = computed(() => {
  const first = formData.value.first;
  const second = formData.value.second;
  const firstValid =
    (first.kind === "mark" && first.mark_id) ||
    (first.kind === "tag" && first.tag_id !== undefined) ||
    (first.kind === "type" && first.type_id !== undefined);
  const secondValid =
    (second.kind === "mark" && second.mark_id) ||
    (second.kind === "tag" && second.tag_id !== undefined) ||
    (second.kind === "type" && second.type_id !== undefined);
  return firstValid && secondValid && formData.value.distance >= 0;
});
const getKindLabel = (kind: IdentifierKind) => {
  const labels: Record<IdentifierKind, string> = {
    mark: "标记名称",
    tag: "分组",
    type: "类型",
  };
  return labels[kind];
};
const getOptionsForKind = (kind: IdentifierKind) => {
  switch (kind) {
    case "mark":
      return markOptions.value;
    case "tag":
      return tagOptions.value;
    case "type":
      return typeOptions.value;
    default:
      return {};
  }
};
const getFirstValue = () => {
  const first = formData.value.first;
  if (first.kind === "mark") return first.mark_id || "";
  if (first.kind === "tag") return first.tag_id?.toString() || "";
  if (first.kind === "type") return first.type_id?.toString() || "";
  return "";
};
const setFirstValue = (value: any) => {
  if (!value) return;
  const valueStr = String(value);
  const kind = formData.value.first.kind;
  formData.value.first = { kind };
  if (kind === "mark") {
    formData.value.first.mark_id = valueStr;
  } else if (kind === "tag") {
    formData.value.first.tag_id = parseInt(valueStr);
  } else if (kind === "type") {
    formData.value.first.type_id = parseInt(valueStr);
  }
};
const getSecondValue = () => {
  const second = formData.value.second;
  if (second.kind === "mark") return second.mark_id || "";
  if (second.kind === "tag") return second.tag_id?.toString() || "";
  if (second.kind === "type") return second.type_id?.toString() || "";
  return "";
};
const setSecondValue = (value: any) => {
  if (!value) return;
  const valueStr = String(value);
  const kind = formData.value.second.kind;
  formData.value.second = { kind };
  if (kind === "mark") {
    formData.value.second.mark_id = valueStr;
  } else if (kind === "tag") {
    formData.value.second.tag_id = parseInt(valueStr);
  } else if (kind === "type") {
    formData.value.second.type_id = parseInt(valueStr);
  }
};
const handleFirstKindChange = (kind: any) => {
  const kindStr = String(kind);
  if (!kindStr || (kindStr !== "mark" && kindStr !== "tag" && kindStr !== "type")) return;
  formData.value.first = { kind: kindStr };
};
const handleSecondKindChange = (kind: any) => {
  const kindStr = String(kind);
  if (!kindStr || (kindStr !== "mark" && kindStr !== "tag" && kindStr !== "type")) return;
  formData.value.second = { kind: kindStr };
};
const loadAllOptions = async () => {
  try {
    const [markRes, tagRes, typeRes] = await Promise.all([
      getAllMarkIDToName(),
      getAllTagIDToName(),
      getAllTypeIDToName(),
    ]);
    console.log("加载选项数据:", {
      markRes: markRes.data,
      tagRes: tagRes.data,
      typeRes: typeRes.data,
    });
    if (markRes.data.data) {
      markOptions.value = markRes.data.data;
    }
    if (tagRes.data.data) {
      tagOptions.value = tagRes.data.data;
    }
    if (typeRes.data.data) {
      typeOptions.value = typeRes.data.data;
    }
  } catch (error) {
    console.error("加载选项数据失败:", error);
  }
};
const handleSubmit = async () => {
  if (!isFormValid.value) return;
  isSubmitting.value = true;
  try {
    const response = await setCartesianDistance(formData.value);
    toast.success("组群距离设置成功");
    handleReset();
  } catch (error: any) {
    console.error("设置距离失败:", error);
  } finally {
    isSubmitting.value = false;
  }
};
const handleReset = () => {
  formData.value = {
    first: {
      kind: "mark",
    },
    second: {
      kind: "mark",
    },
    distance: 0,
  };
};
onMounted(() => {
  loadAllOptions();
});
</script>
<!-- src/components/TypeSelect.vue -->
<script setup lang="ts">
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { ref, watch } from "vue";
import { listMarkTypes } from "@/api/mark/type";
import type { MarkTypeResponse } from "@/types/mark";
const props = defineProps<{
  modelValue?: number; 
}>();
const emit = defineEmits<{
  "update:modelValue": [id: number | undefined];
}>();
const options = ref<MarkTypeResponse[]>([]);
const innerId = ref(props.modelValue);
watch(
  () => props.modelValue,
  (val) => (innerId.value = val),
);
watch(innerId, (val) => emit("update:modelValue", val));
listMarkTypes().then((res) => (options.value = res.data.data ?? []));
</script>
<template>
  <Select v-model="innerId">
    <SelectTrigger class="w-[180px]">
      <SelectValue placeholder="请选择类型" />
    </SelectTrigger>
    <SelectContent>
      <SelectItem
        v-for="opt in options"
        :key="opt.id"
        :value="opt.id"
        class="flex w-full justify-between"
      >
        <span>{{ opt.type_name }}</span>
        <span class="text-muted-foreground">({{ opt.default_danger_zone_m }}m)</span>
      </SelectItem>
    </SelectContent>
  </Select>
</template>
<template>
  <Card class="h-full w-full">
    <CardHeader>
      <div class="flex items-center justify-between gap-2">
        <div>
          <CardTitle class="flex items-center gap-2">
            <Layers class="h-5 w-5" />
            类型列表
          </CardTitle>
          <CardDescription>查看所有标记类型及其默认危险半径</CardDescription>
        </div>
        <Button
          size="icon"
          variant="outline"
          @click="openCreateDialog"
          title="新增类型"
          aria-label="新增类型"
        >
          <Plus class="h-4 w-4" />
        </Button>
      </div>
    </CardHeader>
    <CardContent
      class="grid gap-4"
      :style="{ gridTemplateColumns: `repeat(auto-fill, minmax(${cardMinW}px, 1fr))` }"
    >
      <RouterLink
        v-for="t in types"
        :key="t.id"
        :to="`/type/${t.id}`"
        class="block rounded-lg focus:ring-2 focus:ring-offset-2 focus:outline-none"
      >
        <Card
          class="flex cursor-pointer flex-row items-center justify-between p-3 transition-shadow hover:shadow-md"
        >
          <div>{{ t.type_name }}</div>
          <div class="text-muted-foreground">{{ t.default_danger_zone_m }}m</div>
        </Card>
      </RouterLink>
    </CardContent>
  </Card>
  <!-- 新增类型对话框 -->
  <Dialog v-model:open="createOpen">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>新增标记类型</DialogTitle>
        <DialogDescription>填写类型名称和默认危险半径（可选）。</DialogDescription>
      </DialogHeader>
      <div class="space-y-4">
        <div class="space-y-2">
          <Label for="type-name">类型名称 *</Label>
          <Input id="type-name" v-model="formName" placeholder="例如：人员、叉车" />
        </div>
        <div class="space-y-2">
          <Label for="type-danger">默认危险半径（米，可选）</Label>
          <Input
            id="type-danger"
            v-model.number="formDanger"
            type="number"
            min="0"
            placeholder="留空表示不设置"
          />
        </div>
      </div>
      <DialogFooter>
        <Button variant="outline" :disabled="submitting" @click="createOpen = false">取消</Button>
        <Button :disabled="!formName.trim() || submitting" @click="submitCreate">
          <Loader2 v-if="submitting" class="mr-2 h-4 w-4 animate-spin" />
          {{ submitting ? "创建中..." : "创建" }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
  <!-- 底部提示 -->
  <!-- <div class="text-muted-foreground py-4 text-center text-xs">
    <span v-if="loading">加载中…</span>
    <span v-else-if="finished">没有更多了</span>
  </div> -->
</template>
<script setup lang="ts">
import { ref, onMounted } from "vue";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Layers, Plus } from "lucide-vue-next";
import { listMarkTypes, createMarkType } from "@/api/mark/type";
import type { MarkTypeResponse } from "@/types/mark";
import { toast } from "vue-sonner";
const types = ref<MarkTypeResponse[]>([]);
const cardMinW = 150;
const loading = ref(false);
const finished = ref(false);
const page = ref(1);
const SIZE = 20; 
const createOpen = ref(false);
const formName = ref("");
const formDanger = ref<number | undefined>(undefined);
const submitting = ref(false);
function openCreateDialog() {
  formName.value = "";
  formDanger.value = undefined;
  createOpen.value = true;
}
async function submitCreate() {
  if (!formName.value.trim() || submitting.value) return;
  submitting.value = true;
  try {
    await createMarkType({
      type_name: formName.value.trim(),
      default_danger_zone_m: formDanger.value ?? null,
    });
    toast.success("创建成功", { description: `类型 \"${formName.value.trim()}\" 已创建` });
    createOpen.value = false;
    types.value = [];
    page.value = 1;
    finished.value = false;
    await loadNext();
  } catch (e: any) {
    toast.error("创建失败", { description: e?.message ?? "请稍后重试" });
  } finally {
    submitting.value = false;
  }
}
async function loadNext() {
  if (loading.value || finished.value) return;
  loading.value = true;
  try {
    const { data } = await listMarkTypes({ page: page.value, limit: SIZE });
    const list = data.data ?? [];
    types.value.push(...list);
    if (list.length < SIZE) finished.value = true;
    else page.value += 1;
  } finally {
    loading.value = false;
  }
}
function onScroll(e: Event) {
  const el = e.target as HTMLElement;
  const { scrollTop, scrollHeight, clientHeight } = el;
  if (scrollHeight - scrollTop - clientHeight <= 60) {
    loadNext();
  }
}
onMounted(() => loadNext());
</script>
<template>
  <form @submit="onSubmit" class="space-y-4">
    <FormField v-slot="{ componentField }" name="type_name">
      <FormItem>
        <FormLabel>类型名称</FormLabel>
        <FormControl>
          <Input type="text" placeholder="输入类型名称" v-bind="componentField" />
        </FormControl>
        <FormMessage />
      </FormItem>
    </FormField>
    <FormField v-slot="{ componentField }" name="default_danger_zone_m">
      <FormItem>
        <FormLabel>默认危险半径（米）</FormLabel>
        <FormControl>
          <Input type="number" step="0.1" placeholder="可选" v-bind="componentField" />
        </FormControl>
        <FormMessage />
      </FormItem>
    </FormField>
    <Button type="submit" :disabled="isSubmitting">创建</Button>
  </form>
</template>
<script setup lang="ts">
import { useForm } from "vee-validate";
import { toTypedSchema } from "@vee-validate/zod";
import * as z from "zod";
import { FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { toast } from "vue-sonner";
import { createMarkType } from "@/api/mark/type";
const validationSchema = toTypedSchema(
  z.object({
    type_name: z.string().min(1, "类型名称不能为空").max(255),
    default_danger_zone_m: z.preprocess((val) => {
      const num = Number(val);
      return isNaN(num) ? undefined : num;
    }, z.number().nonnegative().optional()),
  }),
);
const { handleSubmit, isSubmitting } = useForm({
  validationSchema,
});
const onSubmit = handleSubmit(async (values) => {
  console.log("提交数据:", values);
  try {
    await createMarkType(values); 
    toast.success("创建成功", {
      description: values.type_name,
    });
  } catch (e: any) {}
});
</script>
<!-- src\components\station\StationManagePanel.vue -->
<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { required, helpers } from "@vuelidate/validators";
import useVuelidate from "@vuelidate/core";
import { toast } from "vue-sonner";
import { Plus, Pen, Trash, MapPin } from "lucide-vue-next";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { ScrollArea } from "@/components/ui/scroll-area";
import { stationApi } from "@/api";
import type { StationResp, StationCreateReq, StationUpdateReq } from "@/types/station";
interface FormState {
  station_name: string;
  coordinate_x: number | string;
  coordinate_y: number | string;
}
const stations = ref<StationResp[]>([]);
const loading = ref(false);
async function loadStations() {
  loading.value = true;
  try {
    const response = await stationApi.listStations();
    stations.value = response.data.data || [];
  } catch (e: any) {
    if (!e._handled) {
      toast.error("加载基站列表失败", {
        description: e.response?.data?.message || e.message,
      });
    }
  } finally {
    loading.value = false;
  }
}
onMounted(() => {
  loadStations();
});
const createDialogOpen = ref(false);
const createFormInitial: FormState = {
  station_name: "",
  coordinate_x: 0,
  coordinate_y: 0,
};
const createForm = reactive<FormState>({ ...createFormInitial });
const isValidCoordinate = (value: any) => {
  if (value === undefined || value === null) return false;
  if (value === 0 || value === "0") return true;
  if (value === "" || (typeof value === "string" && value.trim() === "")) return false;
  const num = Number(value);
  return !isNaN(num) && isFinite(num);
};
const createRules = {
  station_name: { required: helpers.withMessage("请输入基站名称", required) },
  coordinate_x: {
    isValidCoordinate: helpers.withMessage("请输入有效的X坐标", isValidCoordinate),
  },
  coordinate_y: {
    isValidCoordinate: helpers.withMessage("请输入有效的Y坐标", isValidCoordinate),
  },
};
const createV$ = useVuelidate(createRules, createForm);
const isCreating = ref(false);
async function handleCreate() {
  const valid = await createV$.value.$validate();
  if (!valid) {
    toast.error("请填写完整的表单信息");
    return;
  }
  if (isCreating.value) return;
  isCreating.value = true;
  try {
    await stationApi.createStation({
      station_name: createForm.station_name,
      coordinate_x: Number(createForm.coordinate_x),
      coordinate_y: Number(createForm.coordinate_y),
    });
    toast.success("基站创建成功");
    createDialogOpen.value = false;
    Object.assign(createForm, createFormInitial);
    createV$.value.$reset();
    await loadStations();
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "创建失败";
      toast.error("创建基站失败", { description: errorMsg });
    }
  } finally {
    isCreating.value = false;
  }
}
const editDialogOpen = ref(false);
const editingStation = ref<StationResp | null>(null);
const editForm = reactive<FormState>({
  station_name: "",
  coordinate_x: "",
  coordinate_y: "",
});
const editRules = {
  station_name: { required: helpers.withMessage("请输入基站名称", required) },
  coordinate_x: {
    isValidCoordinate: helpers.withMessage("请输入有效的X坐标", isValidCoordinate),
  },
  coordinate_y: {
    isValidCoordinate: helpers.withMessage("请输入有效的Y坐标", isValidCoordinate),
  },
};
const editV$ = useVuelidate(editRules, editForm);
const isUpdating = ref(false);
function openEditDialog(station: StationResp) {
  editingStation.value = station;
  editForm.station_name = station.station_name;
  editForm.coordinate_x = station.coordinate_x;
  editForm.coordinate_y = station.coordinate_y;
  editV$.value.$reset();
  editDialogOpen.value = true;
}
async function handleUpdate() {
  const valid = await editV$.value.$validate();
  if (!valid) {
    toast.error("请填写完整的表单信息");
    return;
  }
  if (!editingStation.value || isUpdating.value) return;
  isUpdating.value = true;
  try {
    await stationApi.updateStation(editingStation.value.id, {
      station_name: editForm.station_name,
      coordinate_x: Number(editForm.coordinate_x),
      coordinate_y: Number(editForm.coordinate_y),
    });
    toast.success("基站更新成功");
    editDialogOpen.value = false;
    await loadStations();
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "更新失败";
      toast.error("更新基站失败", { description: errorMsg });
    }
  } finally {
    isUpdating.value = false;
  }
}
const isDeleting = ref<Record<string, boolean>>({});
async function handleDelete(id: string) {
  if (isDeleting.value[id]) return;
  isDeleting.value[id] = true;
  try {
    await stationApi.deleteStation(id);
    toast.success("基站删除成功");
    await loadStations();
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "删除失败";
      toast.error("删除基站失败", { description: errorMsg });
    }
  } finally {
    isDeleting.value[id] = false;
  }
}
</script>
<template>
  <div class="flex h-full w-full flex-col gap-4 p-4">
    <!-- 标题和创建按钮 -->
    <Card>
      <CardHeader>
        <div class="flex items-center justify-between">
          <div>
            <CardTitle class="flex items-center gap-2">
              <MapPin class="h-5 w-5" />
              基站管理
            </CardTitle>
            <CardDescription>管理所有基站的信息</CardDescription>
          </div>
          <!-- 创建基站对话框 -->
          <Dialog v-model:open="createDialogOpen">
            <DialogTrigger as-child>
              <Button>
                <Plus class="mr-2 h-4 w-4" />
                新建基站
              </Button>
            </DialogTrigger>
            <DialogContent class="sm:max-w-[500px]">
              <DialogHeader>
                <DialogTitle>新建基站</DialogTitle>
                <DialogDescription>填写基站信息并提交</DialogDescription>
              </DialogHeader>
              <form @submit.prevent="handleCreate">
                <div class="space-y-4 py-4">
                  <!-- 基站名称 -->
                  <div class="flex flex-col gap-2">
                    <Label for="createStationName">基站名称</Label>
                    <Input
                      id="createStationName"
                      v-model="createForm.station_name"
                      placeholder="例如：东区-01"
                      :class="{ 'border-destructive': createV$.station_name.$error }"
                    />
                    <span v-if="createV$.station_name.$error" class="text-destructive text-sm">
                      {{ createV$.station_name.$errors[0].$message }}
                    </span>
                  </div>
                  <!-- X 坐标 -->
                  <div class="flex flex-col gap-2">
                    <Label for="createLocX">X 坐标</Label>
                    <Input
                      id="createLocX"
                      v-model="createForm.coordinate_x"
                      type="number"
                      step="0.01"
                      placeholder="0.00"
                      :class="{ 'border-destructive': createV$.coordinate_x.$error }"
                    />
                    <span v-if="createV$.coordinate_x.$error" class="text-destructive text-sm">
                      {{ createV$.coordinate_x.$errors[0].$message }}
                    </span>
                  </div>
                  <!-- Y 坐标 -->
                  <div class="flex flex-col gap-2">
                    <Label for="createLocY">Y 坐标</Label>
                    <Input
                      id="createLocY"
                      v-model="createForm.coordinate_y"
                      type="number"
                      step="0.01"
                      placeholder="0.00"
                      :class="{ 'border-destructive': createV$.coordinate_y.$error }"
                    />
                    <span v-if="createV$.coordinate_y.$error" class="text-destructive text-sm">
                      {{ createV$.coordinate_y.$errors[0].$message }}
                    </span>
                  </div>
                </div>
                <DialogFooter>
                  <Button type="button" variant="outline" @click="createDialogOpen = false">
                    取消
                  </Button>
                  <Button type="submit" :disabled="isCreating">
                    {{ isCreating ? "创建中..." : "创建" }}
                  </Button>
                </DialogFooter>
              </form>
            </DialogContent>
          </Dialog>
        </div>
      </CardHeader>
    </Card>
    <!-- 基站列表 -->
    <Card class="flex-1">
      <CardContent class="p-0">
        <ScrollArea class="h-[calc(100vh-16rem)]">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>基站名称</TableHead>
                <TableHead>X 坐标</TableHead>
                <TableHead>Y 坐标</TableHead>
                <TableHead class="hidden md:table-cell">创建时间</TableHead>
                <TableHead class="hidden md:table-cell">更新时间</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow v-if="loading">
                <TableCell colspan="6" class="text-center">加载中...</TableCell>
              </TableRow>
              <TableRow v-else-if="stations.length === 0">
                <TableCell colspan="6" class="text-muted-foreground text-center">
                  暂无基站数据，点击右上角创建新基站
                </TableCell>
              </TableRow>
              <TableRow
                v-else
                v-for="station in stations"
                :key="station.id"
                class="hover:bg-muted/50"
              >
                <TableCell class="font-medium">{{ station.station_name }}</TableCell>
                <TableCell>{{ station.coordinate_x }}</TableCell>
                <TableCell>{{ station.coordinate_y }}</TableCell>
                <TableCell class="hidden md:table-cell">
                  {{ new Date(station.created_at).toLocaleString() }}
                </TableCell>
                <TableCell class="hidden md:table-cell">
                  {{ new Date(station.updated_at).toLocaleString() }}
                </TableCell>
                <TableCell class="text-right">
                  <div class="flex justify-end gap-2">
                    <!-- 编辑按钮 -->
                    <Button
                      variant="outline"
                      size="icon"
                      @click="openEditDialog(station)"
                      title="编辑"
                    >
                      <Pen class="h-4 w-4" />
                    </Button>
                    <!-- 删除按钮 -->
                    <AlertDialog>
                      <AlertDialogTrigger as-child>
                        <Button variant="outline" size="icon" class="text-red-500" title="删除">
                          <Trash class="h-4 w-4" />
                        </Button>
                      </AlertDialogTrigger>
                      <AlertDialogContent>
                        <AlertDialogHeader>
                          <AlertDialogTitle>确认删除基站？</AlertDialogTitle>
                          <AlertDialogDescription>
                            你将永久删除基站 "<strong>{{ station.station_name }}</strong
                            >"，此操作无法撤销。
                          </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                          <AlertDialogCancel>取消</AlertDialogCancel>
                          <AlertDialogAction
                            class="bg-red-500 hover:bg-red-600"
                            :disabled="isDeleting[station.id]"
                            @click="handleDelete(station.id)"
                          >
                            {{ isDeleting[station.id] ? "删除中..." : "确认删除" }}
                          </AlertDialogAction>
                        </AlertDialogFooter>
                      </AlertDialogContent>
                    </AlertDialog>
                  </div>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </ScrollArea>
      </CardContent>
    </Card>
    <!-- 编辑基站对话框 -->
    <Dialog v-model:open="editDialogOpen">
      <DialogContent class="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>编辑基站</DialogTitle>
          <DialogDescription>修改基站信息</DialogDescription>
        </DialogHeader>
        <form @submit.prevent="handleUpdate">
          <div class="space-y-4 py-4">
            <!-- 基站名称 -->
            <div class="flex flex-col gap-2">
              <Label for="editStationName">基站名称</Label>
              <Input
                id="editStationName"
                v-model="editForm.station_name"
                placeholder="例如：东区-01"
                :class="{ 'border-destructive': editV$.station_name.$error }"
              />
              <span v-if="editV$.station_name.$error" class="text-destructive text-sm">
                {{ editV$.station_name.$errors[0].$message }}
              </span>
            </div>
            <!-- X 坐标 -->
            <div class="flex flex-col gap-2">
              <Label for="editLocX">X 坐标</Label>
              <Input
                id="editLocX"
                v-model="editForm.coordinate_x"
                type="number"
                step="0.01"
                placeholder="0.00"
                :class="{ 'border-destructive': editV$.coordinate_x.$error }"
              />
              <span v-if="editV$.coordinate_x.$error" class="text-destructive text-sm">
                {{ editV$.coordinate_x.$errors[0].$message }}
              </span>
            </div>
            <!-- Y 坐标 -->
            <div class="flex flex-col gap-2">
              <Label for="editLocY">Y 坐标</Label>
              <Input
                id="editLocY"
                v-model="editForm.coordinate_y"
                type="number"
                step="0.01"
                placeholder="0.00"
                :class="{ 'border-destructive': editV$.coordinate_y.$error }"
              />
              <span v-if="editV$.coordinate_y.$error" class="text-destructive text-sm">
                {{ editV$.coordinate_y.$errors[0].$message }}
              </span>
            </div>
          </div>
          <DialogFooter>
            <Button type="button" variant="outline" @click="editDialogOpen = false"> 取消 </Button>
            <Button type="submit" :disabled="isUpdating">
              {{ isUpdating ? "更新中..." : "更新" }}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  </div>
</template>
<template>
  <Card class="h-full w-full">
    <CardHeader>
      <CardTitle class="flex items-center gap-2">
        <Hash class="h-5 w-5" />
        分组列表
      </CardTitle>
      <CardDescription>查看所有标记使用的分组</CardDescription>
    </CardHeader>
    <CardContent class="p-3 sm:p-6">
      <div class="flex flex-wrap gap-1.5 sm:gap-2">
        <RouterLink
          v-for="tag in tags"
          :key="tag.id"
          :to="`/tag/${tag.id}`"
          class="block rounded-md focus:ring-2 focus:ring-offset-2 focus:outline-none"
        >
          <Badge
            variant="secondary"
            class="hover:bg-secondary/80 cursor-pointer px-2 py-1 text-xs transition-colors sm:px-3 sm:py-1.5 sm:text-sm"
          >
            # {{ tag.tag_name }}
          </Badge>
        </RouterLink>
      </div>
      <p
        v-if="!tags || tags.length === 0"
        class="text-muted-foreground mt-2 text-center text-xs sm:text-sm"
      >
        暂无分组
      </p>
    </CardContent>
  </Card>
</template>
<script setup lang="ts">
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Hash } from "lucide-vue-next";
import { ref, onMounted } from "vue";
import { listMarkTags } from "@/api/mark/tag";
import type { MarkTagResponse } from "@/types/mark";
const tags = ref<MarkTagResponse[]>();
onMounted(async () => {
  try {
    const res = await listMarkTags({
    });
    tags.value = res.data.data ?? [];
  } catch (e) {
    console.error("加载分组失败", e);
  }
});
</script>
<template>
  <AlertDialog>
    <AlertDialogTrigger as-child>
      <Button variant="outline" size="icon" class="text-red-500" title="删除">
        <Trash class="h-4 w-4" />
      </Button>
    </AlertDialogTrigger>
    <AlertDialogContent>
      <AlertDialogHeader>
        <AlertDialogTitle>确认删除标记对距离？</AlertDialogTitle>
        <AlertDialogDescription>
          你将永久删除标记对 {{ getMarkName(mark1Id) }} 和
          {{ getMarkName(mark2Id) }} 之间的距离设置，此操作无法撤销。
        </AlertDialogDescription>
      </AlertDialogHeader>
      <AlertDialogFooter>
        <AlertDialogCancel>取消</AlertDialogCancel>
        <AlertDialogAction
          class="bg-red-500 hover:bg-red-600"
          :disabled="deleting"
          @click="handleDelete"
        >
          {{ deleting ? "删除中..." : "确认删除" }}
        </AlertDialogAction>
      </AlertDialogFooter>
    </AlertDialogContent>
  </AlertDialog>
</template>
<script setup lang="ts">
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { Button } from "@/components/ui/button";
import { Trash } from "lucide-vue-next";
import { deletePairDistance } from "@/api/mark/pair";
import { getMarkName, ensureMarkNamesLoaded } from "@/utils/markName";
import { toast } from "vue-sonner";
import { ref, onMounted } from "vue";
const props = defineProps<{
  mark1Id: string;
  mark2Id: string;
}>();
const emit = defineEmits<{
  deleted: [];
}>();
const deleting = ref(false);
const handleDelete = async () => {
  if (deleting.value) return;
  deleting.value = true;
  try {
    await deletePairDistance(props.mark1Id, props.mark2Id);
    toast.success("删除成功");
    emit("deleted");
  } catch (error: any) {
    console.error(error);
    if (!error._handled) {
      toast.error("删除失败");
    }
  } finally {
    deleting.value = false;
  }
};
onMounted(async () => {
  try {
    await ensureMarkNamesLoaded();
  } catch (error) {
    console.error("加载标记名称失败:", error);
  }
});
</script>
<template>
  <Dialog>
    <DialogTrigger as-child>
      <Button variant="outline" size="icon" title="编辑距离">
        <Pencil class="h-4 w-4" />
      </Button>
    </DialogTrigger>
    <DialogContent class="sm:max-w-[425px]">
      <DialogHeader>
        <DialogTitle>编辑标记对距离</DialogTitle>
        <DialogDescription>
          修改标记对
          <span class="text-accent-foreground font-bold">{{ getMarkName(pair.mark1_id) }}</span>
          和
          <span class="text-accent-foreground font-bold">{{ getMarkName(pair.mark2_id) }}</span>
          之间的距离设置
        </DialogDescription>
      </DialogHeader>
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div class="space-y-2">
          <Label for="distance">安全距离（米）</Label>
          <div class="flex items-center gap-2">
            <Input
              id="distance"
              v-model.number="formData.distance"
              type="number"
              min="0"
              step="0.1"
              placeholder="输入距离值"
              class="flex-1"
              required
            />
            <Badge variant="secondary">米</Badge>
          </div>
        </div>
        <DialogFooter>
          <DialogClose as-child>
            <Button type="button" variant="outline">取消</Button>
          </DialogClose>
          <Button type="submit" :disabled="!isFormValid || isSubmitting">
            <Save class="mr-2 h-4 w-4" />
            {{ isSubmitting ? "保存中..." : "保存" }}
          </Button>
        </DialogFooter>
      </form>
    </DialogContent>
  </Dialog>
</template>
<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { Pencil, Save } from "lucide-vue-next";
import { toast } from "vue-sonner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { setPairDistance } from "@/api/mark/pair";
import { getMarkName, ensureMarkNamesLoaded } from "@/utils/markName";
import type { PairItem } from "@/types/distance";
const props = defineProps<{
  pair: PairItem;
}>();
const emit = defineEmits<{
  updated: [];
}>();
const formData = ref({
  distance: props.pair.distance_m,
});
const isSubmitting = ref(false);
const isFormValid = computed(() => {
  return formData.value.distance >= 0;
});
const handleSubmit = async () => {
  if (!isFormValid.value) return;
  const requestData = {
    mark1_id: props.pair.mark1_id,
    mark2_id: props.pair.mark2_id,
    distance: formData.value.distance,
  };
  isSubmitting.value = true;
  try {
    await setPairDistance(requestData);
    toast.success("距离设置成功");
    emit("updated");
  } catch (error: any) {
    console.error("设置距离失败:", error);
  } finally {
    isSubmitting.value = false;
  }
};
onMounted(async () => {
  try {
    await ensureMarkNamesLoaded();
  } catch (error) {
    console.error("加载标记名称失败:", error);
  }
});
</script>
<script setup lang="ts">
import { reactive, watchEffect } from "vue";
import { updateMark } from "@/api/mark";
import type { MarkUpdateRequest, MarkResponse } from "@/types/mark";
import DangerTypeSelect from "@/components/type/TypeSelect.vue";
import { Input } from "@/components/ui/input";
import { Switch } from "@/components/ui/switch";
import { Button } from "@/components/ui/button";
import {
  TagsInput,
  TagsInputInput,
  TagsInputItem,
  TagsInputItemDelete,
  TagsInputItemText,
} from "@/components/ui/tags-input";
import {
  Drawer,
  DrawerClose,
  DrawerContent,
  DrawerDescription,
  DrawerFooter,
  DrawerHeader,
  DrawerTitle,
  DrawerTrigger,
} from "@/components/ui/drawer";
import { toast } from "vue-sonner";
import { useRouter, useRoute } from "vue-router";
const router = useRouter();
const route = useRoute();
const reloadCurrentPage = () =>
  router.replace({
    path: route.fullPath,
    force: true, 
    replace: true, 
  });
const props = defineProps<{
  mark: MarkResponse;
}>();
const form = reactive<MarkUpdateRequest>({
  mark_name: props.mark.mark_name,
  persist_mqtt: props.mark.persist_mqtt,
  danger_zone_m: props.mark.danger_zone_m || -1,
  mark_type_id: props.mark.mark_type?.id,
  tags: (props.mark.tags ?? []).map((t) => t.tag_name), 
});
const handleSubmit = async () => {
  if (!form.mark_name?.trim()) {
    toast.error("标记名称不能为空");
    return;
  }
  const payload: MarkUpdateRequest = {};
  Object.entries(form).forEach(([k, v]) => {
    if (v != null) {
      (payload as any)[k as keyof MarkUpdateRequest] = v;
    }
  });
  try {
    const { data } = await updateMark(props.mark.id, payload);
    toast.success("标记已更新");
    reloadCurrentPage();
  } catch (e: any) {
  } finally {
  }
};
</script>
<template>
  <Drawer>
    <DrawerTrigger>
      <slot></slot>
    </DrawerTrigger>
    <DrawerContent>
      <DrawerHeader>
        <DrawerTitle>修改标记</DrawerTitle>
        <DrawerDescription>为空，就不修改</DrawerDescription>
      </DrawerHeader>
      <div class="bg-background mx-auto max-w-2xl rounded-xl border p-6 shadow-md">
        <!-- 标记名称 -->
        <div class="mb-5">
          <label class="mb-1 block text-sm font-medium">标记名称</label>
          <Input v-model="form.mark_name" placeholder="请输入标记名称…" />
        </div>
        <!-- 类型 -->
        <div class="mb-5">
          <label class="mb-1 block text-sm font-medium">标记类型</label>
          <DangerTypeSelect v-model="form.mark_type_id" />
        </div>
        <!-- 危险半径 -->
        <div class="mb-5">
          <label class="mb-1 block text-sm font-medium">危险半径（米）</label>
          <Input
            v-model="form.danger_zone_m"
            type="number"
            step="0.1"
            placeholder="留空表示使用类型默认值"
            @input="
              ($event.target as HTMLInputElement).value === ''
                ? undefined
                : (form.danger_zone_m = parseFloat(($event.target as HTMLInputElement).value))
            "
          />
        </div>
        <!-- 分组 -->
        <div class="mb-5">
          <label class="mb-1 block text-sm font-medium">分组</label>
          <TagsInput v-model="form.tags">
            <template v-if="form.tags && form.tags.length">
              <TagsInputItem v-for="tag in form.tags" :key="tag" :value="tag">
                <TagsInputItemText />
                <TagsInputItemDelete />
              </TagsInputItem>
            </template>
            <TagsInputInput placeholder="输入分组后按 Enter 添加" />
          </TagsInput>
          <p class="text-muted-foreground mt-1 text-xs">
            留空表示不改动分组；删除全部后按保存可清空分组。
          </p>
        </div>
        <!-- 持久化 -->
        <div class="mb-6">
          <label class="mb-1 block text-sm font-medium">保存历史数据</label>
          <Switch v-model="mark.persist_mqtt" />
        </div>
      </div>
      <DrawerFooter class="mx-auto flex flex-row justify-between">
        <DrawerClose as-child>
          <Button @click="handleSubmit">修改</Button>
        </DrawerClose>
        <DrawerClose as-child>
          <Button variant="outline"> 取消 </Button>
        </DrawerClose>
      </DrawerFooter>
    </DrawerContent>
  </Drawer>
</template>
<template>
  <div class="flex w-full flex-col">
    <!-- 表格 -->
    <Card class="flex-1">
      <CardContent class="p-0">
        <div class="max-h-[calc(100vh-18rem)] overflow-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>设备ID</TableHead>
                <TableHead>标记名称</TableHead>
                <TableHead>类型</TableHead>
                <TableHead>危险半径</TableHead>
                <TableHead>分组</TableHead>
                <TableHead class="hidden md:table-cell">最后在线</TableHead>
                <TableHead class="hidden lg:table-cell">创建时间</TableHead>
                <TableHead class="hidden lg:table-cell">更新时间</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow v-for="mark in rows" :key="mark.id" class="hover:bg-muted/50">
                <TableCell class="font-medium">{{ mark.device_id }}</TableCell>
                <TableCell>{{ mark.mark_name }}</TableCell>
                <TableCell>
                  <RouterLink
                    v-if="mark.mark_type"
                    :to="`/type/${mark.mark_type.id}`"
                    class="hover:underline"
                  >
                    {{ mark.mark_type.type_name }}
                  </RouterLink>
                  <span v-else class="text-muted-foreground">-</span>
                </TableCell>
                <TableCell>
                  {{ mark.danger_zone_m !== -1 ? mark.danger_zone_m + "m" : "-" }}
                </TableCell>
                <TableCell>
                  <div class="flex flex-wrap gap-1">
                    <template v-if="mark.tags?.length">
                      <RouterLink
                        v-for="tag in mark.tags"
                        :key="tag.id"
                        :to="`/tag/${tag.id}`"
                        class="hover:opacity-80"
                      >
                        <Badge variant="outline" class="cursor-pointer">
                          {{ tag.tag_name }}
                        </Badge>
                      </RouterLink>
                    </template>
                    <span v-else class="text-muted-foreground">-</span>
                  </div>
                </TableCell>
                <TableCell class="hidden md:table-cell">
                  {{
                    mark.last_online_at
                      ? new Date(mark.last_online_at).toLocaleString()
                      : "从未上线"
                  }}
                </TableCell>
                <TableCell class="hidden lg:table-cell">
                  {{ new Date(mark.created_at).toLocaleString() }}
                </TableCell>
                <TableCell class="hidden lg:table-cell">
                  {{ new Date(mark.updated_at).toLocaleString() }}
                </TableCell>
                <TableCell class="text-right">
                  <div class="flex justify-end gap-2">
                    <!-- 编辑按钮 -->
                    <MarkUpdate :mark="mark">
                      <Button variant="outline" size="icon" title="编辑">
                        <Pen class="h-4 w-4" />
                      </Button>
                    </MarkUpdate>
                    <!-- 删除按钮 -->
                    <MarkDelete :id="mark.id" />
                  </div>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>
      </CardContent>
    </Card>
    <!-- 分页 -->
    <Pagination
      v-slot="{ page }"
      :items-per-page="limit"
      :total="total"
      :default-page="1"
      @update:page="go"
      class="mt-4"
    >
      <PaginationContent v-slot="{ items }">
        <PaginationPrevious>上一页</PaginationPrevious>
        <template v-for="(item, idx) in items" :key="idx">
          <PaginationItem
            v-if="item.type === 'page'"
            :value="item.value"
            :is-active="item.value === currPage"
          >
            {{ item.value }}
          </PaginationItem>
        </template>
        <PaginationEllipsis :index="4" />
        <PaginationNext>下一页</PaginationNext>
      </PaginationContent>
    </Pagination>
  </div>
</template>
<script setup lang="ts">
import { ref, watchEffect } from "vue";
import type { MarkResponse } from "@/types/mark";
import type { ListParams } from "@/api/types";
import { Pen } from "lucide-vue-next";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import MarkUpdate from "./MarkUpdateForm.vue";
import MarkDelete from "./MarkDeleteDialog.vue";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import {
  Pagination,
  PaginationContent,
  PaginationEllipsis,
  PaginationItem,
  PaginationNext,
  PaginationPrevious,
} from "@/components/ui/pagination";
import { RouterLink } from "vue-router";
import { useRoute, useRouter } from "vue-router";
const route = useRoute();
const router = useRouter();
const props = withDefaults(
  defineProps<{
    fetcher: (p: ListParams) => Promise<any>;
    limit?: number;
  }>(),
  { limit: 10 },
);
const rows = ref<MarkResponse[]>([]);
const total = ref(0);
const currPage = ref(Number(route.query.page) || 1);
async function go(page = 1) {
  currPage.value = page;
  router.replace({
    query: { ...route.query, page: String(page) },
  });
  const { data } = await props.fetcher({ page, limit: props.limit, preload: true });
  rows.value = data.data;
  total.value = data.pagination.totalItems;
}
watchEffect(() => go(currPage.value));
</script>
<!-- src/components/mark/MarkManagePanel.vue -->
<script setup lang="ts">
import { ref, reactive } from "vue";
import { required, helpers } from "@vuelidate/validators";
import useVuelidate from "@vuelidate/core";
import { toast } from "vue-sonner";
import { Plus, Tag } from "lucide-vue-next";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  TagsInput,
  TagsInputInput,
  TagsInputItem,
  TagsInputItemDelete,
  TagsInputItemText,
} from "@/components/ui/tags-input";
import { createMark, listMarks } from "@/api/mark";
import type { MarkCreateRequest } from "@/types/mark";
import DeviceIDSelect from "@/components/device/DeviceIDSelect.vue";
import TypeSelect from "@/components/type/TypeSelect.vue";
import MarkTablePager from "./MarkTablePager.vue";
interface CreateFormState {
  device_id: string;
  mark_name: string;
  persist_mqtt: boolean;
  danger_zone_m: number | null;
  mark_type_id: number;
  tags: string[] | undefined;
}
const tableKey = ref(0);
function refreshTable() {
  tableKey.value++;
}
const createDialogOpen = ref(false);
const createFormInitial: CreateFormState = {
  device_id: "",
  mark_name: "",
  persist_mqtt: false,
  danger_zone_m: null,
  mark_type_id: 1,
  tags: undefined,
};
const createForm = reactive<CreateFormState>({ ...createFormInitial });
const createRules = {
  device_id: { required: helpers.withMessage("请选择设备ID", required) },
  mark_name: { required: helpers.withMessage("请输入标记名称", required) },
};
const createV$ = useVuelidate(createRules, createForm);
const isCreating = ref(false);
async function handleCreate() {
  const valid = await createV$.value.$validate();
  if (!valid) {
    toast.error("请填写完整的表单信息");
    return;
  }
  if (isCreating.value) return;
  isCreating.value = true;
  try {
    const payload = Object.fromEntries(
      Object.entries(createForm).filter(([_, value]) => value !== undefined),
    ) as unknown as MarkCreateRequest;
    await createMark(payload);
    toast.success("标记创建成功");
    createDialogOpen.value = false;
    Object.assign(createForm, createFormInitial);
    createV$.value.$reset();
    refreshTable();
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "创建失败";
      toast.error("创建标记失败", { description: errorMsg });
    }
  } finally {
    isCreating.value = false;
  }
}
</script>
<template>
  <div class="flex h-full w-full flex-col gap-4 p-4">
    <!-- 标题和创建按钮 -->
    <Card>
      <CardHeader>
        <div class="flex items-center justify-between">
          <div>
            <CardTitle class="flex items-center gap-2">
              <Tag class="h-5 w-5" />
              标记管理
            </CardTitle>
            <CardDescription>管理所有标记的信息（地图上进行分类和区分，为后续的安全管理提供数据支持）</CardDescription>
          </div>
          <!-- 创建标记对话框 -->
          <Dialog v-model:open="createDialogOpen">
            <DialogTrigger as-child>
              <Button>
                <Plus class="mr-2 h-4 w-4" />
                新建标记
              </Button>
            </DialogTrigger>
            <DialogContent class="sm:max-w-[500px]">
              <DialogHeader>
                <DialogTitle>新建标记</DialogTitle>
                <DialogDescription>填写标记信息并提交</DialogDescription>
              </DialogHeader>
              <form @submit.prevent="handleCreate">
                <div class="space-y-4 py-4">
                  <!-- 设备ID -->
                  <div class="flex flex-col gap-2">
                    <Label for="createDeviceId">设备ID</Label>
                    <DeviceIDSelect v-model="createForm.device_id" />
                    <span v-if="createV$.device_id.$error" class="text-destructive text-sm">
                      {{ createV$.device_id.$errors[0].$message }}
                    </span>
                  </div>
                  <!-- 标记名称 -->
                  <div class="flex flex-col gap-2">
                    <Label for="createMarkName">标记名称</Label>
                    <Input
                      id="createMarkName"
                      v-model="createForm.mark_name"
                      placeholder="请输入标记名称"
                      :class="{ 'border-destructive': createV$.mark_name.$error }"
                    />
                    <span v-if="createV$.mark_name.$error" class="text-destructive text-sm">
                      {{ createV$.mark_name.$errors[0].$message }}
                    </span>
                  </div>
                  <!-- 标记类型 -->
                  <div class="flex flex-col gap-2">
                    <Label for="createMarkType">标记类型</Label>
                    <TypeSelect v-model="createForm.mark_type_id" />
                  </div>
                  <!-- 危险半径 -->
                  <div class="flex flex-col gap-2">
                    <Label for="createDangerZone">危险半径（米）</Label>
                    <Input
                      id="createDangerZone"
                      :value="createForm.danger_zone_m ?? ''"
                      type="number"
                      step="0.1"
                      placeholder="留空表示使用类型默认值"
                      @input="
                        ($event.target as HTMLInputElement).value === ''
                          ? (createForm.danger_zone_m = null)
                          : (createForm.danger_zone_m = parseFloat(
                              ($event.target as HTMLInputElement).value,
                            ))
                      "
                    />
                  </div>
                  <!-- 分组 -->
                  <div class="flex flex-col gap-2">
                    <Label>分组</Label>
                    <TagsInput v-model="createForm.tags">
                      <template v-if="createForm.tags && createForm.tags.length">
                        <TagsInputItem v-for="tag in createForm.tags" :key="tag" :value="tag">
                          <TagsInputItemText />
                          <TagsInputItemDelete />
                        </TagsInputItem>
                      </template>
                      <TagsInputInput placeholder="输入分组后按 Enter 添加" />
                    </TagsInput>
                  </div>
                  <!-- 保存历史轨迹 -->
                  <div class="flex items-center gap-2">
                    <Switch id="createPersistMqtt" v-model:checked="createForm.persist_mqtt" />
                    <Label for="createPersistMqtt">保存历史轨迹</Label>
                  </div>
                </div>
                <DialogFooter>
                  <Button type="button" variant="outline" @click="createDialogOpen = false">
                    取消
                  </Button>
                  <Button type="submit" :disabled="isCreating">
                    {{ isCreating ? "创建中..." : "创建" }}
                  </Button>
                </DialogFooter>
              </form>
            </DialogContent>
          </Dialog>
        </div>
      </CardHeader>
    </Card>
    <!-- 标记列表 -->
    <MarkTablePager :key="tableKey" :fetcher="listMarks" :limit="10" />
  </div>
</template>
<template>
  <AlertDialog>
    <AlertDialogTrigger as-child>
      <Button variant="outline" size="icon" class="text-red-500" title="删除">
        <Trash class="h-4 w-4" />
      </Button>
    </AlertDialogTrigger>
    <AlertDialogContent>
      <AlertDialogHeader>
        <AlertDialogTitle>确认删除标记？</AlertDialogTitle>
        <AlertDialogDescription>你将永久删除该标记，此操作无法撤销。</AlertDialogDescription>
      </AlertDialogHeader>
      <AlertDialogFooter>
        <AlertDialogCancel>取消</AlertDialogCancel>
        <AlertDialogAction
          class="bg-red-500 hover:bg-red-600"
          :disabled="deleting"
          @click="handleDelete"
        >
          {{ deleting ? "删除中..." : "确认删除" }}
        </AlertDialogAction>
      </AlertDialogFooter>
    </AlertDialogContent>
  </AlertDialog>
</template>
<script setup lang="ts">
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { Button } from "@/components/ui/button";
import { Trash } from "lucide-vue-next";
import { deleteMark } from "@/api/mark";
import { toast } from "vue-sonner";
import { useRouter, useRoute } from "vue-router";
import { ref } from "vue";
const router = useRouter();
const route = useRoute();
const reloadCurrentPage = () =>
  router.replace({
    path: route.fullPath,
    force: true,
    replace: true,
  });
const props = defineProps<{
  id: string;
}>();
const deleting = ref(false);
const handleDelete = async () => {
  if (deleting.value) return;
  deleting.value = true;
  try {
    await deleteMark(props.id);
    await reloadCurrentPage();
    toast.success("删除成功");
  } catch (error: any) {
    console.error(error);
    if (!error._handled) {
      toast.error("删除失败");
    }
  } finally {
    deleting.value = false;
  }
};
</script>
<template>
  <div class="flex h-full w-full flex-col">
    <!-- 表格 -->
    <Card class="min-h-0 flex-1">
      <CardContent class="h-full p-0">
        <!-- 当数据量较少时，不使用滚动区域，让表格自然撑开 -->
        <div v-if="rows.length <= 10" class="flex h-full flex-col">
          <Table class="flex-1">
            <TableHeader>
              <TableRow>
                <TableHead>标记1</TableHead>
                <TableHead>标记2</TableHead>
                <TableHead>距离 (米)</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow
                v-for="pair in rows"
                :key="`${pair.mark1_id}-${pair.mark2_id}`"
                class="hover:bg-muted/50"
              >
                <TableCell class="font-medium">
                  <Badge variant="outline" class="text-sm">
                    <Tag class="mr-1 h-3 w-3" />
                    {{ getMarkName(pair.mark1_id) }}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Badge variant="outline" class="text-sm">
                    <Tag class="mr-1 h-3 w-3" />
                    {{ getMarkName(pair.mark2_id) }}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Badge variant="secondary" class="text-sm"> {{ pair.distance_m }}m </Badge>
                </TableCell>
                <TableCell class="text-right">
                  <div class="flex justify-end gap-2">
                    <!-- 编辑按钮 -->
                    <PairEditDialog :pair="pair" @updated="refresh" />
                    <!-- 删除按钮 -->
                    <PairDeleteDialog
                      :mark1-id="pair.mark1_id"
                      :mark2-id="pair.mark2_id"
                      @deleted="refresh"
                    />
                  </div>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>
        <!-- 当数据量较多时，使用滚动区域 -->
        <ScrollArea v-else class="h-[calc(100vh-18rem)]">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>标记1</TableHead>
                <TableHead>标记2</TableHead>
                <TableHead>距离 (米)</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow
                v-for="pair in rows"
                :key="`${pair.mark1_id}-${pair.mark2_id}`"
                class="hover:bg-muted/50"
              >
                <TableCell class="font-medium">
                  <Badge variant="outline" class="text-sm">
                    <Tag class="mr-1 h-3 w-3" />
                    {{ getMarkName(pair.mark1_id) }}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Badge variant="outline" class="text-sm">
                    <Tag class="mr-1 h-3 w-3" />
                    {{ getMarkName(pair.mark2_id) }}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Badge variant="secondary" class="text-sm"> {{ pair.distance_m }}m </Badge>
                </TableCell>
                <TableCell class="text-right">
                  <div class="flex justify-end gap-2">
                    <!-- 编辑按钮 -->
                    <PairEditDialog :pair="pair" @updated="refresh" />
                    <!-- 删除按钮 -->
                    <PairDeleteDialog
                      :mark1-id="pair.mark1_id"
                      :mark2-id="pair.mark2_id"
                      @deleted="refresh"
                    />
                  </div>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </ScrollArea>
      </CardContent>
    </Card>
    <!-- 分页 -->
    <Pagination
      v-slot="{ page }"
      :items-per-page="limit"
      :total="total"
      :default-page="1"
      @update:page="go"
      class="mt-4 mb-2"
    >
      <PaginationContent v-slot="{ items }">
        <PaginationPrevious>上一页</PaginationPrevious>
        <template v-for="(item, idx) in items" :key="idx">
          <PaginationItem
            v-if="item.type === 'page'"
            :value="item.value"
            :is-active="item.value === currPage"
          >
            {{ item.value }}
          </PaginationItem>
        </template>
        <PaginationEllipsis :index="4" />
        <PaginationNext>下一页</PaginationNext>
      </PaginationContent>
    </Pagination>
  </div>
</template>
<script setup lang="ts">
import { ref, watchEffect, onMounted } from "vue";
import type { PairItem } from "@/types/distance";
import type { ListParams } from "@/api/types";
import { Tag } from "lucide-vue-next";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import PairDeleteDialog from "@/components/mark/PairDeleteDialog.vue";
import PairEditDialog from "@/components/mark/PairEditDialog.vue";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { ScrollArea } from "@/components/ui/scroll-area";
import {
  Pagination,
  PaginationContent,
  PaginationEllipsis,
  PaginationItem,
  PaginationNext,
  PaginationPrevious,
} from "@/components/ui/pagination";
import { useRoute, useRouter } from "vue-router";
import { getPairsList } from "@/api/mark/pair";
import { getAllMarkIDToName } from "@/api/mark/index";
const route = useRoute();
const router = useRouter();
const props = withDefaults(
  defineProps<{
    limit?: number;
  }>(),
  { limit: 10 },
);
const rows = ref<PairItem[]>([]);
const total = ref(0);
const currPage = ref(Number(route.query.page) || 1);
const markNames = ref<Record<string, string>>({});
const getMarkName = (markId: string) => {
  return markNames.value[markId] || markId;
};
async function go(page = 1) {
  currPage.value = page;
  router.replace({
    query: { ...route.query, page: String(page) },
  });
  const { data } = await getPairsList(page, props.limit);
  rows.value = data.data;
  total.value = data.pagination?.totalItems || 0;
}
function refresh() {
  go(currPage.value);
}
const loadMarkNames = async () => {
  try {
    const response = await getAllMarkIDToName();
    if (response.data.data) {
      markNames.value = response.data.data;
    }
  } catch (error) {
    console.error("加载标记名称失败:", error);
  }
};
watchEffect(() => go(currPage.value));
onMounted(() => {
  loadMarkNames();
});
</script>
<script setup lang="ts">
import DangerTypeSelect from "@/components/type/TypeSelect.vue";
import DeviceIDSelect from "@/components/device/DeviceIDSelect.vue";
import { Input } from "@/components/ui/input";
import { Switch } from "@/components/ui/switch";
import {
  TagsInput,
  TagsInputInput,
  TagsInputItem,
  TagsInputItemDelete,
  TagsInputItemText,
} from "@/components/ui/tags-input";
import { Button } from "@/components/ui/button";
import { reactive } from "vue";
import type { MarkCreateRequest } from "@/types/mark";
import { createMark } from "@/api/mark";
import { toast } from "vue-sonner";
const form = reactive<MarkCreateRequest>({
  device_id: "",
  mark_name: "",
  persist_mqtt: false,
  danger_zone_m: null,
  mark_type_id: 1,
  tags: undefined,
});
const handleSubmit = async () => {
  if (!form.device_id) {
    toast.error("请选择设备 ID");
    return;
  }
  if (!form.mark_name.trim()) {
    toast.error("请输入有效的标记名称");
    return;
  }
  const payload = Object.fromEntries(
    Object.entries(form).filter(([_, value]) => value !== undefined),
  ) as unknown as MarkCreateRequest;
  console.log("正在提交:", payload);
  try {
    await createMark(payload);
    toast.success(`标记 "${form.mark_name}" 创建成功！`);
  } catch (error: any) {
    if (!error._handled) {
      const msg = error?.response?.data?.message || "创建失败，请稍后重试";
      toast.error(msg);
    }
    console.error("创建标记失败:", error);
  }
};
const resetForm = () => {
  form.device_id = "";
  form.mark_name = "";
  form.persist_mqtt = false;
  form.danger_zone_m = null;
  form.mark_type_id = 1;
  form.tags = undefined; 
};
</script>
<template>
  <div class="bg-background mx-auto max-w-2xl rounded-xl border p-6 shadow-md">
    <h2 class="mb-6 text-lg font-semibold">新建标记</h2>
    <!-- 设备 ID 选择 -->
    <div class="mb-5">
      <label class="mb-1 block text-sm font-medium">设备</label>
      <DeviceIDSelect v-model="form.device_id" />
    </div>
    <!-- 标记名称 -->
    <div class="mb-5">
      <label for="mark-name" class="mb-1 block text-sm font-medium">标记名称</label>
      <Input id="mark-name" v-model="form.mark_name" placeholder="请输入标记名称…" />
    </div>
    <!-- 类型选择 -->
    <div class="mb-5">
      <label class="mb-1 block text-sm font-medium">标记类型</label>
      <DangerTypeSelect v-model="form.mark_type_id" />
    </div>
    <!-- 危险半径 -->
    <div class="mb-5">
      <label for="safe-distance" class="mb-1 block text-sm font-medium"> 危险半径（米） </label>
      <Input
        id="safe-distance"
        :value="form.danger_zone_m ?? ''"
        type="number"
        step="0.1"
        placeholder="留空表示使用类型默认值"
        @input="
          ($event.target as HTMLInputElement).value === ''
            ? (form.danger_zone_m = null)
            : (form.danger_zone_m = parseFloat(($event.target as HTMLInputElement).value))
        "
      />
    </div>
    <!-- 分组输入 -->
    <div class="mb-5">
      <label class="mb-1 block text-sm font-medium">分组</label>
      <TagsInput v-model="form.tags">
        <template v-if="form.tags && form.tags.length">
          <TagsInputItem v-for="tag in form.tags" :key="tag" :value="tag">
            <TagsInputItemText />
            <TagsInputItemDelete />
          </TagsInputItem>
        </template>
        <TagsInputInput placeholder="输入分组后按 Enter 添加" />
      </TagsInput>
    </div>
    <!-- 持久化开关 -->
    <div class="mb-6">
      <label for="persist-mqtt-switch" class="text-sm font-medium"> 保存历史轨迹 </label>
      <br />
      <Switch v-model="form.persist_mqtt" />
    </div>
    <!-- 提交按钮 -->
    <div class="flex items-center gap-3">
      <Button
        type="button"
        @click="handleSubmit"
        :disabled="!form.device_id || !form.mark_name.trim()"
      >
        创建标记
      </Button>
      <Button type="button" variant="outline" @click="resetForm"> 重置 </Button>
    </div>
    <!-- 调试信息（可选） -->
    <div class="bg-muted mt-6 hidden rounded-xl border p-4 text-xs">
      <h3 class="mb-2 font-semibold">当前 payload</h3>
      <pre>{{
        JSON.stringify(
          Object.fromEntries(Object.entries(form).filter(([_, v]) => v !== undefined)),
          null,
          2,
        )
      }}</pre>
    </div>
  </div>
</template>
<template>
  <div class="h-full w-full">
    <div ref="chartRef" class="h-full w-full"></div>
  </div>
</template>
<script setup lang="ts">
import { ref, watch, onMounted, onBeforeUnmount } from "vue";
import * as echarts from "echarts/core";
import { ScatterChart } from "echarts/charts";
import { GridComponent, DataZoomComponent, GraphicComponent } from "echarts/components";
import { CanvasRenderer } from "echarts/renderers";
import type { ECBasicOption } from "echarts/types/dist/shared";
echarts.use([ScatterChart, GridComponent, DataZoomComponent, GraphicComponent, CanvasRenderer]);
interface UWBFix {
  id: string;
  x: number;
  y: number;
}
const props = defineProps<{ points: UWBFix[] }>();
const chartRef = ref<HTMLDivElement | null>(null);
let chart: echarts.ECharts | null = null;
let bgEl: any = null;
const bgImg = new Image();
bgImg.src = new URL("@/assets/imgs/uwbmap.png", import.meta.url).href;
function calcBgPixelRect(): { x: number; y: number; width: number; height: number } | null {
  if (!chart) return null;
  const xAxisModel = (chart as any).getModel().getComponent("xAxis", 0);
  const yAxisModel = (chart as any).getModel().getComponent("yAxis", 0);
  const [xMin, xMax] = xAxisModel.axis.scale.getExtent();
  const [yMin, yMax] = yAxisModel.axis.scale.getExtent();
  const lt = chart.convertToPixel("grid", [xMin, yMax]);
  const rb = chart.convertToPixel("grid", [xMax, yMin]);
  return {
    x: lt[0],
    y: lt[1],
    width: rb[0] - lt[0],
    height: rb[1] - lt[1],
  };
}
function updateBackground() {
  const rect = calcBgPixelRect();
  if (!rect) return;
  if (!bgEl) {
    bgEl = new (echarts as any).graphic.Image({
      z: -1,
      style: {
        image: bgImg,
        x: rect.x,
        y: rect.y,
        width: rect.width,
        height: rect.height,
      },
      silent: true,
    });
    chart!.getZr().add(bgEl);
  } else {
    bgEl.setStyle({
      image: bgImg, 
      x: rect.x,
      y: rect.y,
      width: rect.width,
      height: rect.height,
    });
  }
}
function renderChart() {
  if (!chartRef.value) return;
  if (!chart) {
    chart = echarts.init(chartRef.value);
    const option: ECBasicOption = {
      grid: {
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
      },
      xAxis: {
        type: "value",
        min: -1000,
        max: 1000,
        splitLine: { lineStyle: { type: "dashed" } },
      },
      yAxis: {
        type: "value",
        min: -1000,
        max: 1000,
        splitLine: { lineStyle: { type: "dashed" } },
      },
      series: [
        {
          type: "scatter",
          data: [],
          symbolSize: 10,
          itemStyle: {
            borderColor: "#fff",
            borderWidth: 1,
            shadowBlur: 8,
            shadowColor: "rgba(0,0,0,0.2)",
            color: new (echarts as any).graphic.RadialGradient(0.4, 0.3, 1, [
              { offset: 0, color: "rgb(251, 118, 123)" },
              { offset: 1, color: "rgb(204, 46, 72)" },
            ]),
          },
          emphasis: {
            scale: 2,
            itemStyle: { shadowBlur: 20 },
          },
          label: {
            show: true,
            fontSize: 10,
            color: "#666",
            distance: 5,
            position: "top",
            formatter: (p: any) =>
              `ID:${p.value[2]} (${p.value[0].toFixed(2)},${p.value[1].toFixed(2)})`,
          },
        },
      ],
      dataZoom: [
        { type: "inside", xAxisIndex: 0, zoomOnMouseWheel: true, moveOnMouseMove: true },
        { type: "inside", yAxisIndex: 0, zoomOnMouseWheel: true, moveOnMouseMove: true },
        { type: "slider", xAxisIndex: 0, bottom: 10, height: 14 },
        { type: "slider", yAxisIndex: 0, right: 10, width: 14 },
      ],
    };
    chart.setOption(option);
  }
  const data = props.points.map((p) => [p.x, p.y, p.id]);
  chart.setOption({ series: [{ data }] } as any);
  updateBackground();
}
watch(() => props.points, renderChart, { deep: true });
let ro: ResizeObserver | null = null;
onMounted(() => {
  renderChart();
  ro = new ResizeObserver(() => {
    chart?.resize();
    requestAnimationFrame(updateBackground);
  });
  chartRef.value && ro.observe(chartRef.value);
  chart!.on("dataZoom", () => {
    requestAnimationFrame(() => {
      requestAnimationFrame(updateBackground); 
    });
  });
  chart!.on("finished", updateBackground);
});
onBeforeUnmount(() => {
  ro?.disconnect();
  bgEl && chart?.getZr().remove(bgEl);
  chart?.dispose();
});
</script>
<template>
  <UWBScatter :points="list" />
</template>
<script setup lang="ts">
import { onMounted, onUnmounted, ref } from "vue";
import { connectMQTT, disconnectMQTT, parseUWBMessage } from "@/utils/mqtt";
import type { UWBFix } from "@/utils/mqtt";
import type { MqttClient } from "mqtt";
import UWBScatter from "@/components/maps/UWBScatter.vue";
const list = ref<UWBFix[]>([]);
const lastUpdateTime = new Map<string, number>();
const UPDATE_INTERVAL = 1000; 
let mqttClient: MqttClient | null = null;
const msgCallback = (_topic: string, payload: Buffer) => {
  try {
    const fix: UWBFix = parseUWBMessage(_topic, payload); 
    const now = Date.now();
    const lastUpdate = lastUpdateTime.get(fix.id) || 0;
    if (now - lastUpdate < UPDATE_INTERVAL) {
      return;
    }
    lastUpdateTime.set(fix.id, now);
    const idx = list.value.findIndex((p) => p.id === fix.id);
    if (idx >= 0) list.value.splice(idx, 1, fix);
    else list.value.push(fix);
  } catch (e) {
    console.warn("丢弃一条非法 UWB 消息", e);
  }
};
onMounted(() => {
  mqttClient = connectMQTT(); 
  mqttClient.subscribe("location/#", { qos: 0 }, (err) => {
    if (err) return console.error("UWB 订阅失败", err);
    console.log("已订阅 location/#");
  });
  mqttClient.on("message", msgCallback);
});
onUnmounted(() => {
  disconnectMQTT(mqttClient!);
  list.value = []; 
});
</script>
<template>
  <div class="m-0 h-full w-full p-0" id="container"></div>
</template>
<script setup lang="ts">
import AMapLoader from "@amap/amap-jsapi-loader";
import { onMounted, onUnmounted, ref, defineEmits, defineExpose } from "vue";
import { MAP_CONFIG } from "@/config/map";
import { connectMQTT, disconnectMQTT } from "@/utils/mqtt";
import { updateDevicePosition } from "@/utils/map";
import { clearDeviceCircles } from "@/utils/map";
import { parseMessage } from "@/utils/mqtt";
import type { Device } from "@/utils/mqtt";
import type { MqttClient } from "mqtt";
import type { PolygonFenceResp } from "@/types/polygonFence";
let map: AMap.Map | null = null;
let mqttClient: MqttClient | null = null;
const devices = ref<Device[]>([]);
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
  clearDeviceCircles(map!);
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
  fencePolygons.forEach((p) => p.setMap(null as unknown as AMap.Map));
  fencePolygons.length = 0;
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
<template>
  <Card>
    <CardHeader>
      <div class="flex items-center justify-between">
        <div>
          <CardTitle class="flex items-center gap-2">
            <Info class="h-5 w-5" />
            {{ typeInfo.type_name }}
          </CardTitle>
          <CardDescription>
            默认危险半径：{{
              typeInfo.default_danger_zone_m === -1 ? "-" : typeInfo.default_danger_zone_m + " m"
            }}
          </CardDescription>
        </div>
        <Button variant="outline" size="sm" @click="openEditDialog">
          <Pencil class="h-4 w-4" />
          编辑
        </Button>
      </div>
    </CardHeader>
  </Card>
  <!-- 编辑类型对话框 -->
  <Dialog v-model:open="editDialogOpen">
    <DialogContent class="sm:max-w-[500px]">
      <DialogHeader>
        <DialogTitle>编辑类型</DialogTitle>
        <DialogDescription>修改类型信息</DialogDescription>
      </DialogHeader>
      <form @submit.prevent="handleUpdate">
        <div class="space-y-4 py-4">
          <!-- 类型名称 -->
          <div class="flex flex-col gap-2">
            <Label for="editTypeName">类型名称</Label>
            <Input
              id="editTypeName"
              v-model="editForm.type_name"
              placeholder="请输入类型名称"
              :class="{ 'border-destructive': editV$.type_name.$error }"
            />
            <span v-if="editV$.type_name.$error" class="text-destructive text-sm">
              {{ editV$.type_name.$errors[0].$message }}
            </span>
          </div>
          <!-- 默认危险半径 -->
          <div class="flex flex-col gap-2">
            <Label for="editDangerZone">默认危险半径（米）</Label>
            <Input
              id="editDangerZone"
              :value="editForm.default_danger_zone_m ?? ''"
              type="number"
              step="0.1"
              placeholder="留空表示不设置默认值"
              @input="
                ($event.target as HTMLInputElement).value === ''
                  ? (editForm.default_danger_zone_m = null)
                  : (editForm.default_danger_zone_m = parseFloat(
                      ($event.target as HTMLInputElement).value,
                    ))
              "
            />
            <span class="text-muted-foreground text-xs"> 设置 -1 表示无默认值 </span>
          </div>
        </div>
        <DialogFooter>
          <Button type="button" variant="outline" @click="editDialogOpen = false"> 取消 </Button>
          <Button type="submit" :disabled="isUpdating">
            {{ isUpdating ? "更新中..." : "更新" }}
          </Button>
        </DialogFooter>
      </form>
    </DialogContent>
  </Dialog>
</template>
<script setup lang="ts">
import { reactive, ref } from "vue";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Info, Pencil } from "lucide-vue-next";
import type { MarkTypeRequest, MarkTypeResponse } from "@/types/mark";
import { updateMarkType } from "@/api/mark/type";
import { toast } from "vue-sonner";
import { useVuelidate } from "@vuelidate/core";
import { required, helpers } from "@vuelidate/validators";
const props = defineProps<{
  typeInfo: MarkTypeResponse;
}>();
const emit = defineEmits<{
  updated: [];
}>();
const editDialogOpen = ref(false);
const editForm = reactive({
  type_name: "",
  default_danger_zone_m: null as number | null,
});
const editRules = {
  type_name: { required: helpers.withMessage("请输入类型名称", required) },
};
const editV$ = useVuelidate(editRules, editForm);
const isUpdating = ref(false);
function openEditDialog() {
  editForm.type_name = props.typeInfo.type_name;
  editForm.default_danger_zone_m =
    props.typeInfo.default_danger_zone_m === -1 ? null : props.typeInfo.default_danger_zone_m;
  editV$.value.$reset();
  editDialogOpen.value = true;
}
async function handleUpdate() {
  const valid = await editV$.value.$validate();
  if (!valid) {
    toast.error("请填写完整的表单信息");
    return;
  }
  if (isUpdating.value) return;
  isUpdating.value = true;
  try {
    const payload: MarkTypeRequest = {
      type_name: editForm.type_name,
      default_danger_zone_m:
        editForm.default_danger_zone_m === null ? -1 : editForm.default_danger_zone_m,
    };
    await updateMarkType(props.typeInfo.id, payload);
    toast.success("类型更新成功");
    editDialogOpen.value = false;
    emit("updated");
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "更新失败";
      toast.error("更新类型失败", { description: errorMsg });
    }
  } finally {
    isUpdating.value = false;
  }
}
</script>
<template>
  <div class="flex w-full flex-col">
    <!-- 表格 -->
    <Card class="flex-1">
      <CardContent class="p-0">
        <ScrollArea class="h-[calc(100vh-18rem)]">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>ID</TableHead>
                <TableHead>分组名称</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow v-for="tag in rows" :key="tag.id" class="hover:bg-muted/50">
                <TableCell class="font-medium">{{ tag.id }}</TableCell>
                <TableCell>
                  <RouterLink :to="`/tag/${tag.id}`" class="hover:underline">
                    <Badge variant="outline" class="text-sm">
                      <Hash class="mr-1 h-3 w-3" />
                      {{ tag.tag_name }}
                    </Badge>
                  </RouterLink>
                </TableCell>
                <TableCell class="text-right">
                  <div class="flex justify-end gap-2">
                    <!-- 查看按钮 -->
                    <RouterLink :to="`/tag/${tag.id}`">
                      <Button variant="outline" size="icon" title="查看详情">
                        <Eye class="h-4 w-4" />
                      </Button>
                    </RouterLink>
                    <!-- 删除按钮 -->
                    <TagDelete :id="tag.id" @deleted="refresh" />
                  </div>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </ScrollArea>
      </CardContent>
    </Card>
    <!-- 分页 -->
    <Pagination
      v-slot="{ page }"
      :items-per-page="limit"
      :total="total"
      :default-page="1"
      @update:page="go"
      class="mt-4"
    >
      <PaginationContent v-slot="{ items }">
        <PaginationPrevious>上一页</PaginationPrevious>
        <template v-for="(item, idx) in items" :key="idx">
          <PaginationItem
            v-if="item.type === 'page'"
            :value="item.value"
            :is-active="item.value === currPage"
          >
            {{ item.value }}
          </PaginationItem>
        </template>
        <PaginationEllipsis :index="4" />
        <PaginationNext>下一页</PaginationNext>
      </PaginationContent>
    </Pagination>
  </div>
</template>
<script setup lang="ts">
import { ref, watchEffect } from "vue";
import type { MarkTagResponse } from "@/types/mark";
import type { ListParams } from "@/api/types";
import { Eye, Hash } from "lucide-vue-next";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import TagDelete from "./TagDeleteDialog.vue";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { ScrollArea } from "@/components/ui/scroll-area";
import {
  Pagination,
  PaginationContent,
  PaginationEllipsis,
  PaginationItem,
  PaginationNext,
  PaginationPrevious,
} from "@/components/ui/pagination";
import { RouterLink } from "vue-router";
import { useRoute, useRouter } from "vue-router";
const route = useRoute();
const router = useRouter();
const props = withDefaults(
  defineProps<{
    fetcher: (p: ListParams) => Promise<any>;
    limit?: number;
  }>(),
  { limit: 10 },
);
const rows = ref<MarkTagResponse[]>([]);
const total = ref(0);
const currPage = ref(Number(route.query.page) || 1);
async function go(page = 1) {
  currPage.value = page;
  router.replace({
    query: { ...route.query, page: String(page) },
  });
  const { data } = await props.fetcher({ page, limit: props.limit });
  rows.value = data.data;
  total.value = data.pagination.totalItems;
}
function refresh() {
  go(currPage.value);
}
watchEffect(() => go(currPage.value));
</script>
<template>
  <Card>
    <CardHeader>
      <div class="flex items-center justify-between">
        <div>
          <CardTitle class="flex items-center gap-2">
            <Hash class="h-5 w-5" />
            {{ tagInfo.tag_name }}
          </CardTitle>
          <CardDescription>分组 ID: {{ tagInfo.id }}</CardDescription>
        </div>
        <Button variant="outline" size="sm" @click="openEditDialog">
          <Pencil class="h-4 w-4" />
          编辑
        </Button>
      </div>
    </CardHeader>
  </Card>
  <!-- 编辑分组对话框 -->
  <Dialog v-model:open="editDialogOpen">
    <DialogContent class="sm:max-w-[500px]">
      <DialogHeader>
        <DialogTitle>编辑分组</DialogTitle>
        <DialogDescription>修改分组信息</DialogDescription>
      </DialogHeader>
      <form @submit.prevent="handleUpdate">
        <div class="space-y-4 py-4">
          <!-- 分组名称 -->
          <div class="flex flex-col gap-2">
            <Label for="editTagName">分组名称</Label>
            <Input
              id="editTagName"
              v-model="editForm.tag_name"
              placeholder="请输入分组名称"
              :class="{ 'border-destructive': editV$.tag_name.$error }"
            />
            <span v-if="editV$.tag_name.$error" class="text-destructive text-sm">
              {{ editV$.tag_name.$errors[0].$message }}
            </span>
          </div>
        </div>
        <DialogFooter>
          <Button type="button" variant="outline" @click="editDialogOpen = false"> 取消 </Button>
          <Button type="submit" :disabled="isUpdating">
            {{ isUpdating ? "更新中..." : "更新" }}
          </Button>
        </DialogFooter>
      </form>
    </DialogContent>
  </Dialog>
</template>
<script setup lang="ts">
import { reactive, ref } from "vue";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Hash, Pencil } from "lucide-vue-next";
import type { MarkTagRequest, MarkTagResponse } from "@/types/mark";
import { updateMarkTag } from "@/api/mark/tag";
import { toast } from "vue-sonner";
import { useVuelidate } from "@vuelidate/core";
import { required, helpers } from "@vuelidate/validators";
const props = defineProps<{
  tagInfo: MarkTagResponse;
}>();
const emit = defineEmits<{
  updated: [];
}>();
const editDialogOpen = ref(false);
const editForm = reactive({
  tag_name: "",
});
const editRules = {
  tag_name: { required: helpers.withMessage("请输入分组名称", required) },
};
const editV$ = useVuelidate(editRules, editForm);
const isUpdating = ref(false);
function openEditDialog() {
  editForm.tag_name = props.tagInfo.tag_name;
  editV$.value.$reset();
  editDialogOpen.value = true;
}
async function handleUpdate() {
  const valid = await editV$.value.$validate();
  if (!valid) {
    toast.error("请填写完整的表单信息");
    return;
  }
  if (isUpdating.value) return;
  isUpdating.value = true;
  try {
    const payload: MarkTagRequest = {
      tag_name: editForm.tag_name,
    };
    await updateMarkTag(props.tagInfo.id, payload);
    toast.success("分组更新成功");
    editDialogOpen.value = false;
    emit("updated");
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "更新失败";
      toast.error("更新分组失败", { description: errorMsg });
    }
  } finally {
    isUpdating.value = false;
  }
}
</script>
<template>
  <AlertDialog>
    <AlertDialogTrigger as-child>
      <Button variant="outline" size="icon" class="text-red-500" title="删除">
        <Trash class="h-4 w-4" />
      </Button>
    </AlertDialogTrigger>
    <AlertDialogContent>
      <AlertDialogHeader>
        <AlertDialogTitle>确认删除分组？</AlertDialogTitle>
        <AlertDialogDescription>你将永久删除该分组，此操作无法撤销。</AlertDialogDescription>
      </AlertDialogHeader>
      <AlertDialogFooter>
        <AlertDialogCancel>取消</AlertDialogCancel>
        <AlertDialogAction
          class="bg-red-500 hover:bg-red-600"
          :disabled="deleting"
          @click="handleDelete"
        >
          {{ deleting ? "删除中..." : "确认删除" }}
        </AlertDialogAction>
      </AlertDialogFooter>
    </AlertDialogContent>
  </AlertDialog>
</template>
<script setup lang="ts">
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { Button } from "@/components/ui/button";
import { Trash } from "lucide-vue-next";
import { deleteMarkTag } from "@/api/mark/tag";
import { toast } from "vue-sonner";
import { ref } from "vue";
const props = defineProps<{
  id: number;
}>();
const emit = defineEmits<{
  deleted: [];
}>();
const deleting = ref(false);
const handleDelete = async () => {
  if (deleting.value) return;
  deleting.value = true;
  try {
    await deleteMarkTag(props.id);
    toast.success("删除成功");
    emit("deleted");
  } catch (error: any) {
    console.error(error);
    if (!error._handled) {
      toast.error("删除失败");
    }
  } finally {
    deleting.value = false;
  }
};
</script>
<!-- src/components/MenuFooter.vue -->
<template>
  <nav
    class="flex h-full w-full items-stretch border-t border-gray-200 bg-white dark:border-gray-700 dark:bg-gray-900"
  >
    <button
      v-for="(item, idx) in menu"
      :key="idx"
      :class="[
        'flex flex-1 flex-col items-center justify-center text-gray-600',
        'hover:text-blue-500 focus:outline-none',
        active === idx && 'text-blue-600',
        'dark:text-gray-400 dark:hover:text-blue-400',
        active === idx && 'dark:text-blue-400',
      ]"
      @click="active = idx"
    >
      <component :is="item.icon" :size="22" />
      <span class="mt-1 text-xs">{{ item.label }}</span>
    </button>
  </nav>
</template>
<script setup lang="ts">
import { ref } from "vue";
import { Home, MapPin, Tag, User } from "lucide-vue-next";
const active = ref(0);
const menu = [
  { icon: Home, label: "首页" },
  { icon: MapPin, label: "地图" },
  { icon: Tag, label: "分组" },
  { icon: User, label: "用户" },
];
</script>
<script setup lang="ts">
import {
  NavigationMenu,
  NavigationMenuContent,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  NavigationMenuTrigger,
  navigationMenuTriggerStyle,
} from "@/components/ui/navigation-menu";
import { Separator } from "@/components/ui/separator";
import {
  Map,
  MapPinned,
  History,
  Fence,
  Bookmark,
  Info,
  Podcast,
  Settings,
  Ruler,
} from "lucide-vue-next";
import HomeButton from "@/components/layout/HomeLogo.vue";
import ThemeToggle from "./RightControlStrip.vue";
</script>
<template>
  <div class="bg-accent flex h-full w-full items-center justify-between space-x-4">
    <div class="flex">
      <HomeButton class="mr-2 hidden md:flex"></HomeButton>
      <NavigationMenu>
        <NavigationMenuList>
          <NavigationMenuItem>
            <NavigationMenuTrigger class="flex items-center space-x-2">
              <Map class="h-4 w-4" />
              <span>地图</span>
            </NavigationMenuTrigger>
            <NavigationMenuContent class="w-[75vw]">
              <ul
                class="grid w-full gap-3 p-4 md:w-[400px] lg:w-[500px] lg:grid-cols-[minmax(0,1fr)_minmax(0,1fr)]"
              >
                <li class="row-span-5">
                  <NavigationMenuLink as-child>
                    <RouterLink
                      class="from-muted/50 to-muted flex h-full w-full flex-col rounded-md bg-gradient-to-b p-6 no-underline outline-none select-none focus:shadow-md"
                      to="/map"
                    >
                      <div class="h-[60%] w-full shrink-0">
                        <!-- <Map class="h-fit w-fit" /> -->
                        <img
                          src="@/assets/imgs/mini-map.jpg"
                          alt="map"
                          class="h-full w-full rounded-md object-cover"
                        />
                      </div>
                      <div class="flex flex-1 flex-col justify-start">
                        <div class="mt-4 mb-2 text-lg font-medium">地图总览</div>
                        <p class="text-muted-foreground line-clamp-2 text-sm leading-snug">
                          实时 RTK + UWB 地图
                        </p>
                      </div>
                    </RouterLink>
                  </NavigationMenuLink>
                </li>
                <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/map/rtk"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div
                        class="flex items-center justify-between text-sm leading-none font-medium"
                      >
                        实时 RTK 地图 <MapPinned class="h-4 w-4" />
                      </div>
                    </RouterLink>
                  </NavigationMenuLink>
                </li>
                <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/map/settings/fence"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div
                        class="flex items-center justify-between text-sm leading-none font-medium"
                      >
                        实时 UWB 地图 <MapPinned class="h-4 w-4" />
                      </div>
                    </RouterLink> </NavigationMenuLink
                  ><Separator />
                </li>
                <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/map/rtk"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div
                        class="flex items-center justify-between text-sm leading-none font-medium"
                      >
                        历史轨迹 <History class="h-4 w-4" />
                      </div>
                    </RouterLink> </NavigationMenuLink
                  ><Separator />
                </li>
                <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/stations"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div
                        class="flex items-center justify-between text-sm leading-none font-medium"
                      >
                        UWB 基站管理 <Podcast class="h-4 w-4" />
                      </div>
                    </RouterLink>
                  </NavigationMenuLink>
                </li>
                <!-- <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/map/settings/fence"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div
                        class="flex items-center justify-between text-sm leading-none font-medium"
                      >
                        电子围栏管理 <Fence class="h-4 w-4" />
                      </div>
                    </RouterLink>
                  </NavigationMenuLink>
                </li> -->
                <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/map/settings"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div
                        class="flex items-center justify-between text-sm leading-none font-medium"
                      >
                        地图设置 <Settings class="h-4 w-4" />
                      </div>
                    </RouterLink>
                  </NavigationMenuLink>
                </li>
              </ul>
            </NavigationMenuContent>
          </NavigationMenuItem>
          <NavigationMenuItem>
            <NavigationMenuTrigger class="flex items-center space-x-2">
              <Bookmark class="h-4 w-4" />
              <span>电子标记</span>
            </NavigationMenuTrigger>
            <NavigationMenuContent class="w-[75vw]">
              <ul
                class="grid w-full gap-3 p-4 md:w-[400px] lg:w-[500px] lg:grid-cols-[minmax(0,.75fr)_minmax(0,1fr)]"
              >
                <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/marks/status"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div class="flex items-center justify-between text-sm font-medium">
                        标记状态 <History class="h-4 w-4" />
                      </div>
                    </RouterLink>
                  </NavigationMenuLink>
                </li>
                <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/marks/manage"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div class="flex items-center justify-between text-sm font-medium">
                        标记管理 <Fence class="h-4 w-4" />
                      </div>
                    </RouterLink>
                  </NavigationMenuLink>
                </li>
                <li>
                  <NavigationMenuLink as-child>
                    <RouterLink
                      to="/marks/distance"
                      class="hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground block space-y-1 rounded-md p-3 leading-none no-underline transition-colors outline-none select-none"
                    >
                      <div class="flex items-center justify-between text-sm font-medium">
                        距离设置 <Ruler class="h-4 w-4" />
                      </div>
                    </RouterLink>
                  </NavigationMenuLink>
                </li>
              </ul>
            </NavigationMenuContent>
          </NavigationMenuItem>
          <NavigationMenuItem class="hidden md:flex">
            <NavigationMenuLink :class="navigationMenuTriggerStyle()">
              <RouterLink to="/about" class="flex flex-row items-center space-x-2">
                <Info class="text- h-4 w-4" />
                <span class="">关于</span>
                <!-- 确保文字颜色也匹配 -->
              </RouterLink>
            </NavigationMenuLink>
          </NavigationMenuItem>
        </NavigationMenuList>
      </NavigationMenu>
    </div>
    <ThemeToggle class="m-1.5"></ThemeToggle>
  </div>
</template>
<!-- src/components/HomeFooter.vue -->
<template>
  <footer class="flex h-12 shrink-0 items-center justify-center px-4 text-sm text-white md:px-6">
    <!-- 左侧版权 -->
    <div class="flex items-center">
      <Copyright :size="16" />
      <p>2025 上海电力大学Lab 107版权所有</p>
      <a
        href="https://beian.miit.gov.cn"
        target="_blank"
        rel="noopener noreferrer"
        class="ml-2 underline"
      >
        还没有网络备案😦
      </a>
    </div>
    <!-- 右侧社交媒体图标 -->
    <div class="flex items-center space-x-3">
      <a href="mailto:contact@example.com" title="Email" class="hover:text-gray-200">
        <i class="fas fa-envelope" />
      </a>
      <a
        href="https://github.com/xiaozhuABCD1234"
        target="_blank"
        rel="noopener noreferrer"
        title="我的github主页"
        class="flex items-center gap-1 hover:text-black"
      >
        我的github主页<Github :size="16" />
      </a>
    </div>
  </footer>
</template>
<script setup lang="ts">
import { Github, Copyright } from "lucide-vue-next";
</script>
<script setup lang="ts">
import { Sun, Moon, UserRound } from "lucide-vue-next";
import { useColorMode } from "@vueuse/core";
import { Button } from "@/components/ui/button";
import { HoverCard, HoverCardContent, HoverCardTrigger } from "@/components/ui/hover-card";
const mode = useColorMode(); 
</script>
<template>
  <div class="flex gap-2">
    <HoverCard>
      <HoverCardTrigger>
        <RouterLink to="/profile">
          <Button variant="outline" size="icon"> <UserRound class="h-5 w-5" /> </Button
        ></RouterLink>
      </HoverCardTrigger>
      <HoverCardContent>
        <div class="space-y-1">
          <h4 class="text-sm font-semibold">用户资料</h4>
          <p class="text-muted-foreground text-sm">悬停查看更多信息，点击按钮可跳转到个人中心。</p>
        </div>
      </HoverCardContent></HoverCard
    >
    <Button
      variant="outline"
      size="icon"
      class="rounded-md p-2"
      @click="mode = mode === 'light' ? 'dark' : 'light'"
    >
      <Sun v-if="mode === 'light'" class="h-5 w-5" />
      <Moon v-else class="h-5 w-5" />
    </Button>
  </div>
</template>
<script setup lang="ts">
import { Monitor } from "lucide-vue-next";
</script>
<template>
  <RouterLink to="/" class="flex items-center space-x-2 text-2xl">
    <Monitor class="ml-2 h-8 w-8" />
    <span>展示平台</span>
  </RouterLink>
</template>
<template>
  <!-- 最外层滚动容器 -->
  <ScrollArea class="h-full w-full">
    <!-- 网格容器：自动换行，最小宽度 280px，列数随容器宽度变化 -->
    <div
      class="grid gap-3 p-0.5"
      style="grid-template-columns: repeat(auto-fill, minmax(280px, 1fr))"
    >
      <div
        v-for="m in marks"
        :key="m.id"
        class="bg-card flex items-center gap-3 rounded-md border px-3 py-2 shadow-sm"
      >
        <Wifi v-if="m.online" class="h-5 w-5 text-green-500" />
        <WifiOff v-else class="h-5 w-5 text-gray-400" />
        <Label class="flex-1 truncate" :class="{ 'text-amber-300': !deviceNames.get(m.id) }">
          {{ deviceNames.get(m.id) || "未知设备" }}({{m.id}})
        </Label>
        <Badge variant="outline">{{ m.id }}</Badge>
        <!-- <Badge variant="secondary">{{ m.topic }}</Badge> -->
      </div>
    </div>
    <!-- 空数据提示 -->
    <p v-if="!marks.length" class="mt-4 text-center text-sm text-gray-400">暂无设备在线......</p>
  </ScrollArea>
</template>
<script setup lang="ts">
import type { MarkOnline } from "@/utils/mqtt";
import { Wifi, WifiOff } from "lucide-vue-next";
import { Badge } from "@/components/ui/badge";
import { Label } from "@/components/ui/label";
import { ScrollArea } from "@/components/ui/scroll-area";
defineProps<{
  marks: MarkOnline[];
  deviceNames: Map<string, string>;
}>();
</script>
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
  store.startMQTT();
});
onUnmounted(() => {
});
</script>
<!-- src/components/DeviceSelect.vue -->
<template>
  <Select v-model="modelValue">
    <SelectTrigger id="unnamed-select" class="w-[180px]">
      <SelectValue placeholder="请选择一个设备" />
    </SelectTrigger>
    <SelectContent>
      <!-- 正常选项 -->
      <SelectItem v-for="[id, name] in nameList" :key="id" :value="id">
        {{ name }}
      </SelectItem>
      <!-- 空数据提示 -->
      <SelectItem v-if="nameList.length === 0" disabled value="__empty"> 暂无设备 </SelectItem>
    </SelectContent>
  </Select>
</template>
<script setup lang="ts">
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { getAllDeviceIDToName } from "@/api/mark";
import { ref, computed, watchEffect } from "vue";
const props = defineProps<{
  modelValue?: string; 
}>();
const emit = defineEmits<{
  "update:modelValue": [id: string];
}>();
const selectedId = ref(props.modelValue);
watchEffect(() => (selectedId.value = props.modelValue)); 
const remoteMap = ref<Map<string, string>>(new Map());
async function load() {
  try {
    const res = await getAllDeviceIDToName();
    const record = res.data.data ?? {};
    remoteMap.value = new Map(Object.entries(record));
  } catch (e) {
    console.error("获取设备列表失败", e);
    remoteMap.value = new Map();
  }
}
load();
const nameList = computed(() => [...remoteMap.value]);
</script>
<!-- src/components/DeviceIDSelect.vue -->
<template>
  <Select v-model="selectedUnnamedId">
    <SelectTrigger id="unnamed-select" class="w-[180px]">
      <SelectValue placeholder="请选择一个未命名设备" />
    </SelectTrigger>
    <SelectContent>
      <!-- 如果没数据，给一句提示 -->
      <SelectItem v-for="id in store.unnamedIds" :key="id" :value="id">
        {{ id }}
        <Badge v-if="store.isDeviceOnline(id)" variant="outline" class="ml-2 text-xs"> 在线 </Badge>
        <Badge v-else variant="secondary" class="ml-2 text-xs"> 离线 </Badge>
      </SelectItem>
      <SelectItem v-if="store.unnamedIds.length === 0" disabled value="__empty">
        暂无未命名设备
      </SelectItem>
    </SelectContent>
  </Select>
</template>
<script setup lang="ts">
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { ref, watch } from "vue";
import { useMarksStore } from "@/stores/marks";
const store = useMarksStore();
const props = defineProps<{
  modelValue?: string; 
}>();
const emit = defineEmits<{
  "update:modelValue": [id: string | undefined];
}>();
const selectedUnnamedId = ref(props.modelValue);
watch(
  () => props.modelValue,
  (val) => (selectedUnnamedId.value = val),
);
watch(selectedUnnamedId, (val) => emit("update:modelValue", val));
</script>
<!-- src/views/About.vue -->
<template>
  <div class="flex flex-col bg-gradient-to-br">
    <div class="mx-auto w-full max-w-3xl flex-1 p-8">
      <h1 class="mb-2 text-4xl font-bold text-slate-900 dark:text-slate-100">关于项目</h1>
      <p class="mb-8 text-slate-600 dark:text-slate-400">基于现代化技术栈开发的全栈应用</p>
      <div class="space-y-4">
        <!-- 前端 -->
        <div
          class="rounded-xl border bg-white p-6 shadow-sm dark:border-slate-700 dark:bg-slate-800"
        >
          <h2 class="mb-3 text-lg font-semibold text-slate-900 dark:text-slate-100">前端技术栈</h2>
          <div class="flex flex-wrap gap-2">
            <span
              class="rounded-full bg-blue-100 px-3 py-1 text-sm text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
              >Vue 3</span
            >
            <span
              class="rounded-full bg-purple-100 px-3 py-1 text-sm text-purple-800 dark:bg-purple-900/30 dark:text-purple-300"
              >Vite</span
            >
            <span
              class="rounded-full bg-cyan-100 px-3 py-1 text-sm text-cyan-800 dark:bg-cyan-900/30 dark:text-cyan-300"
              >Tailwind CSS</span
            >
            <span
              class="rounded-full bg-indigo-100 px-3 py-1 text-sm text-indigo-800 dark:bg-indigo-900/30 dark:text-indigo-300"
              >shadcn-vue</span
            >
            <span
              class="rounded-full bg-slate-100 px-3 py-1 text-sm text-slate-800 dark:bg-slate-700 dark:text-slate-300"
              >Lucide</span
            >
          </div>
        </div>
        <!-- 后端 -->
        <div
          class="rounded-xl border bg-white p-6 shadow-sm dark:border-slate-700 dark:bg-slate-800"
        >
          <h2 class="mb-3 text-lg font-semibold text-slate-900 dark:text-slate-100">后端技术栈</h2>
          <div class="flex flex-wrap gap-2">
            <span
              class="rounded-full bg-green-100 px-3 py-1 text-sm text-green-800 dark:bg-green-900/30 dark:text-green-300"
              >Go</span
            >
            <span
              class="rounded-full bg-teal-100 px-3 py-1 text-sm text-teal-800 dark:bg-teal-900/30 dark:text-teal-300"
              >Gin</span
            >
            <span
              class="rounded-full bg-emerald-100 px-3 py-1 text-sm text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-300"
              >Fiber</span
            >
            <span
              class="rounded-full bg-amber-100 px-3 py-1 text-sm text-amber-800 dark:bg-amber-900/30 dark:text-amber-300"
              >GORM</span
            >
            <span
              class="rounded-full bg-blue-100 px-3 py-1 text-sm text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
              >PostgreSQL</span
            >
            <span
              class="rounded-full bg-green-100 px-3 py-1 text-sm text-green-800 dark:bg-green-900/30 dark:text-green-300"
              >MongoDB</span
            >
          </div>
        </div>
        <!-- 通信 & 基础设施 -->
        <div
          class="rounded-xl border bg-white p-6 shadow-sm dark:border-slate-700 dark:bg-slate-800"
        >
          <h2 class="mb-3 text-lg font-semibold text-slate-900 dark:text-slate-100">通信与部署</h2>
          <div class="flex flex-wrap gap-2">
            <span
              class="rounded-full bg-green-100 px-3 py-1 text-sm text-green-800 dark:bg-green-900/30 dark:text-green-300"
              >Nginx</span
            >
            <span
              class="rounded-full bg-orange-100 px-3 py-1 text-sm text-orange-800 dark:bg-orange-900/30 dark:text-orange-300"
              >MQTT</span
            >
            <span
              class="rounded-full bg-blue-100 px-3 py-1 text-sm text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
              >Mosquitto</span
            >
            <span
              class="rounded-full bg-sky-100 px-3 py-1 text-sm text-sky-800 dark:bg-sky-900/30 dark:text-sky-300"
              >Docker</span
            >
            <span
              class="rounded-full bg-blue-100 px-3 py-1 text-sm text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"
              >Docker Compose</span
            >
            <span
              class="rounded-full bg-red-100 px-3 py-1 text-sm text-red-800 dark:bg-red-900/30 dark:text-red-300"
              >Axios</span
            >
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import Autoplay from "embla-carousel-autoplay";
import { Carousel, CarouselContent, CarouselItem } from "@/components/ui/carousel";
const plugin = Autoplay({ delay: 2000, stopOnMouseEnter: true, stopOnInteraction: false });
</script>
<template>
  <!-- 全屏轮播 -->
  <Carousel
    class="h-full w-full"
    :opts="{ loop: true }"
    :plugins="[plugin]"
    @mouseenter="plugin.stop"
    @mouseleave="[plugin.reset(), plugin.play()]"
  >
    <CarouselContent class="h-[calc(100vh-3rem)]">
      <!-- 第 1 张 -->
      <CarouselItem class="relative h-full w-full">
        <div class="h-full w-full bg-[url('@/assets/imgs/home-map.png')] bg-cover bg-center">
          <div class="absolute inset-0 bg-black/10" />
          <div class="relative flex h-full items-center justify-center">
            <h1 class="text-background text-8xl font-bold">地图总览</h1>
          </div>
        </div>
      </CarouselItem>
      <!-- 第 2 张 -->
      <CarouselItem class="relative h-full w-full">
        <div class="h-full w-full bg-[url('@/assets/imgs/home-loc.png')] bg-no-repeat bg-center">
          <div class="absolute inset-0 bg-black/10" />
          <div class="relative flex h-full items-center justify-center">
            <h1 class="text-background text-8xl font-bold">定位平台</h1>
          </div>
        </div>
      </CarouselItem>
      <!-- <CarouselItem class="relative h-full w-full">
        <div class="h-full w-full bg-cover bg-center" style="background-image: url(/img/tags.jpg)">
          <div class="absolute inset-0 bg-black/30" />
          <div class="relative flex h-full items-center justify-center">
            <h1 class="text-5xl font-bold text-white">实时报警</h1>
          </div>
        </div>
      </CarouselItem> -->
    </CarouselContent>
  </Carousel>
</template>
<style lang="css" scoped>
:deep(.embla__container) {
  height: 100%;
}
</style>
<template>
  <div class="flex h-full w-full flex-col gap-4 p-4">
    <!-- 页面标题和显示控制 -->
    <Card>
      <CardHeader>
        <div class="flex items-center justify-between">
          <div>
            <CardTitle class="flex items-center gap-2">
              <Ruler class="h-5 w-5" />
              距离设置管理
            </CardTitle>
            <CardDescription>配置标记、分组和类型之间的安全距离</CardDescription>
          </div>
        </div>
      </CardHeader>
      <CardContent class="flex justify-between">
        <!-- 功能说明 -->
        <div class="flex items-start gap-3">
          <Info class="mt-0.5 h-5 w-5 flex-shrink-0 text-blue-500" />
          <div class="space-y-2">
            <h3 class="text-sm font-semibold">功能说明</h3>
            <div class="text-muted-foreground space-y-1 text-xs sm:text-sm">
              <p>• <strong>点对点距离设置</strong>：为两个特定标记设置安全距离</p>
              <p>• <strong>组合距离设置</strong>：为多个标记批量设置统一距离</p>
              <p>• <strong>组群距离设置</strong>：为两组不同类型的对象设置距离</p>
              <p>• <strong>距离列表</strong>：查看、编辑和删除已设置的标记对距离</p>
            </div>
          </div>
        </div>
        <!-- 显示控制 -->
        <div class="flex flex-col gap-3">
          <div class="flex items-center gap-2">
            <Eye class="text-muted-foreground h-4 w-4" />
            <span class="text-sm font-medium">显示设置</span>
          </div>
          <div class="flex flex-col gap-2">
            <Button
              v-for="option in displayOptions"
              :key="option.key"
              :variant="selectedDisplays.includes(option.key) ? 'default' : 'outline'"
              :size="'sm'"
              @click="toggleDisplay(option.key)"
              class="flex w-full items-center justify-start gap-2"
            >
              <component :is="option.icon" class="h-4 w-4" />
              {{ option.label }}
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
    <!-- 设置表单网格 -->
    <div
      v-if="
        hasSelectedDisplays &&
        (selectedDisplays.includes('pair') ||
          selectedDisplays.includes('combinations') ||
          selectedDisplays.includes('cartesian'))
      "
      class="grid grid-cols-1 gap-4 lg:grid-cols-[repeat(auto-fit,minmax(320px,1fr))] xl:grid-cols-[repeat(auto-fit,minmax(320px,1fr))]"
    >
      <!-- 点对点距离设置 -->
      <div v-if="selectedDisplays.includes('pair')" class="flex flex-col">
        <PairDistanceForm class="flex-1" />
      </div>
      <!-- 组合距离设置 -->
      <div v-if="selectedDisplays.includes('combinations')" class="flex flex-col">
        <CombinationsDistanceForm class="flex-1" />
      </div>
      <!-- 组群距离设置 -->
      <div
        v-if="selectedDisplays.includes('cartesian')"
        class="flex flex-col lg:col-span-2 xl:col-span-1"
      >
        <CartesianDistanceForm class="flex-1" />
      </div>
    </div>
    <!-- 距离列表 -->
    <div v-if="selectedDisplays.includes('pairs-list')" class="flex-1">
      <PairTablePager :limit="10" />
    </div>
    <!-- 空状态 -->
    <Card v-if="!hasSelectedDisplays" class="flex-1">
      <CardContent class="flex flex-col items-center justify-center py-12 text-center">
        <div class="bg-muted mb-4 flex h-16 w-16 items-center justify-center rounded-full">
          <EyeOff class="text-muted-foreground h-8 w-8" />
        </div>
        <h3 class="mb-2 text-lg font-semibold">未选择任何功能</h3>
        <p class="text-muted-foreground text-sm">请在上方选择要显示的距离设置功能</p>
      </CardContent>
    </Card>
  </div>
</template>
<script setup lang="ts">
import { ref, computed } from "vue";
import { Ruler, Info, Eye, EyeOff, Link2, Network, Grid3x3, Table } from "lucide-vue-next";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import PairDistanceForm from "@/components/distance/PairDistanceForm.vue";
import CombinationsDistanceForm from "@/components/distance/CombinationsDistanceForm.vue";
import CartesianDistanceForm from "@/components/distance/CartesianDistanceForm.vue";
import PairTablePager from "@/components/mark/PairTablePager.vue";
const displayOptions = [
  {
    key: "pair",
    label: "单对设置",
    icon: Link2,
  },
  {
    key: "combinations",
    label: "组合设置",
    icon: Network,
  },
  {
    key: "cartesian",
    label: "笛卡尔积",
    icon: Grid3x3,
  },
  {
    key: "pairs-list",
    label: "距离列表",
    icon: Table,
  },
];
const selectedDisplays = ref<string[]>(["pair", "cartesian", "pairs-list"]);
const hasSelectedDisplays = computed(() => selectedDisplays.value.length > 0);
const toggleDisplay = (key: string) => {
  const index = selectedDisplays.value.indexOf(key);
  if (index > -1) {
    selectedDisplays.value.splice(index, 1);
  } else {
    selectedDisplays.value.push(key);
  }
};
</script>
<template>
  <!-- 大屏：2×4 网格 -->
  <div class="hidden h-full auto-rows-max grid-cols-4 gap-2 p-4 md:grid">
    <Button v-for="i in 8" :key="i" @click="handleStart(i)">
      {{ i }}
    </Button>
  </div>
  <!-- 小屏：从上往下平均占满，间隔 5 -->
  <div class="flex h-lvh flex-col gap-5 p-4 md:hidden">
    <Button v-for="i in 4" :key="i" @click="handleStart(i)" class="w-full flex-1">
      {{ i }}
    </Button>
  </div>
</template>
<script setup lang="ts">
import { onMounted, onUnmounted } from "vue";
import { Button } from "@/components/ui/button";
import { startWarning } from "@/api/warning";
async function handleStart(deviceId: number) {
  try {
    await startWarning(deviceId);
    console.log(`设备 ${deviceId} 告警已开启`);
  } catch (e) {
    console.error(`设备 ${deviceId} 开启失败`, e);
  }
}
function onKeyDown(e: KeyboardEvent) {
  if (e.key >= "0" && e.key <= "9") {
    handleStart(Number(e.key));
  }
}
onMounted(() => window.addEventListener("keydown", onKeyDown));
onUnmounted(() => window.removeEventListener("keydown", onKeyDown));
</script>
<script setup lang="ts">
import UWBLiveScatter from "@/components/maps/UWBLiveScatter.vue";
</script>
<template>
  <div
    class="h-full w-full overflow-hidden rounded-sm border border-gray-300 p-1 backdrop-blur-2xl dark:border-gray-600"
  >
    <div class="h-full w-full overflow-hidden rounded-sm"><UWBLiveScatter /></div>
  </div>
</template>
<script setup lang="ts">
import { onMounted, onUnmounted, ref, watch } from "vue";
import { getLatestCustomMap } from "@/api/customMap";
import { listStations } from "@/api/station";
import { listIndoorFences, createPolygonFence, deletePolygonFence } from "@/api/polygonFence";
import type { CustomMapResp } from "@/types/customMap";
import type { StationResp } from "@/types/station";
import type { PolygonFenceResp, Point } from "@/types/polygonFence";
import { connectMQTT, disconnectMQTT, parseUWBMessage, type UWBFix } from "@/utils/mqtt";
import { useMarksStore } from "@/stores/marks";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { toast } from "vue-sonner";
import { Plus, Loader2, Trash2 } from "lucide-vue-next";
import MarkOnlineGrid from "@/components/device/MarkOnlineGrid.vue";
import {
  PixelScaler,
  drawCurrentPolygon,
  DoubleBufferCanvas,
  drawStaticLayerWithDoubleBuffer,
  drawDynamicLayerWithDoubleBuffer,
} from "@/utils/canvasDrawing";
const mapData = ref<CustomMapResp | null>(null);
const stations = ref<StationResp[]>([]);
const fences = ref<PolygonFenceResp[]>([]);
const marksStore = useMarksStore();
const deviceCoordinates = ref<Map<string, UWBFix>>(new Map());
const deviceDangerRadii = ref<Map<string, number>>(new Map());
const isDrawing = ref(false);
const currentPolygon = ref<Point[]>([]);
const fenceName = ref("");
const fenceDescription = ref("");
const isIndoor = ref(true); 
const isSaving = ref(false);
const showDeleteDialog = ref(false);
const fenceToDelete = ref<{ id: string; name: string } | null>(null);
const deletingFenceId = ref<string | null>(null);
async function drawStaticLayer() {
  return new Promise<void>((resolve) => {
    requestAnimationFrame(async () => {
      if (!staticDoubleBuffer) {
        resolve();
        return;
      }
      staticDoubleBuffer.resize();
      await drawStaticLayerWithDoubleBuffer(
        staticDoubleBuffer,
        mapData.value,
        stations.value,
        fences.value,
      );
      resolve();
    });
  });
}
async function drawDynamicLayer() {
  return new Promise<void>((resolve) => {
    requestAnimationFrame(async () => {
      if (!dynamicDoubleBuffer) {
        resolve();
        return;
      }
      dynamicDoubleBuffer.resize();
      await drawDynamicLayerWithDoubleBuffer(
        dynamicDoubleBuffer,
        mapData.value,
        deviceCoordinates.value,
        marksStore.markList,
        marksStore.deviceNames,
        currentPolygon.value,
        isDrawing.value,
      );
      resolve();
    });
  });
}
async function loadData() {
  try {
    console.log("开始加载数据...");
    const [mapRes, stationsRes, fencesRes] = await Promise.all([
      getLatestCustomMap(),
      listStations(),
      listIndoorFences(true), 
    ]);
    console.log("地图响应:", mapRes);
    console.log("基站响应:", stationsRes);
    console.log("围栏响应:", fencesRes);
    if (mapRes.data && mapRes.data.data) {
      mapData.value = mapRes.data.data;
      console.log("✅ 地图数据加载成功:", mapData.value);
    } else {
      console.error("❌ 地图数据加载失败:", mapRes.data?.message || mapRes);
    }
    if (stationsRes.data && stationsRes.data.data) {
      stations.value = stationsRes.data.data;
      console.log("✅ 基站数据加载成功，数量:", stations.value.length);
    } else {
      console.error("❌ 基站数据加载失败:", stationsRes.data?.message || stationsRes);
      stations.value = [];
    }
    if (fencesRes.data && fencesRes.data.data) {
      fences.value = fencesRes.data.data;
      console.log("✅ 围栏数据加载成功，数量:", fences.value.length);
    } else {
      console.error("❌ 围栏数据加载失败:", fencesRes.data?.message || fencesRes);
      fences.value = [];
    }
    console.log("准备绘制地图...");
    await drawStaticLayer();
    await drawDynamicLayer();
  } catch (error) {
    console.error("❌ 加载数据时发生错误:", error);
  }
}
function initLocationMQTT() {
  try {
    console.log("正在连接位置数据 MQTT...");
    const locationClient = connectMQTT();
    locationClient.on("connect", () => {
      console.log("✅ 位置数据 MQTT 连接成功");
      locationClient.subscribe("location/#", (err: any) => {
        if (err) {
          console.error("❌ 订阅位置数据主题失败:", err);
        } else {
          console.log("✅ 已订阅位置数据主题: location/#");
        }
      });
    });
    locationClient.on("message", (topic: string, payload: Buffer) => {
      try {
        console.log(`📨 收到位置 MQTT 消息: ${topic}`);
        console.log(`📦 消息内容:`, payload.toString());
        if (topic.startsWith("location/")) {
          try {
            const uwbData = parseUWBMessage(topic, payload);
            deviceCoordinates.value.set(uwbData.id, uwbData);
            console.log(`📍 设备 ${uwbData.id} UWB 坐标: (${uwbData.x}, ${uwbData.y})`);
            drawDynamicLayer();
          } catch (error) {
            console.log(`⚠️ 位置消息解析失败，可能是 RTK 数据: ${topic}`, error);
            console.log(`📦 原始消息内容:`, payload.toString());
          }
        } else {
          console.log(`❓ 未知位置主题: ${topic}`);
        }
      } catch (error) {
        console.error("❌ 处理位置 MQTT 消息失败:", error);
        console.log(`📦 原始消息内容:`, payload.toString());
      }
    });
    locationClient.on("error", (error: any) => {
      console.error("❌ 位置数据 MQTT 连接错误:", error);
    });
    locationClient.on("offline", () => {
      console.warn("⚠️ 位置数据 MQTT 连接离线");
    });
    return locationClient;
  } catch (error) {
    console.error("❌ 初始化位置数据 MQTT 失败:", error);
    return null;
  }
}
let locationMqttClient: any = null;
let staticDoubleBuffer: DoubleBufferCanvas | null = null;
let dynamicDoubleBuffer: DoubleBufferCanvas | null = null;
function handleCanvasClick(event: MouseEvent) {
  if (!isDrawing.value || !mapData.value) return;
  const canvas = event.target as HTMLCanvasElement;
  const rect = canvas.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;
  const px = event.clientX - rect.left;
  const py = event.clientY - rect.top;
  const scaler = new PixelScaler(
    rect.width,
    rect.height,
    mapData.value.x_min,
    mapData.value.x_max,
    mapData.value.y_min,
    mapData.value.y_max,
  );
  const { x, y } = scaler.toXY(px, py);
  currentPolygon.value.push({ x: Math.round(x), y: Math.round(y) });
  console.log("添加新点:", { x: Math.round(x), y: Math.round(y) });
  console.log("当前顶点数:", currentPolygon.value.length);
  drawDynamicLayer();
  setTimeout(() => {
    const pointsList = document.querySelector(".points-list-container");
    if (pointsList) {
      pointsList.scrollTop = pointsList.scrollHeight;
    }
  }, 100);
}
function startDrawing() {
  isDrawing.value = true;
  currentPolygon.value = [];
  fenceName.value = "";
  fenceDescription.value = "";
  isIndoor.value = true; 
}
function cancelDrawing() {
  isDrawing.value = false;
  currentPolygon.value = [];
  drawDynamicLayer();
}
function removePoint(index: number) {
  currentPolygon.value.splice(index, 1);
  drawDynamicLayer();
}
function updatePoint(index: number, axis: "x" | "y", value: string) {
  const numValue = parseFloat(value);
  if (!isNaN(numValue)) {
    currentPolygon.value[index][axis] = Math.round(numValue);
    console.log(`更新点 ${index + 1} 的 ${axis} 坐标为: ${Math.round(numValue)}`);
    drawDynamicLayer();
  }
}
function openDeleteDialog(fenceId: string, fenceName: string) {
  fenceToDelete.value = { id: fenceId, name: fenceName };
  showDeleteDialog.value = true;
}
async function confirmDeleteFence() {
  if (!fenceToDelete.value) return;
  const { id, name } = fenceToDelete.value;
  deletingFenceId.value = id;
  showDeleteDialog.value = false;
  try {
    const res = await deletePolygonFence(id);
    toast.success("删除成功", {
      description: `围栏"${name}"已被删除`,
    });
    const fencesRes = await listIndoorFences(true);
    if (fencesRes.data && fencesRes.data.data) {
      fences.value = fencesRes.data.data;
    }
    await drawStaticLayer();
    await drawDynamicLayer();
  } catch (error) {
    console.error("Error deleting fence:", error);
    toast.error("删除围栏时发生错误", {
      description: "请检查网络连接后重试",
    });
  } finally {
    deletingFenceId.value = null;
    fenceToDelete.value = null;
  }
}
async function finishDrawing() {
  if (currentPolygon.value.length < 3) {
    toast.error("多边形至少需要3个顶点", {
      description: "请在地图上继续添加更多顶点",
    });
    return;
  }
  if (!fenceName.value.trim()) {
    toast.error("请输入围栏名称", {
      description: "围栏名称是必填项",
    });
    return;
  }
  isSaving.value = true;
  try {
    const res = await createPolygonFence({
      is_indoor: isIndoor.value,
      fence_name: fenceName.value,
      points: currentPolygon.value,
      description: fenceDescription.value,
    });
    toast.success("围栏创建成功", {
      description: `围栏"${fenceName.value}"已成功创建`,
    });
    const fencesRes = await listIndoorFences(true);
    if (fencesRes.data && fencesRes.data.data) {
      fences.value = fencesRes.data.data;
    }
    await drawStaticLayer();
    await drawDynamicLayer();
    cancelDrawing();
  } catch (error) {
    console.error("Error creating fence:", error);
    toast.error("创建围栏时发生错误", {
      description: "请检查网络连接后重试",
    });
  } finally {
    isSaving.value = false;
  }
}
let resizeObserver: ResizeObserver | null = null;
onMounted(() => {
  console.log("Component mounted, loading data...");
  const baseCanvas = document.getElementById("uwb-map-canvas") as HTMLCanvasElement;
  if (baseCanvas) {
    staticDoubleBuffer = new DoubleBufferCanvas(baseCanvas);
    console.log("✅ 静态层双缓冲Canvas初始化成功");
  } else {
    console.error("❌ 无法找到静态层 Canvas 元素");
  }
  const animCanvas = document.getElementById("uwb-anim-canvas") as HTMLCanvasElement;
  if (animCanvas) {
    dynamicDoubleBuffer = new DoubleBufferCanvas(animCanvas);
    console.log("✅ 动态层双缓冲Canvas初始化成功");
  } else {
    console.error("❌ 无法找到动态层 Canvas 元素");
  }
  loadData();
  marksStore.startMQTT();
  locationMqttClient = initLocationMQTT();
  console.log("🔍 检查设备名称加载情况:");
  console.log("设备名称映射:", marksStore.deviceNames);
  console.log("设备名称映射大小:", marksStore.deviceNames.size);
  console.log("设备列表:", marksStore.markList);
  console.log("设备列表长度:", marksStore.markList.length);
  marksStore.markList.forEach((device) => {
    const name = marksStore.deviceNames.get(device.id);
    console.log(`设备 ${device.id}: 名称="${name}" (类型: ${typeof name})`);
  });
  watch(
    () => marksStore.deviceNames,
    (newDeviceNames) => {
      console.log("🔄 设备名称映射已更新:", newDeviceNames);
      console.log("设备名称映射大小:", newDeviceNames.size);
      marksStore.markList.forEach((device) => {
        const name = newDeviceNames.get(device.id);
        console.log(`设备 ${device.id}: 名称="${name}" (类型: ${typeof name})`);
      });
    },
    { deep: true },
  );
  window.addEventListener("resize", () => {
    drawStaticLayer();
    drawDynamicLayer();
  });
  const canvasElement = document.getElementById("uwb-map-canvas");
  if (canvasElement) {
    resizeObserver = new ResizeObserver(() => {
      console.log("Canvas size changed, redrawing static & dynamic layers...");
      requestAnimationFrame(() => {
        drawStaticLayer();
        drawDynamicLayer();
      });
    });
    resizeObserver.observe(canvasElement);
    const animElement = document.getElementById("uwb-anim-canvas");
    if (animElement) resizeObserver.observe(animElement);
  }
});
onUnmounted(() => {
  if (staticDoubleBuffer) {
    console.log("正在清理静态层双缓冲Canvas...");
    staticDoubleBuffer.destroy();
    staticDoubleBuffer = null;
    console.log("✅ 静态层双缓冲Canvas已清理");
  }
  if (dynamicDoubleBuffer) {
    console.log("正在清理动态层双缓冲Canvas...");
    dynamicDoubleBuffer.destroy();
    dynamicDoubleBuffer = null;
    console.log("✅ 动态层双缓冲Canvas已清理");
  }
  if (locationMqttClient) {
    console.log("正在断开位置数据 MQTT 连接...");
    disconnectMQTT(locationMqttClient);
    locationMqttClient = null;
    console.log("✅ 位置数据 MQTT 连接已断开");
  }
  if (resizeObserver) {
    resizeObserver.disconnect();
    resizeObserver = null;
  }
});
</script>
<template>
  <div class="h-[calc(100vh-3rem)] w-full bg-gray-50 p-4">
    <ResizablePanelGroup direction="horizontal" class="h-full rounded-lg border">
      <!-- 左侧：地图画布 -->
      <ResizablePanel :default-size="65" :min-size="30">
        <div class="relative h-full w-full">
          <!-- 背景层 -->
          <canvas
            id="uwb-map-canvas"
            class="absolute inset-0 h-full w-full rounded-lg border-2 border-gray-300 shadow-lg"
            :class="{ 'cursor-crosshair': isDrawing }"
            @click="handleCanvasClick"
          />
          <!-- 动画层 -->
          <canvas
            id="uwb-anim-canvas"
            class="absolute inset-0 h-full w-full rounded-lg border-2 border-gray-300 shadow-lg"
            :class="{ 'cursor-crosshair': isDrawing }"
            @click="handleCanvasClick"
          />
        </div>
      </ResizablePanel>
      <!-- 分隔条 -->
      <ResizableHandle with-handle />
      <!-- 右侧：控制面板 -->
      <ResizablePanel :default-size="35" :min-size="25">
        <Card class="h-full rounded-none border-0">
          <CardHeader>
            <CardTitle>电子围栏绘制</CardTitle>
          </CardHeader>
          <CardContent class="h-[calc(100%-80px)]">
            <ScrollArea class="h-full pr-4">
              <div class="space-y-4">
                <!-- 绘制控制 -->
                <div v-if="!isDrawing" class="space-y-2">
                  <Button class="w-full" @click="startDrawing">
                    <Plus class="mr-2 h-4 w-4" />
                    开始绘制围栏
                  </Button>
                  <p class="text-muted-foreground text-sm">
                    点击"开始绘制围栏"按钮，然后在地图上点击以添加多边形顶点
                  </p>
                </div>
                <!-- 绘制中 -->
                <div v-else class="space-y-4">
                  <div class="rounded-lg bg-orange-50 p-3 text-sm text-orange-800">
                    <p class="font-semibold">绘制模式已激活</p>
                    <p class="mt-1">点击地图添加顶点，至少需要3个顶点才能完成</p>
                  </div>
                  <!-- 围栏名称 -->
                  <div class="space-y-2">
                    <Label for="fence-name">围栏名称 *</Label>
                    <Input id="fence-name" v-model="fenceName" placeholder="例如：区域A" />
                  </div>
                  <!-- 围栏描述 -->
                  <div class="space-y-2">
                    <Label for="fence-description">描述（可选）</Label>
                    <Input
                      id="fence-description"
                      v-model="fenceDescription"
                      placeholder="围栏用途说明"
                    />
                  </div>
                  <!-- 顶点列表 -->
                  <div class="space-y-2">
                    <Label>多边形顶点 ({{ currentPolygon.length }}个)</Label>
                    <div v-if="currentPolygon.length === 0" class="text-muted-foreground text-sm">
                      暂无顶点，点击地图添加
                    </div>
                    <div v-else class="points-list-container max-h-96 space-y-2 overflow-y-auto">
                      <div
                        v-for="(point, index) in currentPolygon"
                        :key="`point-${index}-${point.x}-${point.y}`"
                        class="flex items-center gap-2 rounded-lg border bg-white p-2"
                      >
                        <span class="w-6 text-center font-semibold text-orange-600">
                          {{ index + 1 }}
                        </span>
                        <div class="flex flex-1 items-center gap-2">
                          <div class="flex flex-1 items-center gap-1">
                            <Label class="text-xs">X:</Label>
                            <Input
                              :model-value="point.x"
                              type="number"
                              class="h-8 flex-1 text-sm"
                              @update:model-value="(val) => updatePoint(index, 'x', String(val))"
                            />
                          </div>
                          <div class="flex flex-1 items-center gap-1">
                            <Label class="text-xs">Y:</Label>
                            <Input
                              :model-value="point.y"
                              type="number"
                              class="h-8 flex-1 text-sm"
                              @update:model-value="(val) => updatePoint(index, 'y', String(val))"
                            />
                          </div>
                        </div>
                        <Button variant="destructive" size="sm" @click="removePoint(index)">
                          删除
                        </Button>
                      </div>
                    </div>
                  </div>
                  <!-- 操作按钮 -->
                  <div class="flex gap-2">
                    <Button
                      class="flex-1"
                      variant="default"
                      :disabled="currentPolygon.length < 3 || !fenceName.trim() || isSaving"
                      @click="finishDrawing"
                    >
                      <Loader2 v-if="isSaving" class="mr-2 h-4 w-4 animate-spin" />
                      {{ isSaving ? "保存中..." : "完成并保存" }}
                    </Button>
                    <Button
                      class="flex-1"
                      variant="outline"
                      :disabled="isSaving"
                      @click="cancelDrawing"
                    >
                      取消
                    </Button>
                  </div>
                </div>
                <!-- UWB 设备状态 -->
                <div class="mt-4 space-y-2">
                  <Label>UWB 设备状态 ({{ marksStore.markList.length }}个)</Label>
                  <div class="h-48">
                    <MarkOnlineGrid
                      :marks="marksStore.markList"
                      :device-names="marksStore.deviceNames"
                    />
                  </div>
                </div>
                <!-- 已有围栏列表 -->
                <div class="mt-6 space-y-2">
                  <Label>已有围栏 ({{ fences.length }}个)</Label>
                  <div v-if="fences.length === 0" class="text-muted-foreground text-sm">
                    暂无围栏
                  </div>
                  <div v-else class="space-y-2">
                    <div
                      v-for="fence in fences"
                      :key="fence.id"
                      class="rounded-lg border bg-white p-3"
                    >
                      <div class="flex items-center justify-between gap-2">
                        <div class="flex-1">
                          <p class="font-semibold">{{ fence.fence_name }}</p>
                          <p class="text-muted-foreground text-xs">
                            {{ fence.points.length }} 个顶点
                            <span v-if="fence.is_indoor" class="text-green-600">· 室内</span>
                            <span v-else class="text-orange-600">· 室外</span>
                            <span v-if="fence.is_active" class="text-blue-600">· 已激活</span>
                            <span v-else class="text-gray-400">· 未激活</span>
                          </p>
                        </div>
                        <Button
                          variant="destructive"
                          size="sm"
                          :disabled="deletingFenceId === fence.id"
                          @click="openDeleteDialog(fence.id, fence.fence_name)"
                        >
                          <Loader2
                            v-if="deletingFenceId === fence.id"
                            class="mr-2 h-4 w-4 animate-spin"
                          />
                          <Trash2 v-else class="h-4 w-4" />
                          {{ deletingFenceId === fence.id ? "删除中..." : "删除" }}
                        </Button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </ScrollArea>
          </CardContent>
        </Card>
      </ResizablePanel>
    </ResizablePanelGroup>
    <!-- 删除确认对话框 -->
    <AlertDialog v-model:open="showDeleteDialog">
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>确定要删除这个围栏吗？</AlertDialogTitle>
          <AlertDialogDescription>
            此操作无法撤销。将永久删除围栏"{{ fenceToDelete?.name }}"及其所有数据。
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>取消</AlertDialogCancel>
          <AlertDialogAction
            class="bg-destructive hover:bg-destructive/90"
            @click="confirmDeleteFence"
          >
            删除
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { getMe } from "@/api/user";
import type { User } from "@/api/user";
import { UserRoundPen } from "lucide-vue-next";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
const user = ref<User | null>(null);
const loading = ref(true);
const router = useRouter();
async function fetchCurrentUser(): Promise<User | null> {
  try {
    const { data } = await getMe();
    return data.data || null; 
  } catch (err) {
    console.error("获取当前用户信息失败", err);
    router.replace("/login");
    return null;
  }
}
onMounted(async () => {
  user.value = await fetchCurrentUser();
  loading.value = false;
});
</script>
<template>
  <div class="flex h-full w-full items-center justify-center">
    <Card class="w-md">
      <CardHeader>
        <CardTitle class="text-2xl">你好！{{ user?.username }}</CardTitle>
        <CardDescription>点击下方可以修改用户信息</CardDescription>
      </CardHeader>
      <CardContent class="grid gap-4">
        <!-- 用户名 -->
        <div class="flex items-center justify-between gap-4">
          <Label class="text-lg"> ID </Label>
          <Skeleton v-if="loading" class="h-6 w-24" />
          <p v-else class="text-muted-foreground text-sm">{{ user?.id }}</p>
        </div>
        <div class="flex items-center justify-between gap-4">
          <Label class="text-lg"> 用户名 </Label><Skeleton v-if="loading" class="h-6 w-24" />
          <p v-else class="text-muted-foreground">{{ user?.username }}</p>
        </div>
        <!-- 用户类型 -->
        <div class="flex items-center justify-between gap-4">
          <Label class="text-lg"> 用户类型 </Label><Skeleton v-if="loading" class="h-6 w-24" />
          <p v-else class="text-muted-foreground">{{ user?.user_type }}</p>
        </div>
      </CardContent>
      <CardFooter>
        <Sheet>
          <SheetTrigger
            ><Button class="w-full">
              <UserRoundPen class="mr-2 h-4 w-4" /> 修改
            </Button></SheetTrigger
          >
          <SheetContent side="bottom">
            <SheetHeader>
              <SheetTitle>修改用户信息</SheetTitle>
              <SheetDescription> 在这里修改你的信息，为空则不修改 </SheetDescription>
            </SheetHeader>
            <div class="flex h-full w-full items-center justify-center">
              <div class="flex flex-col gap-4 py-4 md:w-1/2">
                <!-- 用户名 -->
                <div class="flex items-center gap-4">
                  <Label for="username" class="w-20 shrink-0 text-right">用户名</Label>
                  <Input id="username" class="flex-1" type="text" placeholder="请输入新用户名" />
                </div>
                <!-- 密码 -->
                <div class="flex items-center gap-4">
                  <Label for="password" class="w-20 shrink-0 text-right">密码</Label>
                  <Input id="password" class="flex-1" type="password" placeholder="请输入新密码" />
                </div>
                <div class="flex items-center gap-4">
                  <Label for="password_check" class="w-20 shrink-0 text-right">确认密码</Label>
                  <Input
                    id="password_check"
                    class="flex-1"
                    type="password"
                    placeholder="请确认新密码"
                  />
                </div>
              </div>
            </div>
            <SheetFooter>
              <SheetClose as-child class="flex flex-row-reverse items-center justify-start">
                <Button type="submit" class="m-2.5"> 保存修改 </Button>
              </SheetClose>
            </SheetFooter>
          </SheetContent>
        </Sheet>
      </CardFooter>
    </Card>
  </div>
</template>
<template>
  <div class="flex h-full w-full flex-col gap-4 p-4">
    <!-- 类型信息卡片 -->
    <TypeInfoCard :typeInfo="typeData" @updated="loadTypeData" />
    <!-- 标记列表 -->
    <MarkTablePager :fetcher="fetchByType" />
  </div>
</template>
<script setup lang="ts">
import { computed, ref, onMounted } from "vue";
import { useRoute } from "vue-router";
import { getMarksByTypeID, getMarkTypeByID } from "@/api/mark/type";
import MarkTablePager from "@/components/mark/MarkTablePager.vue";
import TypeInfoCard from "@/components/mark/TypeInfoCard.vue";
import type { MarkTypeResponse } from "@/types/mark";
const route = useRoute();
const typeId = computed(() => {
  const raw = route.params.typeId;
  const id = Array.isArray(raw) ? raw[0] : raw;
  return Number(id) || 0; 
});
const fetchByType = (p: any) => getMarksByTypeID(typeId.value, p);
const typeData = ref<MarkTypeResponse>({
  id: 1,
  type_name: "警示标志",
  default_danger_zone_m: 5.0,
});
async function loadTypeData() {
  try {
    const res = await getMarkTypeByID(typeId.value);
    if (res.data?.data) {
      typeData.value = res.data.data;
    }
  } catch {
  } finally {
  }
}
onMounted(async () => {
  await loadTypeData();
});
</script>
<template>
  <div class="flex h-full w-full flex-col gap-4 p-4">
    <!-- 标题卡片 -->
    <Card>
      <CardHeader>
        <div class="flex items-center justify-between">
          <div>
            <CardTitle class="flex items-center gap-2">
              <Hash class="h-5 w-5" />
              所有分组
            </CardTitle>
            <CardDescription>查看和管理所有分组的详细信息</CardDescription>
          </div>
        </div>
      </CardHeader>
    </Card>
    <!-- 分组列表 -->
    <TagTablePager :fetcher="listMarkTags" />
  </div>
</template>
<script setup lang="ts">
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Hash } from "lucide-vue-next";
import TagTablePager from "@/components/mark/TagTablePager.vue";
import { listMarkTags } from "@/api/mark/tag";
</script>
<template>
  <div class="flex h-full w-full flex-col gap-4 p-4">
    <!-- 分组信息卡片 -->
    <TagInfoCard :tagInfo="tagData" @updated="loadTagData" />
    <!-- 标记列表 -->
    <MarkTablePager :fetcher="fetchByTag" />
  </div>
</template>
<script setup lang="ts">
import { computed, ref, onMounted } from "vue";
import { useRoute } from "vue-router";
import { getMarksByTagID, getMarkTagByID } from "@/api/mark/tag";
import MarkTablePager from "@/components/mark/MarkTablePager.vue";
import TagInfoCard from "@/components/mark/TagInfoCard.vue";
import type { MarkTagResponse } from "@/types/mark";
const route = useRoute();
const tagId = computed(() => {
  const raw = route.params.tagId;
  const id = Array.isArray(raw) ? raw[0] : raw;
  return Number(id) || 0; 
});
const fetchByTag = (p: any) => getMarksByTagID(tagId.value, p);
const tagData = ref<MarkTagResponse>({
  id: 1,
  tag_name: "示例分组",
});
async function loadTagData() {
  try {
    const res = await getMarkTagByID(tagId.value);
    if (res.data?.data) {
      tagData.value = res.data.data;
    }
  } catch {
  } finally {
  }
}
onMounted(async () => {
  await loadTagData();
});
</script>
<template>
  <div class="h-full w-full">
    <StationManagePanel />
  </div>
</template>
<script setup lang="ts">
import StationManagePanel from "@/components/station/StationManagePanel.vue";
</script>
<!-- src/views/RTKMapView.vue -->
<script setup lang="ts">
import { ref, onMounted } from "vue";
import NewMap from "@/components/maps/RealtimeMap.vue";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
import { listOutdoorFences, createPolygonFence, deletePolygonFence } from "@/api/polygonFence";
import type { PolygonFenceResp, Point } from "@/types/polygonFence";
import { toast } from "vue-sonner";
const mapRef = ref<InstanceType<typeof NewMap> | null>(null);
const fences = ref<PolygonFenceResp[]>([]);
const isDrawing = ref(false);
const currentPolygon = ref<Point[]>([]);
const fenceName = ref("");
const fenceDescription = ref("");
const isSaving = ref(false);
const deletingFenceId = ref<string | null>(null);
async function loadOutdoorFences() {
  const res = await listOutdoorFences(true);
  if (res.data && res.data.data) {
    fences.value = res.data.data;
    mapRef.value?.setOutdoorFences(fences.value);
  } else {
    fences.value = [];
  }
}
function startDrawing() {
  isDrawing.value = true;
  currentPolygon.value = [];
  fenceName.value = "";
  fenceDescription.value = "";
  mapRef.value?.startPolygonDrawing();
}
function cancelDrawing() {
  isDrawing.value = false;
  currentPolygon.value = [];
  mapRef.value?.cancelDrawing();
}
function onPolygonDrawn(points: { x: number; y: number }[]) {
  isDrawing.value = true;
  currentPolygon.value = points.map((p) => ({ x: p.x, y: p.y }));
}
async function finishDrawing() {
  if (currentPolygon.value.length < 3) {
    toast.error("多边形至少需要3个顶点");
    return;
  }
  if (!fenceName.value.trim()) {
    toast.error("请输入围栏名称");
    return;
  }
  isSaving.value = true;
  try {
    await createPolygonFence({
      is_indoor: false,
      fence_name: fenceName.value,
      points: currentPolygon.value,
      description: fenceDescription.value,
    });
    toast.success("围栏创建成功");
    await loadOutdoorFences();
    cancelDrawing();
  } catch (e) {
    toast.error("创建围栏失败");
  } finally {
    isSaving.value = false;
  }
}
async function removeFence(id: string) {
  deletingFenceId.value = id;
  try {
    await deletePolygonFence(id);
    toast.success("删除成功");
    await loadOutdoorFences();
  } catch (e) {
    toast.error("删除失败");
  } finally {
    deletingFenceId.value = null;
  }
}
onMounted(() => {
  loadOutdoorFences();
});
</script>
<template>
  <div class="h-[calc(100vh-3rem)] w-full bg-gray-50 p-4">
    <ResizablePanelGroup direction="horizontal" class="h-full rounded-lg border">
      <ResizablePanel :default-size="65" :min-size="30">
        <div class="relative h-full w-full">
          <NewMap ref="mapRef" @polygon-drawn="onPolygonDrawn" />
        </div>
      </ResizablePanel>
      <ResizableHandle with-handle />
      <ResizablePanel :default-size="35" :min-size="25">
        <Card class="h-full rounded-none border-0">
          <CardHeader>
            <CardTitle>室外电子围栏</CardTitle>
          </CardHeader>
          <CardContent class="h-[calc(100%-80px)]">
            <ScrollArea class="h-full pr-4">
              <div class="space-y-4">
                <div v-if="!isDrawing" class="space-y-2">
                  <Button class="w-full" @click="startDrawing">开始绘制围栏</Button>
                  <p class="text-muted-foreground text-sm">在地图上点击绘制多边形</p>
                </div>
                <div v-else class="space-y-4">
                  <div class="rounded-lg bg-blue-50 p-3 text-sm text-blue-800">
                    <p class="font-semibold">绘制模式已激活</p>
                    <p class="mt-1">完成鼠标绘制后可编辑名称并保存</p>
                  </div>
                  <div class="space-y-2">
                    <Label for="fence-name">围栏名称 *</Label>
                    <Input id="fence-name" v-model="fenceName" placeholder="例如：室外区域A" />
                  </div>
                  <div class="space-y-2">
                    <Label for="fence-description">描述（可选）</Label>
                    <Input
                      id="fence-description"
                      v-model="fenceDescription"
                      placeholder="围栏用途说明"
                    />
                  </div>
                  <div class="space-y-2">
                    <Label>顶点 ({{ currentPolygon.length }} 个)</Label>
                    <div v-if="currentPolygon.length === 0" class="text-muted-foreground text-sm">
                      暂无顶点
                    </div>
                    <div v-else class="max-h-72 space-y-2 overflow-y-auto">
                      <div
                        v-for="(pt, idx) in currentPolygon"
                        :key="`pt-${idx}-${pt.x}-${pt.y}`"
                        class="flex items-center gap-3 rounded border bg-white p-2"
                      >
                        <span class="w-6 text-center text-blue-600">{{ idx + 1 }}</span>
                        <div class="flex gap-2 text-sm">
                          <span>X: {{ pt.x }}</span>
                          <span>Y: {{ pt.y }}</span>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="flex gap-2">
                    <Button
                      class="flex-1"
                      :disabled="currentPolygon.length < 3 || !fenceName.trim() || isSaving"
                      @click="finishDrawing"
                    >
                      {{ isSaving ? "保存中..." : "完成并保存" }}
                    </Button>
                    <Button
                      class="flex-1"
                      variant="outline"
                      :disabled="isSaving"
                      @click="cancelDrawing"
                      >取消</Button
                    >
                  </div>
                </div>
                <div class="mt-4 space-y-2">
                  <Label>已有室外围栏 ({{ fences.length }} 个)</Label>
                  <div v-if="fences.length === 0" class="text-muted-foreground text-sm">
                    暂无围栏
                  </div>
                  <div v-else class="space-y-2">
                    <div v-for="f in fences" :key="f.id" class="rounded-lg border bg-white p-3">
                      <div class="flex items-center justify-between gap-2">
                        <div class="flex-1">
                          <p class="font-semibold">{{ f.fence_name }}</p>
                          <p class="text-muted-foreground text-xs">
                            {{ f.points.length }} 个顶点
                            <span class="text-orange-600">· 室外</span>
                            <span v-if="f.is_active" class="text-blue-600">· 已激活</span>
                            <span v-else class="text-gray-400">· 未激活</span>
                          </p>
                        </div>
                        <Button
                          variant="destructive"
                          size="sm"
                          :disabled="deletingFenceId === f.id"
                          @click="removeFence(f.id)"
                        >
                          {{ deletingFenceId === f.id ? "删除中..." : "删除" }}
                        </Button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </ScrollArea>
          </CardContent>
        </Card>
      </ResizablePanel>
    </ResizablePanelGroup>
  </div>
</template>
<template>
  <div class="h-[calc(100vh-3rem)] p-4">
    <!-- 移动端垂直布局 -->
    <div class="flex h-full w-full flex-col gap-2 md:hidden">
      <div class="flex-1">
        <MarksOnline />
      </div>
      <div class="flex-1">
        <TypeGrid />
      </div>
      <div class="flex-1">
        <TagGrid />
      </div>
    </div>
    <!-- 桌面端可调节布局 -->
    <ResizablePanelGroup direction="horizontal" class="hidden h-full w-full gap-2 md:flex">
      <ResizablePanel>
        <MarksOnline />
      </ResizablePanel>
      <ResizableHandle with-handle />
      <ResizablePanel>
        <ResizablePanelGroup direction="vertical" class="h-full w-full gap-2">
          <ResizablePanel>
            <TypeGrid />
          </ResizablePanel>
          <ResizableHandle with-handle />
          <ResizablePanel>
            <TagGrid />
          </ResizablePanel>
        </ResizablePanelGroup>
      </ResizablePanel>
    </ResizablePanelGroup>
  </div>
</template>
<script setup lang="ts">
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
import MarksOnline from "@/components/device/MarkOnline.vue";
import TypeGrid from "@/components/type/TypeGrid.vue";
import TagGrid from "@/components/tag/TagGrid.vue";
</script>
<template>
  <div class="h-full w-full">
    <MarkManagePanel />
  </div>
</template>
<script setup lang="ts">
import MarkManagePanel from "@/components/mark/MarkManagePanel.vue";
</script>
<template>
  <div class="h-[calc(100vh-3rem)]">
    <!-- 动态方向：>=768px 时水平，<768px 时垂直 -->
    <ResizablePanelGroup :direction="isMobile ? 'vertical' : 'horizontal'" class="h-full w-full">
      <ResizablePanel>
        <RealtimeMap />
      </ResizablePanel>
      <!-- 手机端隐藏拖拽条，更清爽 -->
      <ResizableHandle v-if="!isMobile" with-handle />
      <ResizablePanel>
        <UWBLiveScatter />
      </ResizablePanel>
    </ResizablePanelGroup>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount } from "vue";
import { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "@/components/ui/resizable";
import UWBLiveScatter from "@/components/maps/UWBLiveScatter.vue";
import RealtimeMap from "@/components/maps/RealtimeMap.vue";
const isMobile = ref(false); 
function checkMobile() {
  isMobile.value = window.matchMedia("(max-width: 767px)").matches;
}
let mql: MediaQueryList;
onMounted(() => {
  mql = window.matchMedia("(max-width: 767px)");
  checkMobile();
  mql.addEventListener("change", checkMobile); 
});
onBeforeUnmount(() => {
  mql.removeEventListener("change", checkMobile);
});
</script>
<!-- src/views/MapSettingsView.vue -->
<script setup lang="ts">
import { ref, reactive, onMounted, computed } from "vue";
import { required, helpers } from "@vuelidate/validators";
import useVuelidate from "@vuelidate/core";
import { toast } from "vue-sonner";
import { Plus, Pen, Trash, Map, Image as ImageIcon, Eye } from "lucide-vue-next";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { ScrollArea } from "@/components/ui/scroll-area";
import { customMapApi } from "@/api";
import type { CustomMapResp, CustomMapCreateReq, CustomMapUpdateReq } from "@/types/customMap";
import { useRouter } from 'vue-router';
const router = useRouter();
interface FormState {
  map_name: string;
  image_base64?: string;
  image_ext?: ".jpg" | ".jpeg" | ".png" | ".gif" | ".webp";
  x_min: number | string;
  x_max: number | string;
  y_min: number | string;
  y_max: number | string;
  center_x: number | string;
  center_y: number | string;
  scale_ratio: number | string;
  description?: string;
}
const customMaps = ref<CustomMapResp[]>([]);
const loading = ref(false);
async function loadCustomMaps() {
  loading.value = true;
  try {
    const response = await customMapApi.listCustomMaps();
    customMaps.value = response.data.data || [];
  } catch (e: any) {
    if (!e._handled) {
      toast.error("加载地图列表失败", {
        description: e.response?.data?.message || e.message,
      });
    }
  } finally {
    loading.value = false;
  }
}
onMounted(() => {
  loadCustomMaps();
});
function getImageExtension(filename: string): ".jpg" | ".jpeg" | ".png" | ".gif" | ".webp" {
  const ext = filename.toLowerCase().split(".").pop() || "";
  const extMap: Record<string, ".jpg" | ".jpeg" | ".png" | ".gif" | ".webp"> = {
    jpg: ".jpg",
    jpeg: ".jpeg",
    png: ".png",
    gif: ".gif",
    webp: ".webp",
  };
  return extMap[ext] || ".png";
}
function handleImageUpload(event: Event, form: FormState) {
  const input = event.target as HTMLInputElement;
  const file = input.files?.[0];
  if (!file) return;
  const allowedTypes = ["image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp"];
  if (!allowedTypes.includes(file.type)) {
    toast.error("不支持的图片格式", {
      description: "请上传 JPG, JPEG, PNG, GIF 或 WEBP 格式的图片",
    });
    return;
  }
  const maxSize = 5 * 1024 * 1024; 
  if (file.size > maxSize) {
    toast.error("图片文件过大", {
      description: "请上传小于 5MB 的图片",
    });
    return;
  }
  const reader = new FileReader();
  reader.onload = (e) => {
    const base64 = e.target?.result as string;
    const base64Data = base64.split(",")[1];
    form.image_base64 = base64Data;
    form.image_ext = getImageExtension(file.name);
    toast.success("图片上传成功");
  };
  reader.onerror = () => {
    toast.error("图片读取失败");
  };
  reader.readAsDataURL(file);
}
const createDialogOpen = ref(false);
const createFormInitial: FormState = {
  map_name: "",
  image_base64: undefined,
  image_ext: undefined,
  x_min: 0,
  x_max: 100,
  y_min: 0,
  y_max: 100,
  center_x: 50,
  center_y: 50,
  scale_ratio: 1.0,
  description: "",
};
const createForm = reactive<FormState>({ ...createFormInitial });
const isValidNumber = (value: any) => {
  if (value === undefined || value === null) return false;
  if (value === 0 || value === "0") return true;
  if (value === "" || (typeof value === "string" && value.trim() === "")) return false;
  const num = Number(value);
  return !isNaN(num) && isFinite(num);
};
const createRules = {
  map_name: { required: helpers.withMessage("请输入地图名称", required) },
  x_min: { isValidNumber: helpers.withMessage("请输入有效的X最小值", isValidNumber) },
  x_max: { isValidNumber: helpers.withMessage("请输入有效的X最大值", isValidNumber) },
  y_min: { isValidNumber: helpers.withMessage("请输入有效的Y最小值", isValidNumber) },
  y_max: { isValidNumber: helpers.withMessage("请输入有效的Y最大值", isValidNumber) },
  center_x: { isValidNumber: helpers.withMessage("请输入有效的中心X坐标", isValidNumber) },
  center_y: { isValidNumber: helpers.withMessage("请输入有效的中心Y坐标", isValidNumber) },
  scale_ratio: { isValidNumber: helpers.withMessage("请输入有效的缩放比例", isValidNumber) },
};
const createV$ = useVuelidate(createRules, createForm);
const isCreating = ref(false);
const createImagePreview = computed(() => {
  if (createForm.image_base64) {
    return `data:image/${createForm.image_ext?.replace(".", "")};base64,${createForm.image_base64}`;
  }
  return null;
});
async function handleCreate() {
  const valid = await createV$.value.$validate();
  if (!valid) {
    toast.error("请填写完整的表单信息");
    return;
  }
  if (isCreating.value) return;
  isCreating.value = true;
  try {
    const data: CustomMapCreateReq = {
      map_name: createForm.map_name,
      image_base64: createForm.image_base64,
      image_ext: createForm.image_ext,
      x_min: Number(createForm.x_min),
      x_max: Number(createForm.x_max),
      y_min: Number(createForm.y_min),
      y_max: Number(createForm.y_max),
      center_x: Number(createForm.center_x),
      center_y: Number(createForm.center_y),
      scale_ratio: Number(createForm.scale_ratio),
      description: createForm.description || undefined,
    };
    await customMapApi.createCustomMap(data);
    toast.success("地图创建成功");
    createDialogOpen.value = false;
    Object.assign(createForm, createFormInitial);
    createV$.value.$reset();
    router.push("/map/settings/fence")
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "创建失败";
      toast.error("创建地图失败", { description: errorMsg });
    }
  } finally {
    isCreating.value = false;
  }
}
const editDialogOpen = ref(false);
const editingMap = ref<CustomMapResp | null>(null);
const editForm = reactive<FormState>({
  map_name: "",
  image_base64: undefined,
  image_ext: undefined,
  x_min: "",
  x_max: "",
  y_min: "",
  y_max: "",
  center_x: "",
  center_y: "",
  scale_ratio: "",
  description: "",
});
const editRules = {
  map_name: { required: helpers.withMessage("请输入地图名称", required) },
  x_min: { isValidNumber: helpers.withMessage("请输入有效的X最小值", isValidNumber) },
  x_max: { isValidNumber: helpers.withMessage("请输入有效的X最大值", isValidNumber) },
  y_min: { isValidNumber: helpers.withMessage("请输入有效的Y最小值", isValidNumber) },
  y_max: { isValidNumber: helpers.withMessage("请输入有效的Y最大值", isValidNumber) },
  center_x: { isValidNumber: helpers.withMessage("请输入有效的中心X坐标", isValidNumber) },
  center_y: { isValidNumber: helpers.withMessage("请输入有效的中心Y坐标", isValidNumber) },
  scale_ratio: { isValidNumber: helpers.withMessage("请输入有效的缩放比例", isValidNumber) },
};
const editV$ = useVuelidate(editRules, editForm);
const isUpdating = ref(false);
const editImagePreview = computed(() => {
  if (editForm.image_base64) {
    return `data:image/${editForm.image_ext?.replace(".", "")};base64,${editForm.image_base64}`;
  }
  if (editingMap.value?.image_url) {
    return editingMap.value.image_url;
  }
  return null;
});
function openEditDialog(map: CustomMapResp) {
  editingMap.value = map;
  editForm.map_name = map.map_name;
  editForm.x_min = map.x_min;
  editForm.x_max = map.x_max;
  editForm.y_min = map.y_min;
  editForm.y_max = map.y_max;
  editForm.center_x = map.center_x;
  editForm.center_y = map.center_y;
  editForm.scale_ratio = map.scale_ratio;
  editForm.description = map.description;
  editForm.image_base64 = undefined;
  editForm.image_ext = undefined;
  editV$.value.$reset();
  editDialogOpen.value = true;
}
async function handleUpdate() {
  const valid = await editV$.value.$validate();
  if (!valid) {
    toast.error("请填写完整的表单信息");
    return;
  }
  if (!editingMap.value || isUpdating.value) return;
  isUpdating.value = true;
  try {
    const data: CustomMapUpdateReq = {
      map_name: editForm.map_name,
      x_min: Number(editForm.x_min),
      x_max: Number(editForm.x_max),
      y_min: Number(editForm.y_min),
      y_max: Number(editForm.y_max),
      center_x: Number(editForm.center_x),
      center_y: Number(editForm.center_y),
      scale_ratio: Number(editForm.scale_ratio),
      description: editForm.description || undefined,
    };
    if (editForm.image_base64) {
      data.image_base64 = editForm.image_base64;
      data.image_ext = editForm.image_ext;
    }
    await customMapApi.updateCustomMap(editingMap.value.id, data);
    toast.success("地图更新成功");
    editDialogOpen.value = false;
    router.push("/map/settings/fence")
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "更新失败";
      toast.error("更新地图失败", { description: errorMsg });
    }
  } finally {
    isUpdating.value = false;
  }
}
const isDeleting = ref<Record<string, boolean>>({});
async function handleDelete(id: string) {
  if (isDeleting.value[id]) return;
  isDeleting.value[id] = true;
  try {
    await customMapApi.deleteCustomMap(id);
    toast.success("地图删除成功");
    await loadCustomMaps();
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "删除失败";
      toast.error("删除地图失败", { description: errorMsg });
    }
  } finally {
    isDeleting.value[id] = false;
  }
}
const previewDialogOpen = ref(false);
const previewMap = ref<CustomMapResp | null>(null);
function openPreviewDialog(map: CustomMapResp) {
  previewMap.value = map;
  previewDialogOpen.value = true;
}
</script>
<template>
  <div class="flex h-full w-full flex-col gap-4 p-4">
    <!-- 标题和创建按钮 -->
    <Card>
      <CardHeader>
        <div class="flex items-center justify-between">
          <div>
            <CardTitle class="flex items-center gap-2">
              <Map class="h-5 w-5" />
              地图管理
            </CardTitle>
            <CardDescription>管理自定义地图配置</CardDescription>
          </div>
          <!-- 创建地图对话框 -->
          <Dialog v-model:open="createDialogOpen">
            <DialogTrigger as-child>
              <Button>
                <Plus class="mr-2 h-4 w-4" />
                新建地图
              </Button>
            </DialogTrigger>
            <DialogContent class="sm:max-w-[600px]">
              <DialogHeader>
                <DialogTitle>新建地图</DialogTitle>
                <DialogDescription>填写地图配置信息并上传地图图片</DialogDescription>
              </DialogHeader>
              <form @submit.prevent="handleCreate">
                <ScrollArea class="max-h-[calc(100vh-16rem)]">
                  <div class="space-y-4 px-1 py-4">
                    <!-- 地图名称 -->
                    <div class="flex flex-col gap-2">
                      <Label for="createMapName">地图名称</Label>
                      <Input
                        id="createMapName"
                        v-model="createForm.map_name"
                        placeholder="例如：一楼平面图"
                        :class="{ 'border-destructive': createV$.map_name.$error }"
                      />
                      <span v-if="createV$.map_name.$error" class="text-destructive text-sm">
                        {{ createV$.map_name.$errors[0].$message }}
                      </span>
                    </div>
                    <!-- 地图描述 -->
                    <div class="flex flex-col gap-2">
                      <Label for="createDescription">描述（可选）</Label>
                      <Textarea
                        id="createDescription"
                        v-model="createForm.description"
                        placeholder="地图描述..."
                        rows="2"
                      />
                    </div>
                    <!-- 图片上传 -->
                    <div class="flex flex-col gap-2">
                      <Label for="createImage">地图图片（可选）</Label>
                      <Input
                        id="createImage"
                        type="file"
                        accept="image/jpeg,image/jpg,image/png,image/gif,image/webp"
                        @change="(e: Event) => handleImageUpload(e, createForm)"
                      />
                      <span class="text-muted-foreground text-xs">
                        支持 JPG, PNG, GIF, WEBP 格式，最大 5MB
                      </span>
                      <!-- 图片预览 -->
                      <div v-if="createImagePreview" class="mt-2">
                        <img
                          :src="createImagePreview"
                          alt="预览"
                          class="max-h-40 rounded border object-contain"
                        />
                      </div>
                    </div>
                    <!-- 坐标范围 -->
                    <div class="grid grid-cols-2 gap-4">
                      <div class="flex flex-col gap-2">
                        <Label for="createXMin">X 最小值</Label>
                        <Input
                          id="createXMin"
                          v-model="createForm.x_min"
                          type="number"
                          step="0.01"
                          placeholder="0"
                          :class="{ 'border-destructive': createV$.x_min.$error }"
                        />
                        <span v-if="createV$.x_min.$error" class="text-destructive text-sm">
                          {{ createV$.x_min.$errors[0].$message }}
                        </span>
                      </div>
                      <div class="flex flex-col gap-2">
                        <Label for="createXMax">X 最大值</Label>
                        <Input
                          id="createXMax"
                          v-model="createForm.x_max"
                          type="number"
                          step="0.01"
                          placeholder="100"
                          :class="{ 'border-destructive': createV$.x_max.$error }"
                        />
                        <span v-if="createV$.x_max.$error" class="text-destructive text-sm">
                          {{ createV$.x_max.$errors[0].$message }}
                        </span>
                      </div>
                      <div class="flex flex-col gap-2">
                        <Label for="createYMin">Y 最小值</Label>
                        <Input
                          id="createYMin"
                          v-model="createForm.y_min"
                          type="number"
                          step="0.01"
                          placeholder="0"
                          :class="{ 'border-destructive': createV$.y_min.$error }"
                        />
                        <span v-if="createV$.y_min.$error" class="text-destructive text-sm">
                          {{ createV$.y_min.$errors[0].$message }}
                        </span>
                      </div>
                      <div class="flex flex-col gap-2">
                        <Label for="createYMax">Y 最大值</Label>
                        <Input
                          id="createYMax"
                          v-model="createForm.y_max"
                          type="number"
                          step="0.01"
                          placeholder="100"
                          :class="{ 'border-destructive': createV$.y_max.$error }"
                        />
                        <span v-if="createV$.y_max.$error" class="text-destructive text-sm">
                          {{ createV$.y_max.$errors[0].$message }}
                        </span>
                      </div>
                    </div>
                    <!-- 中心点坐标 -->
                    <div class="grid grid-cols-2 gap-4">
                      <div class="flex flex-col gap-2">
                        <Label for="createCenterX">中心 X 坐标</Label>
                        <Input
                          id="createCenterX"
                          v-model="createForm.center_x"
                          type="number"
                          step="0.01"
                          placeholder="50"
                          :class="{ 'border-destructive': createV$.center_x.$error }"
                        />
                        <span v-if="createV$.center_x.$error" class="text-destructive text-sm">
                          {{ createV$.center_x.$errors[0].$message }}
                        </span>
                      </div>
                      <div class="flex flex-col gap-2">
                        <Label for="createCenterY">中心 Y 坐标</Label>
                        <Input
                          id="createCenterY"
                          v-model="createForm.center_y"
                          type="number"
                          step="0.01"
                          placeholder="50"
                          :class="{ 'border-destructive': createV$.center_y.$error }"
                        />
                        <span v-if="createV$.center_y.$error" class="text-destructive text-sm">
                          {{ createV$.center_y.$errors[0].$message }}
                        </span>
                      </div>
                    </div>
                    <!-- 缩放比例 -->
                    <!-- <div class="flex flex-col gap-2">
                      <Label for="createScaleRatio">缩放比例</Label>
                      <Input
                        id="createScaleRatio"
                        v-model="createForm.scale_ratio"
                        type="number"
                        step="0.1"
                        placeholder="1.0"
                        :class="{ 'border-destructive': createV$.scale_ratio.$error }"
                      />
                      <span v-if="createV$.scale_ratio.$error" class="text-destructive text-sm">
                        {{ createV$.scale_ratio.$errors[0].$message }}
                      </span>
                    </div> -->
                  </div>
                </ScrollArea>
                <DialogFooter>
                  <Button type="button" variant="outline" @click="createDialogOpen = false">
                    取消
                  </Button>
                  <Button type="submit" :disabled="isCreating">
                    {{ isCreating ? "创建中..." : "创建" }}
                  </Button>
                </DialogFooter>
              </form>
            </DialogContent>
          </Dialog>
        </div>
      </CardHeader>
    </Card>
    <!-- 地图列表 -->
    <Card class="flex-1">
      <CardContent class="p-0">
        <ScrollArea class="h-[calc(100vh-16rem)]">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>地图名称</TableHead>
                <TableHead>坐标范围</TableHead>
                <TableHead>中心点</TableHead>
                <TableHead>缩放比例</TableHead>
                <TableHead class="hidden md:table-cell">创建时间</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow v-if="loading">
                <TableCell colspan="6" class="text-center">加载中...</TableCell>
              </TableRow>
              <TableRow v-else-if="customMaps.length === 0">
                <TableCell colspan="6" class="text-muted-foreground text-center">
                  暂无地图数据，点击右上角创建新地图
                </TableCell>
              </TableRow>
              <TableRow v-else v-for="map in customMaps" :key="map.id" class="hover:bg-muted/50">
                <TableCell class="font-medium">
                  <div class="flex flex-col">
                    <span>{{ map.map_name }}</span>
                    <span v-if="map.description" class="text-muted-foreground text-xs">
                      {{ map.description }}
                    </span>
                  </div>
                </TableCell>
                <TableCell>
                  <div class="text-sm">
                    <div>X: {{ map.x_min }} ~ {{ map.x_max }}</div>
                    <div>Y: {{ map.y_min }} ~ {{ map.y_max }}</div>
                  </div>
                </TableCell>
                <TableCell>
                  <div class="text-sm">({{ map.center_x }}, {{ map.center_y }})</div>
                </TableCell>
                <TableCell>{{ map.scale_ratio }}</TableCell>
                <TableCell class="hidden md:table-cell">
                  {{ new Date(map.created_at).toLocaleString() }}
                </TableCell>
                <TableCell class="text-right">
                  <div class="flex justify-end gap-2">
                    <!-- 预览按钮 -->
                    <Button
                      variant="outline"
                      size="icon"
                      @click="openPreviewDialog(map)"
                      title="预览"
                    >
                      <Eye class="h-4 w-4" />
                    </Button>
                    <!-- 编辑按钮 -->
                    <Button variant="outline" size="icon" @click="openEditDialog(map)" title="编辑">
                      <Pen class="h-4 w-4" />
                    </Button>
                    <!-- 删除按钮 -->
                    <AlertDialog>
                      <AlertDialogTrigger as-child>
                        <Button variant="outline" size="icon" class="text-red-500" title="删除">
                          <Trash class="h-4 w-4" />
                        </Button>
                      </AlertDialogTrigger>
                      <AlertDialogContent>
                        <AlertDialogHeader>
                          <AlertDialogTitle>确认删除地图？</AlertDialogTitle>
                          <AlertDialogDescription>
                            你将永久删除地图 "<strong>{{ map.map_name }}</strong
                            >"，此操作无法撤销。
                          </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                          <AlertDialogCancel>取消</AlertDialogCancel>
                          <AlertDialogAction
                            class="bg-red-500 hover:bg-red-600"
                            :disabled="isDeleting[map.id]"
                            @click="handleDelete(map.id)"
                          >
                            {{ isDeleting[map.id] ? "删除中..." : "确认删除" }}
                          </AlertDialogAction>
                        </AlertDialogFooter>
                      </AlertDialogContent>
                    </AlertDialog>
                  </div>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </ScrollArea>
      </CardContent>
    </Card>
    <!-- 编辑地图对话框 -->
    <Dialog v-model:open="editDialogOpen">
      <DialogContent class="sm:max-w-[600px]">
        <DialogHeader>
          <DialogTitle>编辑地图</DialogTitle>
          <DialogDescription>修改地图配置信息</DialogDescription>
        </DialogHeader>
        <form @submit.prevent="handleUpdate">
          <ScrollArea class="max-h-[calc(100vh-16rem)]">
            <div class="space-y-4 px-1 py-4">
              <!-- 地图名称 -->
              <div class="flex flex-col gap-2">
                <Label for="editMapName">地图名称</Label>
                <Input
                  id="editMapName"
                  v-model="editForm.map_name"
                  placeholder="例如：一楼平面图"
                  :class="{ 'border-destructive': editV$.map_name.$error }"
                />
                <span v-if="editV$.map_name.$error" class="text-destructive text-sm">
                  {{ editV$.map_name.$errors[0].$message }}
                </span>
              </div>
              <!-- 地图描述 -->
              <div class="flex flex-col gap-2">
                <Label for="editDescription">描述（可选）</Label>
                <Textarea
                  id="editDescription"
                  v-model="editForm.description"
                  placeholder="地图描述..."
                  rows="2"
                />
              </div>
              <!-- 图片上传 -->
              <div class="flex flex-col gap-2">
                <Label for="editImage">更换地图图片（可选）</Label>
                <Input
                  id="editImage"
                  type="file"
                  accept="image/jpeg,image/jpg,image/png,image/gif,image/webp"
                  @change="(e: Event) => handleImageUpload(e, editForm)"
                />
                <span class="text-muted-foreground text-xs"> 不上传则保持原图片不变 </span>
                <!-- 图片预览 -->
                <div v-if="editImagePreview" class="mt-2">
                  <img
                    :src="editImagePreview"
                    alt="预览"
                    class="max-h-40 rounded border object-contain"
                  />
                </div>
              </div>
              <!-- 坐标范围 -->
              <div class="grid grid-cols-2 gap-4">
                <div class="flex flex-col gap-2">
                  <Label for="editXMin">X 最小值</Label>
                  <Input
                    id="editXMin"
                    v-model="editForm.x_min"
                    type="number"
                    step="0.01"
                    :class="{ 'border-destructive': editV$.x_min.$error }"
                  />
                  <span v-if="editV$.x_min.$error" class="text-destructive text-sm">
                    {{ editV$.x_min.$errors[0].$message }}
                  </span>
                </div>
                <div class="flex flex-col gap-2">
                  <Label for="editXMax">X 最大值</Label>
                  <Input
                    id="editXMax"
                    v-model="editForm.x_max"
                    type="number"
                    step="0.01"
                    :class="{ 'border-destructive': editV$.x_max.$error }"
                  />
                  <span v-if="editV$.x_max.$error" class="text-destructive text-sm">
                    {{ editV$.x_max.$errors[0].$message }}
                  </span>
                </div>
                <div class="flex flex-col gap-2">
                  <Label for="editYMin">Y 最小值</Label>
                  <Input
                    id="editYMin"
                    v-model="editForm.y_min"
                    type="number"
                    step="0.01"
                    :class="{ 'border-destructive': editV$.y_min.$error }"
                  />
                  <span v-if="editV$.y_min.$error" class="text-destructive text-sm">
                    {{ editV$.y_min.$errors[0].$message }}
                  </span>
                </div>
                <div class="flex flex-col gap-2">
                  <Label for="editYMax">Y 最大值</Label>
                  <Input
                    id="editYMax"
                    v-model="editForm.y_max"
                    type="number"
                    step="0.01"
                    :class="{ 'border-destructive': editV$.y_max.$error }"
                  />
                  <span v-if="editV$.y_max.$error" class="text-destructive text-sm">
                    {{ editV$.y_max.$errors[0].$message }}
                  </span>
                </div>
              </div>
              <!-- 中心点坐标 -->
              <div class="grid grid-cols-2 gap-4">
                <div class="flex flex-col gap-2">
                  <Label for="editCenterX">中心 X 坐标</Label>
                  <Input
                    id="editCenterX"
                    v-model="editForm.center_x"
                    type="number"
                    step="0.01"
                    :class="{ 'border-destructive': editV$.center_x.$error }"
                  />
                  <span v-if="editV$.center_x.$error" class="text-destructive text-sm">
                    {{ editV$.center_x.$errors[0].$message }}
                  </span>
                </div>
                <div class="flex flex-col gap-2">
                  <Label for="editCenterY">中心 Y 坐标</Label>
                  <Input
                    id="editCenterY"
                    v-model="editForm.center_y"
                    type="number"
                    step="0.01"
                    :class="{ 'border-destructive': editV$.center_y.$error }"
                  />
                  <span v-if="editV$.center_y.$error" class="text-destructive text-sm">
                    {{ editV$.center_y.$errors[0].$message }}
                  </span>
                </div>
              </div>
              <!-- 缩放比例 -->
              <!-- <div class="flex flex-col gap-2">
                <Label for="editScaleRatio">缩放比例</Label>
                <Input
                  id="editScaleRatio"
                  v-model="editForm.scale_ratio"
                  type="number"
                  step="0.1"
                  :class="{ 'border-destructive': editV$.scale_ratio.$error }"
                />
                <span v-if="editV$.scale_ratio.$error" class="text-destructive text-sm">
                  {{ editV$.scale_ratio.$errors[0].$message }}
                </span>
              </div> -->
            </div>
          </ScrollArea>
          <DialogFooter>
            <Button type="button" variant="outline" @click="editDialogOpen = false"> 取消 </Button>
            <Button type="submit" :disabled="isUpdating">
              {{ isUpdating ? "更新中..." : "更新" }}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
    <!-- 预览地图对话框 -->
    <Dialog v-model:open="previewDialogOpen">
      <DialogContent class="sm:max-w-[800px]">
        <DialogHeader>
          <DialogTitle>{{ previewMap?.map_name }}</DialogTitle>
          <DialogDescription v-if="previewMap?.description">
            {{ previewMap.description }}
          </DialogDescription>
        </DialogHeader>
        <div v-if="previewMap" class="space-y-4">
          <!-- 地图图片 -->
          <div v-if="previewMap.image_url" class="rounded border">
            <img
              :src="previewMap.image_url"
              :alt="previewMap.map_name"
              class="h-auto w-full rounded object-contain"
            />
          </div>
          <div v-else class="bg-muted flex items-center justify-center rounded border p-8">
            <div class="text-muted-foreground flex items-center gap-2">
              <ImageIcon class="h-5 w-5" />
              <span>暂无地图图片</span>
            </div>
          </div>
          <!-- 地图信息 -->
          <div class="grid grid-cols-2 gap-4 rounded border p-4 text-sm">
            <div>
              <span class="text-muted-foreground">坐标范围 X：</span>
              <span class="font-medium">{{ previewMap.x_min }} ~ {{ previewMap.x_max }}</span>
            </div>
            <div>
              <span class="text-muted-foreground">坐标范围 Y：</span>
              <span class="font-medium">{{ previewMap.y_min }} ~ {{ previewMap.y_max }}</span>
            </div>
            <div>
              <span class="text-muted-foreground">中心点：</span>
              <span class="font-medium"
                >({{ previewMap.center_x }}, {{ previewMap.center_y }})</span
              >
            </div>
            <div>
              <span class="text-muted-foreground">缩放比例：</span>
              <span class="font-medium">{{ previewMap.scale_ratio }}</span>
            </div>
            <div class="col-span-2">
              <span class="text-muted-foreground">创建时间：</span>
              <span class="font-medium">{{
                new Date(previewMap.created_at).toLocaleString()
              }}</span>
            </div>
            <div class="col-span-2">
              <span class="text-muted-foreground">更新时间：</span>
              <span class="font-medium">{{
                new Date(previewMap.updated_at).toLocaleString()
              }}</span>
            </div>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" @click="previewDialogOpen = false">关闭</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </div>
</template>
<!-- src/views/LoginView.vue -->
<template>
  <!-- 全屏渐变背景 -->
  <div
    class="fixed inset-0 z-[999] flex items-center justify-center bg-gradient-to-br from-blue-50 via-indigo-200 to-blue-400 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700"
  >
    <div
      class="flex w-full max-w-sm flex-col rounded-xl bg-white shadow-2xl md:max-w-2xl md:flex-row dark:bg-gray-800 dark:shadow-black/40"
    >
      <!-- 左侧图片：仅桌面显示 -->
      <div class="hidden md:flex md:w-1/2">
        <img
          src="@/assets/imgs/login.png"
          alt="登录配图"
          class="h-full w-full rounded-l-xl object-cover"
        />
      </div>
      <!-- 右侧登录表单 -->
      <div class="w-full p-8 md:w-1/2">
        <h1 class="text-center text-2xl font-bold text-gray-800 dark:text-gray-100">登录</h1>
        <!-- 登录表单 -->
        <form @submit.prevent="onSubmit" class="space-y-6">
          <!-- 用户名 -->
          <label for="username" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            用户名
          </label>
          <Input
            id="username"
            v-model="form.username"
            type="text"
            placeholder="请输入用户名"
            maxlength="32"
          />
          <!-- 密码 -->
          <label for="password" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            密码
          </label>
          <Input
            id="password"
            v-model="form.password"
            type="password"
            placeholder="请输入密码"
            show-password
            maxlength="64"
            class=""
          />
          <!-- 提交按钮 -->
          <Button type="submit" class="w-full" :disabled="loading" :loading="loading">
            {{ loading ? "登录中..." : "登录" }}
          </Button>
        </form>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { useRouter } from "vue-router";
import { userApi } from "@/api";
import { toast } from "vue-sonner";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
const router = useRouter();
const form = reactive({
  username: "",
  password: "",
});
const loading = ref(false);
async function onSubmit() {
  if (!form.username.trim()) {
    toast.error("请输入用户名", {
      description: "用户名为必填项",
    });
    return;
  }
  if (!form.password) {
    toast.error("请输入密码", {
      description: "密码为必填项",
    });
    return;
  }
  loading.value = true;
  try {
    const { data: resp } = await userApi.login({
      username: form.username,
      password: form.password,
    });
    if (resp.data?.access_token && resp.data?.refresh_token) {
      localStorage.setItem("access_token", resp.data.access_token);
      localStorage.setItem("refresh_token", resp.data.refresh_token);
      localStorage.setItem("access_token_time", Date.now().toString());
      localStorage.setItem("refresh_token_time", Date.now().toString());
    }
    console.log("登录成功！");
    toast.success("登录成功！", {
      description: "欢迎回来，即将跳转...",
      duration: 3000,
    });
    document.title = "展示平台";
    router.replace("/");
  } catch (e: unknown) {
    const handled = (e as unknown as { _handled: boolean })?._handled;
    if (handled) return;
    toast.error("登录失败", {
      description: "登录失败，请检查账号密码",
      duration: 5000,
    });
  } finally {
    loading.value = false;
  }
}
onMounted(() => {
  localStorage.removeItem("access_token");
  localStorage.removeItem("refresh_token");
  localStorage.removeItem("refresh_token_time");
  localStorage.removeItem("refresh_token_time");
  document.title = "请登录";
});
</script>

```