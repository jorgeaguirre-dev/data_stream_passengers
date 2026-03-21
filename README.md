# Data Stream Passengers

## GitLab
This project is also avalaible in GitLab.com: https://gitlab.com/hi-group623012/HI-data_stream_passengers

## Flow
El flujo real:

- Pub/Sub: Recibe el evento de búsqueda.
- Dataflow: Lee de Pub/Sub y escribe el JSON crudo en una tabla llamada vuelos_raw en BigQuery.
- Dataform: Toma esa tabla vuelos_raw, aplica el SQL (limpieza, cálculos, filtros) y crea una tabla nueva llamada pasajeros_segmentados.

### Dataflow:
It ingests the Pub/Sub JSON and saves it in the table `vuelos_raw`.

### Dataform:
Toma los "datos crudos" `vuelos_raw` y crea la tabla `segmentacion_pasajeros` usando SQL al dejar los datos en BigQuery.
It takes the "raw data" `flights_raw` and creates the `passenger_segmentation` table using SQL by leaving the data in BigQuery.

- Assertions (Calidad de Datos): No solo mueves datos; aseguras que sean correctos (ej: que el user_id nunca sea nulo).
- Dependency Management: Si cambias la tabla base, Dataform sabe exactamente qué tablas dependientes debe actualizar.
- Version Control: Al igual que en tus proyectos de GitHub, todo el código de Dataform vive en Git, permitiendo auditoría y trabajo en equipo.

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

