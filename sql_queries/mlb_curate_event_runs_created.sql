-- INSERT INTO mlb.curated_events_runs_created (
WITH events AS (
  SELECT 
    player_id,
    mlbam_game_id,
    mlbam_game_date,
    event,
    COUNT(*) as event_count
  FROM (
    SELECT 
      COALESCE(batter_id, pitcher_id) as player_id,
      mlbam_game_id,
      mlbam_game_date::date as mlbam_game_date,
      event
    FROM mlb.curated_pbp_events
  ) subquery
  GROUP BY player_id, mlbam_game_id, mlbam_game_date, event
),
event_counts AS (
SELECT 
  player_id,
  mlbam_game_id,
  mlbam_game_date,
  SUM(CASE WHEN event = 'Balk' THEN event_count ELSE 0 END) as balk,
  SUM(CASE WHEN event = 'Batter Out' THEN event_count ELSE 0 END) as batter_out,
  SUM(CASE WHEN event = 'Bunt Groundout' THEN event_count ELSE 0 END) as bunt_groundout,
  SUM(CASE WHEN event = 'Bunt Lineout' THEN event_count ELSE 0 END) as bunt_lineout,
  SUM(CASE WHEN event = 'Bunt Pop Out' THEN event_count ELSE 0 END) as bunt_pop_out,
  SUM(CASE WHEN event = 'Catcher Interference' THEN event_count ELSE 0 END) as catcher_interference,
  SUM(CASE WHEN event = 'Caught Stealing 2B' THEN event_count ELSE 0 END) as caught_stealing_2b,
  SUM(CASE WHEN event = 'Caught Stealing 3B' THEN event_count ELSE 0 END) as caught_stealing_3b,
  SUM(CASE WHEN event = 'Caught Stealing Home' THEN event_count ELSE 0 END) as caught_stealing_home,
  SUM(CASE WHEN event = 'Double' THEN event_count ELSE 0 END) as double,
  SUM(CASE WHEN event = 'Double Play' THEN event_count ELSE 0 END) as double_play,
  SUM(CASE WHEN event = 'Field Error' THEN event_count ELSE 0 END) as field_error,
  SUM(CASE WHEN event = 'Fielders Choice' THEN event_count ELSE 0 END) as fielders_choice,
  SUM(CASE WHEN event = 'Fielders Choice Out' THEN event_count ELSE 0 END) as fielders_choice_out,
  SUM(CASE WHEN event = 'Flyout' THEN event_count ELSE 0 END) as flyout,
  SUM(CASE WHEN event = 'Forceout' THEN event_count ELSE 0 END) as forceout,
  SUM(CASE WHEN event = 'Game Advisory' THEN event_count ELSE 0 END) as game_advisory,
  SUM(CASE WHEN event = 'Grounded Into DP' THEN event_count ELSE 0 END) as grounded_into_dp,
  SUM(CASE WHEN event = 'Groundout' THEN event_count ELSE 0 END) as groundout,
  SUM(CASE WHEN event = 'Hit By Pitch' THEN event_count ELSE 0 END) as hit_by_pitch,
  SUM(CASE WHEN event = 'Home Run' THEN event_count ELSE 0 END) as home_run,
  SUM(CASE WHEN event = 'Intent Walk' THEN event_count ELSE 0 END) as intent_walk,
  SUM(CASE WHEN event = 'Lineout' THEN event_count ELSE 0 END) as lineout,
  SUM(CASE WHEN event IS NULL THEN event_count ELSE 0 END) as nan,
  SUM(CASE WHEN event = 'Pickoff 1B' THEN event_count ELSE 0 END) as pickoff_1b,
  SUM(CASE WHEN event = 'Pickoff 2B' THEN event_count ELSE 0 END) as pickoff_2b,
  SUM(CASE WHEN event = 'Pickoff 3B' THEN event_count ELSE 0 END) as pickoff_3b,
  SUM(CASE WHEN event = 'Pickoff Caught Stealing 2B' THEN event_count ELSE 0 END) as pickoff_caught_stealing_2b,
  SUM(CASE WHEN event = 'Pickoff Caught Stealing 3B' THEN event_count ELSE 0 END) as pickoff_caught_stealing_3b,
  SUM(CASE WHEN event = 'Pickoff Caught Stealing Home' THEN event_count ELSE 0 END) as pickoff_caught_stealing_home,
  SUM(CASE WHEN event = 'Pitching Substitution' THEN event_count ELSE 0 END) as pitching_substitution,
  SUM(CASE WHEN event = 'Pop Out' THEN event_count ELSE 0 END) as pop_out,
  SUM(CASE WHEN event = 'Runner Out' THEN event_count ELSE 0 END) as runner_out,
  SUM(CASE WHEN event = 'Runner Placed On Base' THEN event_count ELSE 0 END) as runner_placed_on_base,
  SUM(CASE WHEN event = 'Sac Bunt' THEN event_count ELSE 0 END) as sac_bunt,
  SUM(CASE WHEN event = 'Sac Fly' THEN event_count ELSE 0 END) as sac_fly,
  SUM(CASE WHEN event = 'Sac Fly Double Play' THEN event_count ELSE 0 END) as sac_fly_double_play,
  SUM(CASE WHEN event = 'Single' THEN event_count ELSE 0 END) as single,
  SUM(CASE WHEN event = 'Strikeout' THEN event_count ELSE 0 END) as strikeout,
  SUM(CASE WHEN event = 'Strikeout Double Play' THEN event_count ELSE 0 END) as strikeout_double_play,
  SUM(CASE WHEN event = 'Triple' THEN event_count ELSE 0 END) as triple,
  SUM(CASE WHEN event = 'Triple Play' THEN event_count ELSE 0 END) as triple_play,
  SUM(CASE WHEN event = 'Walk' THEN event_count ELSE 0 END) as walk,
  SUM(CASE WHEN event = 'Wild Pitch' THEN event_count ELSE 0 END) as wild_pitch,
  SUM(CASE WHEN event = 'Stolen Base 2B' THEN event_count ELSE 0 END) as stolen_base_2b,
  SUM(CASE WHEN event = 'Stolen Base 3B' THEN event_count ELSE 0 END) as stolen_base_3b,
  SUM(CASE WHEN event = 'Caught Stealing' THEN event_count ELSE 0 END) as caught_stealing
FROM events
WHERE mlbam_game_date >= DATE('2024-10-01')
GROUP BY player_id, mlbam_game_id, mlbam_game_date
ORDER BY player_id, mlbam_game_id, mlbam_game_date
),
calculated_stats AS (
  SELECT *,
    single + (double * 2) + (triple * 3) + (home_run * 4) AS tb,
    bunt_groundout + double + field_error + fielders_choice + flyout + grounded_into_dp + groundout + hit_by_pitch + home_run + intent_walk + lineout + pop_out + sac_bunt + sac_fly + single + strikeout + strikeout_double_play + triple + walk AS ab,
    single + double + triple + home_run AS hits,
    single + double + triple + home_run + walk + hit_by_pitch - (caught_stealing_2b + caught_stealing_3b + caught_stealing_home) - grounded_into_dp AS on_base,
    single + (double * 2) + (triple * 3) + (home_run * 4) + 
    (0.26 * (walk + hit_by_pitch - intent_walk)) + 
    (0.52 * (sac_bunt + sac_fly + stolen_base_2b + stolen_base_3b)) AS bases_advanced,
    bunt_groundout + double + field_error + fielders_choice + flyout + grounded_into_dp + groundout + hit_by_pitch + home_run + intent_walk + lineout + pop_out + sac_bunt + sac_fly + single + strikeout + strikeout_double_play + triple + walk + walk + sac_bunt + sac_fly AS opportunities
  FROM event_counts
)
INSERT INTO mlb.curated_events_runs_created
(player_id, mlbam_game_id, mlbam_game_date, balk, batter_out, bunt_groundout, bunt_lineout, bunt_pop_out, catcher_interference, caught_stealing_2b, caught_stealing_3b, caught_stealing_home, "double", double_play, field_error, fielders_choice, fielders_choice_out, flyout, forceout, game_advisory, grounded_into_dp, groundout, hit_by_pitch, home_run, intent_walk, lineout, nan, pickoff_1b, pickoff_2b, pickoff_3b, pickoff_caught_stealing_2b, pickoff_caught_stealing_3b, pickoff_caught_stealing_home, pitching_substitution, pop_out, runner_out, runner_placed_on_base, sac_bunt, sac_fly, sac_fly_double_play, single, strikeout, strikeout_double_play, triple, triple_play, walk, wild_pitch, stolen_base_2b, stolen_base_3b, caught_stealing, tb, ab, hits, on_base, bases_advanced, opportunities, technical_rc)
SELECT *
  ,CASE 
    WHEN opportunities = 0 THEN NULL 
    ELSE (on_base * bases_advanced) / opportunities 
  END AS technical_rc
FROM calculated_stats
ORDER BY player_id, mlbam_game_id, mlbam_game_date 
ON CONFLICT (player_id, mlbam_game_id, mlbam_game_date)
DO UPDATE 
SET player_id=EXCLUDED.player_id, mlbam_game_id=EXCLUDED.mlbam_game_id, mlbam_game_date=EXCLUDED.mlbam_game_date, balk=EXCLUDED.balk, batter_out=EXCLUDED.batter_out, bunt_groundout=EXCLUDED.bunt_groundout, bunt_lineout=EXCLUDED.bunt_lineout, bunt_pop_out=EXCLUDED.bunt_pop_out, catcher_interference=EXCLUDED.catcher_interference, caught_stealing_2b=EXCLUDED.caught_stealing_2b, caught_stealing_3b=EXCLUDED.caught_stealing_3b, caught_stealing_home=EXCLUDED.caught_stealing_home, "double"=EXCLUDED."double", double_play=EXCLUDED.double_play, field_error=EXCLUDED.field_error, fielders_choice=EXCLUDED.fielders_choice, fielders_choice_out=EXCLUDED.fielders_choice_out, flyout=EXCLUDED.flyout, forceout=EXCLUDED.forceout, game_advisory=EXCLUDED.game_advisory, grounded_into_dp=EXCLUDED.grounded_into_dp, groundout=EXCLUDED.groundout, hit_by_pitch=EXCLUDED.hit_by_pitch, home_run=EXCLUDED.home_run, intent_walk=EXCLUDED.intent_walk, lineout=EXCLUDED.lineout, nan=EXCLUDED.nan, pickoff_1b=EXCLUDED.pickoff_1b, pickoff_2b=EXCLUDED.pickoff_2b, pickoff_3b=EXCLUDED.pickoff_3b, pickoff_caught_stealing_2b=EXCLUDED.pickoff_caught_stealing_2b, pickoff_caught_stealing_3b=EXCLUDED.pickoff_caught_stealing_3b, pickoff_caught_stealing_home=EXCLUDED.pickoff_caught_stealing_home, pitching_substitution=EXCLUDED.pitching_substitution, pop_out=EXCLUDED.pop_out, runner_out=EXCLUDED.runner_out, runner_placed_on_base=EXCLUDED.runner_placed_on_base, sac_bunt=EXCLUDED.sac_bunt, sac_fly=EXCLUDED.sac_fly, sac_fly_double_play=EXCLUDED.sac_fly_double_play, single=EXCLUDED.single, strikeout=EXCLUDED.strikeout, strikeout_double_play=EXCLUDED.strikeout_double_play, triple=EXCLUDED.triple, triple_play=EXCLUDED.triple_play, walk=EXCLUDED.walk, wild_pitch=EXCLUDED.wild_pitch, stolen_base_2b=EXCLUDED.stolen_base_2b, stolen_base_3b=EXCLUDED.stolen_base_3b, caught_stealing=EXCLUDED.caught_stealing, tb=EXCLUDED.tb, ab=EXCLUDED.ab, hits=EXCLUDED.hits, on_base=EXCLUDED.on_base, bases_advanced=EXCLUDED.bases_advanced, opportunities=EXCLUDED.opportunities, technical_rc=EXCLUDED.technical_rc, created_at=EXCLUDED.created_at, updated_at=EXCLUDED.updated_at;

