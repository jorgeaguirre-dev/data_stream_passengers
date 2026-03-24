# Data Stream Passengers

## ✈️ Airline Data Platform
**Real-Time Passenger Segmentation:** Este proyecto implementa una arquitectura Event-Driven en Google Cloud para segmentar pasajeros en tiempo real basada en su comportamiento de búsqueda.

Ingesta en Tiempo Real: Implementé un pipeline de Apache Beam en Dataflow que procesa eventos de búsqueda de vuelos con auto-scaling.

Gobernanza y Calidad: Utilicé Dataform para orquestar las transformaciones dentro de BigQuery, implementando Data Quality Assertions y manteniendo un linaje de datos claro.

CI/CD Robusto: El despliegue es 100% automatizado, manejando secretos de GCP de forma segura y gestionando el estado de Terraform en un backend remoto.

## GitLab
This project is also avalaible in GitLab.com: https://gitlab.com/hi-group623012/HI-data_stream_passengers

## 🏗️ Arquitectura
**Ingesta:** Google Pub/Sub recibe eventos de búsqueda en formato JSON. Una rutina simula un sistema superior que envía los datos al Tópico.

**Procesamiento:** Pipeline de Apache Beam (Python) es ejecutado en Dataflow para limpiar y validar los datos en streaming. Luego almacena en BigQuery.

**Almacenamiento:** BigQuery como Data Warehouse.

**Transformación:** Dataform se usa para orquestar modelos SQL y generar segmentos de "Alta Prioridad".

**IaC:** Terraform gestiona toda la infraestructura, con estado remoto en GCS. Todo el entorno (Pub/Sub, BigQuery, Storage) se despliega con Terraform desde GitHub Actions, garantizando que el entorno sea replicable.

## 🚀 Ejecución

```bash
gcloud auth application-default login --project data-stream-passengers
gcloud config set project data-stream-passengers

# to storage the terraform state in the next bucket
gcloud storage buckets create

gcloud services enable pubsub.googleapis.com \
                       dataflow.googleapis.com \
                       bigquery.googleapis.com \
                       storage.googleapis.com \
                       compute.googleapis.com
```

### Despliega la infraestructura

```bash
terraform init
terraform plan
terraform apply -auto-approve

export TOPIC_ID=$(terraform output -raw pubsub_topic_id)

export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)"/iam/service-account.json"
export PROJECT_ID=$(terraform output -raw project_id)
export BUCKET_URL=$(terraform output -raw staging_bucket_url)
```

### Lanzar Pipeline
Se debe usar el script de lanzamiento que consume los terraform outputs para configurar el Job de Dataflow automáticamente.
```bash
# Crear y arrancar el JOB
python pipeline.py \
    --runner DataflowRunner \
    --project $PROJECT_ID \
    --region us-central1 \
    --staging_location $BUCKET_URL/staging \
    --temp_location $BUCKET_URL/temp \
    --job_name airline-segmentation-v2 \
    --streaming

```
### Simulación de Eventos

Se debe ejecutar un script de python `gen_data.py` para generar datos / eventos de prueba.

## Real Data Flow

- Pub/Sub: Recibe el evento de búsqueda and saves it in the table `vuelos_raw`.
- Dataflow: Lee de Pub/Sub y escribe el JSON crudo en una tabla llamada vuelos_raw en BigQuery.
- Dataform: Toma esa tabla vuelos_raw, aplica el SQL (limpieza, cálculos, filtros) y crea una tabla nueva llamada pasajeros_segmentados.

### Dataform:
Toma los "datos crudos" `vuelos_raw` y crea la tabla `segmentacion_pasajeros` usando SQL al dejar los datos en BigQuery.

- Assertions (Calidad de Datos): No solo mueves datos; aseguras que sean correctos (ej: que el user_id nunca sea nulo).
- Dependency Management: Si cambias la tabla base, Dataform sabe exactamente qué tablas dependientes debe actualizar.
- Version Control: Al igual que en tus proyectos de GitHub, todo el código de Dataform vive en Git, permitiendo auditoría y trabajo en equipo.

## Modelo de Dataform:
Segmentación de Clientes

### Función:
- Identificar pasajeros "Premium con intención inmediata" `definitions/sources.sqlx`
- Crear la tabla de negocio `definitions/premium_leads.sqlx`

