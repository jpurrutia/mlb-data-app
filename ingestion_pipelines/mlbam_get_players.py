def get_players(sport_code, season):
    """get players based on the season and sport code"""
    url = f"https://statsapi.mlb.com/api/v1/sports/{sport_code}/players?season={season}"
    r = requests.get(url)
    x = r.json()
    # setup db conn
    conn = h.local_dbc()
    cur = conn.cursor()
    for i in x["people"]:
        try:
            q = (
                i["id"],
                i["firstName"],
                i.get("middleName"),
                i["lastName"],
                i.get("useName"),
                i.get("birthDate"),
                i.get("birthCity"),
                i.get("birthStateProvince"),
                i.get("birthCountry"),
                i.get("height"),
                i.get("weight"),
                i["primaryPosition"].get("code"),
                i.get("draftYear"),
                i.get("lastPlayedDate"),
                i.get("mlbDebutDate"),
                i["batSide"]["code"] if i.get("batSide") else None,
                i["pitchHand"]["code"] if i.get("pitchHand") else None,
                i.get("isVerified"),
            )
            cur.execute(
                """insert into mlbam.players values (
            %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s,
            %s, %s, %s, %s, %s,
            %s, %s, %s) ON CONFLICT DO NOTHING;""",
                q,
            )
        except Exception as e:
            print(i)
            conn.rollback()
            conn.close()
            raise e
    conn.commit()
    conn.close()
