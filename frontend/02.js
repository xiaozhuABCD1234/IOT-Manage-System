import mqtt from "mqtt";

const id = 2;
// 多个点，每个点是一个数组 [x, y]
const xy = [
  [121.889916, 30.899597],
  [121.889553, 30.899542],
  [121.889438, 30.899564],
  [121.889411, 30.899621],
  [121.889397, 30.899817],
  [121.889615, 30.899875],
  [121.889774, 30.899955],
  [121.889774, 30.899955],
  [121.889914, 30.899596],
  [121.890812, 30.89961],
  [121.890824, 30.900469],
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
  if (!sendingActive || currentIndex >= points.length) return;

  var msg = {
    id: id,
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

// 安全关闭连接的示例（根据需要调用）
// process.on('SIGINT', () => {
//   sendingActive = false;
//   client.end();
// });
