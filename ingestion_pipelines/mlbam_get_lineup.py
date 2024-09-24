from typing import Dict, Any
from datetime import date

import json
import requests
import psycopg2

from db_utils import connect_to_db  # , write_schedule_payload_to_table
from mlbam_utils import get_game_pbp


def extract_team_data(payload: Dict[str, Any], home_away: str) -> Dict[str, Any]:
    try:
        team_data = {
            "battingOrder": payload["liveData"]["boxscore"]["teams"][home_away][
                "battingOrder"
            ],
            "bullpen": payload["liveData"]["boxscore"]["teams"][home_away]["bullpen"],
            "probablePitcher": None,
        }

        probable_pitchers = payload["gameData"].get("probablePitchers", {})
        if probable_pitchers.get(home_away):
            team_data["probablePitcher"] = probable_pitchers[home_away].get("id")

        return team_data

    except KeyError as e:
        print(f"Missing expected key in payload: {e}")

    return {"battingOrder": None, "bullpen": None, "probablePitcher": None}


def create_full_payload(payload: Dict[str, Any]) -> Dict[str, Any]:
    try:
        return {
            "home": extract_team_data(payload, "home"),
            "away": extract_team_data(payload, "away"),
        }

    except ValueError as e:
        raise ValueError(f"Error creating full payoad: {e}")


def create_json_payload(lineup_data: Dict[str, Any]) -> str:
    return json.dumps(lineup_data, indent=2)


def write_lineup_payload_to_table(
    game_date: date,
    game_id: int,
    schema: str,
    table: str,
    payload: Dict[str, Any],
    cursor,
):
    try:
        cursor.execute(
            f"""INSERT INTO {schema}.raw_{table} (mlbam_game_date, mlbam_game_id, {table}_payload, created_at, updated_at)
            VALUES (%s, %s, %s::jsonb, NOW(), NOW())
            ON CONFLICT (id)
            DO UPDATE SET {table}_payload = EXCLUDED.{table}_payload, updated_at = NOW()""",
            (game_date, game_id, payload),
        )
        print(f"Successfully written payload for {game_id} to {schema}.raw_{table}")
    except psycopg2.Error as e:
        print(f"SQL error: {e}")
    return


def main():
    try:
        pbp_data = get_game_pbp("745541")
        breakpoint()
        full_payload = create_full_payload(pbp_data)
        breakpoint()
        json_payload = create_json_payload(full_payload)

        db = connect_to_db()

        with db.cursor() as cur:
            write_lineup_payload_to_table(
                pbp_data["gameData"]["datetime"]["officialDate"],
                pbp_data["gamePk"],
                "mlb",
                "lineups",
                json_payload,
                cur,
            )

            db.commit()

    except ValueError as e:
        print(f"Error {e}")
    except psycopg2.Error as e:
        print(f"Database error: {e}")
    finally:
        if db:
            db.close()


if __name__ == "__main__":
    main()
