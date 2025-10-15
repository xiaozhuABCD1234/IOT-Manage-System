import { defineStore } from "pinia";
import { ref, computed } from "vue";
import type { MarkOnline } from "@/utils/mqtt";
import { createDeviceStateMachine } from "@/utils/deviceState";
import { connectMQTT, disconnectMQTT, parseOnlineMessage, TOPIC_ONLINE } from "@/utils/mqtt";
import { getAllDeviceIDToName } from "@/api/mark";
import type { MqttClient } from "mqtt";

export const useMarksStore = defineStore("marks", () => {
  // 设备在线状态
  const marks = ref<MarkOnline[]>([]);

  // 设备名称映射
  const deviceNames = ref<Map<string, string>>(new Map());

  // MQTT连接状态
  const isConnected = ref(false);
  const connectionError = ref<string | null>(null);

  // MQTT客户端实例
  let mqttClient: MqttClient | null = null;
  let nameTimer: number | null = null;

  /* 把状态机直接建在 store 内部，生命周期跟随 store */
  const sm = createDeviceStateMachine(marks);

  // 计算属性：未命名的设备ID列表
  const unnamedIds = computed(() => {
    const namedSet = new Set(deviceNames.value.keys());
    return marks.value.map((m) => m.id).filter((id) => !namedSet.has(id));
  });

  // 计算属性：在线设备数量
  const onlineCount = computed(() => marks.value.filter((m) => m.online).length);

  // 计算属性：离线设备数量
  const offlineCount = computed(() => marks.value.filter((m) => !m.online).length);

  // 加载设备名称
  const loadDeviceNames = async () => {
    try {
      const res = await getAllDeviceIDToName();
      const obj = res.data.data;
      deviceNames.value = new Map(Object.entries(obj || {}));
    } catch (error) {
      console.error("加载设备名称失败:", error);
    }
  };

  // 启动MQTT连接
  const startMQTT = () => {
    if (mqttClient) {
      console.log("MQTT已连接，跳过重复连接");
      return;
    }

    try {
      mqttClient = connectMQTT();
      isConnected.value = true;
      connectionError.value = null;

      // 订阅在线状态主题
      mqttClient.subscribe(TOPIC_ONLINE, { qos: 0 }, (err) => {
        if (err) {
          console.error("订阅online/#失败", err);
          connectionError.value = "订阅失败: " + err.message;
          return;
        }
        console.log("已订阅 online/#");
      });

      // 监听消息
      mqttClient.on("message", (topic, payload) => {
        const data = parseOnlineMessage(topic, payload);
        sm.onMessage(data);
      });

      // 监听连接状态变化
      mqttClient.on("connect", () => {
        isConnected.value = true;
        connectionError.value = null;
        console.log("MQTT已连接");
      });

      mqttClient.on("reconnect", () => {
        console.log("MQTT正在重连");
      });

      mqttClient.on("error", (error) => {
        console.error("MQTT错误", error);
        connectionError.value = "连接错误: " + error.message;
        isConnected.value = false;
      });

      mqttClient.on("offline", () => {
        console.warn("MQTT离线");
        isConnected.value = false;
      });

      // 启动状态机
      sm.start();

      // 启动设备名称定时刷新
      loadDeviceNames(); // 立即加载一次
      nameTimer = window.setInterval(loadDeviceNames, 10000); // 从3秒改为10秒
    } catch (error) {
      console.error("启动MQTT失败:", error);
      connectionError.value = "启动失败: " + (error as Error).message;
      isConnected.value = false;
    }
  };

  // 停止MQTT连接
  const stopMQTT = () => {
    if (mqttClient) {
      disconnectMQTT(mqttClient);
      mqttClient = null;
    }

    if (nameTimer !== null) {
      window.clearInterval(nameTimer);
      nameTimer = null;
    }

    sm.stop();
    isConnected.value = false;
    connectionError.value = null;
  };

  // 重新连接MQTT
  const reconnectMQTT = () => {
    stopMQTT();
    setTimeout(() => {
      startMQTT();
    }, 1000);
  };

  // 获取设备名称
  const getDeviceName = (deviceId: string): string => {
    return deviceNames.value.get(deviceId) || "未知设备";
  };

  // 检查设备是否在线
  const isDeviceOnline = (deviceId: string): boolean => {
    const device = marks.value.find((m) => m.id === deviceId);
    return device?.online || false;
  };

  // 获取设备信息
  const getDeviceInfo = (deviceId: string): MarkOnline | undefined => {
    return marks.value.find((m) => m.id === deviceId);
  };

  return {
    // 状态
    markList: marks,
    deviceNames,
    isConnected,
    connectionError,

    // 计算属性
    unnamedIds,
    onlineCount,
    offlineCount,

    // 方法
    startMQTT,
    stopMQTT,
    reconnectMQTT,
    loadDeviceNames,
    getDeviceName,
    isDeviceOnline,
    getDeviceInfo,

    // 状态机方法（保持向后兼容）
    onMessage: sm.onMessage,
    start: sm.start,
    stop: sm.stop,
  };
});
