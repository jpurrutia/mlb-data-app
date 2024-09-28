WITH flattened_game_lineups AS (
	SELECT g.game_id
		,g.date AS game_date
		,g.away_team_id
		,l.away_probable_pitcher
		,jsonb_array_elements(l.away_bullpen) AS away_bullpen
		,jsonb_array_elements(l.away_batters) AS away_batters
		,g.home_team_id
		,l.home_probable_pitcher
		,jsonb_array_elements(l.home_bullpen) AS home_bullpen
		,jsonb_array_elements(l.home_batters) AS home_batters
	FROM mlb.curated_games g
	JOIN mlb.curated_lineups l
	ON g.game_id = l.mlbam_game_id
),
home_batter_game_runs_created AS (
	SELECT l.game_id
		,l.home_batters
		,CAST(l.home_team_id AS integer) AS home_team_id
		,'home' AS home_away
		,c.technical_rc
	FROM flattened_game_lineups l
	JOIN mlb.curated_events_runs_created c
	ON l.game_id = c.mlbam_game_id 
	AND CAST(l.home_batters AS integer) = CAST(c.player_id AS integer)
),
away_batter_game_runs_created AS (
	SELECT l.game_id
		,l.away_batters
		,CAST(l.away_team_id AS integer) AS away_team_id
		,'away' AS home_away
		,c.technical_rc
	FROM flattened_game_lineups l
	JOIN mlb.curated_events_runs_created c
	ON l.game_id = c.mlbam_game_id 
	AND CAST(l.away_batters AS integer) = CAST(c.player_id AS integer)
),
game_batter_lineup_values AS (
	SELECT game_id
		,home_team_id AS team_id	
		,home_batters AS batters
		,home_away
		,technical_rc
	FROM home_batter_game_runs_created
	UNION ALL
	SELECT game_id
		,away_team_id AS team_id
		,away_batters AS batters
		,home_away
		,technical_rc
	FROM away_batter_game_runs_created
)
SELECT 
	team_id
	,home_away
	,SUM(technical_rc)
FROM game_batter_lineup_values
GROUP BY team_id, home_away

