// main.ts（或某个组件）
import { connectMQTT } from "./mqtt.ts";

const topic = "online";
const ID = "device-001";
// 1. 建立连接
const client = connectMQTT();
// client.on("message", (topic, payload) => {
// 	console.log(`📨 收到 ${topic}:`, payload.toString());
// });
// 2. 连接成功后做点什么
client.on("connect", () => {
	console.log("👉 开始订阅和发布");

	client.subscribe(topic, (err) => {
		if (err) return console.error("订阅失败", err);
		console.log("✅ 已订阅", topic);
	});

	const msg = { id: ID }; // 1. 普通对象
	const payload = JSON.stringify(msg); // 2. 先转字符串

	/* 每 3 秒发一次 */
	setInterval(() => {
		const payload = JSON.stringify({ id: ID, ts: Date.now() });
		client.publish(topic, payload, { qos: 1, retain: false }, (err) => {
			if (err) return console.error("发布失败", err);
			console.log("📤 已发送 →", topic, payload);
		});
	}, 3000);
});

client.on("connect", () => {
	console.log("👉 开始订阅和发布");

	client.subscribe(topic, (err) => {
		if (err) return console.error("订阅失败", err);
		console.log("✅ 已订阅", topic);
	});

	const msg = { id: "device-002" }; // 1. 普通对象

	/* 每 3 秒发一次 */
	setInterval(() => {
		const payload = JSON.stringify(msg);
		client.publish(topic, payload, { qos: 1, retain: false }, (err) => {
			if (err) return console.error("发布失败", err);
			console.log("📤 已发送 →", topic, payload);
		});
	}, 4000);
});

client.on("connect", () => {
	console.log("👉 开始订阅和发布");

	client.subscribe(topic, (err) => {
		if (err) return console.error("订阅失败", err);
		console.log("✅ 已订阅", topic);
	});

	const msg = { id: "002" }; // 1. 普通对象

	/* 每 3 秒发一次 */
	setInterval(() => {
		const payload = JSON.stringify(msg);
		client.publish(topic, payload, { qos: 1, retain: false }, (err) => {
			if (err) return console.error("发布失败", err);
			console.log("📤 已发送 →", topic, payload);
		});
	}, 3500);
});
