##############################
#project-wide variables
variable "project" {
  default = "iconic-range-220603"
}

variable "location" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-b"
}

variable "version_label" {
  default = "demo"
}
##############################
# storage variables
variable "raw_bucket_name" {
  default = "iot-raw-data-sung"
}

variable "staging_bucket_name" {
  default = "iot-dataflow-stage-sung"
}

variable "storage_class" {
  default = "REGIONAL"
}

variable "versioning_enabled" {
  default = true
}


##############################
