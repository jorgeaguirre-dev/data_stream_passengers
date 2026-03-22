import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
import json

def run():
    # Enrutando Beam para leer de Pub/Sub y escribir en BigQuery
    options = PipelineOptions(
        streaming=True,
        project="data-stream-passengers",
        region="us-central1",
        staging_location="gs://airline_dataflow_staging/staging",
        temp_location="gs://airline_dataflow_staging/temp"
    )

    with beam.Pipeline(options=options) as p:
        (
            p
            | "Read from PubSub" >> beam.io.ReadFromPubSub(topic="projects/data-stream-passengers/topics/flight-search-events")
            | "Parse JSON" >> beam.Map(lambda x: json.loads(x.decode("utf-8")))
            | "Write to BigQuery" >> beam.io.WriteToBigQuery(
                "data-stream-passengers:passenger_segmentation.raw_events",
                schema="user_id:STRING, origin:STRING, destination:STRING, cabin:STRING, timestamp:FLOAT",
                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
                write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND
            )
        )

if __name__ == "__main__":
    run()