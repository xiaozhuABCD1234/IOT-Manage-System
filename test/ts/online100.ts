// main.ts
import { connectMQTT } from "./mqtt.ts";

type Device = {
	id: string;
	client: any; // mqtt.MqttClient
	timer: NodeJS.Timeout; // ← 这里
};

const devices: Device[] = [];
const topic = "online";

/** 创建单个设备 */
function createDevice(index: number): Device {
	const id = `device-${String(index).padStart(3, "0")}`;
	const client = connectMQTT(); // 每个设备独立 clientId

	// 连接成功后的统一处理
	client.once("connect", () => {
		console.log(`✅ ${id} 已连接`);
		client.subscribe(topic, (err: Error | null) => {
			if (err) console.error(`${id} 订阅失败`, err);
			else console.log(`✅ ${id} 已订阅 ${topic}`);
		});

		// 随机周期 2000–6000 ms
		const period = 2000 + Math.random() * 4000;
		const timer = setInterval(() => {
			const payload = JSON.stringify({ id, ts: Date.now() });
			client.publish(
				topic,
				payload,
				{ qos: 1, retain: false },
				(err?: Error) => {
					if (err) console.error(`${id} 发布失败`, err);
					else console.log(`📤 ${id} → ${topic} : ${payload}`);
				}
			);
		}, period);

		(client as any).__timer = timer; // 把 timer 挂在实例上方便后面清理
	});

	return { id, client, timer: (client as any).__timer };
}

/* ---------- 批量创建 1..100 ---------- */
for (let i = 1; i <= 100; i++) devices.push(createDevice(i));

/* ---------- 优雅退出 ---------- */
export function stopAll() {
	devices.forEach((d) => {
		clearInterval(d.timer);
		d.client.end(true); // force disconnect
	});
	console.log("已停止所有设备");
}

/* 测试：10 秒后全部停止
setTimeout(stopAll, 10_000);
*/
