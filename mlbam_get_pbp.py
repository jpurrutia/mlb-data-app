import json
import requests
import psycopg2

# import pandas as pd
# from flatten_json import flatten

from db_utils import connect_to_db, write_pbp_payload_to_table


def get_game_pbp(game_id):
    url = f"https://statsapi.mlb.com/api/v1.1/game/{game_id}/feed/live?sportId=1"

    response = requests.get(url)

    if response.status_code != 200:
        raise ValueError(
            f"Failed to fetch schedule data. Status code: {response.status_code}"
        )

    pbp_data = response.json()

    if not isinstance(pbp_data, dict) or not pbp_data["liveData"]["plays"]["allPlays"]:
        raise ValueError(f"Invalid Payload: expected play by play data with plays data")

    return pbp_data


def main():
    try:
        pbp_data = get_game_pbp("745541")
        pbp_payload = json.dumps(pbp_data)

        db = connect_to_db()

        with db.cursor() as cur:
            write_pbp_payload_to_table(
                pbp_data["gameData"]["datetime"]["officialDate"],
                pbp_data["gamePk"],
                "mlb",
                "pbp",
                pbp_payload,
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
