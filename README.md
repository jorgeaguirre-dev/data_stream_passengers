# Data Stream Passengers

✈️ SkyHigh Data Platform: Real-Time Passenger Segmentation
Este proyecto implementa una arquitectura Event-Driven en Google Cloud para segmentar pasajeros en tiempo real basada en su comportamiento de búsqueda.

🏗️ Arquitectura
Ingesta: Google Pub/Sub recibe eventos de búsqueda en formato JSON.

Procesamiento: Pipeline de Apache Beam (Python) ejecutado en Dataflow que limpia y valida los datos en streaming.

Almacenamiento: BigQuery como Data Warehouse.

Transformación: Dataform para orquestar modelos SQL y generar segmentos de "Alta Prioridad".

IaC: Infraestructura completa gestionada con Terraform.

🚀 Cómo ejecutar
Infraestructura:

Bash
terraform init && terraform apply
Lanzar Pipeline:
Usa el script de lanzamiento que consume los terraform outputs para configurar el Job de Dataflow automáticamente.

Simulación:
Ejecuta python scripts/simulate_traffic.py para generar eventos de prueba.

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


# Extraemos los valores reales que creó Terraform
export PROJECT_ID=$(terraform output -raw project_id)
export TOPIC_ID=$(terraform output -raw pubsub_topic_id)
export BUCKET_URL=$(terraform output -raw staging_bucket_url)

python pipeline.py \
    --runner DataflowRunner \
    --project $PROJECT_ID \
    --region us-central1 \
    --staging_location $BUCKET_URL/staging \
    --temp_location $BUCKET_URL/temp \
    --template_location $BUCKET_URL/templates/airline-pipeline \
    --job_name airline-segmentation-v1 \
    --streaming


# Asegúrar que las variables tengan los valores de los outputs del nuevo TF
export PROJECT_ID=$(terraform output -raw project_id)
export BUCKET_URL=$(terraform output -raw staging_bucket_url)

python pipeline.py \
    --runner DataflowRunner \
    --project $PROJECT_ID \
    --region us-central1 \
    --staging_location $BUCKET_URL/staging \
    --temp_location $BUCKET_URL/temp \
    --job_name airline-segmentation-v2 \
    --streaming



python pipeline.py \
    --runner DataflowRunner \
    --project data-stream-passengers \
    --region us-central1 \
    --temp_location gs://airline-dataflow-staging/temp \
    --job_name flight-segmentation-v2


# Para cancelar inmediatamente
gcloud dataflow jobs cancel ID_DEL_JOB --region=us-central1
```
## Modelo de Dataform: Segmentación de Clientes
Identificar pasajeros "Premium con intención inmediata"

```sql
config {
  type: "declaration",
  database: "data-stream-passengers",
  schema: "passenger_segmentation",
  name: "raw_events",
}
```

Crear la tabla de negocio (definitions/premium_leads.sqlx)
```sql
config {
  type: "table",
  assertions: {
    rowConditions: ["search_count > 0"]
  }
}

SELECT
  user_id,
  count(*) as search_count,
  max(timestamp) as last_search,
  -- Lógica: Si buscó Business o más de 3 veces, es High Priority
  CASE
    WHEN logical_or(cabin = 'Business') OR count(*) > 3 THEN 'High Priority'
    ELSE 'Standard'
  END as segment
FROM ${ref("raw_events")}
GROUP BY 1
```