import json
import re
from openai import OpenAI
import os

from location_operations import get_coordinates_nominatim

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def generate_general_response(prompt):
    try:
        instruction = "You are a helpful assistant. Provide answers relevant to people in Korea."
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "system", "content": instruction}, {"role": "user", "content": prompt}],
            max_tokens=300
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        raise Exception(f"Error generating response: {str(e)}")


def generate_human_response(prompt, results):
    response_prompt = f"""
    Based on the following retrieved data, respond to the user query:
    User query: "{prompt}"
    Data: {results}
    Generate a helpful and natural response.
    """
    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": response_prompt}],
            max_tokens=500
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        raise Exception(f"Failed to generate human response: {str(e)}")

def infer_type_and_location(prompt):
    # default values
    DEFAULT_LAT = 37.551170
    DEFAULT_LON = 126.988228
    DEFAULT_LOCATION = "Seoul Station, South Korea"

    gpt_prompt = f"""
    You are an AI assistant specializing in Muslim-friendly places in Korea.
    Analyze the following user prompt: "{prompt}".
    Return a JSON object with:
    - 'inquiry_type': A type of inquiry that user is asking for ('general_inquiry' or 'search_inquiry'). Our data contains locations of restaurants and tourist attractions, decide whether these data can provide value to the user prompt. If not somewhat relation or value, inquiry_type must return general_inquiry.
      'general_inquiry' does not require dataset calls, while 'search_inquiry' requires dataset interaction.
    - 'inquiry_subtype': If 'general_inquiry', return None. For 'search_inquiry', specify 'itinerary_inquiry' (user is asking to create a plan/itinerary) or 'direct_inquiry' (user asks for specific location details), it can not be null. The result can not be anything else except for either these 3 options.
    - 'type': an array of classifications ('Restaurant' and/or 'Tourist Attraction').
    - 'location': A specific location mentioned in the prompt, if any. Default to '{DEFAULT_LOCATION}' if not provided.
    - 'coordinates': A dictionary with 'latitude' and 'longitude' values. For 'Seoul' or 'South Korea' or 'current location' or 'my location', always return {{'latitude': 37.551170, 'longitude': 126.988228}}.
    """

    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": gpt_prompt}],
            max_tokens=200
        )

        result = response.choices[0].message.content.strip()
        print("Debug - GPT Output:", result)

        # Extract JSON content
        json_match = re.search(r'{.*}', result, re.DOTALL)
        if not json_match:
            raise ValueError("No valid JSON found in GPT response.")

        clean_json = json_match.group(0)

        # Parse the JSON content
        parsed_result = json.loads(clean_json)

        inquiry_type = parsed_result.get("inquiry_type", "general_inquiry")
        inquiry_subtype = parsed_result.get("inquiry_subtype", None)
        classification = parsed_result.get("type", ["Restaurant", "Tourist Attraction"])
        location = parsed_result.get("location", DEFAULT_LOCATION)
        coordinates = parsed_result.get("coordinates", {"latitude": DEFAULT_LAT, "longitude": DEFAULT_LON})

        # If location is specific, we handle it separately
        if location != DEFAULT_LOCATION and "Seoul" not in location and "South Korea" not in location:
            try:
                lat, lon = get_coordinates_nominatim(location)
                coordinates = {"latitude": lat, "longitude": lon}
            except Exception as e:
                print(f"Geocoding failed for {location}: {e}")
                coordinates = {"latitude": DEFAULT_LAT, "longitude": DEFAULT_LON}

        return {
            "inquiry_type": inquiry_type,
            "inquiry_subtype": inquiry_subtype,
            "type": classification,
            "location": location,
            "coordinates": coordinates
        }

    except json.JSONDecodeError as jde:
        raise ValueError(f"Failed to parse GPT response as JSON. Raw output: {result}. Error: {str(jde)}")
    except Exception as e:
        raise ValueError(f"Failed to infer type and location: {str(e)}")
