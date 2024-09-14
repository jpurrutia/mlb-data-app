package main

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type user struct {
	ID       string `json:"id"`
	First    string `json:"first"`
	Last     string `json:"last"`
	Username string `json:"username"`
}

type Event struct {
	ID         string    `json:"id"`
	GameID     int       `json:"game_id"`
	Inning     int       `json:"inning"`
	Date       time.Time `json:"date"`
	HalfInning string    `json:"half_inning"`
	Batter     string    `json:"batter"`
	Pitcher    string    `json:"pitcher"`
	Event      string    `json:"event"`
}

var users = []user{
	{ID: "1", First: "JP", Last: "Urrutia", Username: "jpurrutia"},
	{ID: "2", First: "Juan", Last: "Pablo", Username: "jpablo"},
	{ID: "3", First: "Pablo", Last: "Juan", Username: "pjuan"},
}

var DB *gorm.DB

func ConnectDatabase() {
	dsn := "host=localhost user=jpurrutia password=postgres dbname=postgres port=5432 sslmode=disable TimeZone=Asia/Shanghai search_path=mlb"
	database, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("Failed to connect to database!")
	}

	DB = database
}

func setUpRouter() *gin.Engine {
	router := gin.Default()
	router.GET("/users", listUsers)
	router.GET("/users/:id", getUser)
	router.GET("/events", ListEventsController)
	router.POST("/users", createUser)

	return router
}

func listUsers(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, users)
}

func getUser(c *gin.Context) {
	id := c.Param("id")

	for _, user := range users {
		if user.ID == id {
			c.IndentedJSON(http.StatusOK, user)
			return
		}
	}
	c.IndentedJSON(http.StatusNotFound, gin.H{"error": "user not found"})
}

func createUser(c *gin.Context) {
	var newUser user
	if err := c.BindJSON(&newUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	users = append(users, newUser)
	c.JSON(http.StatusCreated, newUser)

}

func listEvents(db *gorm.DB) ([]Event, error) {
	var event []Event
	if err := db.Find(&event).Error; err != nil {
		return nil, err
	}
	return event, nil
}

func ListEventsController(c *gin.Context) {
	var events []Event
	events, err := listEvents(DB)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": events})
}

func main() {
	router := setUpRouter()
	ConnectDatabase()

	router.Run("localhost:8080")
}
