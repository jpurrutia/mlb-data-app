
-- convert md5 to uuid
CREATE OR REPLACE FUNCTION md5_to_uuid(md5_hash text) RETURNS uuid AS $$
DECLARE
    hex_str text;
BEGIN
    hex_str := LOWER(md5_hash);
    RETURN CAST(SUBSTRING(hex_str FROM 1 FOR 8) || '-' ||
                SUBSTRING(hex_str FROM 9 FOR 4) || '-' ||
                '4' || SUBSTRING(hex_str FROM 13 FOR 3) || '-' ||
                CASE
					WHEN SUBSTRING(hex_str FROM 17 FOR 1) BETWEEN '8' AND 'b'
					THEN SUBSTRING(hex_str FROM 17 FOR 1)
				ELSE 'a'END ||
                SUBSTRING(hex_str FROM 18 FOR 3) || '-' ||
                SUBSTRING(hex_str FROM 21 FOR 12) AS uuid);
END;
$$ LANGUAGE plpgsql;


-- set lineup id
CREATE OR REPLACE FUNCTION set_raw_game_lineups_id()
RETURNS TRIGGER AS $$
BEGIN
	NEW.id = md5_to_uuid(MD5(CONCAT(NEW.mlbam_game_id::text, NEW.mlbam_team_id::text, NEW.schedule_date::text)));
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;
