import mqtt, { MqttClient } from "mqtt";

const MQTT_URL = "ws://localhost:8083/mqtt";
// const MQTT_URL = "tcp://localhost:1883/mqtt";

const MQTT_OPTS = {
	clientId: "vue_" + Math.random().toString(16).slice(3, 9),
	clean: true,
	connectTimeout: 4000,
	reconnectPeriod: 1000,
	username: "admin",
	password: "admin",
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

	client.on("connect", () => console.log("✅ MQTT 已连接"));
	client.on("reconnect", () => console.log("🔄 正在重连"));
	client.on("error", (e) => console.error("❌ MQTT 错误", e));
	client.on("offline", () => console.warn("📡 离线"));
	client.on("message", (topic, payload) => {
		console.log(`📨 收到 ${topic}:`, payload.toString());
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
