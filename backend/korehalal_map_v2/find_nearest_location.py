import sys
import json
from geopy.distance import geodesic
import pandas as pd
import os
import logging
import numpy as np

# Set up logging
logging.basicConfig(
    filename="location_service.log",
    level=logging.DEBUG,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

logging.info("Script started")

script_dir = os.path.dirname(os.path.abspath(__file__)) 
dataset_path = os.path.join(script_dir, '../dataset/combined_dataset.csv') 

# Load the dataset
try:
    dataset = pd.read_csv(dataset_path)
    logging.info("Dataset loaded successfully from %s", dataset_path)
except Exception as e:
    error_message = {"error": "Failed to load dataset", "details": str(e)}
    logging.error("Failed to load dataset: %s", str(e))
    print(json.dumps(error_message))
    sys.exit(1)

df = pd.DataFrame(dataset)
logging.debug("Dataset head: %s", df.head())

# Define type mappings
type_mappings = {
    "halal": "Halal restaurant",
    "seafood": "Seafood restaurant",
    "vegetarian": "Vegetarian restaurant",
    "hotel": "Hotel",
    "prayer": "Prayer"
}

categories_list = [
    "indonesian", "korean", "uzbek", "arabic", "turkish", 
    "western", "asian", "japanese", "moroccan", "chinese", 
    "indian", "pakistani", "american", "international", "cafe"
]

def infer_type(prompt):
    """Infer type from the user prompt using NLP"""
    logging.debug("Inferring type from prompt: %s", prompt)
    prompt_words = set(prompt.lower().split())
    
    for keyword, place_type in type_mappings.items():
        if keyword in prompt_words:
            logging.info("Type inferred: %s", place_type)
            return place_type
    
    logging.warning("No type matched for prompt: %s", prompt)
    return None

def infer_category(prompt):
    """Infer category by matching words in the prompt (for restaurants)"""
    logging.debug("Inferring category from prompt: %s", prompt)
    prompt_words = set(prompt.lower().split())
    
    for category in categories_list:
        if category in prompt_words:
            logging.info("Category inferred: %s", category.capitalize())
            return category.capitalize()
    
    logging.warning("No category matched for prompt: %s", prompt)
    return None

def find_nearest_locations(user_lat, user_lon, place_type, category=None, max_results=2):
    logging.debug("Finding nearest locations for type: %s, category: %s", place_type, category)
    
    if place_type.lower().endswith("restaurant") and category:
        filtered = df[(df['Classification'].str.lower() == place_type.lower()) & 
                      (df['Category'].str.lower() == category.lower())]
    else:
        filtered = df[df['Classification'].str.lower() == place_type.lower()]
    
    if filtered.empty:
        logging.warning("No locations found for type: %s, category: %s", place_type, category)
        return []
    
    filtered = filtered.copy()
    filtered.loc[:, 'distance'] = filtered.apply(
        lambda row: geodesic((user_lat, user_lon), (row['Latitude'], row['Longitude'])).km, axis=1
    )

    filtered = filtered.replace({np.nan: 'N/A'})
    
    sorted_results = filtered.sort_values(by='distance').head(max_results)
    sorted_results = sorted_results.drop(columns=['WKT', 'Description'], errors='ignore') # contact or other columns can be dropped because we cant have NaN values in dataset 
    logging.info("Found %d locations", len(sorted_results))
    return sorted_results.to_dict(orient='records')

if __name__ == "__main__":
    try:
        logging.info("Parsing input arguments")
        user_lat = float(sys.argv[1])
        user_lon = float(sys.argv[2])
        prompt = sys.argv[3].lower()

        # Infer type from prompt
        place_type = infer_type(prompt)
        if not place_type:
            logging.error("No matching type found for prompt: %s", prompt)
            print(json.dumps({"error": "No matching type found in prompt."}))
            sys.exit(1)
        
        # For restaurants, infer category
        category = None
        if "restaurant" in place_type.lower():
            category = infer_category(prompt)
        
        # Find nearest locations
        results = find_nearest_locations(user_lat, user_lon, place_type, category)
        logging.debug("Results: %s", results)
        
        print(json.dumps(results, ensure_ascii=False))
    
    except Exception as e:
        error_message = {"error": "Python script error", "details": str(e)}
        logging.error("Script error: %s", str(e))
        print(json.dumps(error_message))
        sys.exit(1)
