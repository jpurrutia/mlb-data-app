CREATE TABLE mlb.schedule (
	id uuid PRIMARY KEY NOT NULL,
	schedule_date timestamp NOT NULL,
	games_payload jsonb -- could be NULL IF there ARE NO games that day
);

CREATE TABLE mlb.games (
	id uuid PRIMARY KEY NOT NULL,
	mlbam_game_id integer NOT NULL,
	game_payload jsonb NOT NULL
);

CREATE TABLE mlb.pbp (
	id uuid PRIMARY KEY NOT NULL,
	mlbam_game_id integer NOT NULL,
	pbp_payload jsonb NOT NULL
);

CREATE TABLE mlb.raw_game_lineups (
	-- might need to see if this is scalable
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
