import os
import json
import time
from google.cloud import pubsub_v1

# 1. Configuración de Credenciales
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "../iam/service-account.json"

project_id = "data-stream-passengers"
topic_id = "flight-search-events"

publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(project_id, topic_id)

def simulate_searches():
    # Simulamos un pasajero buscando un vuelo de Buenos Aires a Santiago
    data = {
        "user_id": "user_123",
        "origin": "EZE",
        "destination": "SCL",
        "cabin": "Business",
        "timestamp": time.time()
    }
    
    message_json = json.dumps(data)
    message_bytes = message_json.encode("utf-8")

    # Enviamos al tópico de Pub/Sub
    future = publisher.publish(topic_path, data=message_bytes)
    print(f"Mensaje enviado: {future.result()}")

if __name__ == "__main__":
    print("Iniciando simulación de tráfico para Aerolinea...")
    for i in range(5): # Enviamos 5 eventos
        simulate_searches()
        time.sleep(2)