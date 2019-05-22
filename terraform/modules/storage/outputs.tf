output "data-store-metadata" {
  value = "${google_storage_bucket.data-store.name}"
}

output "dataflow-staging-metadata" {
  value = "${google_storage_bucket.dataflow-staging.name}"
}
