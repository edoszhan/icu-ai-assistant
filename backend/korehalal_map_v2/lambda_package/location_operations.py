import requests
import logging 

def get_coordinates_nominatim(place_name):
    base_url = "https://nominatim.openstreetmap.org/search"
    params = {"q": place_name, "format": "json", "limit": 1}
    response = requests.get(base_url, params=params)
    data = response.json()
    if data:
        return float(data[0]['lat']), float(data[0]['lon'])
    else:
        logging.debug("get_nominatim_failed error")
