package main

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

// client

// user as application user
type user struct {
	ID       string `json:"id"`
	First    string `json:"first"`
	Last     string `json:"last"`
	Username string `json:"username"`
}

// players, lineup, team, game

var users = []user{
	{ID: "1", First: "JP", Last: "Urrutia", Username: "jpurrutia"},
	{ID: "2", First: "John", Last: "Smith", Username: "jsmith"},
	{ID: "3", First: "Joe", Last: "Schmoe", Username: "jschmoe"},
}

func getUsers(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, users)
}

// accept user name, validate it, print user to stdout
// handle duplicate user names or empty parameters

func postUsers(c *gin.Context) {
	var newUser user

	// Call BindJson to binf the json to newUser
	if err := c.BindJSON(&newUser); err != nil {
		return
	}

	fmt.Println("This users are:", users)

	found := false

	for _, username := range users {

		if username == newUser {
			found = true
			fmt.Println("The slice contains", newUser)
			break
		}
	}
	if found == false {
		fmt.Println("The slice does not contain", newUser)
		users = append(users, newUser)
		c.IndentedJSON(http.StatusCreated, newUser)
	}

}

func getUserByID(c *gin.Context) {
	id := c.Param("id")

	for _, a := range users {
		if a.ID == id {
			c.IndentedJSON(http.StatusOK, a)
			return
		}
	}
	c.IndentedJSON(http.StatusNotFound, gin.H{"message": "album not found"})
}

func main() {
	router := gin.Default()
	router.GET("/users", getUsers)
	router.GET("/users/:id", getUserByID)
	router.POST("/users", postUsers)

	fmt.Println("Server running on http://localhost:8080")
	router.Run("localhost:8080")
}
