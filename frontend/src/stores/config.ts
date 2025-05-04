import { ref } from 'vue'
import { defineStore } from 'pinia'

export const useConfigStore = defineStore('config', () => {
  const mqtturl = ref('ws://106.14.209.20:8083/mqtt')
  const mqttuser = ref('')
  const mqttpwd = ref('')
  const mqttclientid = ref(`emqx_vue_${Date.now()}_${Math.random().toString(16).substr(2, 8)}`)
  const mqtttopic = ref('location/sensors/#')

  const serverUrl = ref('ws://127.0.0.1:8000/ws')
  return { mqtturl, mqttuser, mqttpwd, mqttclientid, mqtttopic ,serverUrl}
})
