INSERT INTO mlb.curated_lineups (
SELECT
    mlbam_game_date AS game_date
    ,mlbam_game_id
    ,(lineups_payload->'away'->>'probablePitcher')::integer AS away_probable_pitcher
    ,(lineups_payload->'home'->>'probablePitcher')::integer AS home_probable_pitcher
    ,lineups_payload->'away'->'battingOrder' AS away_batters
    ,lineups_payload->'home'->'battingOrder' AS home_batters
    ,lineups_payload->'away'->'bullpen' AS away_bullpen
    ,lineups_payload->'home'->'bullpen' AS home_bullpen
FROM mlb.raw_lineups
ORDER BY mlbam_game_date, mlbam_game_id
)


-- Seconv version with lineup change and substitution
WITH play_event_info AS (
SELECT
	mlbam_game_date
	,mlbam_game_id
	,jsonb_array_elements(pbp_payload->'liveData'->'plays'->'allPlays')->'matchup'->'batter'->'id' AS batter_id
	--,jsonb_array_elements(pbp_payload->'liveData'->'plays'->'allPlays')->'matchup'->'batter'->>'fullName' AS batter_fullname
	--,jsonb_array_elements(pbp_payload->'liveData'->'plays'->'allPlays')-- ->'matchup'->'batter' AS batter_info
	,jsonb_array_elements( 
		(jsonb_array_elements(
			pbp_payload->'liveData'->'plays'->'allPlays'))->'playEvents')->'replacedPlayer'->>'id' AS replaced_player --->'replacedPlayer'->>'id' AS play_events
	,jsonb_array_elements(
		(jsonb_array_elements(
			pbp_payload->'liveData'->'plays'->'allPlays'))->'playEvents')->'details'->>'description' AS play_event_description
FROM
    mlb.raw_pbp rp WHERE mlbam_game_id = 775294
),
filtered_substitution_events AS (
SELECT *
FROM play_event_info
WHERE replaced_player IS NOT NULL
),
curated_lineups AS (
SELECT
    mlbam_game_date AS game_date
    ,mlbam_game_id
    ,(lineups_payload->'away'->>'probablePitcher')::integer AS away_probable_pitcher
    ,(lineups_payload->'home'->>'probablePitcher')::integer AS home_probable_pitcher
    ,lineups_payload->'away'->'battingOrder' AS away_batters
    ,lineups_payload->'home'->'battingOrder' AS home_batters
    ,lineups_payload->'away'->'bullpen' AS away_bullpen
    ,lineups_payload->'home'->'bullpen' AS home_bullpen
FROM mlb.raw_lineups
ORDER BY mlbam_game_date, mlbam_game_id
),
batting_order_changes AS (
SELECT
	e.id
	--,mlbam_game_date
	,e.mlbam_game_id
	--,pbp_payload
	,e.batter_id
	,l.home_batters
	,batter_fullname
	,batter_info
	--,play_event_description
	,CASE WHEN e.play_event_description LIKE '%Defensive Substitution%'
	THEN 'defensive sub'
	WHEN e.play_event_description LIKE '%Offensive Substitution%'
	THEN 'offensive sub'
	ELSE '' END AS sub_test
	,(regexp_matches(e.play_event_description, '(\w+ \w+)\s+replaces\s+(\w+ \w+)', 'g'))[1] AS subbed_in
	,(regexp_matches(e.play_event_description, '(\w+ \w+)\s+replaces\s+(\w+ \w+)', 'g'))[2] AS subbed_out
FROM play_event_info e
JOIN curated_lineups l
ON e.mlbam_game_id = l.mlbam_game_id
WHERE play_event_description LIKE '%Substitution%'
)
SELECT * FROM batting_order_changes;

/* BAD QUERIES

WITH game_data AS (
    SELECT DISTINCT
        mlbam_game_date AS game_date,
        mlbam_game_id,
        lineups_payload->'away'->>'probablePitcher' AS away_probable_pitcher,
        lineups_payload->'home'->>'probablePitcher' AS home_probable_pitcher
    FROM mlb.raw_lineups
),
away_batters AS (
    SELECT
        mlbam_game_id,
        jsonb_array_elements(lineups_payload->'away'->'battingOrder') AS away_batters
    FROM mlb.raw_lineups
),
home_batters AS (
    SELECT
        mlbam_game_id,
        jsonb_array_elements(lineups_payload->'home'->'battingOrder') AS home_batters
    FROM mlb.raw_lineups
),
away_bullpen AS (
    SELECT
        mlbam_game_id,
        jsonb_array_elements(lineups_payload->'away'->'bullpen') AS away_bullpen
    FROM mlb.raw_lineups
),
home_bullpen AS (
    SELECT
        mlbam_game_id,
        jsonb_array_elements(lineups_payload->'home'->'bullpen') AS home_bullpen
    FROM mlb.raw_lineups
)
SELECT
    gd.game_date,
    gd.mlbam_game_id,
    ab.away_batters,
    gd.away_probable_pitcher,
    abp.away_bullpen,
    hb.home_batters,
    hbp.home_bullpen,
    gd.home_probable_pitcher
FROM game_data gd
LEFT JOIN away_batters ab ON gd.mlbam_game_id = ab.mlbam_game_id
LEFT JOIN home_batters hb ON gd.mlbam_game_id = hb.mlbam_game_id
LEFT JOIN away_bullpen abp ON gd.mlbam_game_id = abp.mlbam_game_id
LEFT JOIN home_bullpen hbp ON gd.mlbam_game_id = hbp.mlbam_game_id
ORDER BY gd.game_date, gd.mlbam_game_id, ab.away_batters, hb.home_batters, abp.away_bullpen, hbp.home_bullpen;


INSERT INTO mlb.curated_lineups (
SELECT
    mlbam_game_date AS game_date
    ,mlbam_game_id
    ,(lineups_payload->'away'->>'probablePitcher')::integer AS away_probable_pitcher
    ,(lineups_payload->'home'->>'probablePitcher')::integer AS home_probable_pitcher
    ,lineups_payload->'away'->'battingOrder' AS away_batters
    ,lineups_payload->'home'->'battingOrder' AS home_batters
    ,lineups_payload->'away'->'bullpen' AS away_bullpen
    ,lineups_payload->'home'->'bullpen' AS home_bullpen
FROM mlb.raw_lineups
ORDER BY mlbam_game_date, mlbam_game_id
)


WITH flattened_lineup AS (
	SELECT
		mlbam_game_date AS game_date
		,mlbam_game_id
		,jsonb_array_elements(lineups_payload->'away'->'battingOrder') AS away_batters
		,lineups_payload->'away'->>'probablePitcher' AS away_probable_pitcher
		,jsonb_array_elements(lineups_payload->'away'->'bullpen') AS away_bullpen
		,jsonb_array_elements(lineups_payload->'home'->'battingOrder') AS home_batters
		,jsonb_array_elements(lineups_payload->'home'->'bullpen') AS home_bullpen
		,lineups_payload->'home'->>'probablePitcher' AS home_probable_pitcher
FROM mlb.raw_lineups
)
SELECT
	*
FROM  flattened_lineup
*/