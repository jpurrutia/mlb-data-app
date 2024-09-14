package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Game struct {
	// TODO: set primary key
	GameID           int       `json:"id"`
	Date             time.Time `json:"date"`
	GameGUID         uuid.UUID `json:"game_guid"`
	Season           int       `json:"season"`
	GameType         string    `json:"game_type"`
	GameStateCode    string    `json:"game_stat_code"`
	GameNumber       int       `json:"game_number"`
	DayNight         string    `json:"day_night"`
	DoubleHeaderFlag bool      `json:"double_header_flag"`
	AwayTeamID       int       `json:"away_team_id"`
	AwayScore        int       `json:"away_score"`
	AwayTeamWins     int       `json:"away_team_wins"`
	AwayTeamLosses   int       `json:"away_team_losses"`
	HomeTeamID       int       `json:"home_team_id"`
	HomeTeamWins     int       `json:"home_team_wins"`
	HomeTeamLosses   int       `json:"home_team_losses"`
	VenueID          int       `json:"venue_id"`
}

func ListGames(db *gorm.DB) ([]Game, error) {
	var games []Game
	if err := db.Find(&games).Error; err != nil {
		return nil, err
	}
	return games, nil
}
