from typing import Dict, Any

import json
import requests
import psycopg2

from db_utils import connect_to_db, write_payload_to_sql_table


def get_mlb_schedule(dt: str) -> Dict[str, Any]:
    url = f"https://statsapi.mlb.com/api/v1/schedule?startDate={dt}&endDate={dt}&sportId=1"
    response = requests.get(url)

    # check if response status is OK
    if response.status_code != 200:
        raise ValueError(
            f"Failed to fetch schedule data. Status code: {response.status_code}"
        )

    schedule_data = response.json()

    if not isinstance(schedule_data, dict) or "dates" not in schedule_data:
        raise ValueError(
            "Invalid Schedule Data: expected a a dictionary with 'dates' key."
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


def main():
    try:
        result_data = get_mlb_schedule("2024-08-28")
        schedule_payload = json.dumps(result_data)
        result_date = get_schedule_date(schedule_data=result_data)

        db = connect_to_db()

        with db.cursor() as cur:
            write_payload_to_sql_table(
                result_date, "mlb", "schedule", schedule_payload, cur
            )

            db.commit()

    except ValueError as e:
        print(f"Error {e}")
    except psycopg2.Error as e:
        print(f"Database error: {e}")
    finally:
        if db:
            db.close()


if __name__ == "__main__":
    main()
