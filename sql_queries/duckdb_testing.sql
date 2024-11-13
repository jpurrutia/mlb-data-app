/* unnest liveData */

CREATE TABLE game_data AS
SELECT *
FROM read_json_auto('./sample_data/2024_10_29_ws_game_4_pregame_pbp.json');

CREATE TABLE post_game_data AS
SELECT *
FROM read_json_auto('./sample_data/2024_10_29_ws_game_4_postgame_pbp.json');


WITH unnested_plays AS (
    SELECT unnest(livedata.plays.allplays) AS all_plays
    FROM post_game_dat
)

SELECT all_plays.event
FROM unnested_plays;



WITH play_events AS (
    SELECT unnest(livedata.plays.allplays).playevents.details AS details
    FROM
        post_game_data
)

SELECT details FROM play_events;

WITH play_events_cte AS (
    SELECT unnest(livedata.plays.allplays).playevents AS play_events
    FROM
        post_game_data
)

SELECT unnest(play_events) FROM play_events_cte;


/*  GET FOULS */
WITH play_events_cte AS (
    SELECT unnest(livedata.plays.allplays).playevents AS play_events
    FROM
        post_game_data
),

unnested_event_details_cte AS (
    SELECT unnest(play_events) AS unnested_event_details
    FROM play_events_cte
)

SELECT unnested_event_details.details.description
FROM unnested_event_details_cte
WHERE unnested_event_details_cte.description = 'Foul';


/* Offensive Sub Duck DB Version */
WITH play_events AS (
    SELECT (unnest(livedata.plays.allplays, recursive := true)) AS play_events
    FROM
        post_game_data
),

event_details AS (
    SELECT unnest(playevents).details.description AS description
    FROM play_events
)

SELECT description
FROM event_details
WHERE description LIKE '%Offensive Substitution%';

/* PostgreSQL
WITH play_event_info AS (
    SELECT
        *,
        jsonb_array_elements(pbp_payload -> 'liveData' -> 'plays' -> 'allPlays')
        -> 'matchup'
        -> 'batter'
        -> 'id' AS batter_id,
        jsonb_array_elements(pbp_payload -> 'liveData' -> 'plays' -> 'allPlays')
        -> 'matchup'
        -> 'batter'
        ->> 'fullName' AS batter_fullname,
        jsonb_array_elements(pbp_payload -> 'liveData' -> 'plays' -> 'allPlays')
        -> 'matchup'
        -> 'batter' AS batter_info,
        jsonb_array_elements(
            (jsonb_array_elements(
                pbp_payload -> 'liveData' -> 'plays' -> 'allPlays'
            )) -> 'playEvents'
        ) -> 'details' ->> 'description' AS play_event_description
    FROM
        mlb.raw_pbp AS rp
    WHERE mlbam_game_id = 775294
)

SELECT *
FROM play_event_info
WHERE play_event_description LIKE '%Offensive%';
	,regexp_matches(
		play_event_description,
		''(?<=replaces\s)(.*)(?=\.)'',
		''g''
	) AS subbed_out

┌───────────────────────────────────────────────────────────────────────┐
│                              description                              │
│                                varchar                                │
├───────────────────────────────────────────────────────────────────────┤
│ Offensive Substitution: Pinch-hitter Chris Taylor replaces Gavin Lux. │
└───────────────────────────────────────────────────────────────────────┘
*/
