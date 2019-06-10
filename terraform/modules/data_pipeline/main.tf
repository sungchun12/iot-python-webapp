resource "google_cloudiot_registry" "iot-registry" {
  name   = var.iot_registry_name
  region = var.location

  event_notification_config = {
    pubsub_topic_name = google_pubsub_topic.data-pipeline-topic.id
  }

  state_notification_config = {
    pubsub_topic_name = google_pubsub_topic.iot-device-status.id
  }

  http_config = {
    http_enabled_state = var.http_config_state
  }

  mqtt_config = {
    mqtt_enabled_state = var.mqtt_config_state
  }

  # credentials {
  #   public_key_certificate = {
  #     format      = "X509_CERTIFICATE_PEM"
  #     certificate = "rsa_cert.pem"
  #   }
  # }
}

resource "google_pubsub_topic" "data-pipeline-topic" {
  name    = var.data_pipeline_topic_name
  project = var.project

  labels = {
    version = var.version_label
  }
}

resource "google_pubsub_topic" "iot-device-status" {
  name    = var.device_status_topic_name
  project = var.project

  labels = {
    version = var.version_label
  }
}

resource "google_bigquery_dataset" "iot_dataset" {
  dataset_id  = var.dataset_name
  description = var.dataset_desc
  project     = var.project
  location    = "US"

  labels = {
    version = var.version_label
  }
}

resource "google_bigquery_table" "iot_raw_data" {
  dataset_id  = google_bigquery_dataset.iot_dataset.dataset_id
  table_id    = var.table_name
  description = var.table_desc

  time_partitioning {
    type = "DAY"
  }

  labels = {
    version = var.version_label
  }

  schema = "${file("${path.module}/schema.json")}"
}

resource "google_bigtable_instance" "iot-stream-database" {
  name          = var.bigtable_db_name
  instance_type = var.bigtable_db_instance_type #change to PRODUCTION when ready

  cluster {
    cluster_id = var.bigtable_db_cluster_name
    zone       = var.zone

    # num_nodes    = 0
    storage_type = var.bigtable_db_storage_type
  }
}

resource "google_bigtable_table" "iot-stream-table" {
  name          = var.bigtable_table_name
  instance_name = google_bigtable_instance.iot-stream-database.name
  split_keys    = var.bigtable_table_split_keys
}

resource "google_dataflow_job" "dataflow-raw-data-stream" {
  name              = "dataflow-test"
  template_gcs_path = "gs://dataflow-templates/latest/PubSub_to_BigQuery" # use the java template
  temp_gcs_location = "gs://iot-dataflow-stage-sung/tmp/"
  zone              = var.zone
  on_delete         = "cancel" #finish ingesting remaining data
  parameters = {
    inputTopic      = "projects/iconic-range-220603/topics/data-pipeline-topic" # google_pubsub_topic.data-pipeline-topic.id
    outputTableSpec = "iconic-rage-220603:iot_dataset.iot_raw_data"
  }
}
