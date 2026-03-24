# SkyHigh Data Platform — Real-Time Passenger Segmentation

Event-driven pipeline on Google Cloud that ingests flight search events, processes them in real time, and segments passengers by purchase intent.

## Architecture

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

---

## Project Structure

```
.
├── .github/workflows/deploy.yml   # CI/CD pipeline
├── definitions/                   # Dataform SQL models
│   ├── dataform.json              # Dataform project config
│   ├── sources.sqlx               # Declaration of raw_events source table
│   └── high_intent_passengers.sqlx # Segmentation business logic
├── infra/                         # Terraform IaC
│   ├── main.tf
│   ├── vars.tf
│   └── outputs.tf
├── src/
│   ├── pipeline.py                # Apache Beam pipeline
│   └── gen_data.py                # Traffic simulator (Pub/Sub publisher)
└── requirements.in                # Python dependencies
```

---

## Installation

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
gcloud services enable pubsub.googleapis.com \
                       dataflow.googleapis.com \
                       bigquery.googleapis.com \
                       storage.googleapis.com \
                       compute.googleapis.com
```

### 2. Install Python dependencies

```bash
pip install apache-beam[gcp] google-cloud-pubsub
```

### 3. Provision infrastructure

```bash
cd infra
terraform init
terraform apply -auto-approve
```

This creates:
- Pub/Sub topic `flight-search-events`
- BigQuery dataset `passenger_segmentation`
- Cloud Storage bucket for Dataflow staging

---

## Running

### Launch the Dataflow pipeline

```bash
export GOOGLE_APPLICATION_CREDENTIALS="iam/service-account.json"
export PROJECT_ID=$(cd infra && terraform output -raw project_id)
export BUCKET_URL=$(cd infra && terraform output -raw staging_bucket_url)

python src/pipeline.py \
  --runner DataflowRunner \
  --project $PROJECT_ID \
  --region us-central1 \
  --staging_location $BUCKET_URL/staging \
  --temp_location $BUCKET_URL/temp \
  --job_name airline-segmentation \
  --streaming
```

### Simulate traffic (generate test events)

```bash
python src/gen_data.py
```

Publishes 5 sample events to Pub/Sub with a 2-second interval. Each event represents a passenger searching for a flight (e.g. EZE → SCL, Business cabin).

### Cancel a running Dataflow job

```bash
gcloud dataflow jobs cancel JOB_ID --region=us-central1
```

---

## Dataform SQL Models (`definitions/`)

### `sources.sqlx` — Source declaration

Declares `raw_events` as an external source table (not created by Dataform, just referenced).

```js
config {
  type: "declaration",
  database: "data-stream-passengers",
  schema: "passenger_segmentation",
  name: "raw_events"
}
```

No SQL body — it only tells Dataform where the raw data lives so other models can reference it via `${ref("raw_events")}`.

---

### `high_intent_passengers.sqlx` — Segmentation model

Creates the `high_intent_passengers` table in BigQuery by applying business logic on top of `raw_events`.

```sql
config {
  type: "table",
  assertions: {
    nonNull: ["user_id"],
    rowConditions: ["priority_score IN ('High', 'Standard')"]
  }
}

SELECT
  user_id,
  origin,
  destination,
  CASE
    WHEN cabin = 'Business' THEN 'High'
    ELSE 'Standard'
  END AS priority_score,
  CURRENT_TIMESTAMP() as processed_at
FROM ${ref("raw_events")}
WHERE TIMESTAMP_SECONDS(CAST(timestamp AS INT64)) >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
```

- Filters events from the last 24 hours only.
- Assigns `High` priority to Business cabin passengers, `Standard` to the rest.
- Assertions enforce data quality: `user_id` is never null and `priority_score` is always a valid value.

---

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

---

## Terraform Outputs (`infra/outputs.tf`)

| Output | Description |
|---|---|
| `project_id` | GCP project ID |
| `pubsub_topic_id` | Full Pub/Sub topic ID for the publisher |
| `staging_bucket_url` | GCS URL used for Dataflow staging and temp files |
| `bigquery_dataset_id` | BigQuery dataset ID where raw events land |
