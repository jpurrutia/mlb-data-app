

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

### Get Play by Play
- need to figure out how I'm going to account for empty payloads with game statusCode
`pbp_data["gameData"]["status"]["statusCode"]`
- I can create an enum and get the different status. Depending on status, write payload or return empty
  payload
```
   "status": {
      "abstractGameState": "Preview",
      "codedGameState": "S",
      "detailedState": "Scheduled",
      "statusCode": "S",
      "startTimeTBD": false,
      "abstractGameCode": "P"
```

### Probables pitchers
- pbp data: indexed -> pbp_data['gameData']['probablePitchers']
- pbp_data['gameData']['probablePitchers']['home']['id']
- pbp_data['gameData']['probablePitchers']['away']['id']
I've inserted logic here to check if there is data in here and to retun None if there is None. I'll overwrite these values when I find something and update records

{'away': {'id': 681293, 'fullName': 'Spencer Arrighetti', 'link': '/api/v1/people/681293'}, 'home': {'id': 592836, 'fullName': 'Taijuan Walker', 'link': '/api/v1/people/592836'}}

### Get Line up data
- pbp_data['liveData']['boxscore']['teams']['home']['battingOrder']
- pbp_data['liveData']['boxscore']['teams']['away']['battingOrder']
This could be empty depending on the game status and lineup hasnt been announced. SO I guess we write
empty value to database and then update.

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

## Update Sept 11. 2024
We need to transform the pbp data into the runs created stuff I've done in python.
BUT do I do it in python? If yes, how do I orchestrate that? I can't trigger python via postgresql.
Can I find a way to pivot in PostgreSQL? If I do choose python, what tool orchestrates and runs the
Python? It was cronjob to initially run the other python scripts. Maybe I do that for the Run calculated stuff too? 
Query DB table and write back to new table?

Right now we have the events matched up with the baseball reference for the sample data and steals. Define the columns and we're good.


### GoLang Portion: API and Client (Javascript)

Making API Calls

4 necessary things to build a Go Client
- http.Client
- http.Request
- context.Context -> times or cancel functions
- Request payload


Building a client that connects to your server

server in one terminal tab
client running in another terminal tab


### Integration and Contract Testing
Reliability between services is paramount in modern software. If you are building an API that is meant
to define communication betweens services or that are system critical it might be worth expanding
your test stack.
● Integrations Tests
● End-to-End Tests
Additional info here


- integration tests with github actions
- Sidecar docker containers - io style calls
- Mock database to mock integration
- docker container
- script to make call and 