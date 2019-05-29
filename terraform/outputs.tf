# access store module output values
output "data-store-metadata" {
  value = module.storage.data-store-metadata
}

output "dataflow-staging-metadata" {
  value = module.storage.dataflow-staging-metadata
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

