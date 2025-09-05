package utils

import (
	"log"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

var MQTTClient mqtt.Client

// InitMQTT 由 main.go 主动调用
func InitMQTT() {
	url := GetEnv("MQTT_BROKER", "ws://8.133.17.175:8083")
	opts := mqtt.NewClientOptions().
		AddBroker(url).
		SetClientID("mqtt_saver").
		SetUsername(GetEnv("MQTT_USERNAME", "admin")).
		SetPassword(GetEnv("MQTT_PASSWORD", "admin")).
		SetKeepAlive(60 * time.Second).
		SetPingTimeout(10 * time.Second).
		SetAutoReconnect(true).
		SetMaxReconnectInterval(10 * time.Second).
		SetCleanSession(false)

	MQTTClient = mqtt.NewClient(opts)
	if token := MQTTClient.Connect(); token.Wait() && token.Error() != nil {
		log.Fatalf("mqtt connect error: %v", token.Error())
	}
	log.Println("连接" + url + " mqtt broker 成功")
}

func CloseMQTT() {
	if MQTTClient != nil && MQTTClient.IsConnected() {
		MQTTClient.Disconnect(250) // 250 ms 等待内部 goroutine 结束
		log.Println("mqtt disconnected")
	}
	MQTTClient = nil // 方便再 Init
	log.Println("断开mqtt broker连接成功")
}

