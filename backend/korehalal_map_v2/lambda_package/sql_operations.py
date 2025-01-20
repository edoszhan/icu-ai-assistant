import pymysql
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

def get_places_by_type(user_location, place_types, limit=3):
    connection = connect_to_db()
    user_lat = user_location["latitude"]
    user_lon = user_location["longitude"]

    all_results = []
    try:
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            for place_type in place_types:
                sql_query = """
                SELECT name, address, description, type,
                ( 6371 * acos(cos(radians(%s)) * cos(radians(latitude)) 
                * cos(radians(longitude) - radians(%s)) + sin(radians(%s)) 
                * sin(radians(latitude)))) AS distance_km
                FROM locations
                WHERE type = %s
                ORDER BY distance_km ASC
                LIMIT %s;
                """
                cursor.execute(sql_query, (user_lat, user_lon, user_lat, place_type, limit))
                results = cursor.fetchall()
                all_results.extend(results)

        return all_results

    except Exception as e:
        raise Exception(f"Error fetching places by type: {str(e)}")
    finally:
        connection.close()