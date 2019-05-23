# access store module output values
output "data-store-metadata" {
  value = "${module.storage.data-store-metadata}"
}

output "dataflow-staging-metadata" {
  value = "${module.storage.dataflow-staging-metadata}"
}

output "data-pipeline-topic-metadata" {
  value = "${module.data_pipeline.data-pipeline-topic-metadata}"
}

output "data-pipeline-dataset-metadata" {
  value = "${module.data_pipeline.data-pipeline-dataset-metadata}"
}

output "data-pipeline-table-metadata" {
  value = "${module.data_pipeline.data-pipeline-table-metadata}"
}

output "data-pipeline-bigtable-metadata" {
  value = "${module.data_pipeline.data-pipeline-bigtable-metadata}"
}

output "data-pipeline-bigtable-table-metadata" {
  value = "${module.data_pipeline.data-pipeline-bigtable-table-metadata}"
}
