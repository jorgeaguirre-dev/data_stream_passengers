import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
import json
import sys

def run(argv=None):
    # Esto permite que Beam tome los parámetros de la terminal (--project, --staging_location, etc.)
    pipeline_options = PipelineOptions(argv)

    with beam.Pipeline(options=pipeline_options) as p:
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
    run(sys.argv)