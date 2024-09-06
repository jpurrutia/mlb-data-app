

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