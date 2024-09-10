

Thinking about object oriented approach
base classes that set up database connections and set context for mlb class
Those base classes at LLI used ORM but honestly this is not lightweight and I don't think
I need to go down this route


# DUCKDB testing
persistent storage
```
conn = duckdb.connect("file.db")
duckdb.sql("LOAD pg_duckdb;")
duckdb.sql("SELECT 4;")
duckdb.sql("CREATE EXTENSION pg_duckdb;")
```

# Data Sources and Endpoints

### Probables pitchers
- pbp data: indexed -> pbp_data['gameData']['probablePitchers']
- pbp_data['gameData']['probablePitchers']['home']['id']
- pbp_data['gameData']['probablePitchers']['away']['id']


{'away': {'id': 681293, 'fullName': 'Spencer Arrighetti', 'link': '/api/v1/people/681293'}, 'home': {'id': 592836, 'fullName': 'Taijuan Walker', 'link': '/api/v1/people/592836'}}

### Get Line up data
- pbp_data['liveData']['boxscore']['teams']['home']['battingOrder']
- pbp_data['liveData']['boxscore']['teams']['away']['battingOrder']

### Get bullben data
- pbp_data['liveData']['boxscore']['teams']['away']['bullpen']

First pitch
- pbp_data['gameData']['gameInfo']
{'attendance': 37778, 'firstPitch': '2024-08-28T20:07:00.000Z', 'gameDurationMinutes': 148}

Combining three columns
`md5_to_uuid_func.sql` - Has the transformation logic to create a unique id for lineups table by concatenating and hashing the unique id for md5, this then gets converted to a uuid. This test logic could be used for other tables, just need to make sure it works.

Need to ensure that the function made for md5_to_uuid is actually necessary.

### validation functions
Validation Functions are functions that can be run in tandem with pipelines.
Simple but effective functions that ensures valid function runs and data collection/movement

## Update Sept 10. 2024
Tables for raw_schedule, raw_pbp, and raw_game lineups have mock data.
The next step is to curate these records into silver tables
- curated_schedule
- curated_pbp
- curated_lineups (if necessary - this might just be transformed in the process)

We curate that data and then we move towards create the calculated gold_ tables for the API to consume.

Then we start building the API and react client.


After MVP
- write tests
- backfills
- streaming
- CICD
- Cloud Hosting
- Security?

