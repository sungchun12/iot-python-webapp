##############################
#project-wide variables
variable "project" {
  default     = "iconic-range-220603"
  description = "name of your GCP project"
}

variable "location" {
  default     = "us-central1"
  description = "location of various GCP services"
}

variable "zone" {
  default     = "us-central1-b"
  description = "a granular location typically for VMs"
}

variable "version_label" {
  default     = "demo"
  description = "helpful label to version GCP resources per deployment"
}
##############################
# storage variables
variable "raw_bucket_name" {
  default = "iot-raw-data-sung"
  description = "bucket name where all the raw streaming data is stored"
}

variable "staging_bucket_name" {
  default = "iot-dataflow-stage-sung"
  description = "bucket name where dataflow stages data during transformations"
}

variable "storage_class" {
  default = "REGIONAL"
  description = "type of storage depending on frequency of data use"
}

variable "versioning_enabled" {
  default = true
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

##############################
