package client

import (
	"log"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

// MustSubscribe 一次性挂接所有订阅，失败 fatal。
func MustSubscribe(c mqtt.Client) {
	// online 主题需要两个回调
	token := c.Subscribe("online/#", 1, MultiHandler(EchoMsg))
	if token.Wait() && token.Error() != nil {
		log.Fatalf("[FATAL] 订阅 online/# 失败: %v", token.Error())
	}

	// location 主题只要打印
	token = c.Subscribe("location/#", 1, MultiHandler())
	if token.Wait() && token.Error() != nil {
		log.Fatalf("[FATAL] 订阅 location/# 失败: %v", token.Error())
	}

	log.Println("[INFO] MQTT 订阅已完成")
}

// MultiHandler 把多个 mqtt.MessageHandler 串成一次调用。
func MultiHandler(handlers ...mqtt.MessageHandler) mqtt.MessageHandler {
	return func(c mqtt.Client, m mqtt.Message) {
		for _, h := range handlers {
			h(c, m)
		}
	}
}
