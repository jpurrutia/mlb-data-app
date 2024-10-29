-- https://datalemur.com/sql-tutorial/sql-time-series-window-function-lead-lag

-- check data lemur
WITH game_level_technical_rc AS (
	SELECT
		mlbam_game_date
		,mlbam_game_id
		,player_id
		,SUM(technical_rc) AS game_technical_rc
	FROM mlb.curated_events_runs_created 
	GROUP BY player_id, mlbam_game_date, mlbam_game_id
	ORDER BY player_id, mlbam_game_date, mlbam_game_id
)
SELECT
	*
	,LEAD(game_technical_rc) OVER (PARTITION BY player_id ORDER BY mlbam_game_date, mlbam_game_id) AS next_game_technical_rc
	,LEAD(game_technical_rc, 3) OVER (PARTITION BY player_id ORDER BY mlbam_game_date, mlbam_game_id) AS next_3_game_technical_rc
	,LEAD(game_technical_rc, 14) OVER (PARTITION BY player_id ORDER BY mlbam_game_date, mlbam_game_id) AS next_14_game_technical_rc
	,LAG(game_technical_rc) OVER (PARTITION BY player_id ORDER BY mlbam_game_date, mlbam_game_id) AS last_game_technical_rc
	,LAG(game_technical_rc, 3) OVER (PARTITION BY player_id ORDER BY mlbam_game_date, mlbam_game_id) AS last_3_game_technical_rc
	,LAG(game_technical_rc, 14) OVER (PARTITION BY player_id ORDER BY mlbam_game_date, mlbam_game_id) AS last_14_game_technical_rc
FROM game_level_technical_rc

-- #TODO: Move to own fule
--- lineup analytics 
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
	WHERE g.game_id = 775294
)
SELECT
	l.game_id
	,l.home_batters
	,c.player_id
	,CAST(l.home_team_id AS integer) AS home_team_id
	,'home' AS home_away
	,c.technical_rc
FROM flattened_game_lineups l
INNER JOIN mlb.curated_events_runs_created c
ON l.game_id = c.mlbam_game_id
AND CAST(l.home_batters AS integer) = CAST(c.player_id AS integer)
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
	WHERE l.game_id = 775294
),
--SELECT * FROM home_batter_game_runs_created
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
	WHERE l.game_id = 775294
)
SELECT * FROM away_batter_game_runs_created

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
	game_id
	,team_id
	,home_away
	,technical_rc
	-- ,SUM(technical_rc)
FROM game_batter_lineup_values
-- WHERE game_id = 775284
GROUP BY team_id, home_away, game_id


SELECT * FROM 