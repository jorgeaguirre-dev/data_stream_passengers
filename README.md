# Data Stream Passengers

## ✈️ Airline Data Platform

**Real-Time Passenger Segmentation:** This project implements an event-driven architecture pipeline on Google Cloud that ingests flight search events, processes them in real time, and segments passengers by purchase intent.

**Real-Time Ingestion:** An Apache Beam pipeline runs on Dataflow to process flight search events with auto-scaling, ensuring the system adapts to variable traffic loads without manual intervention.

**Governance and Quality:** Dataform orchestrates all transformations inside BigQuery, enforcing Data Quality Assertions and maintaining a clear data lineage across every model.

**Robust CI/CD:** The deployment is 100% automated, handling GCP secrets securely and managing Terraform state in a remote backend, so every push to `main` produces a reproducible and auditable environment.

## GitLab

This project is also available on GitLab: https://gitlab.com/hi-group623012/HI-data_stream_passengers

## 🏗️ Architecture

```
[gen_data.py] → Pub/Sub → Dataflow (pipeline.py) → BigQuery (raw_events) → Dataform → high_intent_passengers
```

| Layer | Tool | Role |
|---|---|---|
| Ingestion | Google Pub/Sub | Receives JSON search events |
| Processing | Apache Beam / Dataflow | Reads from Pub/Sub, writes raw data to BigQuery |
| Storage | BigQuery | Hosts `raw_events` and segmented tables |
| Transformation | Dataform | Applies SQL logic to produce `high_intent_passengers` |
| IaC | Terraform | Provisions all GCP resources |
| CI/CD | GitHub Actions | Deploys infra and launches pipeline on push to `main` |

**Ingestion:** Google Pub/Sub receives flight search events in JSON format. A simulation routine mimics an upstream system that publishes events to the topic.

**Processing:** An Apache Beam pipeline (Python) runs on Dataflow to clean and validate the streaming data before writing it to BigQuery.

**Storage:** BigQuery serves as the Data Warehouse, hosting both the raw events table and the final segmented output.

**Transformation:** Dataform orchestrates SQL models to generate the "High Priority" passenger segments from the raw data.

**IaC:** Terraform manages the entire infrastructure with remote state stored in GCS. The full environment — Pub/Sub, BigQuery, and Cloud Storage — is provisioned from GitHub Actions, guaranteeing a fully replicable setup.

## 🚀 Getting Started

### Prerequisites
- Python 3.9+
- Terraform >= 1.0
- GCP project with billing enabled
- A service account key with the following roles:
  - `roles/pubsub.publisher`
  - `roles/dataflow.worker`
  - `roles/bigquery.dataEditor`
  - `roles/storage.objectAdmin`

### 1. Enable GCP APIs

```bash
gcloud auth application-default login --project data-stream-passengers
gcloud config set project data-stream-passengers

gcloud services enable pubsub.googleapis.com \
                       dataflow.googleapis.com \
                       bigquery.googleapis.com \
                       storage.googleapis.com \
                       compute.googleapis.com
```

### 2. Install Python dependencies

```bash
pip install -r requirements.txt
```

### 3. Provision the infrastructure

Run the following commands to create the GCS bucket for Terraform remote state, initialize the providers, and deploy all resources.

```bash
gcloud storage buckets create gs://terraform-state-data-stream-passengers

cd infra
terraform init
terraform plan
terraform apply -auto-approve

export TOPIC_ID=$(terraform output -raw pubsub_topic_id)
export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)"/../iam/service-account.json"
export PROJECT_ID=$(terraform output -raw project_id)
export BUCKET_URL=$(terraform output -raw staging_bucket_url)
```

This creates:
- Pub/Sub topic `flight-search-events`
- BigQuery dataset `passenger_segmentation`
- Cloud Storage bucket for Dataflow staging

## Running

### 4. Launch the Dataflow pipeline

Use the launch script below, which consumes the Terraform outputs to configure the Dataflow job automatically.

```bash
python src/pipeline.py \
    --runner DataflowRunner \
    --project $PROJECT_ID \
    --region us-central1 \
    --staging_location $BUCKET_URL/staging \
    --temp_location $BUCKET_URL/temp \
    --job_name airline-segmentation \
    --streaming
```

### 5. Simulate events

Run the `gen_data.py` script to generate test events and publish them to Pub/Sub.

```bash
python src/gen_data.py
```

This publishes 5 sample events with a 2-second interval between each one. Every event represents a passenger searching for a flight (e.g. EZE → SCL, Business cabin).

## Real Data Flow

- **Pub/Sub:** Receives the flight search event and holds it in the topic until the pipeline consumes it.
- **Dataflow:** Reads from Pub/Sub and writes the raw JSON payload into the `raw_events` table in BigQuery.
- **Dataform:** Reads `raw_events`, applies SQL transformations (cleaning, calculations, and filters), and produces the final `high_intent_passengers` table.

## Dataform SQL Models (`definitions/`)

Dataform takes the raw data from `raw_events` and builds the `passenger_segmentation` table using SQL directly inside BigQuery.

Other models reference the source table via `${ref("raw_events")}`, which allows Dataform to resolve dependencies automatically.

- **Assertions (Data Quality):** Data is not just moved — it is validated. For example, `user_id` is asserted to never be null before the model is considered successful.
- **Dependency Management:** If the base table changes, Dataform knows exactly which downstream tables need to be rebuilt, preventing stale or inconsistent data.
- **Version Control:** All Dataform code lives in Git alongside the rest of the project, enabling full auditability and team collaboration.

## Dataform Model: `high_intent_passengers.sqlx`

Creates the `high_intent_passengers` table in BigQuery by applying business logic on top of `raw_events`.

### Purpose
- Identify passengers with immediate premium purchase intent (`definitions/sources.sqlx`)
- Build the business-ready segmentation table (`definitions/high_intent_passengers.sqlx`)

## CI/CD — `.github/workflows/deploy.yml`

Triggered on every push to `main`. Steps:

1. Authenticates to GCP using the `GCP_SA_KEY` repository secret.
2. Runs `terraform init && terraform apply` inside `infra/`.
3. Captures `project_id` and `staging_bucket_url` from Terraform outputs.
4. Installs Python dependencies.
5. Launches the Dataflow streaming pipeline using the Terraform outputs as parameters.

### Required GitHub Secret

| Secret | Description |
|---|---|
| `GCP_SA_KEY` | JSON content of the GCP service account key |
