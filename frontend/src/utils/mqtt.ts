import mqtt from "mqtt";
import type { MqttClient } from "mqtt";
import { MQTT_CONFIG } from "@/config/mqtt";
import gcoord from "gcoord";

const MQTT_URL = MQTT_CONFIG.MQTT_URL;
// const MQTT_URL = "tcp://localhost:1883/mqtt";

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

let client: MqttClient | null = null;

/** 建立连接并返回客户端 */
export function connectMQTT(): MqttClient {
  if (client && client.connected) return client;

  client = mqtt.connect(MQTT_URL, MQTT_OPTS);

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
export function disconnectMQTT() {
  if (client) {
    client.end();
    client = null;
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

export const parseMessage = (payload: Buffer) => {
  const data = JSON.parse(payload.toString()) as Msg;

  const rtkSen = data.sens.find((s) => s.n === "RTK");
  if (!rtkSen || !Array.isArray(rtkSen.v) || rtkSen.v.length !== 2) {
    throw new Error("缺少 RTK 字段或格式错误");
  }

  const [lngWGS, latWGS] = rtkSen.v as [number, number];
  const [lngGCJ, latGCJ] = gcoord.transform([lngWGS, latWGS], gcoord.WGS84, gcoord.GCJ02);

  return { id: data.id, lng: lngGCJ, lat: latGCJ };
};
