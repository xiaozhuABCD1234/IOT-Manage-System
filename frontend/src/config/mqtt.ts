export const MQTT_CONFIG = {
  MQTT_URL: import.meta.env.VITE_MQTT_URL,
  clientId: "vue_" + Math.random().toString(16).slice(3, 9),
  clean: true,
  connectTimeout: 4000,
  reconnectPeriod: 1000,
  username: "admin",
  password: "admin",
};
