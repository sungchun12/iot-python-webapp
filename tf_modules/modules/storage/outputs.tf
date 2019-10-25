output "data-store-metadata" {
  value = google_storage_bucket.data-store.url
}

output "dataflow-staging-metadata" {
  value = google_storage_bucket.dataflow-staging.url
}

output "source-code-bucket-metadata" {
  value = google_storage_bucket.source-code-bucket.url
}
