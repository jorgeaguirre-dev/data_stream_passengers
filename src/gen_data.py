import os
import json
import time
from google.cloud import pubsub_v1

# 1. Credentials configuration
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "../iam/service-account.json"

project_id = "data-stream-passengers"
topic_id = "flight-search-events"

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(project_id, topic_id)

def simulate_searches():
    # Simulates a passenger searching for a flight from Buenos Aires to Santiago
    data = {
        "user_id": "user_456",
        "origin": "EZE",
        "destination": "SCL",
        "cabin": "Business",
        "timestamp": time.time()
    }
    
    message_json = json.dumps(data)
    message_bytes = message_json.encode("utf-8")

    # Publishes the message to the Pub/Sub topic
    future = publisher.publish(topic_path, data=message_bytes)
    print(f"Message sent: {future.result()}")

if __name__ == "__main__":
    print("Starting traffic simulation for Airline...")
    for i in range(5):  # Sends 5 events
        simulate_searches()
        time.sleep(2)