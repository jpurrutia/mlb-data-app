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
    mlbam_game_id integer NULL,
    inning int4 NULL,
    half_inning varchar NULL,
    batter_id integer NULL,
    pitcher_id integer NULL,
    "event" varchar NULL
);

-- mlb.curated_events_runs_created definition

-- Drop table

-- DROP TABLE mlb.curated_events_runs_created;

CREATE TABLE mlb.curated_events_runs_created (
    player_id text NULL,
    mlbam_game_id int4 NOT NULL,
    mlbam_game_date date NULL,
    balk int4 NULL,
    batter_out int4 NULL,
    bunt_groundout int4 NULL,
    bunt_lineout int4 NULL,
    bunt_pop_out int4 NULL,
    catcher_interference int4 NULL,
    caught_stealing_2b int4 NULL,
    caught_stealing_3b int4 NULL,
    caught_stealing_home int4 NULL,
    "double" int4 NULL,
    double_play int4 NULL,
    field_error int4 NULL,
    fielders_choice int4 NULL,
    fielders_choice_out int4 NULL,
    flyout int4 NULL,
    forceout int4 NULL,
    game_advisory int4 NULL,
    grounded_into_dp int4 NULL,
    groundout int4 NULL,
    hit_by_pitch int4 NULL,
    home_run int4 NULL,
    intent_walk int4 NULL,
    lineout int4 NULL,
    nan int4 NULL,
    pickoff_1b int4 NULL,
    pickoff_2b int4 NULL,
    pickoff_3b int4 NULL,
    pickoff_caught_stealing_2b int4 NULL,
    pickoff_caught_stealing_3b int4 NULL,
    pickoff_caught_stealing_home int4 NULL,
    pitching_substitution int4 NULL,
    pop_out int4 NULL,
    runner_out int4 NULL,
    runner_placed_on_base int4 NULL,
    sac_bunt int4 NULL,
    sac_fly int4 NULL,
    sac_fly_double_play int4 NULL,
    single int4 NULL,
    strikeout int4 NULL,
    strikeout_double_play int4 NULL,
    triple int4 NULL,
    triple_play int4 NULL,
    walk int4 NULL,
    wild_pitch int4 NULL,
    stolen_base_2b int4 NULL,
    stolen_base_3b int4 NULL,
    caught_stealing int4 NULL,
    tb int4 NULL,
    ab int4 NULL,
    hits int4 NULL,
    on_base int4 NULL,
    bases_advanced numeric NULL,
    opportunities numeric NULL,
    technical_rc numeric NULL,
    created_at timestamptz DEFAULT now() NULL,
    updated_at timestamptz DEFAULT now() NULL,
    CONSTRAINT curated_events_rc_key UNIQUE (
        player_id, mlbam_game_id, mlbam_game_date
    )

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
    id uuid,
    schedule_date timestamp NOT NULL,
    mlbam_game_id integer NOT NULL,
    mlbam_team_id integer NOT NULL,
    lineup jsonb,
    lineup_set boolean DEFAULT FALSE NOT NULL,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
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
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
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



CREATE TABLE mlb.players (
    id int4 NOT NULL,
    first_name text NULL,
    middle_name text NULL,
    last_name text NULL,
    used_name text NULL,
    birthdate date NULL,
    birth_city text NULL,
    birth_state text NULL,
    birth_country text NULL,
    height varchar(10) NULL,
    weight int4 NULL,
    primary_position varchar(10) NULL,
    draft_year int4 NULL,
    last_played date NULL,
    mlb_debut date NULL,
    bat_side varchar(1) NULL,
    pitch_hand varchar(1) NULL,
    is_verified bool NULL,
    last_updated timestamp NULL,
    CONSTRAINT mlbam_players_pk PRIMARY KEY (id)
);
CREATE INDEX mlb_players_birthdate ON mlb.players USING btree (birthdate);
