import time
from typing import Dict, Any
from datetime import datetime, timedelta

import json

import pandas as pd
from mlbam_utils import get_game_pbp
from db_utils import connect_to_db, write_pbp_payload_to_table, query_dates_gameid


# get dates data from schedule table

# historical backfill


def historical_backfill(mlb_game_ids):
    # Connect to the database once
    db = connect_to_db()

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

    mlb_game_ids = query_dates_gameid()
    historical_backfill(mlb_game_ids)


if __name__ == "__main__":
    main()
