# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------
variable "project" {
}

variable "location" {
}

variable "zone" {
}

variable "service_account_email" {
}

variable "version_label" {
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator
# ---------------------------------------------------------------------------------------------------------------------
variable "cloud_run_name" {
  description = "Name of cloud run resource in console"
  type        = string
  default     = "tf-dash-cloud-run-demo"
}

variable "container_image_name" {
  description = "Docker container image name"
  type        = string
  default     = "dash-cloudrun-demo"
}

variable "container_image" {
  description = "Docker container registry URL"
  type        = string
  default     = "gcr.io/iconic-range-220603/dash-cloudrun-demo"
}

# variables below are passed through the root module from other modules to maintain consistent deployment configs
variable "google_application_credentials_ciphertext" {
}

variable "iot_registry_name" {
}

variable "bigtable_db_name" {
}

variable "bigtable_table_name" {
}

variable "row_filter" {
}
