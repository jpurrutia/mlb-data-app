import datetime
import json
import psycopg2

# import pandas as pd
# from flatten_json import flatten

from db_utils import connect_to_db, write_pbp_payload_to_table
from mlbam_utils import get_game_pbp


def main():
    try:
        pbp_data = get_game_pbp("745541")
        # no_pbp_data = get_game_pbp("0")
        pbp_payload = json.dumps(pbp_data)

        db = connect_to_db()

        with db.cursor() as cur:
            breakpoint()
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
