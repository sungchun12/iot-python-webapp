# access store module output values
output "data-store-metadata" {
  value = "${module.storage.data-store-metadata}"
}

output "dataflow-staging-metadata" {
  value = "${module.storage.dataflow-staging-metadata}"
}
