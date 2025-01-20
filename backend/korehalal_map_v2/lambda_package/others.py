# [THIS FILE IS PURELY FOR TESTING CONNECTIVITY, API CALLS AND OTHER DETAILS]
# import urllib.request

# def lambda_handler(event, context):
#     try:
#         url = "https://example.com"
#         response = urllib.request.urlopen(url, timeout=10)
#         return {
#             "statusCode": 200,
#             "body": f"Internet access successful. Status code: {response.getcode()}"
#         }
#     except Exception as e:
#         return {
#             "statusCode": 500,
#             "body": f"Internet access failed. Error: {str(e)}"
#         }


# import pymysql
# import os

# def lambda_handler(event, context):
#     # RDS connection details
#     try:
#         connection = pymysql.connect(
#             host=os.getenv("RDS_HOST"),
#             user=os.getenv("RDS_USERNAME"),
#             password=os.getenv("RDS_PASSWORD"),
#             database=os.getenv("RDS_DB_NAME"),
#             connect_timeout=10
#         )

#         with connection.cursor() as cursor:
#             cursor.execute("SELECT 1")  
#             result = cursor.fetchone()

#         connection.close()

#         return {
#             "statusCode": 200,
#             "body": "DB access successful. Test query result: {}".format(result[0])
#         }

#     except Exception as e:
#         return {
#             "statusCode": 500,
#             "body": f"Failed to connect to RDS. Error: {str(e)}"
#         }

# import json
# from sql_operations import query_database, get_places_by_type

# def lambda_handler(event, context):
#     body = json.loads(event["body"])
#     prompt = body.get("prompt", "")

#     user_location = {"latitude": 37.551170, "longitude": 126.988228}
#     place_types = ["Restaurant", "Tourist Attraction"]

#     try:
#         direct_results = query_database(user_location, place_types)
#         itinerary_results = get_places_by_type(user_location, place_types, limit=3)

#         return {
#             "statusCode": 200,
#             "body": json.dumps({
#                 "direct_results": direct_results,
#                 "itinerary_results": itinerary_results
#             })
#         }

#     except Exception as e:
#         return {
#             "statusCode": 500,
#             "body": json.dumps({"error": str(e)})
#         }
