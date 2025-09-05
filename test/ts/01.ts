// main.ts（或某个组件）
import { connectMQTT } from "./mqtt.ts";

// 1. 建立连接
const client = connectMQTT();

// 2. 连接成功后做点什么
client.on("connect", () => {
	console.log("👉 开始订阅和发布");

	// 订阅一条主题
	client.subscribe("test/topic", (err) => {
		if (err) return console.error("订阅失败", err);
		console.log("✅ 已订阅 test/topic");
	});
});

client.on("message", (topic, payload) => {
	console.log(`📨 收到 ${topic}:`, payload.toString());
});
