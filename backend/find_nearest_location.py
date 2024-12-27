import sys
from geopy.distance import geodesic
import pandas as pd

# Simulated dataset
data = [
    {"name": "Restaurant A", "latitude": 37.551170, "longitude": 126.988228, "category": "Arabic"},
    {"name": "Restaurant B", "latitude": 37.560000, "longitude": 126.990000, "category": "Uzbek"},
    {"name": "Restaurant C", "latitude": 37.550000, "longitude": 126.980000, "category": "Arabic"},
    {"name": "Restaurant D", "latitude": 37.551170, "longitude": 120.988228, "category": "Chinese"},
    {"name": "Restaurant E", "latitude": 37.560000, "longitude": 122.990000, "category": "Taiwanese"},
    {"name": "Restaurant F", "latitude": 47.550000, "longitude": 132.980000, "category": "Arabic"},
    {"name": "Restaurant J", "latitude": 35.551170, "longitude": 124.888228, "category": "Arabic"},
    {"name": "Restaurant K", "latitude": 38.560000, "longitude": 146.890000, "category": "Uzbek"},
    {"name": "Restaurant L", "latitude": 39.550000, "longitude": 136.980000, "category": "Arabic"},
]

df = pd.DataFrame(data)

def find_nearest_locations(user_lat, user_lon, category, max_results=2):
    filtered = df[df['category'].str.lower() == category.lower()]

    if filtered.empty:
        return "No matching locations found."

    filtered['distance'] = filtered.apply(
        lambda row: geodesic((user_lat, user_lon), (row['latitude'], row['longitude'])).km, axis=1
    )

    sorted_results = filtered.sort_values(by='distance').head(max_results)
    return sorted_results.to_dict(orient='records')

if __name__ == "__main__":
    # Parse inputs from Laravel
    user_lat = float(sys.argv[1])
    user_lon = float(sys.argv[2])
    prompt = sys.argv[3].lower()

    # Infer category from prompt
    category = "arabic" if "arabic" in prompt else "uzbek"

    # Find nearest locations
    results = find_nearest_locations(user_lat, user_lon, category)
    print(results)
