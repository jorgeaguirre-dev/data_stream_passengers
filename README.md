# Data Stream Passengers


## Flow

### Dataflow:
It ingests the Pub/Sub JSON and saves it in the table `vuelos_raw`.

### Dataform:
Toma los "datos crudos" `vuelos_raw` y crea la tabla `segmentacion_pasajeros` usando SQL al dejar los datos en BigQuery.
It takes the "raw data" `flights_raw` and creates the `passenger_segmentation` table using SQL by leaving the data in BigQuery.

## Ejecución

```bash
gcloud auth application-default login --project data-stream-passengers
gcloud config set project data-stream-passengers

gcloud services enable pubsub.googleapis.com \
                       dataflow.googleapis.com \
                       bigquery.googleapis.com \
                       storage.googleapis.com \
                       compute.googleapis.com

terraform init
terraform plan
terraform apply -auto-approve

```

