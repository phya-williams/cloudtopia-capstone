import json, random, os
from azure.storage.blob import BlobServiceClient

connect_str = os.getenv('STORAGE_CONNECTION_STRING')
blob_service_client = BlobServiceClient.from_connection_string(connect_str)
container_name = "weatherdata"

def generate_weather():
    return {
        "temperature": random.randint(60, 100),
        "wind_speed": random.randint(0, 40),
        "condition": random.choice(["sunny", "cloudy", "rain", "storm"])
    }

blob_client = blob_service_client.get_blob_client(container=container_name, blob="latest_weather.json")
data = generate_weather()
blob_client.upload_blob(json.dumps(data), overwrite=True)
print("Weather data uploaded:", data)
