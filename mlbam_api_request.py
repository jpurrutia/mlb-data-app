import json
import requests

import pandas as pd
from flatten_json import flatten


def get_game_pbp(game_id):
    url = f"https://statsapi.mlb.com/api/v1.1/game/{game_id}/feed/live?sportId=1"
    return requests.get(url).json()


def main():

    resp = get_game_pbp("745541")

    # flatten(resp["liveData"]["plays"]["allPlays"][0]["result"])
    """ (function) def json_normalize( """

    uuid.UUID

    print("hi")


if __name__ == "__main__":
    main()
