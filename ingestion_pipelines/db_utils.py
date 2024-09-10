from datetime import date
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


def write_schedule_payload_to_table(
    dt: str,
    schema: str,
    table: str,
    payload: Dict[str, Any],
    cursor,
):
    try:
        cursor.execute(
            f"""INSERT INTO {schema}.raw_{table} ({table}_date, {table}_payload, created_at, updated_at)
            VALUES (%s, %s::jsonb, NOW(), NOW())
            ON CONFLICT (schedule_date)
            DO UPDATE SET {table}_payload = EXCLUDED.{table}_payload, updated_at = NOW()""",
            (dt, payload),
        )
        print(f"Successfully written payload for {dt} to {schema}.raw_{table}")
    except psycopg2.Error as e:
        print(f"SQL error: {e}")
    return


def write_pbp_payload_to_table(
    game_date: date,
    game_id: int,
    schema: str,
    table: str,
    payload: Dict[str, Any],
    cursor,
):
    try:
        cursor.execute(
            f"""INSERT INTO {schema}.raw_{table} (mlbam_game_date, mlbam_game_id, {table}_payload, created_at, updated_at)
            VALUES (%s, %s, %s::jsonb, NOW(), NOW())
            ON CONFLICT (mlbam_game_id)
            DO UPDATE SET {table}_payload = EXCLUDED.{table}_payload, updated_at = NOW()""",
            (game_date, game_id, payload),
        )
        print(f"Successfully written payload for {game_id} to {schema}.raw_{table}")
    except psycopg2.Error as e:
        print(f"SQL error: {e}")
    return
