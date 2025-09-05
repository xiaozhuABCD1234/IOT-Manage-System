// main.ts
import { connectMQTT } from "./mqtt.ts";

const ID = "device-001";
const OnlineTopic = `online/${ID}`;
const LocTopic = `location/${ID}`;
const EchoTopic = `echo/${ID}`;

const client = connectMQTT();

client.on("connect", () => {
	console.log("👉 开始订阅和发布");

	/* 1. 订阅回声主题 */
	client.subscribe(EchoTopic, (err) => {
		if (err) return console.error("订阅失败", err);
		console.log("✅ 已订阅", EchoTopic);
	});

	/* 2. 打印收到的回声数据 */
	client.on("message", (topic, payload) => {
		if (topic === EchoTopic) {
			// payload 是 Buffer，先转字符串再解析
			try {
				const obj = JSON.parse(payload.toString());
				console.log("🔊 收到回声 ←", obj);
			} catch (e) {
				console.log("🔊 收到回声 ←", payload.toString());
			}
		}
	});

	/* 3. 每 3 s 心跳 */
	setInterval(() => {
		const payload = JSON.stringify({ id: ID, ts: Date.now() });
		client.publish(OnlineTopic, payload, { qos: 0, retain: false });
	}, 3000);

	/* 4. 每 1 s 位置 */
	setInterval(() => {
		const locPayload = JSON.stringify({
			id: ID,
			sens: [{ n: "RTK", u: "deg", v: [121.891751, 30.902079] }],
		});
		client.publish(LocTopic, locPayload, { qos: 0, retain: true });
	}, 1000); // 1 s
});
