WITH play_event_info AS (
    SELECT

        mlbam_game_date,
        mlbam_game_id,
        jsonb_array_elements(pbp_payload -> 'liveData' -> 'plays' -> 'allPlays')
        -> 'matchup'
        -> 'batter'
        -> 'id' AS batter_id,
        --,jsonb_array_elements(pbp_payload->'liveData'->'plays'->'allPlays')->'matchup'->'batter'->>'fullName' AS batter_fullname
        --,jsonb_array_elements(pbp_payload->'liveData'->'plays'->'allPlays')-- ->'matchup'->'batter' AS batter_info
        jsonb_array_elements(
            (jsonb_array_elements(
                pbp_payload -> 'liveData' -> 'plays' -> 'allPlays'
            )) -> 'playEvents'
        --->'replacedPlayer'->>'id' AS play_events
        ) -> 'replacedPlayer' ->> 'id' AS replaced_player,
        jsonb_array_elements(
            (jsonb_array_elements(
                pbp_payload -> 'liveData' -> 'plays' -> 'allPlays'
            )) -> 'playEvents'
        ) -> 'details' ->> 'description' AS play_event_description
    FROM
        mlb.raw_pbp rp
    WHERE mlbam_game_id = 775294
),

filtered_substitution_events AS (
    SELECT *
    FROM play_event_info
    WHERE replaced_player IS NOT NULL
),

curated_lineups AS (
    SELECT
        mlbam_game_date AS game_date,
        mlbam_game_id,
        (
            lineups_payload -> 'away' ->> 'probablePitcher'
        )::integer AS away_probable_pitcher,
        (
            lineups_payload -> 'home' ->> 'probablePitcher'
        )::integer AS home_probable_pitcher,
        lineups_payload -> 'away' -> 'battingOrder' AS away_batters,
        lineups_payload -> 'home' -> 'battingOrder' AS home_batters,
        lineups_payload -> 'away' -> 'bullpen' AS away_bullpen,
        lineups_payload -> 'home' -> 'bullpen' AS home_bullpen
    FROM mlb.raw_lineups
    ORDER BY mlbam_game_date, mlbam_game_id
),

substitutions_events AS (
    SELECT
        --e.id
        --,mlbam_game_date
        e.mlbam_game_id,
        --,pbp_payload
        e.batter_id,
        l.home_batters,
        e.play_event_description,
        CASE
            WHEN e.play_event_description LIKE '%Defensive Substitution%'
                THEN 'defensive sub'
            WHEN e.play_event_description LIKE '%Offensive Substitution%'
                THEN 'offensive sub'
            ELSE ''
        END AS substitution_type
    FROM play_event_info e
    JOIN curated_lineups l
        ON e.mlbam_game_id = l.mlbam_game_id
    WHERE play_event_description LIKE '%Substitution%'
)

SELECT
    play_event_description,
    substitution_type,
    (
        regexp_matches(
            play_event_description,
            '(\w+ \w+)\s+replaces\s+(\w+ \w+)',
            'g'
        )
    )[1] AS test_1
    ,
    (
        regexp_matches(
            play_event_description,
            '(\w+ \w+)\s+replaces\s+(\w+ \w+)',
            'g'
        )
    )[2] AS test_2

    /*(
        regexp_matches(
            play_event_description, '(\w+ \w+)\s+replaces\s+(\w+ \w+)', 'g'
        )
    )[1] AS subbed_in,
    (
        regexp_matches(
            play_event_description, '(\w+ \w+)\s+replaces\s+(\w+ \w+)', 'g'
        )
    )[2] AS subbed_out
    */
FROM substitutions_events;

/*
                                             play_event_description                                             | substitution_type |    subbed_in    |  subbed_out
----------------------------------------------------------------------------------------------------------------+--------------------+-----------------+---------------
 Offensive Substitution: Pinch-hitter Jose Trevino replaces Austin Wells.                                       | offensive sub      | Jose Trevino    | Austin Wells
 Offensive Substitution: Pinch-runner Oswaldo Cabrera replaces Anthony Rizzo.                                   | offensive sub      | Oswaldo Cabrera | Anthony Rizzo
 Defensive Substitution: Chris Taylor replaces left fielder Teoscar Hernández, batting 3rd, playing left field. | defensive sub      | Chris Taylor    | left fielder
*/
