variable "project" {
}

variable "location" {
}

variable "version_label" {
}

variable "raw_bucket_name" {
  default     = "iot-raw-data-sung"
  description = "bucket name where all the raw streaming data is stored"
}

variable "staging_bucket_name" {
  default     = "iot-dataflow-stage-sung"
  description = "bucket name where dataflow stages data during transformations"
}

variable "storage_class" {
  default     = "REGIONAL"
  description = "type of storage depending on frequency of data use"
}

variable "versioning_enabled" {
  default     = true
  description = "you typically want to enable bucket versioning"
}

variable "main_page_suffix" {
  default     = "index.html"
  description = "behaves as bucket's directory index"
}

variable "not_found_page" {
  default     = "404.html"
  description = "custom object to return when a requested resource is not found"
}
