package main

import (
	"log"

	"IOT-Manage-System/mqtt-saver/utils"
)

func main() {
	client, err := utils.InitMongo()
	if err != nil {
		log.Fatalf("链接mongodb失败: %v", err)
	}
	defer utils.CloseMongo()

	client.Database("")
	for {

	}
}
