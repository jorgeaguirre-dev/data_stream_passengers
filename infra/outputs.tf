# Topic ID for the message publishing script
output "pubsub_topic_id" {
  value       = google_pubsub_topic.flight_searches.id
  description = "The full ID of the Pub/Sub topic for event ingestion."
}

# Bucket name for Dataflow jobs
output "staging_bucket_url" {
  value       = google_storage_bucket.airline_dataflow_staging.url
  description = "The GCS URL for Dataflow temporary file staging."
}

# Dataset ID for configuring Dataform or dashboards
output "bigquery_dataset_id" {
  value       = google_bigquery_dataset.flights_ds.dataset_id
  description = "The BigQuery dataset ID where raw data will land."
}

# The project ID
output "project_id" {
  value = var.project_id
}