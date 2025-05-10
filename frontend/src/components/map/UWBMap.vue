<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import mqtt from 'mqtt'
import { useConfigStore } from '@/stores/config'

const ConfigStore = useConfigStore();

const emits = defineEmits(['message-received'])

// MQTT客户端实例
const mqttClient = ref<mqtt.MqttClient | null>(null)

// MQTT配置
const MQTT_CONFIG = {
  url: ConfigStore.mqtturl,
  options: {
    clean: true,
    connectTimeout: 4000,
    clientId: ConfigStore.mqttclientid,
    username: ConfigStore.mqttuser,
    password: ConfigStore.mqttpwd,
  },
  topic: ConfigStore.mqtttopic,
};

// 解析MQTT消息
const parseMessage = (topic: string, payload: Buffer) => {
  const data = JSON.parse(payload.toString());
  const id = data.id;
  const sensors = data.sensors;
  return {
    id,
    lng: sensors[0].data.value[0],
    lat: sensors[0].data.value[1],
  };
};

// 处理MQTT连接
const handleMqttConnection = () => {
  // 创建MQTT客户端
  mqttClient.value = mqtt.connect(MQTT_CONFIG.url, MQTT_CONFIG.options)

  // 监听连接事件
  mqttClient.value.on('connect', () => {
    console.log('Connected to MQTT broker')
    // 订阅主题
    mqttClient.value.subscribe(MQTT_CONFIG.topic, (err) => {
      if (err) {
        console.error('Subscription failed:', err)
      } else {
        console.log(`Subscribed to topic: ${MQTT_CONFIG.topic}`)
      }
    })
  })

  // 监听消息事件
  mqttClient.value.on('message', (topic, payload) => {
    const msg = parseMessage(topic, payload);
    const message = {
      topic,
      payload: msg
    }
    console.log('Received message:', message)
    emits('message-received', message)
  })

  // 监听错误事件
  mqttClient.value.on('error', (err) => {
    console.error('MQTT error:', err)
  })
}

// 处理组件挂载
onMounted(() => {
  handleMqttConnection()
})

// 处理组件卸载
onUnmounted(() => {
  if (mqttClient.value) {
    // 取消订阅
    mqttClient.value.unsubscribe(MQTT_CONFIG.topic, (err) => {
      if (err) {
        console.error('Unsubscription failed:', err)
      } else {
        console.log(`Unsubscribed from topic: ${MQTT_CONFIG.topic}`)
      }
    })
    // 断开连接
    mqttClient.value.end(true, () => {
      console.log('Disconnected from MQTT broker')
    })
    mqttClient.value = null
  }
})
</script>

<template>
  <div class="mqtt-receiver">
    <h3>MQTT Receiver</h3>
    <p>Connected to: {{ MQTT_CONFIG.url }}</p>
    <p>Subscribed to: {{ MQTT_CONFIG.topic }}</p>
  </div>
</template>

<style scoped>
.mqtt-receiver {
  padding: 16px;
  border-radius: 8px;
  background-color: #f5f5f5;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  margin-bottom: 16px;
}

h3 {
  margin-top: 0;
  color: #333;
}

p {
  margin: 8px 0;
  color: #666;
}
</style>
