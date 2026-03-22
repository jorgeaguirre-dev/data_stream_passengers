variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "data-stream-passengers"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
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
  default     = "airline-dataflow-staging"
}

variable "dataflow_job_name" {
  description = "Nombre del job de Dataflow"
  type        = string
  default     = "segmentation-pipeline"
}
