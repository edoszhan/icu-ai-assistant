import json
import re
import os
import time
import sys
import logging
from openai import OpenAI, OpenAIError
from location_operations import get_coordinates_nominatim

logging.basicConfig(filename='/tmp/python_debug.log', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')
api_key = os.getenv("OPENAI_API_KEY")

if not api_key:
    logging.error("❌ OPENAI_API_KEY environment variable is missing!")
    raise ValueError("OPENAI_API_KEY environment variable is not set. Please configure it before running.")

try:
    client = OpenAI(api_key=api_key)
    logging.debug("✅ OpenAI client initialized successfully.")
except OpenAIError as e:
    logging.error("❌ Failed to initialize OpenAI client: %s", str(e))

def generate_general_response(prompt):
    start_time = time.time()
    try:
        instruction = "You are a helpful assistant for users interested in Muslim-friendly travel to Korea. Answer only questions related to Korea travel and Muslim travel services. If a query is outside this scope, politely ask the user to specify their question in relation to these topics. Provide clear and structured responses with proper spacing between words and numbers."
        
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": instruction},
                {"role": "user", "content": prompt},
            ],
            max_tokens=700,
            stream=True
        )
        
        for chunk in response:
            print(chunk.choices[0].delta.content, end="")  

        # buffer = ""
        # last_char = " "  # Assume initial space for correct spacing logic

        # for chunk in response:
        #     if hasattr(chunk.choices[0].delta, "content") and chunk.choices[0].delta.content is not None:
        #         token = chunk.choices[0].delta.content

        #         if token.strip():  # Ensure token is non-empty
        #             # **Fix issue 1:** Ensure space between words and numbers
        #             if re.search(r'([a-zA-Z])(\d)', last_char + token):  # Example: "The5th" → "The 5th"
        #                 buffer += " " 
        #             elif re.search(r'(\d)([a-zA-Z])', last_char + token):  # Example: "4years" → "4 years"
        #                 buffer += " "

        #             # # **Fix issue 3:** Prevent extra spaces (GPT may already provide them)
        #             if last_char.strip() and token[0].isalnum() and last_char.isalnum():
        #                 buffer += ""  # Only add a space if needed

        #             buffer += token
        #             last_char = token[-1] if token else last_char  # Update last_char

        #             # **Fix issue 2:** Prevent additional space after sentence-ending punctuation
        #             if re.search(r'[.!?]$', token):
        #                 buffer = buffer.rstrip()  # Remove trailing spaces after punctuation

        #             # Flush when we reach a space, punctuation, or newline
        #             if re.search(r'\s|[.,!?;:\"]$', token):
        #                 sys.stdout.write(buffer)
        #                 sys.stdout.flush()
        #                 buffer = ""  # Reset buffer

        #             time.sleep(0.02)  # Simulated streaming delay

        # if buffer:  # Print any remaining buffer
        #     sys.stdout.write(buffer)
        #     sys.stdout.flush()

    except Exception as e:
        sys.stderr.write(f"Error: {str(e)}\n")
        sys.stderr.flush()
    finally:
        end_time = time.time()
        logging.debug("generate_general_response execution time: %.4f seconds", end_time - start_time)


def reset_session():
    global session_history
    session_history = [
        {"role": "system", "content": "You are a helpful travel assistant specializing in Korea."}
    ]

session_history = [
    {"role": "system", "content": "You are a helpful travel assistant. Your users are people abroad who are interested in coming to Korea or people already in Korea. If questions ask for directions for places outside of South Korea, politely clarify that your focus is only in Korea. Be friendly and tailor your responses for Muslim users."}
]

