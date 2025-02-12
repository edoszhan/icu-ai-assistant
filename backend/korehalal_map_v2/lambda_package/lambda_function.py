import json
import sys 
import logging
from gpt_functions import generate_general_response, infer_type_and_location, generate_human_response, reset_session
from sql_operations import query_database, get_places_by_type

# Setup logging
logging.basicConfig(filename='/tmp/python_debug.log', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

def process_request(prompt):
    # reset_session()
    try:
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
                logging.debug("Itinerary inquiry detected. Fetching places...")
                # get 3 places per type 
                logging.debug("Calling get_places_by_type() with location: %s and place type: %s", user_location, place_type)
                results = get_places_by_type(user_location, place_type, limit=3)
                logging.debug("Places retrieved: %s", results)
                response = generate_human_response(prompt, results)
                logging.debug("Generated human response: %s", response)
            elif inquiry_subtype == "direct_inquiry":
                # query the database for specific locations or detail
                results = query_database(user_location, place_type)
                response = generate_human_response(prompt, results)
        else:
            response = "Invalid inquiry type."
        return response

    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    try:
        input_data = sys.stdin.read().strip()
        request = json.loads(input_data)
        prompt = request.get("prompt", "")
        response = process_request(prompt)

    except Exception as e:
        print(json.dumps({"error": str(e)}))