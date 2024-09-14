package controllers

import (
	"mlb-server/config"
	"mlb-server/models"
	"net/http"

	"github.com/gin-gonic/gin"
)

func ListGamesController(c *gin.Context) {
	var games []models.Game
	games, err := models.ListGames(config.DB)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"games": games})
}
