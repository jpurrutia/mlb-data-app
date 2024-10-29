-- DDL Updated and added to 
WITH dates_payload AS (
	SELECT jsonb_array_elements(schedule_payload->'dates') AS dates_payload
	FROM mlb.raw_schedule
),
flattened_games_payload AS (
	SELECT dates_payload->>'date' AS date
		,jsonb_array_elements(dates_payload->'games') AS games
	FROM dates_payload
),
transformed_games AS (
SELECT 
	(games->>'gamePk')::integer AS game_id
	,CAST(date AS DATE) AS game_date
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
),
flatten_game_duplicates AS (
	SELECT *
		,ROW_NUMBER() OVER (PARTITION BY game_id ORDER BY game_date DESC) AS row_num
	FROM transformed_games
),
filter_postponed_games AS (
	SELECT *
	FROM flatten_game_duplicates WHERE row_num = 1 -- AND game_id IN (238, 1157, 2112, 4394)
)
INSERT INTO mlb.curated_games (game_id, date, game_guid, season, game_type, game_state_code, game_state
,game_number, day_night, double_header_flag, away_team_id, away_score, away_team_wins
,away_team_losses, home_team_id, home_score, home_team_wins, home_team_losses, venue_id
)
SELECT
	game_id
	,game_date
	,game_guid
	,season
	,game_type
	,game_state_code
	,game_state
	,game_number
	,day_night
	,double_header_flag
	,away_team_id
	,away_score
	,away_team_wins
	,away_team_losses
	,home_team_id
	,home_score
	,home_team_wins
	,home_team_losses
	,venue_id
FROM filter_postponed_games
ON CONFLICT (game_id)
DO UPDATE
SET date = EXCLUDED.date
,game_guid = EXCLUDED.game_guid
,game_type = EXCLUDED.game_type
,game_state_code = EXCLUDED.game_state_code
,game_state = EXCLUDED.game_state
,game_number = EXCLUDED.game_number
,day_night = EXCLUDED.day_night
,double_header_flag = EXCLUDED.double_header_flag
,away_team_id = EXCLUDED.away_team_id
,away_score = EXCLUDED.away_score
,away_team_wins = EXCLUDED.away_team_wins
,away_team_losses = EXCLUDED.away_team_losses
,home_team_id = EXCLUDED.home_team_id
,home_score = EXCLUDED.home_score
,home_team_wins = EXCLUDED.home_team_wins
,home_team_losses = EXCLUDED.home_team_losses
,venue_id = EXCLUDED.venue_id
