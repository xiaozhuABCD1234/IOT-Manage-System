import mqtt from "mqtt";
import type { MqttClient } from "mqtt";
import { MQTT_CONFIG } from "@/config/mqtt";
import gcoord from "gcoord";

const MQTT_URL = MQTT_CONFIG.MQTT_URL;
// const MQTT_URL = "tcp://localhost:1883/mqtt";
export const TOPIC_ONLINE = "online/#";

const MQTT_OPTS = {
  clientId: MQTT_CONFIG.clientId,
  clean: MQTT_CONFIG.clean,
  connectTimeout: MQTT_CONFIG.connectTimeout,
  reconnectPeriod: MQTT_CONFIG.reconnectPeriod,
  username: MQTT_CONFIG.username,
  password: MQTT_CONFIG.password,
  will: {
    topic: "device/lwt", // 你想让谁收到
    payload: JSON.stringify({
      // 可以是 Buffer.from(...)
      msg: "客户端异常离线",
      ts: Date.now(),
    }),
    qos: 1 as const,
    retain: false, // 需要持久就设 true
  },
};

// let client: MqttClient | null = null;

/** 建立连接并返回客户端 */
export function connectMQTT(): MqttClient {
  const client: MqttClient = mqtt.connect(MQTT_URL, {
    ...MQTT_OPTS,
    clientId: MQTT_CONFIG.clientId + "_" + Math.random().toString(16).slice(2),
  });

  client.on("connect", () => console.log("MQTT 已连接"));
  client.on("reconnect", () => console.log("MQTT 正在重连"));
  client.on("error", (e) => console.error("MQTT 错误", e));
  client.on("offline", () => console.warn("MQTT 离线"));
  client.on("message", (topic, payload) => {
    console.log(`收到 ${topic}:`, payload.toString());
  });

  return client;
}

/** 主动断开并清理 */
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
  // name?: string;
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

  const rtkSen = data.sens.find((s) => s.n === 'RTK');
  if (!rtkSen || !Array.isArray(rtkSen.v) || rtkSen.v.length !== 2) {
    throw new Error('缺少 RTK 字段或格式错误');
  }

  const [lngWGS, latWGS] = rtkSen.v as [number, number];

  /* ====== 新增：0,0 过滤 ====== */
  if (lngWGS === 0 && latWGS === 0) {
    // 视业务需求 return null 或抛错
    return null;          // 选择“不返回”
    // throw new Error('RTK 原始坐标为 0,0，已丢弃');
  }

  const [lngGCJ, latGCJ] = gcoord.transform(
    [lngWGS, latWGS],
    gcoord.WGS84,
    gcoord.GCJ02
  );

  return { id: data.id, lng: lngGCJ, lat: latGCJ };
};

export const parseUWBMessage = (topic: string, payload: Buffer): UWBFix => {
  const data = JSON.parse(payload.toString()) as Msg;

  // 1. 找 UWB 字段
  const uwbSen = data.sens.find((s) => s.n === "UWB");
  if (!uwbSen || !Array.isArray(uwbSen.v) || uwbSen.v.length !== 2) {
    throw new Error("缺少 UWB 字段或格式错误");
  }

  const [x, y] = uwbSen.v as [number, number];
  return { id: data.id, x, y };
};

export const parseOnlineMessage = (topic: string, payload: Buffer): MarkOnline => {
  // 1. 先尝试从 topic 里截
  let idFromTopic = topic.replace("online", "");
  idFromTopic = idFromTopic.replace(/^\/+|\/+$/g, "");
  // 2. 解析 payload
  let data: MarkOnlineMsg | undefined;
  try {
    data = JSON.parse(payload.toString()) as MarkOnlineMsg;
  } catch {
    data = undefined; // 解析失败就当成空对象
  }

  // 3. 优先 data.id，没有再回退到 topic 截取的
  const id = data?.id?.trim() || idFromTopic;

  // 4. 如果两条路都拿不到，给一个兜底（也可以直接 throw）
  if (!id) {
    // throw new Error(`无法从 topic:${topic} 或 payload 中解析出设备 id`);
    return { id: "unknown", online: true, topic };
  }

  return { id, online: true, topic };
};
