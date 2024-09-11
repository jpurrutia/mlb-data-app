import requests

# import pandas as pd
# from flatten_json import flatten

from db_utils import connect_to_db, write_pbp_payload_to_table


def get_game_pbp(game_id):
    url = f"https://statsapi.mlb.com/api/v1.1/game/{game_id}/feed/live?sportId=1"

    response = requests.get(url)

    if response.status_code != 200:
        raise ValueError(
            f"Failed to fetch pbp data. Status code: {response.status_code}"
        )

    pbp_data = response.json()

    # if game status
    # if pbp_data["gameData"]["status"]["statusCode"] == "S":
    #     print("Game is scheduled but lineup is empty")

    # if not isinstance(pbp_data, dict) or not pbp_data["liveData"]["plays"]["allPlays"]:
    #     raise ValueError(f"Invalid Payload: expected play by play data with plays data")

    return pbp_data
