package models

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type User struct {
	ID       string `json:"id"`
	First    string `json:"first"`
	Last     string `json:"last"`
	Username string `json:"username"`
}

var Users = []User{
	{ID: "1", First: "JP", Last: "Urrutia", Username: "jpurrutia"},
	{ID: "2", First: "Juan", Last: "Pablo", Username: "jpablo"},
	{ID: "3", First: "Pablo", Last: "Juan", Username: "pjuan"},
}

func ListUsers(c *gin.Context) {
	c.IndentedJSON(http.StatusOK, Users)
}

func GetUser(c *gin.Context) {
	id := c.Param("id")

	for _, user := range Users {
		if user.ID == id {
			c.IndentedJSON(http.StatusOK, user)
			return
		}
	}
	c.IndentedJSON(http.StatusNotFound, gin.H{"error": "user not found"})
}

func CreateUser(c *gin.Context) {
	var newUser User
	if err := c.BindJSON(&newUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	Users = append(Users, newUser)
	c.JSON(http.StatusCreated, newUser)

}
