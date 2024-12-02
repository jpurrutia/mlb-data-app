from datetime import date
from typing import Dict, Any

import pandas as pd
import psycopg2
from psycopg2 import OperationalError, DatabaseError


def connect_to_db(username, schema):
    try:
        conn = psycopg2.connect(
            host="localhost",
            user=username,
            database="postgres",
            password="postgres",
            port=5432,
            options=f"-c search_path={schema}",
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
            DO UPDATE SET schedule_date = EXCLUDED.schedule_date, {table}_payload = EXCLUDED.{table}_payload, updated_at = NOW()""",
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


def query_dates_gameid():
    db = connect_to_db()

    try:
        try:
            with db.cursor() as cur:
                cur.execute(
                    """SELECT DISTINCT date, game_id
                       FROM mlb.curated_games
                       WHERE date >= DATE('2024-10-01')
                       ORDER BY date ASC;
                    """
                )
                return pd.DataFrame(cur.fetchall(), columns=["date", "game_id"])
        except (OperationalError, DatabaseError) as e:
            print(f"Database error occurred: {e}")
        except Exception as e:
            print(f"An error occurred: {e}")

    finally:
        db.close()
    return
