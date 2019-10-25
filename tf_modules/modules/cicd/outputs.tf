output "cloud-build-metadata" {
  value = google_cloudbuild_trigger.cloudbuild-trigger.filename
}
