package models

import (
	"time"

	"gorm.io/gorm"
)

type CuratedPBPEvent struct {
	ID         string    `json:"id"`
	GameID     int       `json:"game_id"`
	Inning     int       `json:"inning"`
	Date       time.Time `json:"date"`
	HalfInning string    `json:"half_inning"`
	BatterId   int       `json:"batter_id"`
	PitcherId  int       `json:"pitcher_id"`
	Event      string    `json:"event"`
}

func ListEvents(db *gorm.DB, limit int) ([]CuratedPBPEvent, error) {
	var curatedPbpEvent []CuratedPBPEvent
	if err := db.Limit(limit).Find(&curatedPbpEvent).Error; err != nil {
		return nil, err
	}
	return curatedPbpEvent, nil
}
