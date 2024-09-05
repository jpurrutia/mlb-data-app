import json
import requests
import duckdb


from db_utils import connect_to_db

# import pandas as pd
# from flatten_json import flatten


def get_mlb_schedule(dt):
    url = f"https://statsapi.mlb.com/api/v1/schedule?startDate={dt}&endDate={dt}&sportId=1"
    return requests.get(url).json()


def main():
    # day_schedule = get_mlb_schedule("2024-08-28")
    # print(day_schedule)

    # persistent storage
    # conn = duckdb.connect("file.db")

    # duckdb.sql("LOAD pg_duckdb;")
    # duckdb.sql("SELECT 4;")
    # duckdb.sql("CREATE EXTENSION pg_duckdb;")

    # connect to db
    db = connect_to_db()
    cur = db.cursor()

    # res = cur.execute("SELECT * FROM mlb.games;")
    # data = cur.fetchall()

    cur.execute("CREATE EXTENSION IF NOT EXISTS pg_duckdb;")

    db.commit()

    breakpoint()

    # insert into db
    print("we connected")


if __name__ == "__main__":
    main()
