import psycopg2
from psycopg2 import OperationalError


def connect_to_db():
    try:
        conn = psycopg2.connect(
            host="localhost",
            user="jpurrutia",
            database="postgres",
            password="postgres",
            port=5432,
            options="-c search_path=mlb",
        )
        print("Connection to DB successful")
        return conn
    except OperationalError as e:
        print(f"The error '{e}' occurred.")
    return
