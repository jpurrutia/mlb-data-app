
import pandas as pd
import psycopg2
from pybaseball import batting_leaders, pitching_leaders, fielding_leaders
from psycopg2 import OperationalError, DatabaseError

from db_utils import connect_to_db

db = connect_to_db("devon","mlb")


def pull_fg_leaders(year):
    try:
        # Pull FanGraphs leader data
        print(f"Pulling data for the year: {year}")
        batting_data = batting_leaders(start_season = year, end_season = year)
        pitching_data = pitching_leaders(start_season = year, end_season = year)
        # Assuming a fielding_stats function exists
        fielding_data = fielding_leaders(start_season=year, end_season=year)
        
        # Write to Postgres
        print(f"Writing data to database for the year: {year}")
        batting_data.to_sql(f'fg_batting_{year}', engine, if_exists = 'replace', index = False)
        pitching_data.to_sql(f'fg_pitching_{year}', engine, if_exists = 'replace', index = False)
        fielding_data.to_sql(f'fg_fielding_{year}', engine, if_exists = 'replace', index = False)

        print(f"Data for year {year} successfully written to the database.")
    except Exception as e:
        print(f"Error processing year {year}: {e}")



def main():
    # Loop through years and pull data
    for year in range(2010, 2025):
        pull_fg_leaders(year)



if __name__ == "__main__":
    main()