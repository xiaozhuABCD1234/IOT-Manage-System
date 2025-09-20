// main.ts
import { connectMQTT } from "./mqtt.ts";

const EchoTopic = "warning/#";

const client = connectMQTT();

client.on("connect", () => {
	console.log("👉 开始订阅和发布");

	client.subscribe(EchoTopic, (err) => {
		if (err) return console.error("订阅失败", err);
		console.log("✅ 已订阅", EchoTopic);
	});

	/* 2. 打印收到的回声数据 */
	client.on("message", (topic, payload) => {
		console.log(`📨 收到 ${topic}:`, payload.toString());
	});
});
