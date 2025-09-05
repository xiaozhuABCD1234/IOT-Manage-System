package main

import (
	"encoding/json"
	"fmt"
	"log"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

type Msg struct {
	ID   string `json:"id"`
	Sens []Sen  `json:"sens"`
}

type Sen struct {
	Name  string `json:"n"`
	Unit  string `json:"u"`
	Value any    `json:"v"`
}

func main() {
	// 连接 MQTT
	opts := mqtt.NewClientOptions().
		AddBroker("ws://localhost:8083/mqtt"). // 公共测试 Broker
		SetClientID("go-mqtt-client").
		SetUsername("admin").
		SetPassword("admin")

	client := mqtt.NewClient(opts)
	if token := client.Connect(); token.Wait() && token.Error() != nil {
		log.Fatal(token.Error())
	}
	defer client.Disconnect(250)

	// 构造要发的 JSON 数据
	msg := Msg{
		ID: "112",
		Sens: []Sen{
			{Name: "temperature", Unit: "°C", Value: 23.5},
			{Name: "humidity", Unit: "%", Value: 68},
			{Name: "RTK", Unit: "deg", Value: []float64{121.791851, 30.904012}},
		},
	}

	payload, err := json.Marshal(msg)
	if err != nil {
		log.Fatal(err)
	}

	// 发布
	topic := "device/rtk"
	if token := client.Publish(topic, 0, false, payload); token.Wait() && token.Error() != nil {
		log.Fatal(token.Error())
	}
	fmt.Printf("已发布：%s\n", payload)

	time.Sleep(time.Second) // 等一会儿让消息发完
}
