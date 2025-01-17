from database_connect import connect_to_db

def query_database(user_location, place_types):
    connection = connect_to_db()
    try:
        with connection.cursor() as cursor:
            results = []
            for place_type in place_types:
                query = """
                SELECT name, address, description, type,
                       ST_Distance_Sphere(point(longitude, latitude), point(%s, %s)) AS distance_km
                FROM locations
                WHERE type = %s
                ORDER BY distance_km ASC
                LIMIT 5;
                """
                cursor.execute(query, (user_location["longitude"], user_location["latitude"], place_type))
                rows = cursor.fetchall()
                results.extend([
                    {
                        "Name": row[0],
                        "Address": row[1],
                        "Description": row[2],
                        "Type": row[3],
                        "Distance (km)": round(row[4] / 1000, 2)
                    }
                    for row in rows
                ])
            return results
    finally:
        connection.close()
