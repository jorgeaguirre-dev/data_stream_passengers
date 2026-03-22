# ID del Tópico para el script de envío de mensajes
output "pubsub_topic_id" {
  value       = google_pubsub_topic.flight_searches.id
  description = "El ID completo del tópico de Pub/Sub para la ingesta de eventos."
}

# Nombre del Bucket para los jobs de Dataflow
output "staging_bucket_url" {
  value       = google_storage_bucket.airline_dataflow_staging.url
  description = "La URL de GCS para el staging de archivos temporales de Dataflow."
}

# ID del Dataset para configurar Dataform o dashboards
output "bigquery_dataset_id" {
  value       = google_bigquery_dataset.flights_ds.dataset_id
  description = "El ID del dataset de BigQuery donde aterrizarán los datos crudos."
}

# El ID del proyecto (útil para scripts de automatización)
output "project_id" {
  value = var.project_id
}