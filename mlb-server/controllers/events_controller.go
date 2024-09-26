package controllers

import (
	"net/http"

	"mlb-server/config"
	"mlb-server/models"

	"github.com/gin-gonic/gin"
)

func ListEventsController(c *gin.Context) {
	var events []models.CuratedPBPEvent
	events, err := models.ListEvents(config.DB)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": events})
}
