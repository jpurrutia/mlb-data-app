package main

import (
	"mlb-server/config"
	"mlb-server/routes"
)

func main() {
	config.ConnectDatabase()
	router := routes.SetUpRouter()
	router.Run("localhost:8080")
}
