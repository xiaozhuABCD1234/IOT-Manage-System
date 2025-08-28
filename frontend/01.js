import mqtt from "mqtt";

const id = 1;
// 多个点，每个点是一个数组 [x, y]
const xy = [
  [121.892458, 30.902507],
  [121.893097, 30.902549],
  [121.893311, 30.902627],
  [121.894003, 30.902567],
  [121.893891, 30.902286],
  [121.893944, 30.90225],
  [121.894186, 30.902273],
  [121.894261, 30.90224],
  [121.894111, 30.901775],
  [121.893741, 30.901706],
  [121.893137, 30.899768],
];

const url = "ws://106.14.209.20:8083/mqtt";
const options = {
  clean: true,
  connectTimeout: 10000, // 增加连接超时时间
  reconnectPeriod: 5000, // 启用自动重连，间隔5秒
  clientId: `emqx_test_${Date.now()}_${
    Math.random().toString(16).substr(2, 8)
  }`, // 唯一客户端ID
  username: "", // 根据服务器要求填写
  password: "",
};

const client = mqtt.connect(url, options);

function generatePoints(path, step) {
  const points = [];

  for (let i = 0; i < path.length - 1; i++) {
    const current = path[i];
    const next = path[i + 1];

    // 计算两点之间的距离
    const dx = next[0] - current[0];
    const dy = next[1] - current[1];
    const distance = Math.sqrt(dx * dx + dy * dy);

    // 计算需要插入的点数
    const numPoints = Math.ceil(distance / step);

    // 生成中间点
    for (let j = 0; j <= numPoints; j++) {
      const t = j / numPoints;
      const x = current[0] + t * dx;
      const y = current[1] + t * dy;

      // 添加随机波动（-2 到 2 的随机值）
      const randomOffsetX = 0; // (Math.random() - 0.5) * 4; // -2 到 2
      const randomOffsetY = 0; // (Math.random() - 0.5) * 4; // -2 到 2

      points.push([x + randomOffsetX, y + randomOffsetY]);
    }
  }

  return points;
}

const points = generatePoints(xy, 0.00001);
let currentIndex = 0;
let sendingActive = true;

const sendNextPoint = () => {
  if (!sendingActive || currentIndex >= points.length) {
    clearInterval(intervalId); // 停止定时器
    console.log("All points sent.");
    return;
  }

  var msg = {
    id: id,
    indoor: true,
    sensors: [
      {
        name: "RTK",
        data: {
          unit: "°",
          value: points[currentIndex],
        },
      },
      {
        name: "UWB",
        data: {
          unit: "cm",
          value: [
            ((points[currentIndex][0] - 121.887496) /
              (121.897142 - 121.887496)) * 20,
            ((points[currentIndex][1] - 30.899189) / (30.905237 - 30.899189)) *
            20,
          ],
        },
      },
    ],
  };
  currentIndex++;

  client.publish("location/sensors/1", JSON.stringify(msg), (err) => {
    if (err) {
      console.error("Publish error:", err);
      // 不再立即关闭连接，而是等待自动重连
    } else {
      console.log("Message published:", msg);
    }
  });
};

let intervalId;

client.on("connect", () => {
  console.log("Connected to MQTT broker");
  sendingActive = true;

  client.subscribe("location/sensors/1", (err) => {
    if (err) return console.error("Subscription error:", err);
    console.log("Subscribed to topic: location/sensors/1");
    intervalId = setInterval(sendNextPoint, 1000); // 使用 setInterval 定时发送数据
  });
});

client.on("error", (err) => {
  console.error("MQTT client error:", err);
});

client.on("close", () => {
  console.log("MQTT client disconnected");
  sendingActive = false;
  clearInterval(intervalId); // 确保定时器被清除
});

client.on("reconnect", () => {
  console.log("Attempting to reconnect...");
  sendingActive = true;
});
