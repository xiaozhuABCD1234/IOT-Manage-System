import { computed, ref } from "vue";
import { defineStore } from "pinia";

/**
 * 配置存储模块 - 管理应用程序的全局配置参数
 * 包含MQTT连接配置和服务器地址配置两大模块
 */
export const useConfigStore = defineStore("config", () => {
  // ================= MQTT连接配置 ================= //
  /**
   * MQTT Broker连接地址
   * 格式：ws://ip:port/mqtt 或 wss://domain/mqtt
   * 示例：ws://192.168.1.100:8083/mqtt
   * 注意：确保端口已开放且协议匹配(ws/wss)
   */
  const mqtturl = ref("ws://106.14.209.20:8083/mqtt");

  /**
   * MQTT认证用户名（可选）
   * 若Broker启用认证需填写
   * 示例："sensor_reader"
   */
  const mqttuser = ref("");

  /**
   * MQTT认证密码（可选）
   * 若启用认证需对应填写
   * 示例："securePassword123"
   */
  const mqttpwd = ref("");

  /**
   * MQTT客户端唯一标识
   * 自动生成规则：emqx_vue_时间戳_随机十六进制
   * 保证每次连接具有唯一ID
   * 注意：若需固定客户端ID可手动修改
   */
  const mqttclientid = ref(
    `emqx_vue_${Date.now()}_${Math.random().toString(16).substr(2, 8)}`,
  );

  /**
   * MQTT订阅主题
   * 支持通配符#匹配多级子主题
   * 示例："location/sensors/#" 将接收所有传感器子主题消息
   * 注意：需确保有订阅权限
   */
  const mqtttopic = ref("location/sensors/#");

  const securityJsCode = ref("f8444fa686115a25ea60c937cd6a6ab9");
  const key = ref("d345dbe66fd01f5c41ce3cf7e063597b");

  // ================= 服务器配置 ================= //
  /**
   * 后端服务器地址
   * 留空时自动使用当前网页域名
   * 示例："https://api.example.com" 或 "http://localhost"
   */
  const serverUrl = ref("");

  /**
   * 后端服务器端口
   * 默认值："8000"
   * 当serverUrl为空时生效
   * 示例："3000" 或 "8080"
   */
  const serverPort = ref("");

  // ================= 计算属性 ================= //
  /**
   * 计算有效的服务器WebSocket地址
   * 优先级：
   * 1. 使用显式配置的serverUrl
   * 2. 动态构建当前域名地址
   *
   * 动态构建规则：
   * - 协议：根据页面协议自动匹配(ws/wss)
   * - 域名：使用当前页面hostname
   * - 端口：优先使用serverPort配置值，未配置则使用当前页面端口
   * - 路径：固定添加/ws路径
   *
   * 示例：当页面为https://example.com:8080 且 serverPort=3000时
   * 结果：wss://example.com:3000/ws
   */
  const effectiveServerUrl = computed(() => {
    if (serverUrl.value) {
      return serverUrl.value;
    }

    // 协议转换：http->ws，https->wss
    const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";

    // 获取域名（不含端口和路径）
    const hostname = window.location.hostname;

    // 端口处理逻辑：优先使用配置端口，否则使用当前页面端口
    const port = serverPort.value || window.location.port;

    // 端口存在时添加冒号和端口号
    const portPart = port ? `:${port}` : "";

    // 组装最终URL
    return `${protocol}//${hostname}${portPart}/ws`;
  });

  return {
    // MQTT配置项
    mqtturl,
    mqttuser,
    mqttpwd,
    mqttclientid,
    mqtttopic,

    securityJsCode,
    key,

    // 服务器配置项
    effectiveServerUrl,
  };
});
