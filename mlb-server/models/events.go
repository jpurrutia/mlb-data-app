package models

import (
	"time"

	"gorm.io/gorm"
)

type Event struct {
	ID         string    `json:"id"`
	GameID     int       `json:"game_id"`
	Inning     int       `json:"inning"`
	Date       time.Time `json:"date"`
	HalfInning string    `json:"half_inning"`
	BatterId   string    `json:"batter"`
	PitcherId  string    `json:"pitcher"`
	Event      string    `json:"event"`
}

func ListEvents(db *gorm.DB) ([]Event, error) {
	var event []Event
	if err := db.Find(&event).Error; err != nil {
		return nil, err
	}
	return event, nil
}
