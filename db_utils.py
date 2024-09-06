from typing import Dict, Any

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


def write_payload_to_sql_table(
    dt: str, schema: str, table: str, payload: Dict[str, Any], cursor
):
    try:
        cursor.execute(
            f"""INSERT INTO {schema}.{table} ({table}_date, {table}_payload, created_at, updated_at)
            VALUES (%s, %s::jsonb, NOW(), NOW())
            ON CONFLICT (schedule_date)
            DO UPDATE SET {table}_payload = EXCLUDED.{table}_payload, updated_at = NOW()""",
            (dt, payload),
        )
    except psycopg2.Error as e:
        print(f"SQL error: {e}")
    return
