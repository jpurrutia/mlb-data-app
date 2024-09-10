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
	id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	schedule_date timestamp NOT NULL,
	lineup integer[] timestamp NOT NULL,
	mlbam_team_id integer NOT NULL,
	--UNIQUE (mlbam)
);


CREATE TABLE your_table (
	-- might need to see if this is scalable
    id UUID DEFAULT md5_to_uuid(MD5(CONCAT(game_id, mlbam_team_id, schedule_date))),
	schedule_date timestamp NOT NULL,
	mlbam_game_id integer NOT NULL,
	mlbam_team_id integer NOT NULL,
	lineup integer[] timestamp NOT NULL,
	UNIQUE (id)
);
