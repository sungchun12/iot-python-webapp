output "data-pipeline-topic-metadata" {
  value = "${google_pubsub_topic.data-pipeline-topic.name}"
}
