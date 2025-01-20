import json
from gpt_functions import generate_general_response, infer_type_and_location, generate_human_response
from sql_operations import query_database, get_places_by_type

def lambda_handler(event, context):
    try:
        # parse user input
        body = json.loads(event["body"])
        prompt = body.get("prompt", "")

        # Step 1: Infer inquiry type and location
        inference = infer_type_and_location(prompt)
        inquiry_type = inference["inquiry_type"]
        inquiry_subtype = inference["inquiry_subtype"]
        place_type = inference["type"]
        user_location = inference["coordinates"]

        # Step 2: Handle the inquiry based on type
        if inquiry_type == "general_inquiry":
            # we dont't need database query
            response = generate_general_response(prompt)
        elif inquiry_type == "search_inquiry":
            if inquiry_subtype == "itinerary_inquiry":
                # get 3 places per type 
                results = get_places_by_type(user_location, place_type, limit=3)
                response = generate_human_response(prompt, results)
            elif inquiry_subtype == "direct_inquiry":
                # query the database for specific locations or detail
                results = query_database(user_location, place_type)
                response = generate_human_response(prompt, results)
            else:
                response = "Invalid inquiry subtype."
        else:
            response = "Invalid inquiry type."

        return {
            "statusCode": 200,
            "body": json.dumps({"response": response})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }