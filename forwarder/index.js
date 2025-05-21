import mqtt from "mqtt";

// MQTT 配置
const mqttUrl = "ws://106.14.209.20:8083/mqtt";
const mqttOptions = {
  clean: true,
  connectTimeout: 4000,
  clientId: `emqx_monitor_position_${Date.now()}_${Math.random().toString(16).slice(2)}`,
};

// WebSocket 配置
const wsUrl = "ws://fastapi-service:8000/ws/monitor/position";
// const wsUrl = "ws://127.0.0.1:8000/ws/monitor/position";
// MQTT 客户端
const mqttClient = mqtt.connect(mqttUrl, mqttOptions);

// WebSocket 客户端
let wsClient = null;

// 初始化 WebSocket 连接
function initWebSocket() {
  wsClient = new WebSocket(wsUrl);

  wsClient.onopen = () => {
    console.log("WebSocket 连接成功");
  };

  wsClient.onerror = (error) => {
    console.error("WebSocket 错误:", error);
    // 可以在这里实现重连逻辑
    setTimeout(initWebSocket, 5000);
  };

  wsClient.onclose = () => {
    console.log("WebSocket 连接关闭，尝试重新连接...");
    setTimeout(initWebSocket, 5000);
  };
}

// 初始化 MQTT 客户端
function initMqtt() {
  mqttClient.on("connect", () => {
    console.log("MQTT 已连接");
    // 订阅主题（QoS级别使用数字直接传参）
    mqttClient.subscribe("location/sensors/#", 2, (error) => {
      if (error) {
        console.error("订阅失败:", error);
      } else {
        console.log("MQTT 主题订阅成功");
      }
    });
  });

  mqttClient.on("error", (error) => {
    console.error("MQTT 错误:", error);
    // 可以在这里实现重连逻辑
    setTimeout(() => {
      console.log("尝试重新连接 MQTT...");
      mqttClient.end();
      mqttClient.connect(mqttOptions);
    }, 5000);
  });

  // 消息处理
  mqttClient.on("message", (topic, message) => {
    try {
      const data = JSON.parse(message.toString());
      // console.log("接收到 MQTT 消息:", data);

      const rtkSensor = data.sensors.find((sensor) => sensor.name === "RTK");
      if (!rtkSensor || !Array.isArray(rtkSensor.data?.value)) {
        console.warn("未找到有效的 RTK 数据");
        return;
      }

      const [longitude, latitude] = rtkSensor.data.value;

      const wsMessage = {
        id: data.id,
        latitude: latitude || 0,
        longitude: longitude || 0,
        timestamp: Date.now(), // 添加时间戳
      };

      // 确保 WebSocket 已连接
      if (wsClient && wsClient.readyState === WebSocket.OPEN) {
        wsClient.send(JSON.stringify(wsMessage));
        // console.log("消息已发送到 WebSocket:", wsMessage);
      }
    } catch (error) {
      console.error("处理 MQTT 消息时出错:", error);
    }
  });
}

// 初始化所有服务
function init() {
  console.log("初始化服务...");
  initWebSocket();
  initMqtt();
}

// 启动应用
init();