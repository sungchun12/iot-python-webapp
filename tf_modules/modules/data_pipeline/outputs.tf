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


output "dataflow-raw-data-stream-metadata" {
  value = google_dataflow_job.dataflow-raw-data-stream.name
}

output "cbt-function-object-metadata" {
  value = google_storage_bucket_object.big-table-function-code.name
}

output "cbt-function-metadata" {
  value = google_cloudfunctions_function.big-table-function.name
}

output "data-pipeline-bigtable-rowfilter-metadata" {
  value = google_cloudfunctions_function.big-table-function.environment_variables.ROW_FILTER
}
