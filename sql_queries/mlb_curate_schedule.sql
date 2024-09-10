WITH dates_payload AS (
	SELECT jsonb_array_elements(schedule_payload->'dates') AS dates_payload
	FROM mlb.raw_schedule
),
flattened_games_payload AS (
	SELECT dates_payload->>'date' AS date
		,jsonb_array_elements(dates_payload->'games') AS games
	FROM dates_payload
)
SELECT date
	,games->>'gamePk' AS game_id
	,games->>'gameGuid' AS game_guid
	,games->>'season' AS season
	,games->>'gameType' AS game_type
	--,CASE
	--	WHEN games->'status'->>'statusCode' = 'F' AS game_status THEN
	--	WHEN games->'status'->>'statusCode' = 'F' AS game_status THEN
	--END AS games_
	,games->'status'->>'detailedState' AS game_state
	,games->'teams'->'away'->'team'->>'id' AS away_team_id
	,games->>'dayNight' AS day_night
	,CASE
		WHEN games->>'doubleHeader' = 'N' THEN 0
		WHEN games->>'doubleHeader' = 'Y' THEN 1
		ELSE NULL
	END AS double_header_flag
	-- games->'team's->'away'->'team'->'name' AS away_team_name
	
	,games->'teams'->'away'->>'score' AS away_score
	,games->'teams'->'away'->'leagueRecord'->>'wins' AS away_team_wins
	,games->'teams'->'away'->'leagueRecord'->>'losses' AS away_team_losses
	
	,games->'teams'->'home'->'team'->>'id' AS home_team_id
	-- games->'team's->'home'->'team'->'name' AS home_team_name
	,games->'teams'->'home'->'score' AS home_score
	,games->'teams'->'home'->'leagueRecord'->>'wins' AS away_team_wins
	,games->'teams'->'home'->'leagueRecord'->>'losses' AS away_team_losses
	
	,games->'venue'->'id' AS venue_id
	
	
FROM flattened_games_payload