output "iot-registry-metadata" {
  value = google_cloudiot_registry.iot-registry.name
}

output "data-pipeline-topic-metadata" {
  value = google_pubsub_topic.data-pipeline-topic.name
}

output "iot-device-status-metadata" {
  value = google_pubsub_topic.iot-device-status.name
}

output "data-pipeline-dataset-metadata" {
  value = google_bigquery_dataset.iot_dataset.dataset_id
}

output "data-pipeline-table-metadata" {
  value = google_bigquery_table.iot_raw_data.table_id
}

output "data-pipeline-bigtable-metadata" {
  value = google_bigtable_instance.iot-stream-database.name
}

output "data-pipeline-bigtable-table-metadata" {
  value = google_bigtable_table.iot-stream-table.name
}

