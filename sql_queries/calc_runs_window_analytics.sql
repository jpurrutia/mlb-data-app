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