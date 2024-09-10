CREATE TABLE mlb.raw_schedule (
	id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
	schedule_date timestamp NOT NULL,
	schedule_payload jsonb NULL,
	created_at timestamptz DEFAULT NOW(),
	updated_at timestamptz DEFAULT NOW(),
	UNIQUE (schedule_date) 
);

CREATE TABLE mlb.games (
	id uuid PRIMARY KEY NOT NULL,
	mlbam_game_id integer NOT NULL,
	game_payload jsonb NOT NULL
);

CREATE TABLE mlb.raw_pbp (
	id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	mlbam_game_date date NOT NULL,
	mlbam_game_id int4 NOT NULL,
	pbp_payload jsonb NOT NULL,
	created_at timestamptz DEFAULT NOW(),
	updated_at timestamptz DEFAULT NOW(),
	UNIQUE (mlbam_game_id)
	-- should the unique be a concat of game, date?
);


CREATE TABLE mlb.raw_game_lineups (
	-- might need to see if this is scalable ID creation
    id UUID,
	schedule_date timestamp NOT NULL,
	mlbam_game_id integer NOT NULL,
	mlbam_team_id integer NOT NULL,
	lineup integer[],
	propable_pitcher integer,
	bullpen integer[],
	lineup_set boolean DEFAULT FALSE NOT NULL,
	created_at timestamptz DEFAULT NOW(),
	updated_at timestamptz DEFAULT NOW(),
	UNIQUE (id)
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
