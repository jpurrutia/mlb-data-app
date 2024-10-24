import time
from typing import Dict, Any
from datetime import datetime, timedelta

import json

import pandas as pd
from mlbam_utils import get_game_pbp
from psycopg2 import OperationalError, DatabaseError
from db_utils import connect_to_db, write_pbp_payload_to_table


# get dates data from schedule table

# historical backfill


def query_schedule_dates():
    db = connect_to_db()

    try:
        try:
            with db.cursor() as cur:
                cur.execute(
                    """SELECT DISTINCT date, game_id
                       FROM mlb.curated_games
                       WHERE game_id >= 216813
                       ORDER BY date ASC;
                    """
                )
                return pd.DataFrame(cur.fetchall(), columns=["date", "game_id"])
        except (OperationalError, DatabaseError) as e:
            print(f"Database error occurred: {e}")
        except Exception as e:
            print(f"An error occurred: {e}")

    finally:
        db.close()
    return


def historical_backfill(mlb_game_ids):
    db = connect_to_db()  # Connect to the database once

    for idx, game_id in enumerate(
        mlb_game_ids["game_id"]
    ):  # Use enumerate for the index and iterate over 'game_id' column
        pbp_data = get_game_pbp(game_id)  # Make API call
        pbp_payload = json.dumps(pbp_data)  # Convert data to JSON format

        with db.cursor() as cur:
            write_pbp_payload_to_table(
                pbp_data["gameData"]["datetime"]["officialDate"],
                pbp_data["gamePk"],
                "mlb",
                "pbp",
                pbp_payload,
                cur,
            )
            # Commit after writing the data
            db.commit()

        # Sleep after the API call to avoid rate limitings
        time.sleep(1)

    # Close the database connection when done
    db.close()


def main():

    mlb_game_ids = query_schedule_dates()
    historical_backfill(mlb_game_ids)


if __name__ == "__main__":
    main()
