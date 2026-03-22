# Definición del Proveedor
provider "google" {
  project = var.project_id
  region  = var.region
  # zone  = var.zone
}

# 1. Pub/Sub para Ingesta de Eventos
resource "google_pubsub_topic" "flight_searches" {
  name = var.pubsub_topic_name
}

# 2. Dataset de BigQuery (Capa Raw y Analytics)
resource "google_bigquery_dataset" "flights_ds" {
  dataset_id = var.bigquery_dataset_id
  location   = var.location
}

# 3. Bucket Cloud Storage de Staging para Dataflow
resource "google_storage_bucket" "airline_dataflow_staging" {
  name          = var.dataflow_staging_bucket
  location      = var.location
  force_destroy = true
}

# 4. Job de Dataflow (Streaming)
# resource "google_dataflow_job" "streaming_segmentation" {
#   name              = var.dataflow_job_name
#   template_gcs_path = "gs://dataflow-templates/latest/PubSub_to_BigQuery"
#   temp_gcs_location = "${google_storage_bucket.airline_dataflow_staging.url}/temp"
#   parameters = {
#     inputTopic      = google_pubsub_topic.flight_searches.id
#     outputTableSpec = "${var.project_id}:${google_bigquery_dataset.flights_ds.dataset_id}.raw_events"
#   }
# }
