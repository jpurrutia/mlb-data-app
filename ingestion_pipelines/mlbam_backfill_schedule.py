from typing import Dict, Any
from datetime import datetime, timedelta

import json
import requests
import psycopg2

from db_utils import connect_to_db, write_schedule_payload_to_table


def get_mlb_schedule(dt: str) -> Dict[str, Any]:
    url = f"https://statsapi.mlb.com/api/v1/schedule?startDate={dt}&endDate={dt}&sportId=1"
    response = requests.get(url)

    if response.status_code != 200:
        raise ValueError(
            f"Failed to fetch schedule data. Status code: {response.status_code}"
        )

    schedule_data = response.json()

    if not isinstance(schedule_data, dict) or "dates" not in schedule_data:
        raise ValueError(
            "Invalid Schedule Data: expected a dictionary with 'dates' key."
        )

    dates = schedule_data.get("dates", [])

    if not isinstance(dates, list):
        raise ValueError("Invalid data: 'dates' should be a list.")

    return schedule_data


def get_schedule_date(schedule_data: Dict[str, Any]) -> str:
    dates = schedule_data.get("dates", [])

    if not dates:
        return "There are no games or dates for this day."

    if len(dates) > 1:
        return "Multiple dates in schedule - something is wrong here."

    schedule_data = dates[0]

    return schedule_data["date"]


def historical_backfill(start_date: str, end_date: str):
    current_date = datetime.strptime(start_date, "%Y-%m-%d")
    end_date = datetime.strptime(end_date, "%Y-%m-%d")

    db = connect_to_db()

    try:
        while current_date <= end_date:
            dt_str = current_date.strftime("%Y-%m-%d")
            try:
                # Fetch MLB schedule data for the current date
                schedule_data = get_mlb_schedule(dt_str)
                schedule_payload = json.dumps(schedule_data)
                result_date = get_schedule_date(schedule_data=schedule_data)

                # Insert the data into the schedule table
                with db.cursor() as cur:
                    write_schedule_payload_to_table(
                        result_date, "mlb", "schedule", schedule_payload, cur
                    )
                    db.commit()

                print(f"Successfully inserted data for {dt_str}")

            except ValueError as e:
                print(f"Error for date {dt_str}: {e}")
            except psycopg2.Error as e:
                print(f"Database error for date {dt_str}: {e}")

            # Move to the next day
            current_date += timedelta(days=1)

    finally:
        if db:
            db.close()


if __name__ == "__main__":
    # Define your start date and end date for backfill (going back 10 years)
    end_date = datetime.now().strftime("%Y-%m-%d")
    start_date = (datetime.now() - timedelta(days=5)).strftime("%Y-%m-%d")

    historical_backfill(start_date=start_date, end_date=end_date)
