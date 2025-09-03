package main

import (
	"log"

	"IOT-Manage-System/mqtt-saver/utils"
)

func main() {
	client, err := utils.InitDB()
	if err != nil {
		log.Fatalf("init db: %v", err)
	}
	defer utils.CloseDB()

	client.Database("")
}
