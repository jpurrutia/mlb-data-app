

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

port print statements to logging info messages


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
- pbp_data['liveData']['boxscore']['teams']['home']['bullpen']

First pitch
- pbp_data['gameData']['gameInfo']
{'attendance': 37778, 'firstPitch': '2024-08-28T20:07:00.000Z', 'gameDurationMinutes': 148}




Combining three columns
```
UPDATE table_name 
SET hash_column = MD5(CONCAT(column1, column2, column3));
```

### validation functions
Validation Functions are functions that can be run in tandem with pipelines.
Simple but effective functions that ensures valid function runs and data collection/movement

ensure that the function made for md5_to_uuid is actually necessary