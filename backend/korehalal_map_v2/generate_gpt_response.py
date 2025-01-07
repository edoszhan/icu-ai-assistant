import sys
import json
import openai
from subprocess import Popen, PIPE
import os
from dotenv import load_dotenv

load_dotenv()

openai.api_key = os.getenv('OPENAI_API_KEY')

if not openai.api_key:
    raise ValueError("OpenAI API key is missing. Please set it in the .env file.")

# Default coordinates for Namsan Tower if location is ambiguous
DEFAULT_LAT = 37.551170
DEFAULT_LON = 126.988228

def infer_classification_and_location(prompt):
    gpt_prompt = f"""
        You are an AI assistant specializing in Muslim-friendly places in Korea. Analyze the following user prompt:
        "{prompt}"
        Return a JSON object with 'classification' (e.g., 'Halal restaurant', 'Hotel') and 'location' as a dictionary with 'latitude' and 'longitude'. 
        If no location is mentioned, default to 'Namsan Tower, Seoul', which has DEFAULT_LAT = 37.551170, and DEFAULT_LON = 126.988228.
        """ 
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "You are a helpful assistant."},
                {"role": "user", "content": gpt_prompt},
            ],
            max_tokens=100
        )
        result = response.choices[0]['message']['content'].strip()
        
        # Parse the GPT response as JSON
        parsed_result = json.loads(result)

        # Extract classification and location
        classification = parsed_result.get("classification", "").strip()
        location = parsed_result.get("location", {
            "latitude": 37.551170,
            "longitude": 126.988228
        })

        return classification, location

    except Exception as e:
        raise ValueError(f"Failed to infer classification and location: {str(e)}")


def call_find_nearest_location(lat, lon, classification):
    script_path = os.path.join(os.path.dirname(__file__), 'find_nearest_location.py')
    
    try:
        process = Popen(
            ['python3', script_path, str(lat), str(lon), classification],
            stdout=PIPE,
            stderr=PIPE
        )
        stdout, stderr = process.communicate()

        if process.returncode != 0:
            raise Exception(stderr.decode('utf-8'))

        # Parse output
        return json.loads(stdout.decode('utf-8'))

    except Exception as e:
        return {"error": f"Failed to call find_nearest_location: {str(e)}"}


def generate_answer(results):
    if "error" in results:
        return f"An error occurred: {results['error']}"

    if not results:
        return "Sorry, no nearby places were found for your request."

    response = "Here are the nearest places based on your request:\n\n"
    for i, result in enumerate(results, 1):
        name = result.get("Name", "Unknown")
        classification = result.get("Classification", "N/A")
        category = result.get("Category", "N/A")
        time = result.get("Time", "N/A")
        distance = round(result.get("distance", 0), 2)
        contact = result.get("Contact", "N/A")

        response += (
            f"{i}. **{name}** ({classification})\n"
            f"   - Category: {category}\n"
            f"   - Opening Hours: {time}\n"
            f"   - Distance: {distance} km\n"
            f"   - Contact: {contact}\n\n"
        )
    response += "Let me know if you'd like more details about any of these places!"
    return response


if __name__ == "__main__":
    try:
        prompt = sys.argv[1]
 
        classification, location = infer_classification_and_location(prompt)
        if "error" in classification:
            print(json.dumps({"error": classification}))
            sys.exit(1)

        results = call_find_nearest_location(location["latitude"], location["longitude"], classification)
        
        print(json.dumps(results, ensure_ascii=False))

        # answer = generate_answer(results)
        # print(answer)

    except Exception as e:
        print(json.dumps({"error": f"Script error: {str(e)}"}))
        sys.exit(1)
