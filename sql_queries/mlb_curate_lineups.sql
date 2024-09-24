CREATE TABLE curated_lineups AS (
SELECT
    mlbam_game_date AS game_date,
    mlbam_game_id,
    lineups_payload->'away'->>'probablePitcher' AS away_probable_pitcher,
    lineups_payload->'home'->>'probablePitcher' AS home_probable_pitcher,
    lineups_payload->'away'->'battingOrder' AS away_batters,
    lineups_payload->'home'->'battingOrder' AS home_batters,
    lineups_payload->'away'->'bullpen' AS away_bullpen,
    lineups_payload->'home'->'bullpen' AS home_bullpen
FROM mlb.raw_lineups
ORDER BY mlbam_game_date, mlbam_game_id
)
