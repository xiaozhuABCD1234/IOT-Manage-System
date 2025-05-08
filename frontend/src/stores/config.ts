import { computed, ref } from "vue";
import { defineStore } from "pinia";

/**
 * 配置存储模块 - 管理应用程序的全局配置参数
 * 包含 MQTT 连接配置和服务器地址配置两大模块
 */
export const useConfigStore = defineStore("config", () => {
  // ================= MQTT 连接配置 ================= //
  const mqtturl = ref("ws://106.14.209.20:8083/mqtt"); // MQTT Broker 连接地址
  const mqttuser = ref(""); // MQTT 认证用户名（可选）
  const mqttpwd = ref(""); // MQTT 认证密码（可选）
  const mqttclientid = ref(
    `emqx_vue_${Date.now()}_${Math.random().toString(16).substr(2, 8)}`,
  ); // MQTT 客户端唯一标识
  const mqtttopic = ref("location/sensors/#"); // MQTT 订阅主题
  const securityJsCode = ref("f8444fa686115a25ea60c937cd6a6ab9"); // 安全代码
  const key = ref("d345dbe66fd01f5c41ce3cf7e063597b"); // 密钥

  // ================= 服务器配置 ================= //
  const serverUrl = ref(""); // 后端服务器地址
  const serverPort = ref(""); // 后端服务器端口，默认值为空

  // ================= 计算属性 ================= //
  const effectiveWSUrl = computed(() => {
    if (serverUrl.value) {
      return serverUrl.value;
    }

    // 协议转换：http -> ws，https -> wss
    const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
    const hostname = window.location.hostname; // 获取当前页面的域名
    const port = serverPort.value || window.location.port; // 使用配置端口或当前页面端口
    const portPart = port ? `:${port}` : ""; // 端口存在时添加冒号和端口号

    return `${protocol}//${hostname}${portPart}/ws`; // 组装 WebSocket 地址
  });

  const effectiveHttpUrl = computed(() => {
    const wsUrl = effectiveWSUrl.value;
    return wsUrl.replace(/^wss:/, "https:").replace(/^ws:/, "http:").replace(
      /\/ws$/,
      "",
    );
  });

  // ================= 返回可导出的配置项 ================= //
  return {
    // MQTT 配置项
    mqtturl,
    mqttuser,
    mqttpwd,
    mqttclientid,
    mqtttopic,
    securityJsCode,
    key,

    // 服务器配置项
    serverUrl,
    serverPort,
    effectiveServerUrl: effectiveWSUrl,
    effectiveHttpUrl,
  };
});
