# access store module output values
output "cloud-run-metadata" {
  value = module.app_hosting.cloud-run-metadata
}
output "data-store-metadata" {
  value = module.storage.data-store-metadata
}

output "dataflow-staging-metadata" {
  value = module.storage.dataflow-staging-metadata
}

output "source-code-bucket-metadata" {
  value = module.storage.source-code-bucket-metadata
}

output "iot-registry-metadata" {
  value = module.data_pipeline.iot-registry-metadata
}

output "iot-device-status-metadata" {
  value = module.data_pipeline.iot-device-status-metadata
}

output "data-pipeline-topic-metadata" {
  value = module.data_pipeline.data-pipeline-topic-metadata
}

output "data-pipeline-dataset-metadata" {
  value = module.data_pipeline.data-pipeline-dataset-metadata
}

output "data-pipeline-table-metadata" {
  value = module.data_pipeline.data-pipeline-table-metadata
}

output "data-pipeline-bigtable-metadata" {
  value = module.data_pipeline.data-pipeline-bigtable-metadata
}

output "data-pipeline-bigtable-table-metadata" {
  value = module.data_pipeline.data-pipeline-bigtable-table-metadata
}

output "dataflow-raw-data-stream-metadata" {
  value = module.data_pipeline.dataflow-raw-data-stream-metadata
}

output "cbt-function-object-metadata" {
  value = module.data_pipeline.cbt-function-object-metadata
}

output "cbt-function-metadata" {
  value = module.data_pipeline.cbt-function-metadata
}

output "iot-device-1-metadata" {
  value = module.iot_compute.iot-device-1-metadata
}

output "iot-device-2-metadata" {
  value = module.iot_compute.iot-device-2-metadata
}

output "iot-device-3-metadata" {
  value = module.iot_compute.iot-device-3-metadata
}

output "vpc-network-metadata" {
  value = module.iot_compute.vpc-network-metadata
}

output "ssh-access-firewall-metadata" {
  value = module.iot_compute.ssh-access-firewall-metadata
}

output "kms-keyring-metadata" {
  value = module.secrets_manager.kms-keyring-metadata
}

output "kms-crypto-key-metadata" {
  value = module.secrets_manager.kms-crypto-key-metadata
}
