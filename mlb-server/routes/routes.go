package routes

import (
	"mlb-server/controllers"

	"github.com/gin-gonic/gin"
)

func SetUpRouter() *gin.Engine {
	router := gin.Default()

	router.GET("/events", controllers.ListEventsController)
	//router.GET("/users", listUsers)
	//router.GET("/users/:id", getUser)
	//router.POST("/users", createUser)

	return router
}
