CREATE TABLE mlb.curated_pbp_events AS (
WITH all_plays AS (
SELECT
id AS id,
pbp_payload->'gameData'->'datetime'->>'officialDate' AS game_date,
pbp_payload->>'gamePk' as game_id,
pbp_payload->'gameData'->'game'->>'season' as season,
pbp_payload->'gameData'->'game'->>'type' as game_type,
pbp_payload->'gameData'->'game'->>'doubleHeader' as double_header,
pbp_payload->'gameData'->'teams'->'away'->>'id' as v_tm_id,
pbp_payload->'gameData'->'teams'->'away'->>'name' as v_tm_name,
pbp_payload->'gameData'->'teams'->'away'->>'abbreviation' as v_tm,
pbp_payload->'gameData'->'teams'->'home'->>'id' as h_tm_id,
pbp_payload->'gameData'->'teams'->'home'->>'name' as h_tm_name,
pbp_payload->'gameData'->'teams'->'home'->>'abbreviation' as h_tm,
pbp_payload->'gameData'->'teams'->'home'->'venue'->>'id' as park_id,
pbp_payload->'gameData'->'weather'->>'temp' as temperature,
pbp_payload->'gameData'->'weather'->>'wind' as wind,
pbp_payload->'gameData'->'weather'->>'condition' as weather_conditions,
pbp_payload->'gameData'->'datetime'->>'time' as game_time,
pbp_payload->'gameData'->'datetime'->>'dayNight' as day_night,
jsonb_array_elements(pbp_payload->'liveData'->'plays'->'allPlays') as all_plays
FROM mlb.raw_pbp
),
play_events AS (
    SELECT
        id,
        game_id,
        game_date,
        all_plays->'about'->>'inning' as inning,
        all_plays->'about'->>'halfInning' as half_inning,
        all_plays->'matchup'->'batter'->>'fullName' as batter,
        all_plays->'matchup'->'pitcher'->>'fullName' as pitcher,
        all_plays->'result'->>'event' as event,
        all_plays->'result'->>'description' as description,
        (
            SELECT jsonb_agg(jsonb_build_object(
                'event', runner->'details'->>'event',
                'runner', runner->'details'->'runner'->>'fullName',
                'startBase', runner->'movement'->>'start',
                'endBase', runner->'movement'->>'end'
            ))
            FROM jsonb_array_elements(all_plays->'runners') as runner
            WHERE runner->'details'->>'event' != all_plays->'result'->>'event'
        ) as runner_events
    FROM all_plays
),
unnested_events AS (
    SELECT
        id,
        game_id,
        game_date,
        inning,
        half_inning,
        batter,
        pitcher,
        event,
        runner_events
    FROM play_events
    UNION ALL
    SELECT
        id,
        game_id,
        game_date,
        inning,
        half_inning,
        runner_event->>'runner' as batter,
        pitcher,
        runner_event->>'event' as event,
        NULL as runner_events
    FROM play_events,
    jsonb_array_elements(CASE WHEN runner_events IS NULL THEN '[]'::jsonb ELSE runner_events END) as runner_event
)
SELECT
    id,
    game_id,
    game_date,
    inning,
    half_inning,
    batter,
    pitcher,
    event
FROM unnested_events
ORDER BY id, game_id, inning::int, 
    CASE WHEN half_inning = 'top' THEN 0 ELSE 1 END,
    id
)