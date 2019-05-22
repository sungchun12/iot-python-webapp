resource "google_pubsub_topic" "data-pipeline-topic" {
  name    = "data-pipeline-topic"
  project = "${var.project}"

  labels = {
    version = "demo"
  }
}