def generate_human_response(prompt, results):
    start_time = time.time()
    global session_history
    response_prompt = f"""
    Based on the following retrieved data, respond to the user query:
    User query: "{prompt}"
    Data: {results}
    Generate a helpful and natural response.
    """
    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=session_history + [{"role": "user", "content": response_prompt}],
            max_tokens=1000,
            stream=True
        )

        for chunk in response:
            print(chunk.choices[0].delta.content, end="")  

        # buffer = ""
        # last_char = " "  # decide spacing based on last char

        # for chunk in response:
        #     if hasattr(chunk.choices[0].delta, "content") and chunk.choices[0].delta.content is not None:
        #         token = chunk.choices[0].delta.content.strip()

        #         if last_char and not last_char.isspace() and token and not token.startswith((" ", ".", ",", "'", "\"", "-", "’")):
        #             buffer += " "  # add space btw words

        #         buffer += token
        #         last_char = token[-1] if token else last_char

        #         # new sentences start with space
        #         if re.search(r'[.!?]', token):
        #             buffer += " "

        #         # if sentence-ending punctuation or space is found, print buffer
        #         if re.search(r'\s|[.,!?;:\"]$', token):
        #             sys.stdout.write(buffer)
        #             sys.stdout.flush()
        #             buffer = ""  # reset buffer after printing

        #         time.sleep(0.05)  # delay for streaming effect

        # if buffer: # print remaining buffer
        #     sys.stdout.write(buffer)
        #     sys.stdout.flush()

    except Exception as e:
        sys.stderr.write(f"Error: {str(e)}\n")
        sys.stderr.flush()
    finally:
        end_time = time.time()
        logging.debug("generate_human_response execution time: %.4f seconds", end_time - start_time)

def infer_type_and_location(prompt):
    start_time = time.time()
    # default values
    DEFAULT_LAT = 37.551170
    DEFAULT_LON = 126.988228
    DEFAULT_LOCATION = "Seoul Station, South Korea"

    gpt_prompt = f"""
        You are an AI assistant specializing in Muslim-friendly places in Korea.
        Analyze the following user prompt: "{prompt}".
        Return a JSON object strictly following correct JSON formatting with double quotes around property names and values.

        The output should have:
        - 'inquiry_type': A type of inquiry that user is asking for ('general_inquiry' or 'search_inquiry'). Our data contains locations of restaurants, tourist attractions and prayer rooms, decide whether these data can provide value to the user prompt. If not somewhat relation or value, inquiry_type must return general_inquiry. If users asks questions not related to restaurants/food, tourist attractions/fun places or prayer rooms/mosques, then you can assume 'general_inquiry'.
          'general_inquiry' does not require dataset calls, while 'search_inquiry' requires dataset interaction.
        - 'inquiry_subtype': If 'general_inquiry', return None. For 'search_inquiry', specify 'itinerary_inquiry' or 'direct_inquiry' (user asks for specific location details), it can not be null. The result can not be anything else except for either these 3 options.
        - 'type': An array of classifications ('Restaurant','Tourist Attraction' and/or 'Prayer Room').
        - 'location': A list of specific locations mentioned in the prompt. Identify SPECIFIC location names only (cities/districts/landmarks). If no location specified, use "Seoul Station, South Korea".

        - 'coordinates': A dictionary with "latitude" and "longitude" values as floats, formatted with double quotes.
        For 'Seoul' or 'South Korea' or 'current location' or 'my location', always return {{'latitude': 37.551170, 'longitude': 126.988228}}.

        Example JSON output:
        {{
            "inquiry_type": "search_inquiry",
            "inquiry_subtype": "direct_inquiry",
            "type": ["Restaurant"],
            "location": ["Seoul", "Itaewon", "Gangnam", "Myeongdong"],
            "coordinates": {{"latitude": 37.551170, "longitude": 126.988228}}
        }}
        """

    try:
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": gpt_prompt}],
            max_tokens=100
        )

        result = response.choices[0].message.content.strip()
        # print("Debug - GPT Output:", result)
        # print(f"Prompt tokens - infer type and location: ", response.usage.prompt_tokens)
        # print(f"Completion tokens - infer type and location: ", response.usage.completion_tokens)

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
                coordinates = {"latitude": DEFAULT_LAT, "longitude": DEFAULT_LON}
        end_time = time.time()
        logging.debug("infer_type_and_location execution time: %.4f seconds", end_time - start_time)
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
        return {
            "inquiry_type": "general_inquiry",
            "inquiry_subtype": None,
            "type": [],
            "location": DEFAULT_LOCATION,
            "coordinates": {"latitude": DEFAULT_LAT, "longitude": DEFAULT_LON}
        }
