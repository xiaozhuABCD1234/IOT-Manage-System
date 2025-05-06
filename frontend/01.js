import mqtt from "mqtt";

const url = "ws://106.14.209.20:8083/mqtt";
const options = {
  clean: true,
  connectTimeout: 10000, // 增加连接超时时间
  reconnectPeriod: 5000, // 启用自动重连，间隔5秒
  clientId: `emqx_vue_${Date.now()}_${Math.random().toString(16).substr(2, 8)}`, // 唯一客户端ID
  username: "", // 根据服务器要求填写
  password: "",
};

const client = mqtt.connect(url, options);

const xy = [
  { x: 121.890898, y: 30.902542 },
  { x: 121.89082, y: 30.900452 },
];

function generatePoints(path, step) {
  const points = [];

  for (let i = 0; i < path.length - 1; i++) {
    const current = path[i];
    const next = path[i + 1];

    // 计算两点之间的距离
    const dx = next.x - current.x;
    const dy = next.y - current.y;
    const distance = Math.sqrt(dx * dx + dy * dy);

    // 计算需要插入的点数
    const numPoints = Math.ceil(distance / step);

    // 生成中间点
    for (let j = 0; j <= numPoints; j++) {
      const t = j / numPoints;
      const x = current.x + t * dx;
      const y = current.y + t * dy;

      // 添加随机波动（-2 到 2 的随机值）
      const randomOffsetX = 0; //(Math.random() - 0.5) * 4; // -2 到 2
      const randomOffsetY = 0; //(Math.random() - 0.5) * 4; // -2 到 2

      points.push({
        x: x + randomOffsetX,
        y: y + randomOffsetY,
      });
    }
  }

  return points;
}
const points = generatePoints(xy, 0.00001);
let currentIndex = 0;
let sendingActive = true;

const sendNextPoint = () => {
  if (!sendingActive || currentIndex >= points.length) return;

  // const point = points[currentIndex];
  var msg = {
    id: 1,
    sensors: [
      {
        name: "RTK",
        data: {
          unit: "°",
          value: [points[currentIndex].x, points[currentIndex].y],
        },
      },
      {
        name: "UWB",
        data: {
          unit: "cm",
          value: 1000,
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
    setTimeout(sendNextPoint, 1000); // 保持1秒间隔
  });
};

client.on("connect", () => {
  console.log("Connected to MQTT broker");
  sendingActive = true;

  client.subscribe("location/sensors/1", (err) => {
    if (err) return console.error("Subscription error:", err);
    console.log("Subscribed to topic: location/sensors/1");
    sendNextPoint(); // 开始发送数据
  });
});

client.on("error", (err) => {
  console.error("MQTT client error:", err);
});

client.on("close", () => {
  console.log("MQTT client disconnected");
  sendingActive = false;
});

client.on("reconnect", () => {
  console.log("Attempting to reconnect...");
  sendingActive = true;
});
