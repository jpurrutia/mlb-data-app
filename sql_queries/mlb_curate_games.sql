-- DDL Updated and added to 
INSERT INTO mlb.games (
WITH dates_payload AS (
	SELECT jsonb_array_elements(schedule_payload->'dates') AS dates_payload
	FROM mlb.raw_schedule
),
flattened_games_payload AS (
	SELECT dates_payload->>'date' AS date
		,jsonb_array_elements(dates_payload->'games') AS games
	FROM dates_payload
)
SELECT 
	(games->>'gamePk')::integer AS game_id
	,CAST(date AS DATE) AS date
	,(games->>'gameGuid')::uuid AS game_guid
	,games->>'season' AS season
	,games->>'gameType' AS game_type
	--,CASE
	--	WHEN games->'status'->>'statusCode' = 'F' AS game_status THEN
	--	WHEN games->'status'->>'statusCode' = 'F' AS game_status THEN
	--END AS games_
	,games->'status'->>'codedGameState' AS game_state_code
	,games->'status'->>'detailedState' AS game_state
	,(games->>'gameNumber')::integer AS game_number
	,(games->>'dayNight')::text AS day_night
	,(CASE
		WHEN games->>'doubleHeader' = 'N' THEN 0
		WHEN games->>'doubleHeader' = 'Y' THEN 1
		ELSE NULL
	END)::boolean AS double_header_flag
	,(games->'teams'->'away'->'team'->>'id')::integer AS away_team_id	
	-- games->'team's->'away'->'team'->'name' AS away_team_name
	,(games->'teams'->'away'->>'score')::integer AS away_score 
	,(games->'teams'->'away'->'leagueRecord'->>'wins')::integer AS away_team_wins
	,(games->'teams'->'away'->'leagueRecord'->>'losses')::integer AS away_team_losses
	,(games->'teams'->'home'->'team'->>'id')::integer AS home_team_id
	-- games->'team's->'home'->'team'->'name' AS home_team_name
	,(games->'teams'->'home'->'score')::integer AS home_score
	,(games->'teams'->'home'->'leagueRecord'->>'wins')::integer AS home_team_wins
	,(games->'teams'->'home'->'leagueRecord'->>'losses')::integer AS home_team_losses
	,(games->'venue'->'id')::integer AS venue_id
FROM flattened_games_payload
)
