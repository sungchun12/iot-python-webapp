resource "google_cloudiot_registry" "iot-registry" {
  name   = "iot-registry"
  region = var.location

  event_notification_config = {
    pubsub_topic_name = google_pubsub_topic.data-pipeline-topic.id
  }

  state_notification_config = {
    pubsub_topic_name = google_pubsub_topic.iot-device-status.id
  }

  http_config = {
    http_enabled_state = "HTTP_DISABLED"
  }

  mqtt_config = {
    mqtt_enabled_state = "MQTT_ENABLED"
  }

  # credentials {
  #   public_key_certificate = {
  #     format      = "X509_CERTIFICATE_PEM"
  #     certificate = "rsa_cert.pem"
  #   }
  # }
}

resource "google_pubsub_topic" "data-pipeline-topic" {
  name    = "data-pipeline-topic"
  project = var.project

  labels = {
    version = "demo"
  }
}

resource "google_pubsub_topic" "iot-device-status" {
  name    = "iot-device-status"
  project = var.project

  labels = {
    version = "demo"
  }
}

resource "google_bigquery_dataset" "iot_dataset" {
  dataset_id  = "iot_dataset"
  description = "iot data warehouse"
  project     = var.project
  location    = "US"

  labels = {
    version = "demo"
  }
}

resource "google_bigquery_table" "iot_raw_data" {
  dataset_id  = google_bigquery_dataset.iot_dataset.dataset_id
  table_id    = "iot_raw_data"
  description = "table that accumulates all raw iot streaming data"

  time_partitioning {
    type = "DAY"
  }

  labels = {
    version = "demo"
  }
}

resource "google_bigtable_instance" "iot-stream-database" {
  name          = "iot-stream-database"
  instance_type = "DEVELOPMENT" #changed to PRODUCTION when ready

  cluster {
    cluster_id = "iot-stream-database-cluster"
    zone       = var.zone

    # num_nodes    = 0
    storage_type = "SSD"
  }
}

resource "google_bigtable_table" "iot-stream-table" {
  name          = "iot-stream-table"
  instance_name = google_bigtable_instance.iot-stream-database.name
  split_keys    = ["a", "b", "c"]
}

