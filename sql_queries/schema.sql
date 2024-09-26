------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
-- mlb.raw_schedule definition

-- Drop table
-- DROP TABLE mlb.raw_schedule;

CREATE TABLE mlb.raw_schedule (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	schedule_date date NOT NULL,
	schedule_payload jsonb NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT raw_schedule_pkey PRIMARY KEY (id),
	CONSTRAINT raw_schedule_schedule_date_key UNIQUE (schedule_date)
);

-- mlb.curated_games definition

-- Drop table
-- DROP TABLE mlb.curated_games;

CREATE TABLE mlb.curated_games (
	game_id integer PRIMARY KEY,
	"date" date NULL,
	game_guid uuid NULL,
	season text NULL,
	game_type varchar NULL,
	game_state_code varchar NULL,
	game_state varchar NULL,
	game_number integer NULL,
	day_night varchar NULL,
	double_header_flag bool NULL,
	away_team_id integer NULL,
	away_score integer NULL,
	away_team_wins integer NULL,
	away_team_losses integer NULL,
	home_team_id integer NULL,
	home_score integer NULL,
	home_team_wins integer NULL,
	home_team_losses integer NULL,
	venue_id integer NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	UNIQUE (game_id)
);


------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
-- mlb.raw_pbp definition

-- Drop table
-- DROP TABLE mlb.raw_pbp;

CREATE TABLE mlb.raw_pbp (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	mlbam_game_date date NOT NULL,
	mlbam_game_id integer NOT NULL,
	pbp_payload jsonb NOT NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT raw_pbp_mlbam_game_id_key UNIQUE (mlbam_game_id),
	CONSTRAINT raw_pbp_pkey PRIMARY KEY (id)
);


-- mlb.curated_pbp_events definition

-- Drop table
-- DROP TABLE mlb.curated_pbp_events;

CREATE TABLE mlb.curated_pbp_events (
	id uuid NULL,
	mlbam_game_date date NULL,
	mlbam_game_id int4 NULL,
	inning int4 NULL,
	half_inning varchar NULL,
	batter varchar NULL,
	pitcher varchar NULL,
	"event" varchar NULL
);

-- mlb.curated_events_runs_created definition

-- Drop table
-- DROP TABLE mlb.curated_events_runs_created;

CREATE TABLE mlb.curated_events_runs_created (
	player_name text NULL,
	mlbam_game_id integer NOT NULL,
	mlbam_game_date date NULL,
	balk integer NULL,
	batter_out integer NULL,
	bunt_groundout integer NULL,
	bunt_lineout integer NULL,
	bunt_pop_out integer NULL,
	catcher_interference integer NULL,
	caught_stealing_2b integer NULL,
	caught_stealing_3b integer NULL,
	caught_stealing_home integer NULL,
	"double" integer NULL,
	double_play integer NULL,
	field_error integer NULL,
	fielders_choice integer NULL,
	fielders_choice_out integer NULL,
	flyout integer NULL,
	forceout integer NULL,
	game_advisory integer NULL,
	grounded_into_dp integer NULL,
	groundout integer NULL,
	hit_by_pitch integer NULL,
	home_run integer NULL,
	intent_walk integer NULL,
	lineout integer NULL,
	nan integer NULL,
	pickoff_1b integer NULL,
	pickoff_2b integer NULL,
	pickoff_3b integer NULL,
	pickoff_caught_stealing_2b integer NULL,
	pickoff_caught_stealing_3b integer NULL,
	pickoff_caught_stealing_home integer NULL,
	pitching_substitution integer NULL,
	pop_out integer NULL,
	runner_out integer NULL,
	runner_placed_on_base integer NULL,
	sac_bunt integer NULL,
	sac_fly integer NULL,
	sac_fly_double_play integer NULL,
	single integer NULL,
	strikeout integer NULL,
	strikeout_double_play integer NULL,
	triple integer NULL,
	triple_play integer NULL,
	walk integer NULL,
	wild_pitch integer NULL,
	stolen_base_2b integer NULL,
	stolen_base_3b integer NULL,
	caught_stealing integer NULL,
	tb integer NULL,
	ab integer NULL,
	hits integer NULL,
	on_base integer NULL,
	bases_advanced numeric NULL,
	opportunities numeric NULL,
	technical_rc numeric NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL
	-- figure out the update overwrite on insert
);



-- mlb.raw_lineups definition

-- Drop table
-- DROP TABLE mlb.raw_lineups;

CREATE TABLE mlb.raw_lineups (
	id uuid NULL,
	mlbam_game_date timestamp NOT NULL,
	mlbam_game_id integer NOT NULL,
	lineups_payload jsonb NULL,
	created_at timestamptz DEFAULT now() NULL,
	updated_at timestamptz DEFAULT now() NULL,
	CONSTRAINT raw_lineups_id_key UNIQUE (id)
);

-- Table Triggers
CREATE TRIGGER trigger_set_raw_game_lineups_id BEFORE
INSERT
    ON
    mlb.raw_lineups FOR EACH ROW EXECUTE FUNCTION set_raw_game_lineups_id();

CREATE TABLE mlb.raw_game_lineups_json (
	-- might need to see if this is scalable ID creation
    id UUID,
	schedule_date timestamp NOT NULL,
	mlbam_game_id integer NOT NULL,
	mlbam_team_id integer NOT NULL,
	lineup JSONB,
	lineup_set boolean DEFAULT FALSE NOT NULL,
	created_at timestamptz DEFAULT NOW(),
	updated_at timestamptz DEFAULT NOW(),
	UNIQUE (id)
);

-- mlb.curated_lineups definition

-- Drop table

-- DROP TABLE mlb.curated_lineups;

CREATE TABLE mlb.curated_lineups (
	game_date timestamp NULL,
	mlbam_game_id integer NULL,
	away_probable_pitcher text NULL,
	home_probable_pitcher text NULL,
	away_batters jsonb NULL,
	home_batters jsonb NULL,
	away_bullpen jsonb NULL,
	home_bullpen jsonb NULL,
	created_at timestamptz DEFAULT NOW(),
	updated_at timestamptz DEFAULT NOW(),
	UNIQUE (mlbam_game_id)
);






-- Mock INSERT Record
/*
INSERT INTO mlb.raw_game_lineups (schedule_date, mlbam_game_id, mlbam_team_id, lineup, probable_pitcher, bullpen, home_flag, away_flag, lineup_set, created_at, updated_at)
VALUES ('2024-08-24', 745541, 117, ARRAY[656941, 607208, 547180, 664761, 679032, 624641, 669016, 669720, 596117], 681293, ARRAY[650556, 669854, 686613, 657571, 623352, 579328, 593576, 672391, 605463, 664285, 434378], FALSE, TRUE, TRUE, NOW(), NOW())
ON CONFLICT (id)
DO UPDATE SET lineup = EXCLUDED.lineup
	,probable_pitcher = EXCLUDED.probable_pitcher
	,bullpen = EXCLUDED.bullpen
	,home_flag = EXCLUDED.home_flag
	,away_flag = EXCLUDED.away_flag
	,updated_at = NOW();
*/

-- SELECT
-- SELECT * FROM mlb.raw_game_lineups WHERE schedule_date = '2024-08-24' AND mlbam_game_id = 745541 AND mlbam_team_id = 117;
