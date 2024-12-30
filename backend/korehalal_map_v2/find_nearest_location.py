import sys
import json
from geopy.distance import geodesic
import pandas as pd
import os

script_dir = os.path.dirname(os.path.abspath(__file__)) 
dataset_path = os.path.join(script_dir, '../dataset/Restaurant_1129.csv')  # temporary dataset

# Load the dataset
try:
    dataset = pd.read_csv(dataset_path)
except Exception as e:
    error_message = {"error": "Failed to load dataset", "details": str(e)}
    print(json.dumps(error_message))
    sys.exit(1)

df = pd.DataFrame(dataset)

def infer_category(prompt):
    """Infer category by matching words in the prompt with categories in the dataset."""
    prompt_words = prompt.lower().split()  
    categories = df['Category'].str.lower().unique()  

    # Find the first matching category
    for word in prompt_words:
        if word in categories:
            return word.capitalize()  
    return None  

def find_nearest_locations(user_lat, user_lon, category, max_results=2):
    filtered = df[df['Category'].str.lower() == category.lower()]

    if filtered.empty:
        return []

    filtered = filtered.copy()
    filtered.loc[:, 'distance'] = filtered.apply(
        lambda row: geodesic((user_lat, user_lon), (row['Latitude'], row['Longitude'])).km, axis=1
    )

    sorted_results = filtered.sort_values(by='distance').head(max_results)
    # Drop columns that might not be JSON serializable
    sorted_results = sorted_results.drop(columns=['WKT', 'Description'], errors='ignore')
    return sorted_results.to_dict(orient='records')

if __name__ == "__main__":
    try:
        user_lat = float(sys.argv[1])
        user_lon = float(sys.argv[2])
        prompt = sys.argv[3].lower()

        # Infer category from prompt
        category = infer_category(prompt)
        if not category:
            print(json.dumps({"error": "No matching category found in prompt."}))
            sys.exit(1)

        # Find nearest locations
        results = find_nearest_locations(user_lat, user_lon, category)

        # Return results as JSON
        print(json.dumps(results, ensure_ascii=False))  
    except Exception as e:
        error_message = {"error": "Python script error", "details": str(e)}
        print(json.dumps(error_message))
        sys.exit(1)