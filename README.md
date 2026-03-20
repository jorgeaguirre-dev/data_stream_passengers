# Data Stream Passengers


## Flujo

### Dataflow:
Ingiere el JSON de Pub/Sub y lo guarda en la tabla `vuelos_raw`.

### Dataform:
Toma los "datos crudos" `vuelos_raw` y crea la tabla `segmentacion_pasajeros` usando SQL al dejar los datos en BigQuery.

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

