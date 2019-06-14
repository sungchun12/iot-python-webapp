# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------
variable "project" {
}

variable "location" {
}

variable "version_label" {
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------
variable "raw_bucket_name" {
  description = "bucket name where all the raw streaming data is stored"
  type        = string
  default     = "iot-raw-data-sung"

}

variable "staging_bucket_name" {
  description = "bucket name where dataflow stages data during transformations"
  type        = string
  default     = "iot-dataflow-stage-sung"

}

variable "storage_class" {
  description = "type of storage depending on frequency of data use"
  type        = string
  default     = "REGIONAL"

}

variable "versioning_enabled" {
  description = "you typically want to enable bucket versioning"
  type        = bool
  default     = true

}

variable "main_page_suffix" {
  description = "behaves as bucket's directory index"
  type        = string
  default     = "index.html"

}

variable "not_found_page" {
  description = "custom object to return when a requested resource is not found"
  type        = string
  default     = "404.html"

}

