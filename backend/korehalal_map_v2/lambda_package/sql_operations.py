import pymysql
from database_connect import connect_to_db
import time
import logging

# Ensure logging is set up
logging.basicConfig(filename='/tmp/python_debug.log', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

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
        logging.debug("Database returned: %s", results)

# def get_places_by_type(user_location, place_types, limit=3):
#     connection = connect_to_db()
#     user_lat = user_location["latitude"]
#     user_lon = user_location["longitude"]
#     all_results = []

#     logging.debug("Fetching places for type: %s at location: %s", place_type, user_location)
#     try:
#         with connection.cursor(pymysql.cursors.DictCursor) as cursor:
#             for place_type in place_types:
#                 sql_query = """
#                 SELECT name, address, description, type,
#                     ST_Distance_Sphere(point(longitude, latitude), point(%s, %s)) AS distance_meters
#                 FROM locations
#                 WHERE type = %s
#                 ORDER BY distance_meters ASC
#                 LIMIT %s;
#                 """
#                 cursor.execute(sql_query, (user_lon, user_lat, place_type, limit))
#                 results = cursor.fetchall()

#                 for row in results:
#                     row['distance_km'] = round(row['distance_meters'] / 1000, 2)
#                     del row['distance_meters']  

#                 all_results.extend(results)
#         return all_results

#     except Exception as e:
#         logging.error("Error fetching places: %s", str(e))
#         return []

#     finally:
#         connection.close()
#         logging.debug("Database returned: %s", results)

def get_places_by_type(user_location, place_types, limit=3):
    start_time = time.time()
    connection = connect_to_db()
    if not connection:
        logging.error("❌ Database connection failed. Cannot proceed.")
        return []

    user_lat = user_location["latitude"]
    user_lon = user_location["longitude"]
    all_results = []

    logging.debug("Fetching places for types: %s at location: %s", place_types, user_location)

    try:
        with connection.cursor(pymysql.cursors.DictCursor) as cursor:
            for place_type in place_types:
                logging.debug("Processing place type: %s", place_type)

                sql_query = """
                SELECT name, address, description, type,
                    ST_Distance_Sphere(point(longitude, latitude), point(%s, %s)) AS distance_meters
                FROM locations
                WHERE type = %s
                ORDER BY distance_meters ASC
                LIMIT %s;
                """

                logging.debug("Executing query: %s with values: (%s, %s, %s, %d)", sql_query, user_lon, user_lat, place_type, limit)

                cursor.execute(sql_query, (user_lon, user_lat, place_type, limit))
                results = cursor.fetchall()

                if results:
                    logging.debug("✅ Query returned: %s", results)
                else:
                    logging.warning("⚠️ No results found for place type: %s", place_type)

                for row in results:
                    row['distance_km'] = round(row['distance_meters'] / 1000, 2)
                    del row['distance_meters']
                    all_results.append(row)

        return all_results

    except Exception as e:
        logging.error("❌ Error fetching places: %s", str(e))
        return []

    finally:
        logging.debug("Closing database connection.")
        connection.close()


# ORM CODE (takes 2x more to get response)
# Technically GPT calls protects from SQL injections, so we can keep raw SQL queries

# from sqlalchemy.orm import sessionmaker
# from sqlalchemy import create_engine, func
# from database_connect import get_db_session
# from models import Location  # Ensure models.py defines Location ORM model

# def query_database(user_location, place_types):
#     session = get_db_session()
#     try:
#         results = []
#         for place_type in place_types:
#             query = (
#                 session.query(
#                     Location.name,
#                     Location.address,
#                     Location.description,
#                     Location.type,
#                     func.ST_Distance_Sphere(
#                         func.point(Location.longitude, Location.latitude),
#                         func.point(user_location["longitude"], user_location["latitude"])
#                     ).label("distance_km")
#                 )
#                 .filter(Location.type == place_type)
#                 .order_by("distance_km")
#                 .limit(5)
#             )
            
#             rows = query.all()
#             results.extend([
#                 {
#                     "Name": row.name,
#                     "Address": row.address,
#                     "Description": row.description,
#                     "Type": row.type,
#                     "Distance (km)": round(row.distance_km / 1000, 2)
#                 }
#                 for row in rows
#             ])
#         return results
#     finally:
#         session.close()


# def get_places_by_type(user_location, place_types, limit=3):
#     session = get_db_session()
#     user_lat = user_location["latitude"]
#     user_lon = user_location["longitude"]
#     all_results = []

#     try:
#         for place_type in place_types:
#             query = (
#                 session.query(
#                     Location.name,
#                     Location.address,
#                     Location.description,
#                     Location.type,
#                     func.ST_Distance_Sphere(
#                         func.point(Location.longitude, Location.latitude),
#                         func.point(user_lon, user_lat)
#                     ).label("distance_meters")
#                 )
#                 .filter(Location.type == place_type)
#                 .order_by("distance_meters")
#                 .limit(limit)
#             )

#             results = query.all()
#             for row in results:
#                 all_results.append({
#                     "Name": row.name,
#                     "Address": row.address,
#                     "Description": row.description,
#                     "Type": row.type,
#                     "Distance (km)": round(row.distance_meters / 1000, 2)
#                 })
        
#         return all_results
#     except Exception as e:
#         raise Exception(f"Error fetching places by type: {str(e)}")
#     finally:
#         session.close()
