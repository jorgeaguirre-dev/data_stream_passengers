variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "latam-challenge-project"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "location" {
  description = "GCP resource location"
  type        = string
  default     = "US"
}

variable "pubsub_topic_name" {
  description = "Nombre del tópico Pub/Sub"
  type        = string
  default     = "flight-search-events"
}

variable "bigquery_dataset_id" {
  description = "ID del dataset de BigQuery"
  type        = string
  default     = "passenger_segmentation"
}

variable "dataflow_staging_bucket" {
  description = "Nombre del bucket de staging para Dataflow"
  type        = string
  default     = "latam-dataflow-staging-bucket"
}

variable "dataflow_job_name" {
  description = "Nombre del job de Dataflow"
  type        = string
  default     = "segmentation-pipeline"
}
