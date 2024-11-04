


-- unnest liveData

WITH unnested_plays AS 
    (
        SELECT unnest(liveData.plays.allPlays) as all_plays
        FROM post_game_dat
    )
SELECT all_plays.event 
FROM unnested_plays



WITH play_events AS (
    SELECT
        unnest(liveData.plays.allPlays).playEvents.details as details
    FROM
        post_game_data
)
SELECT details FROM play_events;

WITH play_events_cte AS (
    SELECT
        unnest(liveData.plays.allPlays).playEvents as play_events
    FROM
        post_game_data
)
SELECT unnest(play_events)
FROM play_events_cte;


---  GET FOULS
D WITH play_events_cte AS (
·     SELECT
·         unnest(liveData.plays.allPlays).playEvents as play_events
·     FROM
·         post_game_data
· ), unnested_event_details_cte AS (
· SELECT unnest(play_events) AS unnested_event_details
· FROM play_events_cte)
· SELECT unnested_event_details.details.description as description
· FROM unnested_event_details_cte
‣ WHERE description = 'Foul'
· ;


-- Offensive Sub Duck DB Version
WITH play_events AS (
    SELECT
      (unnest(liveData.plays.allPlays, recursive := true)) AS play_events
    FROM
      post_game_data
  ),
  event_details AS (
      SELECT
          unnest(playEvents).details.description AS description
      FROM play_events
  )
  SELECT description
  FROM event_details
  WHERE description LIKE '%Offensive Substitution%';

-- PostgreSQL
WITH play_event_info AS (
SELECT *
	,jsonb_array_elements(pbp_payload->'liveData'->'plays'->'allPlays')->'matchup'->'batter'->'id' AS batter_id
	,jsonb_array_elements(pbp_payload->'liveData'->'plays'->'allPlays')->'matchup'->'batter'->>'fullName' AS batter_fullname
	,jsonb_array_elements(pbp_payload->'liveData'->'plays'->'allPlays')->'matchup'->'batter' AS batter_info
	,jsonb_array_elements(
		(jsonb_array_elements(
			pbp_payload->'liveData'->'plays'->'allPlays'))->'playEvents')->'details'->>'description' AS play_event_description
FROM
    mlb.raw_pbp rp WHERE mlbam_game_id = 775294
)
SELECT 
	*
	play_event_d
FROM play_event_info 
WHERE play_event_description LIKE '%Offensive%'
    
    
'''
	,regexp_matches(
		play_event_description,
		''(?<=replaces\s)(.*)(?=\.)'',
		''g''
	) AS subbed_out
'''




'''
┌───────────────────────────────────────────────────────────────────────┐
│                              description                              │
│                                varchar                                │
├───────────────────────────────────────────────────────────────────────┤
│ Offensive Substitution: Pinch-hitter Chris Taylor replaces Gavin Lux. │
└───────────────────────────────────────────────────────────────────────┘
'''